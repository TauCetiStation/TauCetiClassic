#define VALUE_NAME "name"
#define VALUE_SENTENCE "sentence"
#define VALUE_BALANCE "balance"
#define VALUE_REASON "reason"
/obj/item/weapon/card/id/labor
	name = "prisoner card"
	desc = "A card used to provide ID and labor accounting."
	icon_state = "labor"
	item_state = "orange-id"
	item_state_world = "labor_world"
	rank = "Prisoner"
	assignment = "Prisoner"
	var/broken_laws
	var/details
	var/permanent = FALSE
	var/labor_sentence = 0
	var/labor_credits = 0
	var/responsible_officer
	var/datum/data/record/security_data = null

/********** Labor managment computer**********/
/obj/machinery/computer/labor
	name = "Labor Management Computer"
	desc = "Used to issue prisoners id cards and manage labor production priorities."
	icon = 'icons/obj/computer.dmi'
	icon_state = "security"
	state_broken_preset = "securityb"
	state_nopower_preset = "security0"
	light_color = "#a91515"
	req_access = list(access_security)
	circuit = /obj/item/weapon/circuitboard/labor
	required_skills = list(/datum/skill/police = SKILL_LEVEL_TRAINED)
	var/obj/item/weapon/card/id/scan		//card that gives access to this console
	var/obj/item/weapon/card/id/labor/modify	//the card we will change
	var/obj/item/device/radio/intercom/radio // for /s announce
	var/list/modified_values = list()

/obj/machinery/computer/labor/atom_init(mapload, obj/item/weapon/circuitboard/C)
	. = ..()
	radio = new (src)

/obj/machinery/computer/labor/Destroy()
	QDEL_NULL(radio)
	return ..()

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

	data["reason"] = modify ? modify.broken_laws : FALSE
	data["details"] = modify ? modify.details : FALSE
	data["permanent"] = modify ? modify.permanent : FALSE
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
					usr.put_in_hands(scan)
				else
					scan.forceMove(get_turf(src))
				update_records()
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
					usr.put_in_hands(modify)
				else
					modify.forceMove(get_turf(src))
				update_records()
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
			var/nam = sanitize(input("Prisoner's name", "Labor Management Computer", modify.registered_name) as text | null, MAX_NAME_LEN)
			if(nam)
				modified_values[VALUE_NAME] = TRUE
				modify.registered_name = nam
				modify.name = text("[modify.registered_name]'s ID Card ([modify.assignment])")
				var/record_id = find_record_by_name(usr, nam)
				modify.security_data = find_security_record("id", record_id)
				if(!modify.security_data)
					tgui_alert(usr, "Unable to find security records for this name.")
			else
				to_chat(usr, "<span class='warning'>Invalid name.</span>")
		if("set_reason")
			var/laws = sanitize(input("Broken space law articles", "Labor Management Computer", modify.broken_laws) as text | null, MAX_NAME_LEN)
			if(laws)
				modified_values[VALUE_REASON] = TRUE
				modify.broken_laws = laws
			else
				to_chat(usr, "<span class='warning'>Invalid name.</span>")
		if("set_details")
			var/det = sanitize(input(usr, "Crime details", "Labor Management Computer", modify.details), MAX_LNAME_LEN)
			modify.details = det
		if("set_sentence")
			var/cr = input("Amount of credits prisoner must work out to be released.", "Labor Management Computer", modify.labor_sentence) as num | null
			if(cr && cr > 0)
				modified_values[VALUE_SENTENCE] = TRUE
				modify.labor_sentence = cr
			else
				to_chat(usr, "<span class='warning'>Invalid amount of credits.</span>")
		if("permanent")
			modify.permanent = !modify.permanent
			modified_values[VALUE_SENTENCE] = modify.permanent || modified_values[VALUE_SENTENCE]
			modify.labor_sentence = 0
		if("set_credits")
			var/cr = input("Amount of credits prisoner already has on his balance.", "Labor Management Computer", modify.labor_credits) as num | null
			if(cr != null && cr >= 0)
				modified_values[VALUE_BALANCE] = TRUE
				modify.labor_credits = cr
			else
				to_chat(usr, "<span class='warning'>Invalid amount of credits.</span>")

	if(last_keyboard_sound <= world.time)
		if(iscarbon(usr))
			playsound(src, pick(SOUNDIN_KEYBOARD), VOL_EFFECTS_MASTER, null, FALSE)
			last_keyboard_sound = world.time + 8

/obj/machinery/computer/labor/proc/update_records()
	if(!modify || !scan)
		return

	if(modified_values[VALUE_NAME] || modified_values[VALUE_REASON] || modified_values[VALUE_SENTENCE])//so it doesn't make an officer responsible for just changing the prisoner's balance
		modify.responsible_officer = scan.registered_name

	if(modify.security_data)
		var/rec
		if(modified_values[VALUE_NAME] || modified_values[VALUE_REASON])
			modify.security_data.fields["criminal"] = "Incarcerated"
			for(var/mob/living/carbon/human/H in global.human_list)
				if(H.real_name == modify.registered_name)
					H.sec_hud_set_security_status()
			rec = "Уголовный статус статус был изменен на <b>Incarcerated</b>.<br>\
					<b>Статья:</b> [modify.broken_laws].<br>\
					<b>Подробности:</b> [modify.details].<br>\
					Направлен на принудительные работы"
			rec += modify.permanent ? " для отбывания пожизненного срока." : ". Сумма отработки: [modify.labor_sentence] кредитов."
			add_record(scan, modify.security_data, rec)
			radio.autosay("[scan.registered_name] направил [modify.registered_name] на принудительные работы. Статья: [modify.broken_laws].", "Security system", freq = radiochannels["Security"])
		else //if the sentence is not new and someone just changed labor amount or balance
			if(modified_values[VALUE_SENTENCE])
				if(modify.permanent)
					rec = "Приговор к принудительным работам был заменён на пожизненный."
				else
					rec = "Приговор к принудительным работам был изменён. Новая сумма отработки: [modify.labor_sentence] кредитов."
				add_record(scan, modify.security_data, rec)
			if(modified_values[VALUE_BALANCE])
				rec = "Кредитный баланс заключённого был изменён. Новый значение баланса: [modify.labor_credits] кредитов."
				add_record(scan, modify.security_data, rec)
	else if(modified_values[VALUE_NAME] || modified_values[VALUE_REASON]) //unable to find records, just announce new sentence
		radio.autosay("[scan.registered_name] направил [modify.registered_name] на принудительные работы. Статья: [modify.broken_laws].", "Security system", freq = radiochannels["Security"])

	for(var/I in modified_values)
		modified_values[I] = FALSE

#undef VALUE_NAME
#undef VALUE_SENTENCE
#undef VALUE_BALANCE
#undef VALUE_REASON
