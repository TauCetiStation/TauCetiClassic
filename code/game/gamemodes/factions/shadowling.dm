/datum/faction/shadowlings
	name = SHADOWLINGS
	ID = SHADOWLINGS
	logo_state = "shadowling-logo"

	required_pref = SHADOW

	initial_role = SHADOWLING
	initroletype = /datum/role/shadowling

	late_role = SHADOW_THRALL
	roletype = /datum/role/thrall

	min_roles = 2
	max_roles = 2

	var/shadowling_ascended = FALSE

/datum/faction/shadowlings/forgeObjectives()
	AppendObjective(/datum/objective/enthrall)
