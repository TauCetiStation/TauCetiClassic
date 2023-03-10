/datum/objective/stay_loyal
	explanation_text = "Stay loyal"

/datum/objective/stay_loyal/check_completion()
	var/datum/faction/loyalists/L = faction
	if(istype(L) && L.check_loyality_members())
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
