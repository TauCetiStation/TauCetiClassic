/datum/event/space_dust

/datum/event/space_dust/start()
	spawn_meteors(1, meteors_dust)

/datum/event/sandstorm
	startWhen = 1
	endWhen = 90
	announceWhen = 0
	announcement = new /datum/announcement/centcomm/dust
	announcement_end = new /datum/announcement/centcomm/dust_passed

/datum/event/sandstorm/tick()
	spawn_meteors(10, meteors_dust)
