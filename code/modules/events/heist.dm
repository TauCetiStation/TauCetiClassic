/datum/event/heist
	announceWhen = 12
	endWhen      = 120

/datum/event/heist/start()
	if(!length(landmarks_list["Heist"]))
		kill()
		return

	create_uniq_faction(/datum/faction/heist)
