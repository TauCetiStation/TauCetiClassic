/datum/objective/destroy_infestation
	explanation_text = "Destroy all members of the Xenomorph race"

/datum/objective/destroy_infestation/check_completion()
	var/datum/faction/infestation/I = find_faction_by_type(/datum/faction/infestation)
	if(!I || I.count_hive_power() == 0)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
