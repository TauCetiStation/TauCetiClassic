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
	var/datum/weakref/displayed_weakref
	var/frame_type = /obj/structure/picture_frame/wooden

/obj/item/weapon/picture_frame/Destroy()
	. = ..()
	if(displayed_weakref)
		var/obj/item/I = displayed_weakref?.resolve()
		QDEL_NULL(I)
		displayed_weakref = null

/obj/item/weapon/picture_frame/wooden
	name = "wooden picture frame"
	frame_type = /obj/structure/picture_frame/wooden

/obj/item/weapon/picture_frame/metal
	name = "metal picture frame"
	icon_state = "metal_frame"
	frame_type = /obj/structure/picture_frame/metal

/obj/item/weapon/picture_frame/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/photo) || istype(I, /obj/item/canvas))
		if(displayed_weakref)
			to_chat(user, "<span class='notice'>[C_CASE(src, NOMINATIVE_CASE)] не пуста.</span>")
			return

		if(istype(I, /obj/item/canvas))
			var/obj/item/canvas/target_canvas = I
			if(!target_canvas.finalized)
				to_chat(user, "<span class='notice'>[C_CASE(target_canvas, NOMINATIVE_CASE)] не завершён.</span>")
				return

		if(!user.drop_from_inventory(I, src))
			return ..()

		displayed_weakref = WEAKREF(I)
		update_icon()
		return

	if(iswrenching(I))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		if(frame_type == /obj/structure/picture_frame/wooden)
			new /obj/item/stack/sheet/wood(src.loc)
		else
			new /obj/item/stack/sheet/metal(src.loc)
		for(var/obj/item in contents)
			item.forceMove(get_turf(src))
		qdel(src)
		return

	return ..()

/obj/item/weapon/picture_frame/attack_hand(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		var/obj/item/I = displayed_weakref?.resolve()
		if(!I)
			return ..()
		if(!user.put_in_hands(I))
			return ..()

		to_chat(user, "<span class='notice'>Вы аккуратно достаёте [CASE(src, ACCUSATIVE_CASE)] из [CASE(src, GENITIVE_CASE)].</span>")
		displayed_weakref = null
		update_icon()
		return
	..()

/obj/item/weapon/picture_frame/attack_self(mob/user)
	user.examinate(src)

/obj/item/weapon/picture_frame/examine(mob/user)
	var/obj/item/canvas/target_canvas = displayed_weakref?.resolve()
	if(target_canvas && (user.r_hand == src || user.l_hand == src))
		target_canvas.show(user)
	else
		..()

/obj/item/weapon/picture_frame/update_icon()
	cut_overlays()
	icon_state = initial(icon_state)
	if(!displayed_weakref)
		return

	var/obj/item/I = displayed_weakref?.resolve()
	var/obj/item/canvas/target_canvas = I
	if(istype(I, /obj/item/canvas))
		icon_state = "[initial(icon_state)]_[target_canvas.width]x[target_canvas.height]"

	add_overlay(target_canvas.get_framed_picture())

/obj/item/weapon/picture_frame/proc/try_build(turf/on_wall)
	if (!Adjacent(on_wall))
		return
	var/ndir = get_dir(on_wall, usr)
	if(!(ndir in cardinal))
		return
	var/turf/T = get_turf(usr)
	var/area/A = get_area(T)
	if(!isfloorturf(T))
		to_chat(usr, "<span class='warning'>Сюда нельзя повесить [CASE(src, ACCUSATIVE_CASE)].</span>")
		return

	if(A.always_unpowered)
		to_chat(usr, "<span class='warning'>Сюда нельзя повесить [CASE(src, ACCUSATIVE_CASE)].</span>")
		return

	if(gotwallitem(T, ndir))
		to_chat(usr, "<span class='warning'>Сюда нельзя повесить [CASE(src, ACCUSATIVE_CASE)].</span>")
		return


	var/obj/structure/picture_frame/target_frame = new frame_type(T, reverse_dir[ndir], 1)
	if(displayed_weakref)
		var/obj/item/I = displayed_weakref?.resolve()
		displayed_weakref = null
		I.forceMove(target_frame)
		target_frame.framed_weakref = WEAKREF(I)

	target_frame.set_dir(ndir)
	target_frame.update_icon()
	target_frame.update_name()
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

	var/datum/weakref/framed_weakref
	var/frame_type = /obj/item/weapon/picture_frame/wooden

/obj/structure/picture_frame/atom_init(mapload, ndir, building = 0)
	. = ..()
	if(building)
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 : -28)
		pixel_y = (ndir & 3)? (ndir == 1 ? 28 : -30) : 0
	update_icon()

/obj/structure/picture_frame/Destroy()
	. = ..()
	if(framed_weakref)
		var/obj/item/I = framed_weakref?.resolve()
		QDEL_NULL(I)
		framed_weakref = null

/obj/structure/picture_frame/wooden
	name = "wooden picture frame"
	frame_type = /obj/item/weapon/picture_frame/wooden

/obj/structure/picture_frame/metal
	name = "metal picture frame"
	icon_state = "metal_frame"
	frame_type = /obj/item/weapon/picture_frame/metal
	max_integrity = 100

/obj/structure/picture_frame/examine(mob/user)
	var/obj/item/canvas/target_canvas = framed_weakref?.resolve()
	if(target_canvas && in_range(src, user))
		target_canvas.show(user)
	else
		..()

/obj/structure/picture_frame/attackby(obj/item/weapon/O, mob/user, params)
	if(istype(O, /obj/item/weapon/photo) || istype(O, /obj/item/canvas))
		if(framed_weakref)
			to_chat(user, "<span class='notice'>[C_CASE(src, NOMINATIVE_CASE)] не пуста.</span>")
			return

		if(istype(O, /obj/item/canvas))
			var/obj/item/canvas/target_canvas = O
			if(!target_canvas.finalized)
				to_chat(user, "<span class='notice'>[C_CASE(target_canvas, NOMINATIVE_CASE)] не завершён.</span>")
				return

		if(!user.drop_from_inventory(O, src))
			return

		framed_weakref = WEAKREF(O)
		update_icon()
		update_name()
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
	if(framed_weakref && (flags & NODECONSTRUCT || !disassembled))
		var/obj/item/I = framed_weakref?.resolve()
		I.forceMove(T)
		framed_weakref = null
	if(flags & NODECONSTRUCT)
		return ..()
	if(disassembled)
		var/obj/item/weapon/picture_frame/target_frame = new frame_type(T)
		if(framed_weakref)
			var/obj/item/I = framed_weakref?.resolve()
			target_frame.displayed_weakref = WEAKREF(I)
			I.forceMove(target_frame)
			framed_weakref = null
		target_frame.update_icon()
		if(user && !issilicon(user))
			user.put_in_hands(target_frame)
	else
		if(frame_type == /obj/item/weapon/picture_frame/wooden)
			new /obj/item/stack/sheet/wood(T)
		if(frame_type == /obj/item/weapon/picture_frame/metal)
			new /obj/item/stack/sheet/metal(T)
	..()

/obj/structure/picture_frame/attack_hand(mob/user)
	if(framed_weakref)
		user.examinate(src)

/obj/structure/picture_frame/update_icon()
	cut_overlays()
	icon_state = initial(icon_state)
	if(!framed_weakref)
		return

	var/obj/item/I = framed_weakref?.resolve()
	var/obj/item/canvas/target_canvas = I
	if(istype(I, /obj/item/canvas))
		icon_state = "[initial(icon_state)]_[target_canvas.width]x[target_canvas.height]"

	add_overlay(target_canvas.get_framed_picture())

/obj/structure/picture_frame/proc/update_name()
	if(framed_weakref)
		var/obj/item/I = framed_weakref?.resolve()
		if(istype(I, /obj/item/canvas))
			var/obj/item/canvas/target_canvas = I
			name = "painting - [target_canvas.painting_name]"
		else
			name = "photo - [I.name]"
	else
		name = initial(name)
