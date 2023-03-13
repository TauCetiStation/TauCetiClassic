/datum/event/feature/area/break_light
	percent_areas = 40

/datum/event/feature/area/break_light/start()
	message_admins("RoundStart Event: [percent_areas]% of light have been broken.")
	for(var/area/target_area in targeted_areas)
		for(var/obj/machinery/light/L in target_area)
			L.broken(TRUE)
