/datum/objective/turn_into_zombie
	explanation_text = "Превратите большую часть людей на станции в зомби."

/datum/objective/turn_into_zombie/check_completion()
	if(!faction)
		return OBJECTIVE_LOSS
	if(!faction.members.len)
		return OBJECTIVE_LOSS
	if(length(faction.members) / faction.check_crew() >= 0.6)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
