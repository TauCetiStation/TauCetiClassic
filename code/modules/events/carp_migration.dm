/datum/event/carp_migration
	announceWhen	= 50
	endWhen = 900
	var/list/spawned_carp = list()
	var/list/spawned_mobs = list(
		/mob/living/simple_animal/hostile/carp = 95,
		/mob/living/simple_animal/hostile/carp/megacarp = 5
		)

/datum/event/carp_migration/setup()
	announceWhen = rand(40, 60)
	endWhen = rand(600,1200)

/datum/event/carp_migration/announce()
	if(severity == EVENT_LEVEL_MAJOR)
		command_alert("Massive migration of unknown biological entities has been detected near [station_name()], please stand-by.", "Lifesign Alert", "carps")
	else
		command_alert("Unknown biological entities have been detected near [station_name()], please stand-by.", "Lifesign Alert", "carps")

/datum/event/carp_migration/start()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			spawn_fish(landmarks_list.len)
		if(EVENT_LEVEL_MODERATE)
			spawn_fish(rand(4, 6))        // 12 to 30 carp, in small groups
		else
			spawn_fish(rand(1, 3), 1, 2)  // 1 to 6 carp, alone or in pairs

/datum/event/carp_migration/end()
	for(var/mob/living/simple_animal/hostile/carp/C in spawned_carp)
		if(!C.stat)
			var/turf/T = get_turf(C)
			if(istype(T, /turf/space))
				qdel(C)

/datum/event/carp_migration/proc/spawn_fish(num_groups, group_size_min = 3, group_size_max = 5)
	var/list/spawn_locations = list()

	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "carpspawn")
			spawn_locations.Add(C.loc)
	spawn_locations = shuffle(spawn_locations)
	num_groups = min(num_groups, spawn_locations.len)

	for(var/i in 1 to num_groups)
		var/group_size = rand(group_size_min, group_size_max)
		var/list/turfs = circlerangeturfs(spawn_locations[i], 2)
		for(var/turf/T in turfs)
			if(!istype(T, /turf/space) && isturf(T.loc)) // no spawn in Grille
				turfs -= T
		group_size = min(group_size, turfs.len)
		for(var/j in 1 to group_size)
			var/carptype = pickweight(spawned_mobs)
			spawned_carp.Add(new carptype(pick_n_take(turfs)))
