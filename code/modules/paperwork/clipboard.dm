/obj/item/weapon/clipboard
	name = "Clipboard"
	icon = 'icons/obj/bureaucracy.dmi'
	hitsound = list('sound/items/misc/folder-slap.ogg')
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = SIZE_TINY
	throw_speed = 3
	throw_range = 10
	var/obj/item/weapon/pen/haspen		//The stored pen.
	var/obj/item/weapon/toppaper	//The topmost piece of paper.
	slot_flags = SLOT_FLAGS_BELT

/obj/item/weapon/clipboard/atom_init()
	. = ..()
	update_icon()

/obj/item/weapon/clipboard/update_icon()
	cut_overlays()
	if(toppaper)
		add_overlay(toppaper.icon_state)
		add_overlay(toppaper.overlays)
	if(haspen)
		add_overlay("clipboard_pen")
	add_overlay("clipboard_over")
	return

/obj/item/weapon/clipboard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/paper) || istype(I, /obj/item/weapon/photo))
		user.drop_from_inventory(I, src)
		if(istype(I, /obj/item/weapon/paper))
			toppaper = I
		to_chat(user, "<span class='notice'>You clip the [I] onto \the [src].</span>")
		update_icon()

	else if(toppaper)
		toppaper.attackby(usr.get_active_hand(), usr, params)
		update_icon()

	else
		return ..()

/obj/item/weapon/clipboard/attack_self(mob/user)
	var/dat = ""
	if(haspen)
		dat += "<A href='byond://?src=\ref[src];pen=1'>Remove Pen</A><BR><HR>"
	else
		dat += "<A href='byond://?src=\ref[src];addpen=1'>Add Pen</A><BR><HR>"

	//The topmost paper. I don't think there's any way to organise contents in byond, so this is what we're stuck with.	-Pete
	if(toppaper)
		var/obj/item/weapon/paper/P = toppaper
		dat += "<A href='byond://?src=\ref[src];write=\ref[P]'>Write</A> <A href='byond://?src=\ref[src];remove=\ref[P]'>Remove</A> - <A href='byond://?src=\ref[src];read=\ref[P]'>[sanitize(P.name)]</A><BR><HR>"

	for(var/obj/item/weapon/paper/P in src)
		if(P==toppaper)
			continue
		dat += "<A href='byond://?src=\ref[src];remove=\ref[P]'>Remove</A> - <A href='byond://?src=\ref[src];read=\ref[P]'>[sanitize(P.name)]</A><BR>"
	for(var/obj/item/weapon/photo/Ph in src)
		dat += "<A href='byond://?src=\ref[src];remove=\ref[Ph]'>Remove</A> - <A href='byond://?src=\ref[src];look=\ref[Ph]'>[sanitize(Ph.name)]</A><BR>"

	var/datum/browser/popup = new(user, "window=clipboard", name)
	popup.set_content(dat)
	popup.open()

	add_fingerprint(usr)
	return

/obj/item/weapon/clipboard/Topic(href, href_list)
	..()
	if(usr.incapacitated())
		return

	if(usr.contents.Find(src))

		if(href_list["pen"])
			if(haspen)
				haspen.loc = usr.loc
				usr.put_in_hands(haspen)
				haspen = null

		if(href_list["addpen"])
			if(!haspen)
				if(istype(usr.get_active_hand(), /obj/item/weapon/pen))
					var/obj/item/weapon/pen/W = usr.get_active_hand()
					usr.drop_from_inventory(W, src)
					haspen = W
					to_chat(usr, "<span class='notice'>You slot the pen into \the [src].</span>")

		if(href_list["write"])
			var/obj/item/P = locate(href_list["write"]) in src
			if(P)
				if(usr.get_active_hand())
					P.attackby(usr.get_active_hand(), usr)

		if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"]) in src
			if(P)
				P.loc = usr.loc
				usr.put_in_hands(P)
				if(P == toppaper)
					toppaper = null
					var/obj/item/weapon/paper/newtop = locate(/obj/item/weapon/paper) in src
					if(newtop && (newtop != P))
						toppaper = newtop
					else
						toppaper = null

		if(href_list["read"])
			var/obj/item/weapon/paper/P = locate(href_list["read"]) in src
			if(P)
				P.show_content(usr)

		if(href_list["look"])
			var/obj/item/weapon/photo/P = locate(href_list["look"]) in src
			if(P)
				P.show(usr)

		if(href_list["top"])
			var/obj/item/P = locate(href_list["top"]) in src
			if(P)
				toppaper = P
				to_chat(usr, "<span class='notice'>You move [P.name] to the top.</span>")

		//Update everything
		attack_self(usr)
		update_icon()
	return
