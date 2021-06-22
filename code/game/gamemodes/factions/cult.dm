/datum/faction/cult
	name = F_BLOODCULT
	ID = F_BLOODCULT
	logo_state = "cult-logo"
	required_pref = ROLE_CULTIST

	initroletype = /datum/role/cultist

	min_roles = 3
	max_roles = 3

	// For objectives
	var/datum/mind/sacrifice_target = null
	var/list/sacrificed = list()

	var/datum/religion/cult/religion

	var/check_leader_time

/datum/faction/cult/can_setup(num_players)
	if(!..())
		return FALSE
	religion = create_religion(/datum/religion/cult)
	religion.mode = src
	return TRUE

/datum/faction/cult/get_initrole_type()
	if(get_active_leads() == 0)
		return /datum/role/cultist/leader
	return ..()

/datum/faction/cult/HandleRecruitedMind(datum/mind/M, override)
	. = ..()
	if(.)
		M.current.Paralyse(5)

/datum/faction/cult/forgeObjectives()
	if(!..())
		return FALSE

	var/list/possibles_objectives = subtypesof(/datum/objective/cult)
	for(var/i in 1 to rand(2, 3))
		AppendObjective(pick_n_take(possibles_objectives))
	return TRUE

/datum/faction/cult/AdminPanelEntry()
	. = ..()
	if(global.cult_religion.captured_areas)
		var/list/zones_name = list()
		for(var/area/A in global.cult_religion.captured_areas)
			zones_name += "[A.name]"

		. += "<br>Подконтрольные зоны культа([zones_name.len]): [get_english_list(zones_name)]"

#define CHECK_LEADER_CD 50
/datum/faction/cult/process()
	if(check_leader_time < world.time)
		check_leader_time = world.time + CHECK_LEADER_CD

		if(get_active_leads() == 0)
			log_mode("There are zero active leaders of cult, trying to add some..")
			var/added_lead = FALSE
			for(var/mob/living/carbon/human/H in religion.members)
				if(H.stat != DEAD && H.client?.inactivity <= 20 MINUTES && H.mind?.holy_role != CULT_ROLE_MASTER)
					var/datum/role/R = H.mind.GetRole(CULTIST)
					R.Drop(H.mind)
					R = HandleNewMind(H.mind)
					R.OnPostSetup(TRUE)

					to_chat(H, "<span class='warning'>Вы теперь новый лидер культа.</span>")
					added_lead = TRUE
					break

			if(added_lead)
				log_mode("Managed to add new leaders of cult.")
				message_admins("Managed to add new leaders of cult.")
			else
				log_mode("Unable to add new leaders of cult.")
				message_admins("Unable to add new leaders of cult.")
				check_leader_time = world.time + 10 MINUTE
#undef CHECK_LEADER_CD

/datum/faction/cult/GetScoreboard()
	var/dat = ..()
	var/acolytes_out = get_cultists_out()
	var/text = "<b>Культистов улетело:</b> [acolytes_out]"
	feedback_set("round_end_result", acolytes_out)

	text += "<br><b>Аспекты([religion.aspects.len]):</b>"
	if(!religion.aspects.len)
		text += "<br>Ниодного аспекта не было выбрано"
	else
		for(var/name in religion.aspects)
			var/datum/aspect/A = religion.aspects[name]
			text += "<br><font color='[A.color]'>[name]</font> - с силой [A.power]"

	text += "<br><br><b>Ритуалы:</b>"
	if(!religion.ritename_by_count.len)
		text += "<br>Ниодного ритуала не было выбрано"
	else
		for(var/name in religion.ritename_by_count)
			var/count = religion.ritename_by_count[name]
			text += "<br><i>[name]</i> - использован [count] [pluralize_russian(count, "раз", "раза", "раз")]"

	dat += text

	return dat

/datum/faction/cult/get_scorestat()
	var/dat = ""

	dat += {"<B><U>CULT STATS</U></B><BR>
	<B>Всего членов Культа:</B> [religion.members.len]<BR>
	<B>Захвачено зон:</B> [religion.captured_areas.len - religion.area_types.len]<BR>
	<B>Накоплено Favor/Piety:</B> [religion.favor]/[religion.piety]<BR>
	<B>Рун на станции:</B> [religion.runes.len]<BR>
	<B>Аномалий уничтожено:</B> [score["destranomaly"]]<BR>
	<HR>"}

	return dat

/datum/faction/cult/proc/get_active_leads()
	var/active_leads = 0
	for(var/datum/role/cultist/leader/R in members)
		var/mob/M = R?.antag?.current
		if(M && M.client && M.client.inactivity <= 20 MINUTES) // 20 minutes inactivity are OK
			active_leads++
	return active_leads

/datum/faction/cult/proc/is_convertable_to_cult(datum/mind/mind)
	if(!istype(mind))
		return FALSE
	if(ishuman(mind.current))
		if((mind.assigned_role in list("Captain", "Chaplain")))
			return FALSE
		if(mind.current.get_species() == GOLEM)
			return FALSE
	if(ismindshielded(mind.current))
		return FALSE
	return TRUE

/datum/faction/cult/proc/get_cultists_out()
	var/acolytes_out = 0
	for(var/datum/role/R in members)
		if(R.antag?.current?.stat != DEAD)
			var/area/A = get_area(R.antag.current)
			if(is_type_in_typecache(A, centcom_areas_typecache))
				acolytes_out++

	return acolytes_out

/datum/faction/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in player_list)
		if(!religion?.can_convert(player))
			ucs += player.mind
	return ucs

/datum/faction/cult/proc/find_sacrifice_target()
	var/list/possible_targets = get_unconvertables()

	if(possible_targets.len)
		sacrifice_target = pick(possible_targets)
