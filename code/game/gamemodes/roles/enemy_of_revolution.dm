/datum/role/enemy_of_revolution
	name = ENEMY_REV
	id = ENEMY_REV

	restricted_jobs = list("AI", "Cyborg")

/datum/role/enemy_of_revolution/CanBeAssigned()
	for(var/role in list(REV, HEADREV, HEADREV_FLASH))
		var/datum/role/R = antag.GetRole(role)
		if(R)
			return FALSE
	return ..()

/datum/role/enemy_of_revolution/forgeObjectives()
	. = ..()
	var/datum/objective/survive/survive_obj = AppendObjective(/datum/objective/survive)
	if(survive_obj)
		survive_obj.explanation_text = "The station has been overrun by revolutionaries, stay alive until the end"

