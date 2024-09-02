/datum/role/thief
	name = THIEF
	id = THIEF
	logo_state = "thief"

/datum/role/thief/forgeObjectives()
	. = ..()
	if(!.)
		return

	AppendObjective(/datum/objective/steal, TRUE)
	AppendObjective(/datum/objective/escape)
