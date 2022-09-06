/datum/event/heist
	announceWhen = 12
	endWhen      = 120
	var/vox_faction = /datum/faction/heist

/datum/event/heist/start()
	if(!global.heiststart.len)
		kill()
		return

	create_uniq_faction(vox_faction)

/datum/event/heist/nuclear
	vox_faction = /datum/faction/heist/nuclear
