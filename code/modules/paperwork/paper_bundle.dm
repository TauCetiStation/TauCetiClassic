/obj/item/weapon/paper_bundle
	name = "paper bundle"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = SIZE_MINUSCULE
	throw_range = 2
	throw_speed = 1
	layer = 4
	attack_verb = list("bapped")
	var/page = 1 // Current page
	var/screen = 0
	var/list/pages = list() //Amount of items clipped to the paper

/obj/item/weapon/paper_bundle/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/weapon/paper/carbon))
		var/obj/item/weapon/paper/carbon/C = I
		if (!C.iscopy && !C.copied)
			to_chat(user, "<span class='notice'>Take off the carbon copy first.</span>")
			add_fingerprint(user)
			return
	// adding sheets
	if(istype(I, /obj/item/weapon/paper) || istype(I, /obj/item/weapon/photo))
		insert_sheet_at(user, pages.len+1, I)

	else if(istype(I, /obj/item/weapon/lighter))
		burnpaper(I, user)

	else if(istype(I, /obj/item/weapon/paper_bundle))
		user.drop_from_inventory(I)
		for(var/obj/O in I)
			O.forceMove(src)
			O.add_fingerprint(usr)
			pages.Add(O)
			if(screen == 2)
				screen = 1
		to_chat(user, "<span class='notice'>You add \the [I.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name].</span>")
		qdel(I)

	else
		if(istype(I, /obj/item/weapon/pen) || istype(I, /obj/item/toy/crayon))
			usr << browse(null, "window=[name]") //Closes the dialog
		var/obj/P = pages[page]
		P.attackby(I, user)

	update_icon()
	attack_self(usr) //Update the browsed page.
	add_fingerprint(usr)
	return

/obj/item/weapon/paper_bundle/proc/insert_sheet_at(mob/user, index, obj/item/weapon/sheet)
	if(istype(sheet, /obj/item/weapon/paper))
		to_chat(user, "<span class='notice'>You add [(sheet.name == "paper") ? "the paper" : sheet.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name].</span>")
	else if(istype(sheet, /obj/item/weapon/photo))
		to_chat(user, "<span class='notice'>You add [(sheet.name == "photo") ? "the photo" : sheet.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name].</span>")

	user.drop_from_inventory(sheet, src)

	pages.Insert(index, sheet)

	if(index <= page)
		page++

/obj/item/weapon/paper_bundle/examine()
	set src in oview(1)

	to_chat(usr, desc)
	if(in_range(usr, src))
		attack_self(usr)
	else
		to_chat(usr, "<span class='notice'>It is too far away.</span>")
	return


/obj/item/weapon/paper_bundle/attack_self(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		var/dat
		var/obj/item/weapon/W = pages[page]
		if(page == 1)
			dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/weapon/paper)) ? "paper" : "photo"]</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV><BR><HR>"
		else if(page == pages.len)
			dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/weapon/paper)) ? "paper" : "photo"]</A></DIV><BR><HR>"
			dat+= "<DIV STYLE='float;left; text-align:right; with:33.33333%'></DIV>"
		else
			dat+= "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=\ref[src];prev_page=1'>Previous Page</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=\ref[src];remove=1'>Remove [(istype(W, /obj/item/weapon/paper)) ? "paper" : "photo"]</A></DIV>"
			dat+= "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=\ref[src];next_page=1'>Next Page</A></DIV><BR><HR>"
		if(istype(pages[page], /obj/item/weapon/paper))
			var/obj/item/weapon/paper/P = W
			dat += P.show_content(human_user, view = FALSE)

			var/datum/browser/popup = new(human_user, "window=[name]", "[sanitize(P.name)]", 300, 480, ntheme = CSS_THEME_LIGHT)
			popup.set_content(dat)
			popup.open()

			P.add_fingerprint(usr)
		else if(istype(pages[page], /obj/item/weapon/photo))
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
	if(loc == usr || istype(loc, /obj/structure/noticeboard) || (istype(src.loc, /obj/item/weapon/folder) && loc.loc == usr))
		usr.set_machine(src)
		var/obj/item/weapon/in_hand = usr.get_active_hand()
		if(href_list["next_page"])
			if(in_hand && (istype(in_hand, /obj/item/weapon/paper) || istype(in_hand, /obj/item/weapon/photo)))
				insert_sheet_at(usr, page+1, in_hand)
			else if(page != pages.len)
				page++
				playsound(src, pick(SOUNDIN_PAGETURN), VOL_EFFECTS_MASTER)
		else if(href_list["prev_page"])
			if(in_hand && (istype(in_hand, /obj/item/weapon/paper) || istype(in_hand, /obj/item/weapon/photo)))
				insert_sheet_at(usr, page, in_hand)
			else if(page > 1)
				page--
				playsound(src, pick(SOUNDIN_PAGETURN), VOL_EFFECTS_MASTER)
		else if(href_list["remove"] && !istype(loc, /obj/structure/noticeboard))
			var/obj/item/weapon/W = pages[page]
			usr.put_in_hands(W)
			pages.Remove(pages[page])

			to_chat(usr, "<span class='notice'>You remove the [W.name] from the bundle.</span>")

			if(pages.len <= 1)
				var/obj/item/weapon/paper/P = src[1]
				usr.drop_from_inventory(src)
				usr.put_in_hands(P)
				qdel(src)

				return

			if(page > pages.len)
				page = pages.len

			update_icon()

		attack_self(usr)
		updateUsrDialog()
	else
		to_chat(usr, "<span class='notice'>You need to hold it in hands!</span>")
	if (istype(src.loc, /mob))
		attack_self(src.loc)
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
	var/obj/item/weapon/paper/P = pages[1]
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
