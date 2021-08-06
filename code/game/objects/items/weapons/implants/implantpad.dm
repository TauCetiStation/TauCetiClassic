/obj/item/weapon/implantpad
	name = "implantpad"
	desc = "Used to modify implants."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantpad-0"
	item_state = "electronic"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	var/obj/item/weapon/implantcase/case = null
	var/broadcasting = null
	var/listening = 1.0

/obj/item/weapon/implantpad/proc/update()
	if (src.case)
		src.icon_state = "implantpad-1"
	else
		src.icon_state = "implantpad-0"
	return


/obj/item/weapon/implantpad/attack_hand(mob/user)
	if ((src.case && (user.l_hand == src || user.r_hand == src)))
		user.put_in_active_hand(case)

		case.add_fingerprint(user)
		src.case = null

		add_fingerprint(user)
		update()
	else
		return ..()
	return


/obj/item/weapon/implantpad/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/implantcase))
		if(!case)
			user.drop_from_inventory(I, src)
			case = I
			update()

	else
		return ..()

/obj/item/weapon/implantpad/attack_self(mob/user)
	user.set_machine(src)
	var/dat = ""
	if (src.case)
		if(src.case.imp)
			if(istype(src.case.imp, /obj/item/weapon/implant))
				dat += case.imp.get_data()
				if(istype(src.case.imp, /obj/item/weapon/implant/tracking))
					dat += {"ID (1-100):
					<A href='byond://?src=\ref[src];tracking_id=-10'>-</A>
					<A href='byond://?src=\ref[src];tracking_id=-1'>-</A> [case.imp:id]
					<A href='byond://?src=\ref[src];tracking_id=1'>+</A>
					<A href='byond://?src=\ref[src];tracking_id=10'>+</A><BR>"}
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"

	var/datum/browser/popup = new(user, "implantpad", "Implant Mini-Computer")
	popup.set_content(dat)
	popup.open()
	return


/obj/item/weapon/implantpad/Topic(href, href_list)
	..()
	if (usr.incapacitated())
		return
	if (Adjacent(usr))
		usr.set_machine(src)
		if (href_list["tracking_id"])
			var/obj/item/weapon/implant/tracking/T = src.case.imp
			T.id += text2num(href_list["tracking_id"])
			T.id = min(100, T.id)
			T.id = max(1, T.id)

		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					attack_self(M)
		add_fingerprint(usr)
	else
		usr << browse(null, "window=implantpad")
		return
	return
