/datum/objective/gang/points
	explanation_text = "Наберите больше очков, чем другие банды."

/datum/objective/gang/points/check_completion()
	var/list/all_gangs = find_factions_by_type(/datum/faction/gang)
	if(!(faction in all_gangs))
		return OBJECTIVE_LOSS
	var/highest_point_value = 0
	for(var/G in all_gangs)
		var/datum/faction/gang/GG = G
		if(GG.points >= highest_point_value && GG.members.len)
			highest_point_value = GG.points

	var/datum/faction/gang/gang = faction
	if(highest_point_value == gang.points)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
