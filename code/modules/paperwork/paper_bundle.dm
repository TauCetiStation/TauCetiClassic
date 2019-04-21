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


/obj/item/weapon/paper_bundle/attackby(obj/item/weapon/W, mob/user)
	..()
	user.SetNextMove(CLICK_CD_INTERACT)
	var/obj/item/weapon/paper/P
	if(istype(W, /obj/item/weapon/paper))
		P = W
		if(P.crumpled>0)
			to_chat(usr, "Paper to crumpled for bundle.")
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
		user.drop_from_inventory(P)
		P.loc = src
		if(istype(user,/mob/living/carbon/human))
			user:update_inv_l_hand()
			user:update_inv_r_hand()
	else if(istype(W, /obj/item/weapon/photo))
		amount++
		if(screen == 2)
			screen = 1
		to_chat(user, "<span class='notice'>You add [(W.name == "photo") ? "the photo" : W.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name].</span>")
		user.drop_from_inventory(W)
		W.loc = src
	else if(istype(W, /obj/item/weapon/lighter))
		burnpaper(W, user)
	else if(istype(W, /obj/item/weapon/paper_bundle))
		user.drop_from_inventory(W)
		for(var/obj/O in W)
			O.loc = src
			O.add_fingerprint(usr)
			src.amount++
			if(screen == 2)
				screen = 1
		to_chat(user, "<span class='notice'>You add \the [W.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name].</span>")
		qdel(W)
	else
		if(istype(W, /obj/item/weapon/pen) || istype(W, /obj/item/toy/crayon))
			usr << browse("", "window=[name]") //Closes the dialog
		P = src[page]
		P.attackby(W, user)


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
			human_user << browse(entity_ja(dat), "window=[name]")
			P.add_fingerprint(usr)
		else if(istype(src[page], /obj/item/weapon/photo))
			var/obj/item/weapon/photo/P = W
			human_user << browse_rsc(P.img, "tmp_photo.png")
			human_user << browse(entity_ja(dat) + "<html><head><title>[sanitize(P.name)]</title></head>" \
			+ "<body style='overflow:hidden'>" \
			+ "<div> <img src='tmp_photo.png' width = '180'" \
			+ "[P.scribble ? "<div> Written on the back:<br><i>[P.scribble]</i>" : ]"\
			+ "</body></html>", "window=[name]")
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
			playsound(src.loc, "pageturn", 50, 1)
		if(href_list["prev_page"])
			if(page == 1)
				return
			else if(page == 2)
				screen = 0
			else if(page == amount+1)
				screen = 1
			page--
			playsound(src.loc, "pageturn", 50, 1)
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

	var/n_name = sanitize_safe(input(usr, "What would you like to label the bundle?", "Bundle Labelling", null)  as text, MAX_NAME_LEN)
	if((loc == usr && usr.stat == CONSCIOUS))
		name = "[(n_name ? text("[n_name]") : "paper")]"
	add_fingerprint(usr)
	return


/obj/item/weapon/paper_bundle/verb/remove_all()
	set name = "Loose bundle"
	set category = "Object"
	set src in usr

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
	var/obj/item/weapon/paper/P = src.contents
	icon_state = P.icon_state
	overlays = P.overlays
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
			overlays += img
	if(i>1)
		desc =  "[i] papers clipped to each other."
	else
		desc = "A single sheet of paper."
	if(photo)
		desc += "\nThere is a photo attached to it."
	overlays += image('icons/obj/bureaucracy.dmi', "clip")
	return
