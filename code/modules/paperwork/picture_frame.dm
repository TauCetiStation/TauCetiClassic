/****************
* picture frame *
****************/

/obj/item/weapon/picture_frame
	name = "picture frame"
	desc = "The perfect showcase for your favorite memories."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "wooden_frame_item"
	w_class = ITEM_SIZE_SMALL
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
	if(istype(I, /obj/item/weapon/wrench))
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
	if(istype(I, /obj/item/weapon/screwdriver))
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

/obj/item/weapon/picture_frame/MouseDrop(obj/over_object)
	if(ishuman(usr) || ismonkey(usr))
		var/mob/M = usr
		if(!(src.loc == usr))
			return
		if(!over_object)
			return

		if(!usr.incapacitated())
			switch(over_object.name)
				if("r_hand")
					if(!M.unEquip(src))
						return
					M.put_in_r_hand(src)
				if("l_hand")
					if(!M.unEquip(src))
						return
					M.put_in_l_hand(src)
			src.add_fingerprint(usr)
	return

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
	var/turf/T = target
	if(get_dist(T, user) > 1)
		return
	if(!istype(T, /turf/simulated/wall))
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
	PF.dir = ndir
	PF.update_icon()
	qdel(src)
	return

/obj/structure/picture_frame
	name = "picture frame"
	desc = "Every time you look it makes you laugh."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "wooden_frame"
	anchored = TRUE
	var/obj/item/weapon/photo/framed
	var/frame_type = /obj/item/weapon/picture_frame/wooden
	var/health = 50
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
	health = 100

/obj/structure/picture_frame/examine(mob/user)
	if(in_range(src, user) && framed)
		framed.show(user)
	else
		..()

/obj/structure/picture_frame/attackby(obj/item/weapon/O, mob/user, params)
	if(istype(O, /obj/item/weapon/screwdriver))
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
		if(frame_glass && O.force > 3)
			playsound(src, 'sound/effects/Glasshit.ogg', VOL_EFFECTS_MASTER)
			glass_health -= O.force
			if(glass_health <= 0)
				frame_glass = null
				playsound(src, 'sound/effects/Glassbr3.ogg', VOL_EFFECTS_MASTER)
				new /obj/item/weapon/shard(get_turf(src))
				new /obj/item/weapon/shard(get_turf(src))
				update_icon()
		else if(O.force > 5)
			switch(O.damtype)
				if("fire")
					playsound(src, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER)
					health -= O.force * 1
				if("brute")
					playsound(src, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
					health -= O.force * 0.75
			if(health <= 0)
				visible_message("<span class='warning'>[user] smashed [src] apart!</span>")
				if(frame_type == /obj/item/weapon/picture_frame/wooden)
					new /obj/item/stack/sheet/wood(get_turf(src))
				if(frame_type == /obj/item/weapon/picture_frame/metal)
					new /obj/item/stack/sheet/metal(get_turf(src))
				if(framed)
					var/obj/item/I = framed
					framed = null
					I.forceMove(get_turf(src))
				qdel(src)
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
			var/obj/item/weapon/picture_frame/F = new frame_type(get_turf(user))
			if(framed)
				var/obj/item/I = framed
				framed = null
				I.forceMove(F)
				F.displayed = I
			if(frame_glass)
				F.frame_glass = TRUE
			F.update_icon()
			if(!issilicon(user))
				user.put_in_hands(F)
			qdel(src)
		return

/obj/structure/picture_frame/MouseDrop(obj/over_object)
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
					var/obj/item/weapon/picture_frame/F = new frame_type(get_turf(M))
					if(framed)
						var/obj/item/I = framed
						framed = null
						I.forceMove(F)
						F.displayed = I
					if(frame_glass)
						F.frame_glass = TRUE
					F.update_icon()
					if(!issilicon(M))
						M.put_in_hands(F)
					qdel(src)
					return
			if(over_object.name in list("r_hand", "l_hand"))
				if(framed)
					var/obj/item/I = framed
					framed = null
					to_chat(M,"<span class='notice'>You carefully remove the photo from \the [src].</span>")
					update_icon()
					switch(over_object.name)
						if("r_hand")
							M.put_in_r_hand(I)
						if("l_hand")
							M.put_in_l_hand(I)
				else
					to_chat(M,"<span class='notice'>There is no photo inside the \the [src].</span>")

			src.add_fingerprint(usr)
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
