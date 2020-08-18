/datum/event/space_dust

/datum/event/space_dust/start()
	spawn_meteors(1, meteors_dust)

/datum/event/sandstorm
	startWhen = 1
	endWhen = 90
	announceWhen = 0

/datum/event/sandstorm/announce()
	command_alert("The [station_name()] is now passing through a belt of space dust.", "[station_name()] Sensor Array")

/datum/event/sandstorm/tick()
	spawn_meteors(10, meteors_dust)

/datum/event/sandstorm/end()
	command_alert("The [station_name()] has now passed through the belt of space dust.", "[station_name()] Sensor Array")
