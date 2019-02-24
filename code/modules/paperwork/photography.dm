/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Picture Frames
 *		Photo Albums
 */

/*******
* film *
*******/
/obj/item/device/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = ITEM_SIZE_TINY


/********
* photo *
********/
/obj/item/weapon/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = ITEM_SIZE_SMALL
	var/icon/img	//Big photo image
	var/scribble	//Scribble on the back.
	var/icon/tiny
	var/list/photographed_names = list() // For occult purposes.

/obj/item/weapon/photo/Destroy()
	img = null
	qdel(tiny)
	tiny = null
	return ..()

/obj/item/weapon/photo/burnpaper(obj/item/weapon/lighter/P, mob/user)
	..()
	for(var/A in photographed_names)
		if(photographed_names[A] == /mob/dead/observer)
			if(prob(10))
				new /obj/item/weapon/reagent_containers/food/snacks/ectoplasm(loc) // I mean, it is already dropped in the parent proc, so this is pretty safe to do.
			break

/obj/item/weapon/photo/attack_self(mob/user)
	user.examinate(src)

/obj/item/weapon/photo/attackby(obj/item/weapon/P, mob/user)
	if(istype(P, /obj/item/weapon/pen) || istype(P, /obj/item/toy/crayon))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null) as text, 128)
		if(loc == user && user.stat == CONSCIOUS)
			scribble = txt
	else if(istype(P, /obj/item/weapon/lighter))
		burnpaper(P, user)
	else if(istype(P, /obj/item/device/occult_scanner))
		for(var/A in photographed_names)
			if(photographed_names[A] == /mob/dead/observer)
				var/obj/item/device/occult_scanner/OS = P
				OS.scanned_type = /mob/dead/observer
				to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")
				break
	..()

/obj/item/weapon/photo/examine()
	set src in oview(1)
	if(in_range(usr, src))
		show(usr)
		to_chat(usr, desc)
	else
		to_chat(usr, "<span class='notice'>It is too far away.</span>")

/obj/item/weapon/photo/proc/show(mob/user)
	user << browse_rsc(img, "tmp_photo.png")
	user << browse(entity_ja("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>"), "window=book;size=192x[scribble ? 400 : 192]")
	onclose(user, "[name]")
	return

/obj/item/weapon/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	var/n_name = sanitize_safe(input(usr, "What would you like to label the photo?", "Photo Labelling", null) as text, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if(( (loc == usr || (loc.loc && loc.loc == usr)) && usr.stat == CONSCIOUS))
		name = "[(n_name ? text("[n_name]") : "photo")]"
	add_fingerprint(usr)
	return

/obj/item/weapon/photo/proc/photocreate(inicon, inimg, indesc)
	icon = inicon
	img = inimg
	desc = indesc


/**************
* photo album *
**************/
/obj/item/weapon/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	can_hold = list("/obj/item/weapon/photo",)
	max_storage_space = DEFAULT_BOX_STORAGE

/obj/item/weapon/storage/photo_album/MouseDrop(obj/over_object as obj)

	if((istype(usr, /mob/living/carbon/human)))
		var/mob/M = usr
		if(!( istype(over_object, /obj/screen) ))
			return ..()
		playsound(loc, "rustle", 50, 1, -5)
		if((!( M.restrained() ) && !( M.stat ) && M.back == src))
			switch(over_object.name)
				if("r_hand")
					if(!M.unEquip(src))
						return
					M.put_in_r_hand(src)
				if("l_hand")
					if(!M.unEquip(src))
						return
					M.put_in_l_hand(src)
			add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if(usr.s_active)
				usr.s_active.close(usr)
			show_to(usr)
			return
	return

/*********
* camera *
*********/
/obj/item/device/camera
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "electropack"
	w_class = ITEM_SIZE_SMALL
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	m_amt = 2000
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = 1
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/see_ghosts = 0 //for the spoop of it
	var/photo_size = 3 //Default is 3x3. 1x1, 5x5, 7x7 are also options

/obj/item/device/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = 1

/obj/item/device/camera/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/device/camera/attack_self(mob/user)
	on = !on
	if(on)
		src.icon_state = icon_on
	else
		src.icon_state = icon_off
	to_chat(user, "You switch the camera [on ? "on" : "off"].")
	return

/obj/item/device/camera/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/camera_film))
		user.SetNextMove(CLICK_CD_INTERACT)
		if(pictures_left)
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [I] into [src].</span>")
		user.drop_item()
		qdel(I)
		pictures_left = pictures_max
		return
	..()

/obj/item/device/camera/spooky/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = src.type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")

/obj/item/device/camera/proc/camera_get_icon(list/turfs, turf/center)
	var/atoms[] = list()
	for(var/turf/T in turfs)
		atoms.Add(T)
		for(var/atom/movable/A in T)
			if(A.invisibility)
				if(see_ghosts)
					if(istype(A, /mob/dead/observer))
						var/mob/dead/observer/O = A
						if(O.orbiting) //so you dont see ghosts following people like antags, etc.
							continue
				else
					continue
			atoms.Add(A)

	var/list/sorted = list()
	var/j
	for(var/i = 1 to atoms.len)
		var/atom/c = atoms[i]
		for(j = sorted.len, j > 0, --j)
			var/atom/c2 = sorted[j]
			if(c2.layer <= c.layer)
				break
		sorted.Insert(j+1, c)

	var/icon/res = get_base_photo_icon()

	for(var/atom/A in sorted)
		var/icon/img = getFlatIcon(A)
		if(istype(A, /mob/living) && A:lying)
			img.Turn(A:lying_current)

		var/offX = 1 + (photo_size-1)*16 + (A.x - center.x) * 32 + A.pixel_x
		var/offY = 1 + (photo_size-1)*16 + (A.y - center.y) * 32 + A.pixel_y
		if(istype(A, /atom/movable))
			offX += A:step_x
			offY += A:step_y

		res.Blend(img, blendMode2iconMode(A.blend_mode), offX, offY)

	for(var/turf/T in turfs)
		res.Blend(getFlatIcon(T.loc), blendMode2iconMode(T.blend_mode), 32 * (T.x - center.x) + 33, 32 * (T.y - center.y) + 33)

	return res


/obj/item/device/camera/proc/camera_get_mobs(turf/the_turf)
	var/mob_detail
	var/names_detail = list()
	for(var/mob/M in the_turf)
		if(M.invisibility)
			if(see_ghosts && istype(M,/mob/dead/observer))
				var/mob/dead/observer/O = M
				if(O.orbiting)
					continue
				if(!mob_detail)
					mob_detail = "You can see a g-g-g-g-ghooooost! "
				else
					mob_detail += "You can also see a g-g-g-g-ghooooost!"
				names_detail[O.name] = O.type
			else
				continue

		var/holding = null

		if(istype(M, /mob/living))
			var/mob/living/L = M
			if(L.l_hand || L.r_hand)
				if(L.l_hand) holding = "They are holding \a [L.l_hand]"
				if(L.r_hand)
					if(holding)
						holding += " and \a [L.r_hand]"
					else
						holding = "They are holding \a [L.r_hand]"

			if(!mob_detail)
				mob_detail = "You can see [L] on the photo[L.health < 75 ? " - [L] looks hurt":""].[holding ? " [holding]":"."]. "
			else
				mob_detail += "You can also see [L] on the photo[L.health < 75 ? " - [L] looks hurt":""].[holding ? " [holding]":"."]."
			names_detail[M.name] = M.type

	return list("mob_detail" = mob_detail, "names_detail" = names_detail)

/obj/item/device/camera/afterattack(atom/target, mob/user, flag)
	if(!on || !pictures_left || ismob(target.loc))
		return
	captureimage(target, user, flag)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	pictures_left--
	desc = "A polaroid camera. It has [pictures_left] photos left."
	to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")
	icon_state = icon_off
	on = 0
	addtimer(CALLBACK(src, .proc/reload), 64)

/obj/item/device/camera/proc/reload()
	icon_state = icon_on
	on = 1

/obj/item/device/camera/proc/captureimage(atom/target, mob/user, flag)  //Proc for both regular and AI-based camera to take the image
	var/mobs = ""
	var/list/mob_names = list()
	var/isAi = istype(user, /mob/living/silicon/ai)
	var/list/seen
	if(!isAi) //crappy check, but without it AI photos would be subject to line of sight from the AI Eye object. Made the best of it by moving the sec camera check inside
		if(user.client)		//To make shooting through security cameras possible
			seen = hear(world.view, user.client.eye) //To make shooting through security cameras possible
		else
			seen = hear(world.view, user)
	else
		seen = hear(world.view, target)

	var/list/turfs = list()
	for(var/turf/T in range(round(photo_size * 0.5), target))
		if(T in seen)
			if(isAi && !cameranet.checkTurfVis(T))
				continue
			else
				var/detail_list = camera_get_mobs(T)
				turfs += T
				mobs += detail_list["mob_detail"]
				mob_names += detail_list["names_detail"]

	var/icon/temp = get_base_photo_icon()
	temp.Blend("#000", ICON_OVERLAY)
	temp.Blend(camera_get_icon(turfs, target), ICON_OVERLAY)

	var/datum/picture/P = createpicture(user, temp, mobs, mob_names, flag)
	printpicture(user, P)

/obj/item/device/camera/proc/createpicture(mob/user, icon/temp, mobs, mob_names, flag)
	var/icon/small_img = icon(temp)
	var/icon/tiny_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	var/icon/pc = icon('icons/obj/bureaucracy.dmi', "photo")
	small_img.Scale(8, 8)
	tiny_img.Scale(4, 4)
	ic.Blend(small_img,ICON_OVERLAY, 13, 13)
	pc.Blend(tiny_img,ICON_OVERLAY, 13, 13)

	var/datum/picture/P = new()
	P.fields["author"] = user
	P.fields["icon"] = ic
	P.fields["tiny"] = pc
	P.fields["img"] = temp
	P.fields["desc"] = mobs
	P.fields["mob_names"] = mob_names // A list inside a list.
	P.fields["pixel_x"] = rand(-10, 10)
	P.fields["pixel_y"] = rand(-10, 10)

	return P

/obj/item/device/camera/proc/printpicture(mob/user, datum/picture/P)
	var/obj/item/weapon/photo/Photo = new/obj/item/weapon/photo()
	Photo.loc = user.loc
	if(!user.get_inactive_hand())
		user.put_in_inactive_hand(Photo)
	Photo.construct(P)

/obj/item/device/camera/proc/get_base_photo_icon()
	var/icon/res
	switch(photo_size)
		if(1)
			res = icon('icons/effects/32x32.dmi', "")
		if(3)
			res = icon('icons/effects/96x96.dmi', "")
		if(5)
			res = icon('icons/effects/160x160.dmi', "")
		if(7)
			res = icon('icons/effects/224x224.dmi', "")
		else
			res = icon('icons/effects/32x32.dmi', "")

	return res

/obj/item/device/camera/verb/set_zoom()
	set name = "Set Camera Zoom"
	set category = "Object"

	if(usr.incapacitated())
		return

	if(photo_size == 3)
		photo_size = 1
		to_chat(usr, "<span class='info'>You zoom the camera in.</span>")
	else
		photo_size = 3
		to_chat(usr, "<span class='info'>You zoom the camera out.</span>")

/obj/item/device/camera/AltClick()
	set_zoom()

/obj/item/device/camera/big_photos
	photo_size = 5

/obj/item/device/camera/big_photos/set_zoom()
	return

/obj/item/device/camera/huge_photos
	photo_size = 7

/obj/item/device/camera/huge_photos/set_zoom()
	return

/obj/item/weapon/photo/proc/construct(datum/picture/P)
	icon = P.fields["icon"]
	tiny = P.fields["tiny"]
	img = P.fields["img"]
	desc = P.fields["desc"]
	photographed_names = P.fields["mob_names"]
	pixel_x = P.fields["pixel_x"]
	pixel_y = P.fields["pixel_y"]

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

/obj/item/weapon/picture_frame/wooden
	name = "wooden picture frame"
	frame_type = /obj/structure/picture_frame/wooden

/obj/item/weapon/picture_frame/metal
	name = "metal picture frame"
	desc = "The perfect shiny showcase for your favorite memories."
	icon_state = "metal_frame_item"
	frame_type = /obj/structure/picture_frame/metal

/obj/item/weapon/picture_frame/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/photo))
		if(!displayed)
			var/obj/item/weapon/photo/Photo = I
			user.unEquip(Photo)
			Photo.forceMove(src)
			displayed = Photo
			update_icon()
		else
			to_chat(user,"<span class='notice'>\The [src] already contains a photo.</span>")
		return
	if(istype(I, /obj/item/weapon/wrench))
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(frame_type == /obj/structure/picture_frame/wooden)
			new /obj/item/stack/sheet/wood(src.loc)
		else
			new /obj/item/stack/sheet/metal(src.loc)
		for(var/obj/C in contents)
			C.loc = get_turf(src)
		qdel(src)
		return
	if(istype(I, /obj/item/stack/sheet/glass))
		if(!frame_glass)
			frame_glass = TRUE
			playsound(src, 'sound/effects/glassknock.ogg', 50, 1)
			to_chat(user,"<span class='notice'>You insert the glass into \the [src].</span>")
			var/obj/item/stack/sheet/glass/G = I
			G.use(1)
			update_icon()
		else
			to_chat(user,"<span class='notice'>There is already a glass in \the [src].</span>")
		return
	if(istype(I, /obj/item/weapon/screwdriver))
		if(frame_glass)
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			frame_glass = FALSE
			to_chat(user,"<span class='notice'>You screw the glass out of \the [src].</span>")
			new /obj/item/stack/sheet/glass(get_turf(src))
			update_icon()
		else
			to_chat(user,"<span class='notice'>There is no glass to screw out in \the [src].</span>")
		return
	..()

/obj/item/weapon/picture_frame/attack_hand(mob/user)
	if(user.r_hand == src || user.l_hand == src)
		if(contents.len)
			var/obj/item/I = pick(contents)
			user.put_in_hands(I)
			to_chat(user,"<span class='notice'>You carefully remove the photo from \the [src].</span>")
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

		if(!usr.restrained() && !usr.stat)
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
	overlays.Cut()
	if(displayed)
		src.icon_state = "[src.icon_state]"
		overlays |= getFlatIcon(displayed)
	if(frame_glass)
		overlays |= icon('icons/obj/bureaucracy.dmi',"frame_glass")
	else
		icon_state = initial(icon_state)


/obj/item/weapon/picture_frame/afterattack(atom/target, mob/user, proximity)
	var/turf/T = target
	if(get_dist(T, user) > 1)
		return
	if(!istype(T, /turf/simulated/wall))
		return
	var/ndir = get_dir(user, T)
	if(!(ndir in cardinal))
		return
	user.visible_message("<span class='notice'>[user] hangs [src] to \the [T].</span>", \
						 "<span class='notice'>You hang [src] to \the [T].</span>")
	if(frame_type == /obj/structure/picture_frame/wooden)
		var/obj/structure/picture_frame/wooden/PF = new /obj/structure/picture_frame/wooden(get_turf(user), ndir, 1)
		if(displayed)
			PF.framed = displayed
		if(contents.len)
			for(var/obj/I in contents)
				I.forceMove(PF)
		if(frame_glass)
			PF.frame_glass = TRUE
		PF.dir = ndir
		PF.update_icon()
	if(frame_type == /obj/structure/picture_frame/metal)
		var/obj/structure/picture_frame/metal/PF = new /obj/structure/picture_frame/metal(get_turf(user), ndir, 1)
		if(displayed)
			PF.framed = displayed
		if(contents.len)
			for(var/obj/I in contents)
				I.forceMove(PF)
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
	icon_state = "wooden_frame_sign"
	var/obj/item/weapon/photo/framed
	var/frame_type = /obj/structure/picture_frame/wooden
	var/health = 50
	var/frame_glass = FALSE
	var/glass_health = 10
	var/screwed = FALSE

/obj/structure/picture_frame/atom_init(mapload, ndir, building = 0)
	. = ..()
	if(building)
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 : -28)
		pixel_y = (ndir & 3)? (ndir == 1 ? 28 : -28) : 0
	update_icon()

/obj/structure/picture_frame/wooden
	name = "wooden picture frame"
	frame_type = /obj/structure/picture_frame/wooden

/obj/structure/picture_frame/metal
	name = "metal picture frame"
	icon_state = "metal_frame_sign"
	frame_type = /obj/structure/picture_frame/metal
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
					playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
					frame_glass = FALSE
					to_chat(user,"<span class='notice'>You screw the glass out of \the [src].</span>")
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
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
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
			playsound(src, 'sound/effects/glassknock.ogg', 50, 1)
			to_chat(user,"<span class='notice'>You insert the glass into \the [src].</span>")
			var/obj/item/stack/sheet/glass/G = O
			G.use(1)
			update_icon()
		else
			to_chat(user,"<span class='notice'>There is already a glass in \the [src].</span>")
		return
	else if(istype(O, /obj/item/weapon/photo))
		if(!framed)
			var/obj/item/weapon/photo/Photo = O
			user.unEquip(Photo)
			Photo.forceMove(src)
			framed = Photo
			update_icon()
		else
			to_chat(user,"<span class='notice'>\The [src] already contains a photo.</span>")
		return
	else
		if(frame_glass && O.force > 3)
			playsound(src, 'sound/effects/Glasshit.ogg', 50, 1)
			glass_health -= O.force
			if(glass_health <= 0)
				frame_glass = null
				playsound(src, 'sound/effects/Glassbr3.ogg', 40, 1)
				new /obj/item/weapon/shard(get_turf(src))
				new /obj/item/weapon/shard(get_turf(src))
				update_icon()
		else if(O.force > 5)
			switch(O.damtype)
				if("fire")
					playsound(src, 'sound/items/welder.ogg', 50, 1)
					health -= O.force * 1
				if("brute")
					playsound(src, 'sound/weapons/slash.ogg', 40, 1)
					health -= O.force * 0.75
			if(health <= 0)
				visible_message("<span class='warning'>[user] smashed [src] apart!</span>")
				if(frame_type == /obj/structure/picture_frame/wooden)
					new /obj/item/stack/sheet/metal(get_turf(src))
				if(frame_type == /obj/structure/picture_frame/metal)
					new /obj/item/stack/sheet/metal(get_turf(src))
				for(var/obj/I in contents)
					I.loc = get_turf(src)
				qdel(src)
		..()

/obj/structure/picture_frame/attack_hand(mob/user)
	if(framed)
		framed.show(user)
	else
		if(do_after(user, 8, target = src))
			user.visible_message("<span class='notice'>[user] takes off \the [src] from the wall.</span>", \
								 "<span class='notice'>You take off \the [src] from the wall.</span>")
			if(frame_type == /obj/structure/picture_frame/wooden)
				var/obj/item/weapon/picture_frame/F = new /obj/item/weapon/picture_frame/wooden(get_turf(user))
				if(framed)
					F.displayed = framed
				if(frame_glass)
					F.frame_glass = TRUE
				if(contents.len)
					for(var/obj/I in contents)
						I.forceMove(F)
				F.update_icon()
				if(!issilicon(user))
					user.put_in_hands(F)
			if(frame_type == /obj/structure/picture_frame/metal)
				var/obj/item/weapon/picture_frame/F = new /obj/item/weapon/picture_frame/metal(get_turf(user))
				if(framed)
					F.displayed = framed
				if(frame_glass)
					F.frame_glass = TRUE
				if(contents.len)
					for(var/obj/I in contents)
						I.forceMove(F)
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
		if(!usr.restrained() && !usr.stat)
			switch(over_object.name)
				if("r_hand")
					if(screwed)
						to_chat(M,"<span class='warning'>It is screwed to the wall.</span>")
						return
					if(contents.len)
						var/obj/item/I = pick(contents)
						M.put_in_r_hand(I)
						to_chat(M,"<span class='notice'>You carefully remove the photo from \the [src].</span>")
						framed = null
						update_icon()
					else
						to_chat(M,"<span class='notice'>There is no photo inside the \the [src].</span>")
				if("l_hand")
					if(screwed)
						to_chat(M,"<span class='warning'>It is screwed to the wall.</span>")
						return
					if(contents.len)
						var/obj/item/I = pick(contents)
						M.put_in_l_hand(I)
						to_chat(M,"<span class='notice'>You carefully remove the photo from \the [src].</span>")
						framed = null
						update_icon()
					else
						to_chat(M,"<span class='notice'>There is no photo inside the \the [src].</span>")
			src.add_fingerprint(usr)
	return

/obj/structure/picture_frame/update_icon()
	overlays.Cut()
	if(framed)
		src.icon_state = "[src.icon_state]"
		overlays |= getFlatIcon(framed)
	if(frame_glass)
		overlays |= icon('icons/obj/bureaucracy.dmi',"frame_glass")
	if(screwed)
		overlays |= icon('icons/obj/bureaucracy.dmi',"frame_screws")
	else
		icon_state = initial(icon_state)
