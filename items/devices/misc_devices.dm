/obj/item/weapon/occult_pinpointer
	name = "occult locator"
	icon = 'tauceti/icons/obj/devices.dmi'
	icon_state = "locoff"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500
	var/obj/item/weapon/ectoplasm/ectoplasm = null
	var/active = 0


	attack_self()
		if(!active)
			active = 1
			search()
			usr << "\blue You activate the [src.name]"
		else
			active = 0
			icon_state = "locoff"
			usr << "\blue You deactivate the [src.name]"

	proc/search()
		if(!active) return
		if(!ectoplasm)
			ectoplasm = locate()
			if(!ectoplasm)
				icon_state = "locnull"
				return
		dir = get_dir(src,ectoplasm)
		switch(get_dist(src,ectoplasm))
			if(0)
				icon_state = "locon"
			if(1 to 8)
				icon_state = "locon"
			if(9 to 16)
				icon_state = "locon"
			if(16 to INFINITY)
				icon_state = "locon"
		spawn(5) .()

/obj/item/device/occult_scanner
	name = "occult scanner"
	icon = 'tauceti/icons/obj/devices.dmi'
	icon_state = "occult_scan"
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	w_class = 2.0
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	m_amt = 500

/obj/item/device/occult_scanner/afterattack(mob/M as mob, mob/user as mob)
	if(user && user.client)
		if(ishuman(M) && M.stat == DEAD)
			user.visible_message("\blue [user] scans [M], the air around them humming gently.")
			user.show_message("\blue [M] was [pick("possessed", "devoured", "destroyed", "murdered", "captured")] by [pick("Cthulhu", "Mi-Go", "Elder God", "dark spirit", "Outsider", "unknown alien creature")]", 1)
		else	return