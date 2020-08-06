/datum/event/wallrot
	var/turf/simulated/wall/center = null

/datum/event/wallrot/setup()
	announceWhen = rand(0, 300)
	endWhen = announceWhen + 1

/datum/event/wallrot/announce()
	if(center)
		command_alert("Harmful fungi detected on station. Station structures may be contaminated.", "Biohazard Alert", "fungi")

/datum/event/wallrot/start()
	// 100 attempts
	for(var/i in 1 to 100)
		var/turf/candidate = locate(rand(1, world.maxx), rand(1, world.maxy), pick(SSmapping.levels_by_trait(ZTRAIT_STATION)))
		if(istype(candidate, /turf/simulated/wall))
			center = candidate
			break

	if(center)
		// Make sure at least one piece of wall rots!
		center.rot()

		// Have a chance to rot lots of other walls.
		var/rotcount = 0
		var/actual_severity = severity * rand(5, 10)
		for(var/turf/simulated/wall/W in range(5, center)) if(prob(50))
			W.rot()
			rotcount++

			// Only rot up to severity walls
			if(rotcount >= actual_severity)
				break
