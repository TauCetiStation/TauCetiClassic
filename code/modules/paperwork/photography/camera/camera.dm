/*
 * Camera
 */

/obj/item/device/camera
	name = "camera"
	icon = 'icons/obj/photography.dmi'
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
	var/on = TRUE
	var/icon_on = "camera"
	var/icon_off = "camera_off"
	var/icon_nopictures = "camera_nopics"
	var/see_ghosts = FALSE //for the spoop of it
	var/photo_size = 3 //Default is 3x3. 1x1, 5x5 are also options
	var/cooldown = 0

/obj/item/device/camera/atom_init()
	. = ..()
	update_desc()

/obj/item/device/camera/update_icon()
	if(!pictures_left)
		icon_state = icon_nopictures
		return
	if(on)
		icon_state = icon_on
	else
		icon_state = icon_off

/obj/item/device/camera/proc/update_desc()
	desc = "[initial(desc)] [pictures_left ? "[pictures_left]" : "No"] photos left."

/obj/item/device/camera/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/device/camera/attack_self(mob/user)
	if(!pictures_left)
		to_chat(user, "<span class='warning'>There is no photos left. Insert more camera film.</span>")
		return
	if(cooldown)
		to_chat(user, "<span class='warning'>\The [src] is recharhing.</span>")
		return
	on = !on
	update_icon()
	user.playsound_local(null, 'sound/items/buttonswitch.ogg', 50)
	to_chat(user, "You switch the camera [on ? "on" : "off"].")
	return

/obj/item/device/camera/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/camera_film))
		user.SetNextMove(CLICK_CD_INTERACT)
		if(pictures_left)
			to_chat(user, "<span class='notice'>[src] still has some film in it!</span>")
			return
		to_chat(user, "<span class='notice'>You insert [I] into \the [src].</span>")
		user.drop_item()
		qdel(I)
		pictures_left = pictures_max
		update_desc()
		update_icon()
		playsound(src, 'sound/items/insert_key.ogg', 50, 1)
		return
	..()

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
				mob_detail = "You can see [L] on the photo[(L.health / L.maxHealth) < 0.75 ? " - [L] looks hurt":""].[holding ? " [holding]":"."]. "
			else
				mob_detail += "You can also see [L] on the photo[(L.health / L.maxHealth) < 0.75 ? " - [L] looks hurt":""].[holding ? " [holding]":"."]."
			names_detail[M.name] = M.type

	return list("mob_detail" = mob_detail, "names_detail" = names_detail)

/obj/item/device/camera/afterattack(atom/target, mob/user, flag)
	if(!on || cooldown || ismob(target.loc))
		return
	if(!pictures_left)
		to_chat(user, "<span class='warning'>There is no photos left. Insert more camera film.</span>")
		return
	captureimage(target, user, flag)

	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	pictures_left--
	update_desc()
	to_chat(user, "<span class='notice'>[pictures_left] photos left.</span>")
	on = FALSE
	update_icon()
	addtimer(CALLBACK(src, .proc/reload), 20)
	cooldown = TRUE

/obj/item/device/camera/proc/reload()
	on = TRUE
	cooldown = FALSE
	update_icon()

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
	var/icon/ic = icon('icons/obj/photography.dmi',"photo")
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

	var/choice = input("Choose the new camera zoom.", "Pick a size of resulting photo.") in list("Big", "Normal", "Small", "Cancel")

	if(usr.incapacitated())
		return
	if(usr.get_active_hand() != src)
		to_chat(usr, "You need to hold \the [src] in your active hand.")
		return

	switch(choice)
		if("Cancel" || null)
			return
		if("Big")
			photo_size = 5
		if("Normal")
			photo_size = 3
		if("Small")
			photo_size = 1

	to_chat(usr, "<span class='info'>You set the camera zoom to [choice].</span>")

/obj/item/device/camera/AltClick()
	set_zoom()

/*
 * Other types of camera
 */

/obj/item/device/camera/spooky
	name = "camera obscura"
	desc = "A polaroid camera, some say it can see ghosts!"
	see_ghosts = 1

/obj/item/device/camera/spooky/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/device/occult_scanner))
		var/obj/item/device/occult_scanner/OS = I
		OS.scanned_type = src.type
		to_chat(user, "<span class='notice'>[src] has been succesfully scanned by [OS]</span>")

/obj/item/device/camera/big_photos
	photo_size = 5

/obj/item/device/camera/big_photos/set_zoom()
	return

/obj/item/device/camera/huge_photos
	photo_size = 7

/obj/item/device/camera/huge_photos/set_zoom()
	return
