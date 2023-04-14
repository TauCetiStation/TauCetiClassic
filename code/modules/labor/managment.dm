/obj/item/weapon/card/id/labor
	name = "prisoner card"
	desc = "A card used to provide ID and labor accounting."
	icon_state = "labor"
	//TODO: add item_state
	rank = "Prisoner"
	assignment = "Prisoner"
	var/labor_sentence = 0
	var/labor_credits = 0

/********** Labor managment computer**********/
/obj/machinery/computer/labor
	name = "Labor Management Computer"
	desc = "Used to issue prisoners id cards and manage labor production priorities."
	icon = 'icons/obj/computer.dmi'
	icon_state = "explosive"
	state_broken_preset = "securityb"
	state_nopower_preset = "security0"
	light_color = "#a91515"
	req_access = list(access_security)
	circuit = /obj/item/weapon/circuitboard/labor
	required_skills = list(/datum/skill/police = SKILL_LEVEL_TRAINED)
	var/obj/item/weapon/card/id/scan		//card that gives access to this console
	var/obj/item/weapon/card/id/labor/modify	//the card we will change

/obj/machinery/computer/labor/atom_init(mapload, obj/item/weapon/circuitboard/C)
	. = ..()
	if(!global.labor_rates.len)
		for(var/T in subtypesof(/datum/labor))
			var/datum/labor/L = new T()
			global.labor_rates[L.nametag] = L

/obj/machinery/computer/labor/attackby(obj/item/weapon/card/id/id_card, mob/user)
	if(!istype(id_card))
		return ..()

	if(!modify && istype(id_card, /obj/item/weapon/card/id/labor))
		if(user.drop_from_inventory(id_card, src))
			modify = id_card
		else
			return ..()
	else if(!scan && user.drop_from_inventory(id_card, src))
		scan = id_card
	else
		return ..()

	playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	SStgui.update_uis(src)
	attack_hand(user)

/obj/machinery/computer/labor/proc/is_authenticated()
	return scan ? check_access(scan) : 0

/obj/machinery/computer/labor/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/computer/labor/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LaborManagment", name)
		ui.open()

/obj/machinery/computer/labor/tgui_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = ..()

	data["scan_name"] = scan ? scan.name : FALSE
	data["target_name"] = modify ? modify.name : FALSE
	data["target_owner"] = modify && modify.registered_name ? modify.registered_name : FALSE
	data["authenticated"] = is_authenticated()

	data["labor_sentence"] = modify ? modify.labor_sentence : FALSE
	data["labor_credits"] = modify ? modify.labor_credits : FALSE

	return data

/obj/machinery/computer/labor/tgui_static_data(mob/user)
	var/list/static_data = list()

	return static_data

/obj/machinery/computer/labor/tgui_act(action, list/params)
	if(..())
		return TRUE
	. = TRUE
	add_fingerprint(usr)

	switch(action)
		if("scan")
			if(scan)
				if(ishuman(usr))
					scan.forceMove(get_turf(usr))
					usr.put_in_hands(scan)
					scan = null
				else
					scan.forceMove(get_turf(src))
					scan = null
				playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/weapon/card/id))
					if(usr.drop_from_inventory(I, src))
						scan = I
						playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			return
		if("target")
			if(modify)
				if(ishuman(usr))
					modify.forceMove(get_turf(usr))
					usr.put_in_hands(modify)
					modify = null
				else
					modify.forceMove(get_turf(src))
					modify = null
				playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/weapon/card/id/labor))
					if(usr.drop_from_inventory(I, src))
						modify = I
						playsound(src, 'sound/machines/terminal_insert.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			return

	if(!scan || !is_authenticated())
		return // everything below here requires card auth

	switch(action)
		if("set_name")
			var/nam = sanitize(input("Prisoner's name", "Name", modify.registered_name) as text | null)
			if(nam)
				modify.registered_name = nam
				modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
			else
				to_chat(usr, "<span class='warning'>Invalid name.</span>")
		if("set_sentence")
			var/cr = input("Amount of credits prisoner must work out to be released.", "Sentence", modify.labor_sentence) as num | null
			if(cr && cr > 0)
				modify.labor_sentence = cr
			else
				to_chat(usr, "<span class='warning'>Invalid amount of credits.</span>")
		if("set_credits")
			var/cr = input("Amount of credits prisoner already has on his balance.", "Balance", modify.labor_credits) as num | null
			if(cr != null && cr >= 0)
				modify.labor_credits = cr
			else
				to_chat(usr, "<span class='warning'>Invalid amount of credits.</span>")

	if(last_keyboard_sound <= world.time)
		if(iscarbon(usr))
			playsound(src, pick(SOUNDIN_KEYBOARD), VOL_EFFECTS_MASTER, null, FALSE)
			last_keyboard_sound = world.time + 8
