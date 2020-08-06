//cael - two events here

//meteor storms are much heavier
/datum/event/meteor_wave
	startWhen		= 6
	endWhen			= 33

/datum/event/meteor_wave/setup()
	endWhen = rand(10,25) * 3

/datum/event/meteor_wave/announce()
	command_alert("Meteors have been detected on collision course with the station. The energy field generator is disabled or missing.", "Meteor Alert", "meteors")

/datum/event/meteor_wave/tick()
	if(IS_MULTIPLE(activeFor, 3))
		spawn_meteors(rand(2,5), get_meteors())

/datum/event/meteor_wave/end()
	command_alert("The station has cleared the meteor storm.", "Meteor Alert", "meteorcleared")

//
/datum/event/meteor_shower
	startWhen		= 5
	endWhen 		= 7
	var/next_meteor = 6
	var/waves = 1

/datum/event/meteor_shower/setup()
	waves = rand(1,4)

/datum/event/meteor_shower/announce()
	command_alert("The station is now in a meteor shower. The energy field generator is disabled or missing.", "Meteor Alert", "meteors")

//meteor showers are lighter and more common,
/datum/event/meteor_shower/tick()
	if(activeFor >= next_meteor)
		spawn_meteors(rand(1,4), get_meteors())
		next_meteor += rand(20,100)
		waves--
		if(waves <= 0)
			endWhen = activeFor + 1
		else
			endWhen = next_meteor + 1

/datum/event/meteor_shower/end()
	command_alert("The station has cleared the meteor shower", "Meteor Alert", "meteorcleared")

/datum/event/proc/get_meteors()
	if(severity == EVENT_LEVEL_MAJOR)
		return meteors_catastrophic
	else
		if(prob(50))
			return meteors_threatening
		return meteors_normal
