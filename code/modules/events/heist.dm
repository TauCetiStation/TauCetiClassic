/datum/event/heist
	announceWhen = 12
	endWhen      = 120

/datum/event/heist/start()
	if(!global.heiststart.len)
		kill()
		return

	create_uniq_faction(/datum/faction/heist)
