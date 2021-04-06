/datum/faction/shadowlings
	name = SHADOWLINGS
	ID = SHADOWLINGS
	logo_state = "shadowling-logo"

	required_pref = ROLE_SHADOWLING

	initial_role = SHADOWLING
	initroletype = /datum/role/shadowling

	late_role = SHADOW_THRALL
	roletype = /datum/role/thrall

	min_roles = 2
	max_roles = 2

	var/shadowling_ascended = FALSE

/datum/faction/shadowlings/forgeObjectives()
	if(!..())
		return FALSE
	AppendObjective(/datum/objective/enthrall)
	return TRUE

/datum/faction/shadowlings/HandleRecruitedMind(datum/mind/M, override = FALSE)
	var/datum/role/R = ..()
	if(!R)
		return null

	R.OnPostSetup() // for huds

	return R
