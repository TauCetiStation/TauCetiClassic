/datum/event/feature/area/minefield
	percent_areas = 3

/datum/event/feature/area/minefield/start()
	var/list/types = list(/obj/item/mine/emp/anchored, /obj/item/mine/incendiary/anchored, /obj/item/mine/shock/anchored, /obj/item/mine/anchored)
	for(var/area/target_area in targeted_areas)
		var/list/all_turfs = get_area_turfs(target_area, ignore_blocked = TRUE)
		for(var/i in 1 to rand(1, 2))
			var/turf/T = pick_n_take(all_turfs)
			var/type = pick(types)

			var/obj/item/mine/M = new type(T)

			message_admins("RoundStart Event: [M] was spawned in [COORD(T)] - [ADMIN_JMP(T)].")
			log_game("RoundStart Event: [M] was spawned in [COORD(T)].")
