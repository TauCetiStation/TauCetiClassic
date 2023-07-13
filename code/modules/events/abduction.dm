/datum/event/abduction
	announceWhen = 12
	endWhen      = 120

/datum/event/abduction/start()
	create_uniq_faction(/datum/faction/abductors)
