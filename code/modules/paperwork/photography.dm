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

/obj/item/weapon/photo/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/pen) || istype(I, /obj/item/toy/crayon))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null) as text, 128)
		if(loc == user && user.stat == CONSCIOUS)
			scribble = txt
	else if(istype(I, /obj/item/weapon/lighter))
		burnpaper(I, user)
	else if(istype(I, /obj/item/device/occult_scanner))
		for(var/A in photographed_names)
			if(photographed_names[A] == /mob/dead/observer)
				var/obj/item/device/occult_scanner/OS = I
				OS.scanned_type = /mob/dead/observer
				to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")
				break
	else
		return ..()

/obj/item/weapon/photo/examine()
	set src in oview(1)
	if(in_range(usr, src))
		show(usr)
		to_chat(usr, desc)
	else
		to_chat(usr, "<span class='notice'>It is too far away.</span>")

/obj/item/weapon/photo/proc/show(mob/user)
	user << browse_rsc(img, "tmp_photo.png")

	var/datum/browser/popup = new(user, "window=book [name]", "[sanitize(name)]", 192, (scribble ? 400 : 192), ntheme = CSS_THEME_LIGHT)
	popup.set_content("<div style='overflow:hidden;text-align:center;'> <img src='tmp_photo.png' width = '192' style='-ms-interpolation-mode:nearest-neighbor'>[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : null]</div>")
	popup.open()

	return

/obj/item/weapon/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	var/n_name = sanitize_safe(input(usr, "What would you like to label the photo?", "Photo Labelling", null) as text, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if(usr.incapacitated())
		return

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
	can_hold = list(/obj/item/weapon/photo)
	max_storage_space = DEFAULT_BOX_STORAGE

/obj/item/weapon/storage/photo_album/MouseDrop(obj/over_object as obj)

	if((istype(usr, /mob/living/carbon/human)))
		var/mob/M = usr
		if(!( istype(over_object, /obj/screen) ))
			return ..()
		playsound(src, SOUNDIN_RUSTLE, VOL_EFFECTS_MASTER, null, null, -5)
		if(!M.incapacitated() && M.back == src)
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
	desc = "A polaroid camera."
	icon_state = "camera"
	item_state = "photocamera"
	w_class = ITEM_SIZE_SMALL
	flags = CONDUCT
	slot_flags = SLOT_FLAGS_BELT
	m_amt = 2000
	var/flash_enabled = TRUE
	var/pictures_max = 10
	var/pictures_left = 10
	var/on = 1
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/see_ghosts = 0 //for the spoop of it
	var/photo_size = 3 //Default is 3x3. 1x1, 5x5, 7x7 are also options

/obj/item/device/camera/atom_init()
	. = ..()
	update_desc()

/obj/item/device/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = 1

/obj/item/device/camera/proc/update_desc()
	desc = "[initial(desc)]. [pictures_left ? "[pictures_left]" : "No"] photos left."

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

/obj/item/device/camera/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/camera_film))
		user.SetNextMove(CLICK_CD_INTERACT)
		if(pictures_left)
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [I] into \the [src].</span>")
		qdel(I)
		pictures_left = pictures_max
		update_desc()
		playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER)
		return
	return ..()

/obj/item/device/camera/spooky/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")
		return
	return ..()

/obj/item/device/camera/proc/camera_get_icon(list/turfs, turf/center)
	var/atoms[] = list()
	for(var/turf/T in turfs)
		atoms.Add(T)
		for(var/atom/movable/A in T)
			if(!A.invisibility || (see_ghosts && isobserver(A)))
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

/obj/item/device/camera/afterattack(atom/target, mob/user, proximity, params)
	if(!on || ismob(target.loc))
		return
	if(!pictures_left)
		to_chat(user, "<span class='warning'>There is no photos left. Insert more camera film.</span>")
		return
	captureimage(target, user, proximity)

	playsound(src, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), VOL_EFFECTS_MASTER, null, null, -3)

	pictures_left--
	update_desc()
	to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")
	icon_state = icon_off
	on = 0
	addtimer(CALLBACK(src, .proc/reload), 64)

/obj/item/device/camera/proc/reload()
	icon_state = icon_on
	on = 1

/obj/item/device/camera/proc/captureimage(atom/target, mob/user, flag)  //Proc for both regular and AI-based camera to take the image
	if(flash_enabled)
		flash_lighting_fx(8, light_power, light_color)

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
	pc.Blend(tiny_img,ICON_OVERLAY, 12, 19)

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
	if(usr.get_active_hand() != src)
		to_chat(usr, "You need to hold \the [src] in your active hand.")
		return

	if(photo_size == 1)
		photo_size = 3
		to_chat(usr, "<span class='info'>You set the camera zoom to normal.</span>")
	else if(photo_size == 3)
		photo_size = 5
		to_chat(usr, "<span class='info'>You set the camera zoom to big.</span>")
	else
		photo_size = 1
		to_chat(usr, "<span class='info'>You set the camera zoom to small.</span>")

/obj/item/device/camera/AltClick(mob/user)
	if(!Adjacent(user))
		return
	if(user.incapacitated())
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
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
