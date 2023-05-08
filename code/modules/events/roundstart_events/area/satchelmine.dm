/datum/event/feature/area/satchelmine
	special_area_types = list(/area/station/hallway, /area/station/civilian)

/datum/event/feature/area/satchelmine/start()
	var/number_of_satchels = rand(1, 3)
	for(var/i = 0, i < number_of_satchels, i++)
		var/area/target_area = pick(targeted_areas - special_area_types)
		message_admins("RoundStart Event: Satchelmine appears in [target_area]")
		var/list/tables = list()
		for(var/obj/structure/table/Table in target_area)
			tables += Table
		if(tables.len)
			var/obj/structure/table/Table = pick(tables)
			var/turf/T = get_turf(Table)
			new /obj/random/misc/storage(T)
		else
			var/list/turf/all_turfs = get_area_turfs(target_area, TRUE, black_list=list(/turf/simulated/wall, /turf/simulated/wall/r_wall))
			var/turf/T = pick(all_turfs)
			new /obj/random/misc/storage(T)