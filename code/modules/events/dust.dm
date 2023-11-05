/datum/event/space_dust

/datum/event/space_dust/start()
	spawn_meteors(1, meteors_dust)

/datum/event/sandstorm
	startWhen = 1
	endWhen = 90
	announceWhen = 0
	announce_begin_type = /datum/announcement/centcomm/dust
	announce_end_type = /datum/announcement/centcomm/dust_passed

/datum/event/sandstorm/tick()
	spawn_meteors(10, meteors_dust)
