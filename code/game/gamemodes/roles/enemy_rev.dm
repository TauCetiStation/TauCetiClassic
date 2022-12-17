/datum/role/enemy_rev
	name = "Enemy of Revolution"
	id = ENEMY_REV
	antag_hud_name = "enemy_rev"
	restricted_jobs = list("AI", "Cyborg")

/datum/role/enemy_rev/CanBeAssigned()
	. = ..()
	for(var/role in list(REV, HEADREV))
		var/datum/role/R = antag.GetRole(role)
		if(R)
			return FALSE

/datum/role/enemy_rev/forgeObjectives()
	. = ..()
	var/datum/objective/survive/survive_obj = AppendObjective(/datum/objective/survive)
	if(survive_obj)
		survive_obj.explanation_text = "The station has been overrun by revolutionaries, stay alive until the end."

