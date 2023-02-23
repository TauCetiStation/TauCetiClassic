/datum/objective/replicator_replicate
	explanation_text = "Construct a Bluespace Catapult and launch at least ten replicators with it!"

/datum/objective/replicator_replicate/check_completion()
	if(global.replicators_faction.replicators_launched >= 10)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
