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
