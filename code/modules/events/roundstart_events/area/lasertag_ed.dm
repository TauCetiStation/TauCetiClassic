/datum/event/feature/area/lasertag_ed
	special_area_types = list(/area/station/security/lobby)

/datum/event/feature/area/lasertag_ed/start()
	for(var/area/target_area in targeted_areas)
		var/list/all_turfs = get_area_turfs(target_area, ignore_blocked = TRUE)

		var/turf/T1 = pick(all_turfs)
		var/turf/T2 = pick(all_turfs)

		new /obj/machinery/bot/secbot/ed209/bluetag(T1)
		new /obj/machinery/bot/secbot/ed209/redtag(T2)

		message_admins("RoundStart Event: Lasertag ED-209 was spawned in [target_area].")
		log_game("RoundStart Event: Lasertag ED-209 was spawned in [target_area].")
