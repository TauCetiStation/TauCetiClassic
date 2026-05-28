/****************
* picture frame *
****************/

/obj/item/weapon/picture_frame
	name = "picture frame"
	cases = list("фоторамка", "фоторамки", "фоторамке", "фоторамку", "фоторамкой", "фоторамке")
	desc = "Рамка для картин или фотографий."
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "wooden_frame"
	w_class = SIZE_TINY
	var/obj/item/displayed
	var/frame_type = /obj/structure/picture_frame/wooden

/obj/item/weapon/picture_frame/Destroy()
	. = ..()
	QDEL_NULL(displayed)

/obj/item/weapon/picture_frame/wooden
	name = "wooden picture frame"
	frame_type = /obj/structure/picture_frame/wooden

/obj/item/weapon/picture_frame/metal
	name = "metal picture frame"
	icon_state = "metal_frame"
	frame_type = /obj/structure/picture_frame/metal

/obj/item/weapon/picture_frame/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/photo) || istype(I, /obj/item/canvas))
		if(!displayed)
			if(istype(I, /obj/item/canvas))
				var/obj/item/canvas/Canvas = I
				if(!Canvas.finalized)
					return
			user.unEquip(I)
			I.forceMove(src)
			displayed = I
			update_icon()
		else
			to_chat(user, "<span class='notice'>\The [src] already contains a picture.</span>")
		return
	if(iswrenching(I))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		if(frame_type == /obj/structure/picture_frame/wooden)
			new /obj/item/stack/sheet/wood(src.loc)
		else
			new /obj/item/stack/sheet/metal(src.loc)
		for(var/obj/C in contents)
			C.forceMove(get_turf(src))
		qdel(src)
		return
	return ..()

/obj/item/weapon/picture_frame/attack_hand(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		if(displayed)
			var/obj/item/I = displayed
			user.put_in_hands(I)
			to_chat(user, "<span class='notice'>You carefully remove the picture from \the [src].</span>")
			displayed = null
			update_icon()
			return
	..()

/obj/item/weapon/picture_frame/attack_self(mob/user)
	user.examinate(src)

/obj/item/weapon/picture_frame/examine(mob/user)
	if((user.r_hand == src || user.l_hand == src) && displayed)
		if(istype(displayed, /obj/item/canvas))
			var/obj/item/canvas/Canvas = displayed
			Canvas.ui_interact(user)
		else
			var/obj/item/weapon/photo/Photo = displayed
			Photo.show(user)
	else
		..()

/obj/item/weapon/picture_frame/update_icon()
	cut_overlays()
	icon_state = initial(icon_state)
	if(displayed)
		if(istype(displayed, /obj/item/canvas))
			var/obj/item/canvas/Canvas = displayed
			icon_state = "[initial(icon_state)]_[Canvas.width]x[Canvas.height]"
			var/mutable_appearance/MA = mutable_appearance(Canvas.generated_icon)
			MA.pixel_x = Canvas.framed_offset_x
			MA.pixel_y = Canvas.framed_offset_y
			add_overlay(MA)
		else
			add_overlay(image(displayed.icon, "photo"))

/obj/item/weapon/picture_frame/proc/try_build(turf/on_wall)
	if (!Adjacent(on_wall))
		return
	var/ndir = get_dir(on_wall, usr)
	if(!(ndir in cardinal))
		return
	var/turf/T = get_turf(usr)
	var/area/A = get_area(T)
	if(!isfloorturf(T))
		to_chat(usr, "<span class='warning'>You cannot place [src] on this spot!</span>")
		return

	if(A.always_unpowered)
		to_chat(usr, "<span class='warning'>You cannot place [src] in this area!</span>")
		return

	if(gotwallitem(T, ndir))
		to_chat(usr, "<span class='warning'>There's already an item on this wall!</span>")
		return


	var/obj/structure/picture_frame/PF = new frame_type(T, reverse_dir[ndir], 1)
	if(displayed)
		var/obj/item/I = displayed
		displayed = null
		I.forceMove(PF)
		PF.framed = I
	PF.set_dir(ndir)
	PF.update_icon()
	PF.update_name()
	qdel(src)

/obj/structure/picture_frame
	name = "picture frame"
	cases = list("фоторамка", "фоторамки", "фоторамке", "фоторамку", "фоторамкой", "фоторамке")
	desc = "Рамка для картин или фотографий."
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "wooden_frame"
	anchored = TRUE

	max_integrity = 50
	resistance_flags = CAN_BE_HIT

	var/obj/item/framed
	var/frame_type = /obj/item/weapon/picture_frame/wooden
	var/screwed = FALSE

/obj/structure/picture_frame/atom_init(mapload, ndir, building = 0)
	. = ..()
	if(building)
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 : -28)
		pixel_y = (ndir & 3)? (ndir == 1 ? 28 : -30) : 0
	update_icon()

/obj/structure/picture_frame/Destroy()
	. = ..()
	QDEL_NULL(framed)

/obj/structure/picture_frame/wooden
	name = "wooden picture frame"
	frame_type = /obj/item/weapon/picture_frame/wooden

/obj/structure/picture_frame/metal
	name = "metal picture frame"
	icon_state = "metal_frame"
	frame_type = /obj/item/weapon/picture_frame/metal
	max_integrity = 100

/obj/structure/picture_frame/examine(mob/user)
	if(in_range(src, user) && framed)
		if(istype(framed, /obj/item/canvas))
			var/obj/item/canvas/Canvas = framed
			Canvas.ui_interact(user)
		else
			var/obj/item/weapon/photo/Photo = framed
			Photo.show(user)
	else
		..()

/obj/structure/picture_frame/attackby(obj/item/weapon/O, mob/user, params)
	if(istype(O, /obj/item/weapon/photo) || istype(O, /obj/item/canvas))
		if(!framed)
			if(istype(O, /obj/item/canvas))
				var/obj/item/canvas/Canvas = O
				if(!Canvas.finalized)
					return
			user.unEquip(O)
			O.forceMove(src)
			framed = O
			update_icon()
			update_name()
		else
			to_chat(user, "<span class='notice'>\The [src] already contains a picture.</span>")
		return
	if(iswrenching(O))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		deconstruct(TRUE, user)
		return
	else
		..()

// TODO move all handling into picture_frame item
/obj/structure/picture_frame/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/picture_frame/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	if(damage_amount < 5)
		return
	switch(damage_type)
		if(BRUTE)
			return 0.75 * damage_amount
		if(BURN)
			return damage_amount

/obj/structure/picture_frame/deconstruct(disassembled, mob/living/user)
	var/turf/T = get_turf(user || loc)
	if(framed && (flags & NODECONSTRUCT || !disassembled))
		framed.forceMove(T)
		framed = null
	if(flags & NODECONSTRUCT)
		return ..()
	if(disassembled)
		var/obj/item/weapon/picture_frame/F = new frame_type(T)
		if(framed)
			F.displayed = framed
			framed.forceMove(F)
			framed = null
		F.update_icon()
		if(user && !issilicon(user))
			user.put_in_hands(F)
	else
		if(frame_type == /obj/item/weapon/picture_frame/wooden)
			new /obj/item/stack/sheet/wood(T)
		if(frame_type == /obj/item/weapon/picture_frame/metal)
			new /obj/item/stack/sheet/metal(T)
	..()

/obj/structure/picture_frame/attack_hand(mob/user)
	if(framed)
		user.examinate(src)

/obj/structure/picture_frame/update_icon()
	cut_overlays()
	icon_state = initial(icon_state)
	if(framed)
		var/mutable_appearance/MA
		if(istype(framed, /obj/item/canvas))
			var/obj/item/canvas/Canvas = framed
			icon_state = "[initial(icon_state)]_[Canvas.width]x[Canvas.height]"
			MA = mutable_appearance(Canvas.generated_icon)
			MA.pixel_x = Canvas.framed_offset_x
			MA.pixel_y = Canvas.framed_offset_y
		else
			MA = mutable_appearance(framed.icon, "photo")
		add_overlay(MA)

/obj/structure/picture_frame/proc/update_name()
	if(framed)
		if(istype(framed, /obj/item/canvas))
			var/obj/item/canvas/Canvas = framed
			name = "painting - [Canvas.painting_name]"
		else
			name = "photo - [framed.name]"
	else
		name = initial(name)
