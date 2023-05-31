/datum/objective/prop/points
	explanation_text = "Накопите 5000 очков"
	var/need_points = 5000

/datum/objective/prop/points/check_completion()
	var/datum/faction/props/P = faction
	if(!istype(P))
		return OBJECTIVE_LOSS
	if(P.points > need_points)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
