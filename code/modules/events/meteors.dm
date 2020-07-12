/datum/event/meteor_wave
	startWhen		= 5
	endWhen 		= 7
	var/next_meteor = 6
	var/waves = 1

/datum/event/meteor_wave/setup()
	waves = severity * rand(1,3)

/datum/event/meteor_wave/announce()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			command_alert("Meteors have been detected on collision course with the station. The energy field generator is disabled or missing.", "Meteor Alert", "meteors")
		else
			command_alert("The station is now in a meteor shower. The energy field generator is disabled or missing.", "Meteor Alert", "meteors")

/datum/event/meteor_wave/tick()
	if(waves && activeFor >= next_meteor)
		spawn()
			spawn_meteors(severity * rand(1,2), get_meteors())
		next_meteor += rand(15, 30) / severity
		waves--
		endWhen = (waves ? next_meteor + 1 : activeFor + 15)

/datum/event/meteor_wave/end()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			command_alert("The station has cleared the meteor storm.", "Meteor Alert", "meteorcleared")
		else
			command_alert("The station has cleared the meteor shower", "Meteor Alert", "meteorcleared")

/datum/event/meteor_wave/proc/get_meteors()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			return meteors_catastrophic
		if(EVENT_LEVEL_MODERATE)
			return meteors_threatening
		else
			return meteors_normal
