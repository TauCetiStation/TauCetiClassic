/datum/data
	var/name = "data"
	var/size = 1.0

/datum/data/function
	name = "function"
	size = 2.0

/datum/data/function/data_control
	name = "data control"

/datum/data/function/id_changer
	name = "id changer"

/datum/data/record
	name = "record"
	size = 5.0
	var/list/fields = list(  )

/datum/data/text
	name = "text"
	var/data = null

/obj/effect/datacore/proc/manifest()
	set waitfor = FALSE
	for(var/mob/living/carbon/human/H in player_list)
		manifest_inject(H)

		CHECK_TICK

/obj/effect/datacore/proc/manifest_modify(name, assignment)
	if(PDA_Manifest.len)
		PDA_Manifest.Cut()
	var/datum/data/record/foundrecord
	var/real_title = assignment

	for(var/datum/data/record/t in data_core.general)
		if (t)
			if(t.fields["name"] == name)
				foundrecord = t
				break

	var/list/all_jobs = get_job_datums()

	for(var/datum/job/J in all_jobs)
		var/list/alttitles = get_alternate_titles(J.title)
		if(!J)	continue
		if(assignment in alttitles)
			real_title = J.title
			break

	if(foundrecord)
		foundrecord.fields["rank"] = assignment
		foundrecord.fields["real_rank"] = real_title

/obj/effect/datacore/proc/manifest_inject(mob/living/carbon/human/H)
	if(PDA_Manifest.len)
		PDA_Manifest.Cut()

	if(H.mind && (H.mind.assigned_role != "MODE"))
		var/assignment
		if(H.mind.role_alt_title)
			assignment = H.mind.role_alt_title
		else if(H.mind.assigned_role)
			assignment = H.mind.assigned_role
		else if(H.job)
			assignment = H.job
		else
			assignment = "Unassigned"

		var/static/record_id_num = 1001
		var/id = num2hex(record_id_num++, 6)

		//General Record
		//Creating photo
		var/icon/ticon = get_id_photo(H, cardinal)
		var/icon/photo_front = new(ticon, dir = SOUTH)
		var/icon/photo_side = new(ticon, dir = WEST)
		var/datum/data/record/G = new()
		G.fields["id"]			= id
		G.fields["name"]		= H.real_name
		G.fields["real_rank"]	= H.mind.assigned_role
		G.fields["rank"]		= assignment
		G.fields["age"]			= H.age
		G.fields["fingerprint"]	= md5(H.dna.uni_identity)
		G.fields["p_stat"]		= "Active"
		G.fields["m_stat"]		= "Stable"
		G.fields["sex"]			= H.gender
		G.fields["species"]		= H.get_species()
		G.fields["home_system"]	= H.home_system
		G.fields["citizenship"]	= H.citizenship
		G.fields["faction"]		= H.personal_faction
		G.fields["religion"]	= H.religion
		G.fields["photo_f"]		= photo_front
		G.fields["photo_s"]		= photo_side
		if(H.gen_record && !jobban_isbanned(H, "Records"))
			G.fields["notes"] = H.gen_record
		else
			G.fields["notes"] = "No notes found."
		if(H.mind.initial_account)
			G.fields["acc_number"]	= H.mind.initial_account.account_number
			G.fields["acc_datum"] = H.mind.initial_account
		else
			G.fields["acc_number"]	= 0
			G.fields["acc_datum"] =	0
		general += G

		//Medical Record
		var/datum/data/record/M = new()
		M.fields["id"]			= id
		M.fields["name"]		= H.real_name
		M.fields["b_type"]		= H.b_type
		M.fields["b_dna"]		= H.dna.unique_enzymes
		M.fields["mi_dis"]		= "None"
		M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
		M.fields["ma_dis"]		= "None"
		M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
		M.fields["alg"]			= "None"
		M.fields["alg_d"]		= "No allergies have been detected in this patient."
		M.fields["cdi"]			= "None"
		M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
		if(H.med_record && !jobban_isbanned(H, "Records"))
			M.fields["notes"] = H.med_record
		else
			M.fields["notes"] = "No notes found."
		medical += M

		//Security Record
		var/datum/data/record/S = new()
		S.fields["id"]			= id
		S.fields["name"]		= H.real_name
		S.fields["criminal"]	= "None"
		S.fields["mi_crim"]		= "None"
		S.fields["mi_crim_d"]	= "No minor crime convictions."
		S.fields["ma_crim"]		= "None"
		S.fields["ma_crim_d"]	= "No major crime convictions."
		S.fields["notes"]		= "No notes."
		if(H.sec_record && !jobban_isbanned(H, "Records"))
			S.fields["notes"] = H.sec_record
		else
			S.fields["notes"] = "No notes."
		security += S

		//Locked Record
		var/datum/data/record/L = new()
		L.fields["id"]			= md5("[H.real_name][H.mind.assigned_role]")
		L.fields["name"]		= H.real_name
		L.fields["rank"] 		= H.mind.assigned_role
		L.fields["age"]			= H.age
		L.fields["sex"]			= H.gender
		L.fields["b_type"]		= H.b_type
		L.fields["b_dna"]		= H.dna.unique_enzymes
		L.fields["enzymes"]		= H.dna.SE // Used in respawning
		L.fields["home_system"]	= H.home_system
		L.fields["citizenship"]	= H.citizenship
		L.fields["faction"]		= H.personal_faction
		L.fields["religion"]	= H.religion
		L.fields["identity"]	= H.dna.UI
		L.fields["image"]		= ticon
		locked += L

		score["crew_total"]++
	return

/proc/get_id_photo(mob/living/carbon/human/H, show_directions = list(SOUTH))
	var/datum/job/J = SSjob.GetJob(H.mind.assigned_role)
	var/datum/preferences/P = H.client.prefs
	return get_flat_human_icon(null, J, P, show_directions)

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
	if(!possible_records)
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
		if(user.incapacitated() || (!in_range(source, user) && !issilicon(user) && !isobserver(user)))
			return
	S.fields["criminal"] = criminal_status
	add_record(author, S, "Уголовный статус статус был изменен на <b>[criminal_status]</b><BR><b>Причина:</b> [reason]")
	for(var/mob/living/carbon/human/H in global.human_list)
		if(H.real_name == target_name)
			H.sec_hud_set_security_status()

