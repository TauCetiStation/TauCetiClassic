/datum/objective/replicator_replicate
	explanation_text = "Construct a Bluespace Catapult and launch at least 20 replicators with it!"

/datum/objective/replicator_replicate/check_completion()
	if(global.replicators_faction.replicators_launched >= REPLICATORS_CATAPULTED_TO_WIN)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
