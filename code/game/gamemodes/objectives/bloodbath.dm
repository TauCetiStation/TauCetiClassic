/datum/objective/bloodbath
	explanation_text = "Убей их всех."

/datum/objective/reproduct/check_completion()
	var/datum/faction/alien/a = faction
	if(istype(a))
		if(a.check_crew() == 0)
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
