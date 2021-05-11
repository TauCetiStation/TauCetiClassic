/datum/event/roundstart/area/dirt/setup()
	num_rand_areas = rand(2, 5)
	. = ..()

/datum/event/roundstart/area/dirt/start()
	var/list/black_types = list(
	/obj/effect/decal/cleanable/cellular/bluespace, /obj/effect/decal/cleanable/cellular/necro,
	/obj/effect/decal/cleanable/bluespace, /obj/effect/decal/cleanable/blood/trail_holder
	)
	black_types += typesof(/obj/effect/decal/cleanable/blood/tracks)

	var/list/possible_dirt_types = subtypesof(/obj/effect/decal/cleanable) - black_types
	for(var/area/target_area in targeted_areas)
		message_admins("RoundStart Event: Dirt appears in [target_area]")
		var/list/turf/all_turfs = get_area_turfs(target_area, TRUE, black_list=list(/turf/simulated/wall, /turf/simulated/wall/r_wall))
		for(var/turf/T in all_turfs)
			if(prob(15))
				var/type = pick(possible_dirt_types)
				new type(T)
