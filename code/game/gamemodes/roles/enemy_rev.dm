/datum/role/enemy_rev
	name = "Enemy of Revolution"
	id = ENEMY_REV

	logo_state = "enemy_revs-logo"
	antag_hud_type = ANTAG_HUD_ENEMY_REV
	antag_hud_name = "enemy_rev"

	restricted_jobs = list("AI", "Cyborg")

/datum/role/enemy_rev/CanBeAssigned(datum/mind/M)
	for(var/role in list(REV, HEADREV))
		var/datum/role/R = M.GetRole(role)
		if(R)
			return FALSE
	return ..()

/datum/role/enemy_rev/forgeObjectives()
	. = ..()
	var/datum/objective/survive/survive_obj = AppendObjective(/datum/objective/survive)
	if(survive_obj)
		survive_obj.explanation_text = "The station has been overrun by revolutionaries, stay alive until the end."

