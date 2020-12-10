/datum/event/space_dust

/datum/event/space_dust/start()
	spawn_meteors(1, meteors_dust)

/datum/event/sandstorm
	startWhen = 1
	endWhen = 90
	announceWhen = 0

/datum/event/sandstorm/announce()
	command_alert("[station_name()] сейчас проходит через пояс космической пыли.", "Сенсорные датчики [station_name()]")

/datum/event/sandstorm/tick()
	spawn_meteors(10, meteors_dust)

/datum/event/sandstorm/end()
	command_alert("[station_name()] прошел через пояс космической пыли.", "Сенсорные датчики [station_name()]")
