/datum/faction/shadowlings
	name = SHADOWLINGS
	ID = SHADOWLINGS
	logo_state = "shadowling-logo"

	required_pref = ROLE_SHADOWLING

	initial_role = SHADOWLING
	initroletype = /datum/role/shadowling

	late_role = SHADOW_THRALL
	roletype = /datum/role/thrall

	max_roles = 2

	var/shadowling_ascended = FALSE

/datum/faction/shadowlings/forgeObjectives()
	AppendObjective(/datum/objective/enthrall)
