//cael - two events here

//meteor storms are much heavier
/datum/event/meteor_wave
	startWhen		= 6
	endWhen			= 33
	announcement = new /datum/announcement/centcomm/meteor_wave
	announcement_end = new /datum/announcement/centcomm/meteor_wave_passed

/datum/event/meteor_wave/setup()
	endWhen = rand(10,25) * 3

/datum/event/meteor_wave/tick()
	if(IS_MULTIPLE(activeFor, 3))
		spawn_meteors(rand(2,5), get_meteors())

//
/datum/event/meteor_shower
	startWhen		= 5
	endWhen 		= 7
	announcement = new /datum/announcement/centcomm/meteor_shower
	announcement_end = new /datum/announcement/centcomm/meteor_shower_passed
	var/next_meteor = 6
	var/waves = 1

/datum/event/meteor_shower/setup()
	waves = rand(1,4)

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

/datum/event/proc/get_meteors()
	if(severity == EVENT_LEVEL_MAJOR)
		return meteors_catastrophic
	else
		if(prob(50))
			return meteors_threatening
		return meteors_normal
