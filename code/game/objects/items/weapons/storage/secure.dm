/*
 *	Absorbs /obj/item/weapon/secstorage.
 *	Reimplements it only slightly to use existing storage functionality.
 *
 *	Contains:
 *		Secure Briefcase
 *		Wall Safe
 *      Syndie Briefcase
 */

// -----------------------------
//         Generic Item
// -----------------------------
/obj/item/weapon/storage/secure
	name = "secstorage"
	var/icon_locking = "secureb"
	var/icon_sparking = "securespark"
	var/icon_opened = "secure0"
	var/locked = 1
	var/code = ""
	var/l_code = null
	var/l_set = 0
	var/l_setshort = 0
	var/l_hacking = 0
	var/emagged = 0
	var/open = 0
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = DEFAULT_BOX_STORAGE

/obj/item/weapon/storage/secure/examine(mob/user)
	..()
	if(src in oview(1, user))
		to_chat(user, "The service panel is [src.open ? "open" : "closed"].")

/obj/item/weapon/storage/secure/attack_alien(mob/user)
	return attack_hand(user)

/obj/item/weapon/storage/secure/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/weapon/storage/secure/attackby(obj/item/I, mob/user, params)
	if(locked)
		if(istype(I, /obj/item/weapon/melee/energy/blade) && !emagged)
			emagged = TRUE
			user.SetNextMove(CLICK_CD_MELEE)
			add_overlay(image('icons/obj/storage.dmi', icon_sparking))
			sleep(6)
			cut_overlays()
			add_overlay(image('icons/obj/storage.dmi', icon_locking))
			locked = 0
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src, 'sound/weapons/blade1.ogg', VOL_EFFECTS_MASTER)
			playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
			to_chat(user, "You slice through the lock on [src].")
			return

		if (isscrewdriver(I))
			if(!user.is_busy(src) && I.use_tool(src, user, 20, volume = 50))
				open = !open
				to_chat(user, "<span class='notice'>You [src.open ? "open" : "close"] the service panel.</span>")
			return
		if ((ismultitool(I)) && (src.open == 1)&& (!src.l_hacking))
			user.show_message("<span class='warning'>Now attempting to reset internal memory, please hold.</span>", SHOWMSG_ALWAYS)
			src.l_hacking = 1
			if (!user.is_busy(src) && I.use_tool(src, usr, 100, volume = 50))
				if (prob(40))
					src.l_setshort = 1
					src.l_set = 0
					src.code = ""
					user.show_message("<span class='warning'>Internal memory reset.  Please give it a few seconds to reinitialize.</span>", SHOWMSG_ALWAYS)
					sleep(80)
					src.l_setshort = 0
					src.l_hacking = 0
				else
					user.show_message("<span class='warning'>Unable to reset internal memory.</span>", SHOWMSG_ALWAYS)
					src.l_hacking = 0
			else	src.l_hacking = 0
			return
		//At this point you have exhausted all the special things to do when locked
		// ... but it's still locked.
		return

	return ..()

/obj/item/weapon/storage/secure/emag_act(mob/user)
	if(!locked || src.emagged)
		return FALSE
	emagged = 1
	user.SetNextMove(CLICK_CD_MELEE)
	add_overlay(image('icons/obj/storage.dmi', icon_sparking))
	sleep(6)
	cut_overlays()
	add_overlay(image('icons/obj/storage.dmi', icon_locking))
	locked = 0
	to_chat(user, "You short out the lock on [src].")
	return TRUE

/obj/item/weapon/storage/secure/MouseDrop(over_object, src_location, over_location)
	if (locked)
		add_fingerprint(usr)
		return
	..()


/obj/item/weapon/storage/secure/attack_self(mob/user)
	tgui_interact(user)

/obj/item/weapon/storage/secure/tgui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SecureSafe", name)
		ui.open()

/obj/item/weapon/storage/secure/tgui_data(mob/user)
	var/list/data = list()
	data["locked"] = locked
	data["code"] = code
	data["emagged"] = emagged
	data["l_setshort"] = l_setshort
	data["l_set"] = l_set
	return data

/obj/item/weapon/storage/secure/tgui_act(action, params)
	if(..())
		return TRUE
	switch (action)
		if("type")
			var/digit = params["digit"]
			if(digit == "E")
				if ((l_set == 0) && (length(code) == 5) && (!l_setshort) && (code != "ERROR"))
					l_code = code
					l_set = 1
				else if ((code == l_code) && (emagged == 0) && (l_set == 1))
					locked = 0
					overlays = null
					overlays += image('icons/obj/storage.dmi', icon_opened)
					code = null
				else
					code = "ERROR"
			else
				if ((digit == "R") && (emagged == 0) && (!l_setshort))
					locked = 1
					overlays = null
					code = null
					close(usr)
				else
					code += text("[]", digit)
					if (length(code) > 5)
						code = "ERROR"
	add_fingerprint(usr)
	return TRUE


// -----------------------------
//        Secure Briefcase
// -----------------------------
/obj/item/weapon/storage/secure/briefcase
	name = "secure briefcase"
	icon = 'icons/obj/storage.dmi'
	icon_state = "secure"
	item_state = "secure-r"
	desc = "A large briefcase with a digital locking system."
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = ITEM_SIZE_LARGE

/obj/item/weapon/storage/secure/briefcase/atom_init()
	. = ..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/storage/secure/briefcase/attack_hand(mob/user)
	if ((src.loc == user) && (src.locked == 1))
		to_chat(usr, "<span class='warning'>[src] is locked and cannot be opened!</span>")
	else if ((src.loc == user) && (!src.locked))
		open(usr)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				close(M)
	add_fingerprint(user)

/obj/item/weapon/storage/secure/briefcase/attackby(obj/item/I, mob/user, params)
	. = ..()
	update_icon()

/obj/item/weapon/storage/secure/briefcase/update_icon()
	if(!locked || emagged)
		item_state = "secure-g"
	else
		item_state = "secure-r"

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_l_hand()
		M.update_inv_r_hand()

//Syndie variant of Secure Briefcase. Contains space cash, slightly more robust.
/obj/item/weapon/storage/secure/briefcase/syndie
	force = 15.0

/obj/item/weapon/storage/secure/briefcase/syndie/atom_init()
	for (var/i in 1 to 4)
		new /obj/item/weapon/spacecash/c1000(src)
	. = ..()


// -----------------------------
//        Secure Safe
// -----------------------------

/obj/item/weapon/storage/secure/safe
	name = "secure safe"
	icon = 'icons/obj/storage.dmi'
	icon_state = "safe"
	icon_opened = "safe0"
	icon_locking = "safeb"
	icon_sparking = "safespark"
	force = 8.0
	w_class = 8.0
	max_w_class = 8
	anchored = TRUE
	density = FALSE
	cant_hold = list(/obj/item/weapon/storage/secure/briefcase)

/obj/item/weapon/storage/secure/safe/atom_init()
	. = ..()
	new /obj/item/weapon/paper(src)
	new /obj/item/weapon/pen(src)

/obj/item/weapon/storage/secure/safe/attack_hand(mob/user)
	tgui_interact(user)

//obj/item/weapon/storage/secure/safe/HoS/atom_init()
//	. = ..()
	//new /obj/item/weapon/storage/lockbox/clusterbang(src) This item is currently broken... and probably shouldnt exist to begin with (even though it's cool)
