/datum/objective/destroy_replicators
	explanation_text = "Destroy all members of the Replicators race"

/datum/objective/destroy_replicators/check_completion()
	var/datum/faction/replicators/I = find_faction_by_type(/datum/faction/replicators)
	if(!I || length(global.alive_replicators) == 0)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
