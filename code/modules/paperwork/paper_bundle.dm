/obj/item/weapon/paper_bundle
	name = "paper bundle"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	throw_range = 2
	throw_speed = 1
	layer = 4
	attack_verb = list("bapped")
	var/amount = 0 //Amount of items clipped to the paper
	var/page = 1
	var/screen = 0

/obj/item/weapon/paper_bundle/attackby(obj/item/I, mob/user, params)
	user.SetNextMove(CLICK_CD_INTERACT)
	var/obj/item/weapon/paper/P
	if(istype(I, /obj/item/weapon/paper))
		P = I
		if(P.crumpled)
			to_chat(usr, "Paper too crumpled for anything")
			return
		if (istype(P, /obj/item/weapon/paper/carbon))
			var/obj/item/weapon/paper/carbon/C = P
			if (!C.iscopy && !C.copied)
				to_chat(user, "<span class='notice'>Take off the carbon copy first.</span>")
				add_fingerprint(user)
				return

		amount++
		if(screen == 2)
			screen = 1
		to_chat(user, "<span class='notice'>You add [(P.name == "paper") ? "the paper" : P.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name].</span>")
		user.drop_from_inventory(P, src)

	else if(istype(I, /obj/item/weapon/photo))
		amount++
		if(screen == 2)
			screen = 1
		to_chat(user, "<span class='notice'>You add [(I.name == "photo") ? "the photo" : I.name] to [(name == "paper bundle") ? "the paper bundle" : name].</span>")
		user.drop_from_inventory(I, src)

	else if(istype(I, /obj/item/weapon/lighter))
		burnpaper(I, user)

	else if(istype(I, /obj/item/weapon/paper_bundle))
		user.drop_from_inventory(I)
		for(var/obj/O in I)
			O.forceMove(src)
			O.add_fingerprint(usr)
			src.amount++
			if(screen == 2)
				screen = 1
		to_chat(user, "<span class='notice'>You add \the [I.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name].</span>")
		qdel(I)

	else
		if(istype(I, /obj/item/weapon/pen) || istype(I, /obj/item/toy/crayon))
			usr << browse("", "window=[name]") //Closes the dialog
		P = src[page]
		P.attackby(I, user, params)

	update_icon()
	attack_self(usr) //Update the browsed page.
	add_fingerprint(usr)
	return


/obj/item/weapon/paper_bundle/examine()
	set src in oview(1)

	to_chat(usr, desc)
	if(in_range(usr, src))
		src.attack_self(usr)
	else
		to_chat(usr, "<span class='notice'>It is too far away.</span>")
	return


/obj/item/weapon/paper_bundle/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat
		var/obj/item/weapon/W = src[page]
		switch(screen)
			if(0)
				dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/weapon/paper)) ? "paper" : "photo"]</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV><BR><HR>"
			if(1)
				dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/weapon/paper)) ? "paper" : "photo"]</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV><BR><HR>"
			if(2)
				dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
				dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/weapon/paper)) ? "paper" : "photo"]</A></DIV><BR><HR>"
				dat+= "<DIV STYLE='float;left; text-align:right; with:33.33333%'></DIV>"
		if(istype(src[page], /obj/item/weapon/paper))
			var/obj/item/weapon/paper/P = W
			dat += P.show_content(human_user, view = FALSE)

			var/datum/browser/popup = new(human_user, "window=[name]", "[sanitize(P.name)]", 300, 480, ntheme = CSS_THEME_LIGHT)
			popup.set_content(dat)
			popup.open()

			P.add_fingerprint(usr)
		else if(istype(src[page], /obj/item/weapon/photo))
			var/obj/item/weapon/photo/P = W
			human_user << browse_rsc(P.img, "tmp_photo.png")

			var/datum/browser/popup = new(human_user, "window=[name]", "[sanitize(P.name)]", 192, (P.scribble ? 400 : 192), ntheme = CSS_THEME_LIGHT)
			popup.set_content(dat + "<div style='overflow:hidden'> <img src='tmp_photo.png' width = '192' style='-ms-interpolation-mode:nearest-neighbor'>[P.scribble ? "<br>Written on the back:<br><i>[P.scribble]</i>" : null]</div>")
			popup.open()

			P.add_fingerprint(usr)
		add_fingerprint(usr)
		update_icon()
	return


/obj/item/weapon/paper_bundle/Topic(href, href_list)
	..()
	if((src in usr.contents) || (istype(src.loc, /obj/item/weapon/folder) && (src.loc in usr.contents)))
		usr.set_machine(src)
		if(href_list["next_page"])
			if(page == amount)
				screen = 2
			else if(page == 1)
				screen = 1
			else if(page == amount+1)
				return
			page++
			playsound(src, pick(SOUNDIN_PAGETURN), VOL_EFFECTS_MASTER)
		if(href_list["prev_page"])
			if(page == 1)
				return
			else if(page == 2)
				screen = 0
			else if(page == amount+1)
				screen = 1
			page--
			playsound(src, pick(SOUNDIN_PAGETURN), VOL_EFFECTS_MASTER)
		if(href_list["remove"])
			var/obj/item/weapon/W = src[page]
			usr.put_in_hands(W)
			to_chat(usr, "<span class='notice'>You remove the [W.name] from the bundle.</span>")
			if(amount == 1)
				var/obj/item/weapon/paper/P = src[1]
				usr.drop_from_inventory(src)
				usr.put_in_hands(P)
				qdel(src)
			else if(page == amount)
				screen = 2
			else if(page == amount+1)
				page--

			amount--
			update_icon()
	else
		to_chat(usr, "<span class='notice'>You need to hold it in hands!</span>")
	if (istype(src.loc, /mob))
		src.attack_self(src.loc)
		updateUsrDialog()



/obj/item/weapon/paper_bundle/verb/rename()
	set name = "Rename bundle"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	var/n_name = sanitize_safe(input(usr, "What would you like to label the bundle?", "Bundle Labelling", null)  as text, MAX_NAME_LEN)
	if(usr.incapacitated())
		return

	if(loc == usr)
		name = "[(n_name ? text("[n_name]") : "paper")]"
		add_fingerprint(usr)


/obj/item/weapon/paper_bundle/verb/remove_all()
	set name = "Loose bundle"
	set category = "Object"
	set src in usr

	if(usr.incapacitated())
		return

	to_chat(usr, "<span class='notice'>You loosen the bundle.</span>")
	for(var/obj/O in src)
		O.loc = usr.loc
		O.layer = initial(O.layer)
		O.plane = initial(O.plane)
		O.add_fingerprint(usr)
	usr.drop_from_inventory(src)
	qdel(src)
	return


/obj/item/weapon/paper_bundle/update_icon()
	cut_overlays()
	if(contents.len)
		var/obj/item/weapon/paper/P = contents[1]
		icon_state = P.icon_state
		copy_overlays(P)
	underlays = 0
	var/i = 0
	var/photo
	for(var/obj/O in src)
		var/image/img = image('icons/obj/bureaucracy.dmi')
		if(istype(O, /obj/item/weapon/paper))
			img.icon_state = O.icon_state
			img.pixel_x -= min(1*i, 2)
			img.pixel_y -= min(1*i, 2)
			pixel_x = min(0.5*i, 1)
			pixel_y = min(  1*i, 2)
			underlays += img
			i++
		else if(istype(O, /obj/item/weapon/photo))
			var/obj/item/weapon/photo/Ph = O
			img = Ph.tiny
			photo = 1
			add_overlay(img)
	if(i>1)
		desc =  "[i] papers clipped to each other."
	else
		desc = "A single sheet of paper."
	if(photo)
		desc += "\nThere is a photo attached to it."
	add_overlay(image('icons/obj/bureaucracy.dmi', "clip"))
	return
