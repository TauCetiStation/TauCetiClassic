/datum/faction/shadowlings
	name = F_SHADOWLINGS
	ID = F_SHADOWLINGS
	logo_state = "shadowling-logo"
	required_pref = ROLE_SHADOWLING

	initroletype = /datum/role/shadowling
	roletype = /datum/role/thrall

	min_roles = 2
	max_roles = 2

	var/shadowling_ascended = FALSE

/datum/faction/shadowlings/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/enthrall)
	return TRUE

/datum/faction/shadowlings/HandleRecruitedMind(datum/mind/M, laterole)
	var/datum/role/R = ..()
	if(!R)
		return null

	R.OnPostSetup() // for huds

	return R
	

/datum/faction/shadowlings/proc/check_crew()
	var/total_human = 0
	for(var/mob/living/carbon/human/H as anything in human_list)
		var/turf/human_loc = get_turf(H)
		if(!human_loc || !is_station_level(human_loc.z))
			continue
		if(H.stat == DEAD)
			continue
		if(!H.mind || !H.client)
			continue
		total_human++
	return total_human
