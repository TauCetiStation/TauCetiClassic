/****************
* picture frame *
****************/

/obj/item/weapon/picture_frame
	name = "picture frame"
	desc = "The perfect showcase for your favorite memories."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "wooden_frame_item"
	w_class = SIZE_TINY
	var/obj/item/weapon/photo/displayed
	var/frame_type = /obj/structure/picture_frame/wooden
	var/frame_glass = FALSE

/obj/item/weapon/picture_frame/Destroy()
	. = ..()
	QDEL_NULL(displayed)

/obj/item/weapon/picture_frame/wooden
	name = "wooden picture frame"
	frame_type = /obj/structure/picture_frame/wooden

/obj/item/weapon/picture_frame/metal
	name = "metal picture frame"
	desc = "The perfect shiny showcase for your favorite memories."
	icon_state = "metal_frame_item"
	frame_type = /obj/structure/picture_frame/metal

/obj/item/weapon/picture_frame/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/photo))
		if(!displayed)
			var/obj/item/weapon/photo/Photo = I
			user.unEquip(Photo)
			Photo.forceMove(src)
			displayed = Photo
			update_icon()
		else
			to_chat(user, "<span class='notice'>\The [src] already contains a photo.</span>")
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
	if(istype(I, /obj/item/stack/sheet/glass))
		if(!frame_glass)
			frame_glass = TRUE
			playsound(src, 'sound/effects/glassknock.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "<span class='notice'>You insert the glass into \the [src].</span>")
			var/obj/item/stack/sheet/glass/G = I
			G.use(1)
			update_icon()
		else
			to_chat(user, "<span class='notice'>There is already a glass in \the [src].</span>")
		return
	if(isscrewing(I))
		if(frame_glass)
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			frame_glass = FALSE
			to_chat(user,"<span class='notice'>You screw the glass out of \the [src].</span>")
			new /obj/item/stack/sheet/glass(get_turf(src))
			update_icon()
		else
			to_chat(user, "<span class='notice'>There is no glass to screw out in \the [src].</span>")
		return
	return ..()

/obj/item/weapon/picture_frame/attack_hand(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		if(displayed)
			var/obj/item/I = displayed
			user.put_in_hands(I)
			to_chat(user, "<span class='notice'>You carefully remove the photo from \the [src].</span>")
			displayed = null
			update_icon()
			return
	..()

/obj/item/weapon/picture_frame/attack_self(mob/user)
	user.examinate(src)

/obj/item/weapon/picture_frame/examine(mob/user)
	if((user.r_hand == src || user.l_hand == src) && displayed)
		displayed.show(user)
	else
		..()

/obj/item/weapon/picture_frame/update_icon()
	cut_overlays()
	if(displayed)
		overlays |= image(displayed.icon, "photo")
	if(frame_glass)
		overlays |= icon('icons/obj/bureaucracy.dmi',"glass_frame_item")

/obj/item/weapon/picture_frame/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	var/turf/T = target
	if(!iswallturf(T))
		return
	var/ndir = get_dir(user, T)
	if(!(ndir in cardinal))
		return
	user.visible_message("<span class='notice'>[user] hangs [src] to \the [T].</span>",
						 "<span class='notice'>You hang [src] to \the [T].</span>")
	var/obj/structure/picture_frame/wooden/PF = new frame_type(get_turf(user), ndir, 1)
	if(displayed)
		var/obj/item/I = displayed
		displayed = null
		I.forceMove(PF)
		PF.framed = I
	if(frame_glass)
		PF.frame_glass = TRUE
	PF.set_dir(ndir)
	PF.update_icon()
	qdel(src)
	return

/obj/structure/picture_frame
	name = "picture frame"
	desc = "Every time you look it makes you laugh."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "wooden_frame"
	anchored = TRUE

	max_integrity = 50
	resistance_flags = CAN_BE_HIT

	var/obj/item/weapon/photo/framed
	var/frame_type = /obj/item/weapon/picture_frame/wooden
	var/frame_glass = FALSE
	var/glass_health = 10
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
		framed.show(user)
	else
		..()

/obj/structure/picture_frame/attackby(obj/item/weapon/O, mob/user, params)
	if(isscrewing(O))
		if(frame_glass)
			var/choice = input("You can either [screwed ? "unscrew from the wall" : "screw to the wall"] \the [src] or screw out the glass from it") in list("[screwed ? "Unscrew" : "Screw"]", "Screw the glass out", "Cancel")
			switch(choice)
				if("Cancel")
					return
				if("Screw the glass out")
					playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
					frame_glass = FALSE
					to_chat(user, "<span class='notice'>You screw the glass out of \the [src].</span>")
					new /obj/item/stack/sheet/glass(get_turf(src))
					update_icon()
					return
		if(screwed)
			user.visible_message("<span class='notice'>[user] starts unscrewing \the [src].</span>",
								 "<span class='notice'>You start unscrewing \the [src].</span>")
		else
			user.visible_message("<span class='notice'>[user] starts screwing \the [src] to the wall.</span>",
								 "<span class='notice'>You start screwing \the [src] to the wall.</span>")
		if(do_after(user, 20 * O.toolspeed, target = src))
			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
			screwed = !screwed
			if(!screwed)
				user.visible_message("<span class='notice'>[user] unscrews \the [src].</span>",
									 "<span class='notice'>You unscrew \the [src].</span>")
			else
				user.visible_message("<span class='notice'>[user] screws \the [src] to the wall.</span>",
								 "<span class='notice'>You screw \the [src] to the wall.</span>")
		update_icon()
		return
	else if(istype(O, /obj/item/stack/sheet/glass))
		if(!frame_glass)
			frame_glass = TRUE
			playsound(src, 'sound/effects/glassknock.ogg', VOL_EFFECTS_MASTER)
			to_chat(user, "<span class='notice'>You insert the glass into \the [src].</span>")
			var/obj/item/stack/sheet/glass/G = O
			G.use(1)
			update_icon()
		else
			to_chat(user, "<span class='notice'>There is already a glass in \the [src].</span>")
		return
	else if(istype(O, /obj/item/weapon/photo))
		if(!framed)
			var/obj/item/weapon/photo/Photo = O
			user.unEquip(Photo)
			Photo.forceMove(src)
			framed = Photo
			update_icon()
		else
			to_chat(user, "<span class='notice'>\The [src] already contains a photo.</span>")
		return
	else
		..()

// TODO move all handling into picture_frame item
/obj/structure/picture_frame/play_attack_sound(damage_amount, damage_type, damage_flag)
	if(frame_glass)
		switch(damage_type)
			if(BRUTE, BURN)
				playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
		return
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/picture_frame/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	if(frame_glass)
		if(damage_amount < 3)
			return
		switch(damage_type)
			if(BRUTE, BURN)
			else
				return
		glass_health -= damage_amount
		if(glass_health > 0)
			return
		frame_glass = null
		playsound(loc, 'sound/effects/Glassbr3.ogg', VOL_EFFECTS_MASTER)
		new /obj/item/weapon/shard(loc)
		update_icon()
		damage_amount = -glass_health

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
		if(frame_glass)
			F.frame_glass = TRUE
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
		framed.show(user)
	else
		if(screwed)
			to_chat(user, "<span class='warning'>It is screwed to the wall.</span>")
			return
		if(do_after(user, 8, target = src))
			user.visible_message("<span class='notice'>[user] takes off \the [src] from the wall.</span>",
								 "<span class='notice'>You take off \the [src] from the wall.</span>")
			deconstruct(TRUE, user)
		return

/obj/structure/picture_frame/MouseDrop(obj/over_object)
	if(istype(over_object, /atom/movable/screen/inventory/hand))
		if(framed)
			to_chat(usr, "<span class='notice'>You carefully remove the photo from \the [src].</span>")
			over_object.MouseDrop_T(framed, usr)
			framed = null
			update_icon()
		else
			to_chat(usr, "<span class='notice'>There is no photo inside the \the [src].</span>")
		add_fingerprint(usr)
		return

	if(ishuman(usr) || ismonkey(usr))
		var/mob/living/carbon/M = usr
		if(!over_object)
			return
		if(!usr.incapacitated())
			if(over_object == M)
				if(screwed)
					to_chat(M,"<span class='warning'>It is screwed to the wall.</span>")
					return
				if(do_after(M, 8, target = src))
					M.visible_message("<span class='notice'>[M] takes off \the [src] from the wall.</span>",
									 "<span class='notice'>You take off \the [src] from the wall.</span>")
					deconstruct(TRUE, M)
					return

			add_fingerprint(usr)
	return

/obj/structure/picture_frame/update_icon()
	cut_overlays()
	if(screwed)
		icon_state = "[initial(icon_state)]_screwed"
	else
		icon_state = initial(icon_state)
	if(framed)
		var/image/P = image(framed.icon, "photo")
		if(dir == SOUTH)
			var/matrix/Mx = matrix()
			Mx.Turn(180)
			Mx.Translate(0, 1)
			P.transform = Mx
		overlays |= P
	if(frame_glass)
		var/image/I = image('icons/obj/bureaucracy.dmi', "glass_frame")
		I.dir = dir
		overlays |= I
