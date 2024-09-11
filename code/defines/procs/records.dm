/proc/CreateGeneralRecord()
	var/datum/data/record/G = new /datum/data/record()
	G.fields["name"] = "New Record"
	G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7)), 6))
	G.fields["rank"] = "Unassigned"
	G.fields["real_rank"] = "Unassigned"
	G.fields["sex"] = "Male"
	G.fields["age"] = "Unknown"
	G.fields["fingerprint"] = "Unknown"
	G.fields["insurance_account_number"] = "Unknown"
	G.fields["insurance_type"] = "Unknown"
	G.fields["p_stat"] = "Active"
	G.fields["m_stat"] = "Stable"
	G.fields["species"] = HUMAN
	G.fields["home_system"]	= "Unknown"
	G.fields["citizenship"]	= "Unknown"
	G.fields["faction"]		= "Unknown"
	G.fields["religion"]	= "Unknown"
	G.fields["photo_f"] = new /icon()
	G.fields["photo_s"] = new /icon()
	PDA_Manifest.Cut()
	data_core.general += G
	return G

/proc/CreateSecurityRecord(name, id)
	var/datum/data/record/R = new /datum/data/record()
	R.fields["name"] = name
	R.fields["id"] = id
	R.name = text("Security Record #[id]")
	R.fields["criminal"] = "None"
	R.fields["mi_crim"] = "None"
	R.fields["mi_crim_d"] = "No minor crime convictions."
	R.fields["ma_crim"] = "None"
	R.fields["ma_crim_d"] = "No major crime convictions."
	R.fields["notes"] = "No notes."
	data_core.security += R
	return R

/proc/get_id_photo(mob/living/carbon/human/H, client/C, show_directions = list(SOUTH))
	var/datum/job/J = SSjob.GetJob(H.mind.assigned_role)
	if(!C)
		C = H.client
	var/datum/preferences/P = C?.prefs
	return get_flat_human_icon(null, J, P, DUMMY_HUMAN_SLOT_MANIFEST, show_directions)

/proc/find_general_record(field, value)
	return find_record(field, value, data_core.general)

/proc/find_medical_record(field, value)
	return find_record(field, value, data_core.medical)

/proc/find_security_record(field, value)
	return find_record(field, value, data_core.security)

/proc/find_record(field, value, list/L)
	for(var/datum/data/record/R in L)
		if(R.fields[field] == value)
			return R

//This proc returns the record ID
/proc/find_record_by_name(mob/user, target_name)
	var/list/possible_records = list()
	var/record_name = null
	for(var/datum/data/record/E in data_core.general)
		if(E.fields["name"] == target_name)
			record_name = "[E.fields["name"]] ([E.fields["rank"]]) ID=[E.fields["id"]]"
			possible_records[record_name] = E.fields["id"]
	if(!possible_records.len)
		return null
	if(possible_records.len > 1)
		var/choice = input(user, "В базе данных найдено несколько человек с таким именем.", "Сделайте выбор", null) in possible_records
		if(!choice)
			return null
		return possible_records[choice]
	else
		return possible_records[record_name]

/proc/add_record(user, datum/data/record/R, message, name = "Unknown")
	var/counter = 1
	while(R.fields[text("com_[]", counter)])
		counter++
	if(user)
		if(ishuman(user))
			var/mob/living/carbon/human/U = user
			name = "[U.get_authentification_name()] ([U.get_assignment()])"
		if(isrobot(user))
			var/mob/living/silicon/robot/U = user
			name = "[U.name] ([U.modtype] [U.braintype])"
		if(isAI(user))
			var/mob/living/silicon/ai/U = user
			name = "[U.name]"
		if(istype(user, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/U = user
			name = "[U.registered_name] ([U.assignment])"
	R.fields[text("com_[counter]")] = text("<b>Made by [name] on [worldtime2text()], [time2text(world.realtime, "DD/MM")]/[game_year]:</b> <BR>[message]")

/* The function changes the criminal status in the database. Used by securityHUD or machinery
 * Arguments:
 * * author - Who changed the criminal status? We need a name.
 * * target_name - Only the target name is given, the database will be searched by name
 * * security_record - Target already found in the database
 * * used_by_computer - If this function is used in a machinery, set TRUE. Needed for additional checks
 * * source - If this function is used in a machinery, pass the src
*/
/proc/change_criminal_status(mob/user, author, target_name, security_record = null, used_by_computer = FALSE, source)
	var/datum/data/record/S = security_record
	if(S)
		target_name = S.fields["name"]
	else
		var/record_id = find_record_by_name(user, target_name)
		if(!record_id)
			to_chat(user, "<span class='warning'>Человек с таким именем не найден в базе данных.</span>")
			return
		S = find_security_record("id", record_id)
	if(!S)
		to_chat(user, "<span class='warning'>Человек с таким именем не найден в базе данных службы безопасности.</span>")
		return
	var/criminal_status = input(user, "Укажите новый уголовный статус для этого человека.", "Уголовный статус", S.fields["criminal"]) in list("None", "*Arrest*", "Incarcerated", "Paroled", "Released", "Cancel")
	if(criminal_status == "Cancel")
		return
	if(criminal_status == S.fields["criminal"]) //if nothing has changed
		return
	var/reason = sanitize(input(user, "Укажите причину:", "Причина", "не указана")  as message)
	if(used_by_computer)
		if(user.incapacitated() || !(user.Adjacent(source) && isliving(user)))
			return
	S.fields["criminal"] = criminal_status
	add_record(author, S, "Уголовный статус статус был изменен на <b>[criminal_status]</b><BR><b>Причина:</b> [reason]")
	for(var/mob/living/carbon/human/H in global.human_list)
		if(H.real_name == target_name)
			H.sec_hud_set_security_status()

