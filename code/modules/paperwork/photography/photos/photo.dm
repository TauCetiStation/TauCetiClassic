/*
 * Photo
 */

/obj/item/weapon/photo
	name = "photo"
	icon = 'icons/obj/photography.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = ITEM_SIZE_SMALL
	var/icon/img	//Big photo image
	var/scribble	//Scribble on the back.
	var/icon/tiny
	var/list/photographed_names = list() // For occult purposes.
	var/photo_id // unique id, used by album.dm

/obj/item/weapon/photo/atom_init()
	. = ..()
	photo_id = "[pick("A", "B", "C", "D", "F")]_[rand(1, 9999)]"

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
		var/choice = input(user, "What do you want to do with \the [src]?", "Choose the option", null) as null|anything in list("Rename the photo", "Write something on the back")
		if(!choice)
			return
		switch(choice)
			if("Rename the photo")
				rename()
			if("Write something on the back")
				write_on_the_back()
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
	var/window_length = 192
	if(scribble)
		window_length += 30 + length(scribble)
	user << browse_rsc(img, "tmp_photo.png")
	user << browse(entity_ja("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden;margin:0;text-align:center'>" \
		+ "<img src='tmp_photo.png' width='192' style='-ms-interpolation-mode:nearest-neighbor' />" \
		+ "[scribble ? "<br>Written on the back:<br><i>[scribble]</i>" : ""]"\
		+ "</body></html>"), "window=photo;size=192x[window_length]")
	onclose(user, "[name]")
	return

/obj/item/weapon/photo/verb/rename()
	set name = "Rename photo"
	set category = "Object"
	set src in view(1)

	if(usr.stat || usr.restrained())
		return

	if(iscarbon(usr))
		var/mob/living/carbon/M = usr
		if(M.r_hand && (istype(M.r_hand, /obj/item/weapon/pen) || istype(M.r_hand, /obj/item/toy/crayon)) || M.l_hand && (istype(M.l_hand, /obj/item/weapon/pen) || istype(M.l_hand, /obj/item/toy/crayon)))
			var/txt = sanitize(input(M, "What would you like to label the photo?", "Photo Labelling", null) as text, MAX_NAME_LEN + 6) // a bit more creative space
			if(!txt)
				return
			if(M.r_hand && (istype(M.r_hand, /obj/item/weapon/pen) || istype(M.r_hand, /obj/item/toy/crayon)) || M.l_hand && (istype(M.l_hand, /obj/item/weapon/pen) || istype(M.l_hand, /obj/item/toy/crayon)))
				if(!(get_dist(src, M) <= 1))
					to_chat(M, "<span class='warning'>[src] is too far away!</span>")
					return
				add_fingerprint(M)
				to_chat(M, "<span class='notice'>You changed [src]'s name to [txt].</span>")
				name = txt
			else
				to_chat(M, "<span class='warning'>You need something to white with.</span>")
		else
			to_chat(M, "<span class='warning'>You need something to white with.</span>")
	else
		to_chat(usr, "<span class='warning'>You're too dumb for this.</span>")

/obj/item/weapon/photo/verb/write_on_the_back()
	set name = "Write on the back"
	set category = "Object"
	set src in view(1)

	if(usr.stat || usr.restrained())
		return

	if(iscarbon(usr))
		var/mob/living/carbon/M = usr
		if(M.r_hand && (istype(M.r_hand, /obj/item/weapon/pen) || istype(M.r_hand, /obj/item/toy/crayon)) || M.l_hand && (istype(M.l_hand, /obj/item/weapon/pen) || istype(M.l_hand, /obj/item/toy/crayon)))
			var/txt = sanitize(input(M, "What would you like to write on the back?", "Photo Writing", null) as text, 128)
			if(!txt)
				return
			if(M.r_hand && (istype(M.r_hand, /obj/item/weapon/pen) || istype(M.r_hand, /obj/item/toy/crayon)) || M.l_hand && (istype(M.l_hand, /obj/item/weapon/pen) || istype(M.l_hand, /obj/item/toy/crayon)))
				if(!(get_dist(src, M) <= 1))
					to_chat(M, "<span class='warning'>[src] is too far away!</span>")
					return
				add_fingerprint(M)
				scribble = txt
				to_chat(M, "<span class='notice'>You wrote something on \the [src].</span>")
			else
				to_chat(M, "<span class='warning'>You need something to white with.</span>")
		else
			to_chat(M, "<span class='warning'>You need something to white with.</span>")
	else
		to_chat(usr, "<span class='warning'>You're too dumb for this.</span>")

/obj/item/weapon/photo/proc/photocreate(inicon, inimg, indesc)
	icon = inicon
	img = inimg
	desc = indesc

/obj/item/weapon/photo/proc/construct(datum/picture/P)
	icon = P.fields["icon"]
	tiny = P.fields["tiny"]
	img = P.fields["img"]
	desc = P.fields["desc"]
	photographed_names = P.fields["mob_names"]
	pixel_x = P.fields["pixel_x"]
	pixel_y = P.fields["pixel_y"]
