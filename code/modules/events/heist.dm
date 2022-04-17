/datum/event/heist
	announceWhen	= 12
	endWhen			= 120

/datum/event/heist/start()
	var/turf/T = pick(global.heiststart)
	if(!T)
		kill()
		return

	create_uniq_faction(/datum/faction/heist)
