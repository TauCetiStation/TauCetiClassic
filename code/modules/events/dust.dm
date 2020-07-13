/datum/event/space_dust

/datum/event/space_dust/start()
	spawn_meteors(1, meteors_dust)

/datum/event/sandstorm
	startWhen = 1
	endWhen = 150 // ~5 min
	announceWhen = 0

/datum/event/sandstorm/tick()
	spawn_meteors(10, meteors_dust)