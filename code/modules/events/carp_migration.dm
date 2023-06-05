/datum/event/carp_migration
	announceWhen	= 50
	endWhen = 900
	announcement = new /datum/announcement/centcomm/carp
	var/datum/announcement/announcement_major = new /datum/announcement/centcomm/carp_major
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
		announcement_major.play()
	else
		announcement.play()

/datum/event/carp_migration/start()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			spawn_fish(length(landmarks_list["carpspawn"]))
		if(EVENT_LEVEL_MODERATE)
			spawn_fish(rand(4, 6))        // 12 to 30 carp, in small groups
		else
			spawn_fish(rand(1, 3), 1, 2)  // 1 to 6 carp, alone or in pairs

/datum/event/carp_migration/end()
	for(var/mob/living/simple_animal/hostile/carp/C in spawned_carp)
		if(C.stat == CONSCIOUS)
			var/turf/T = get_turf(C)
			if(isenvironmentturf(T))
				qdel(C)

/datum/event/carp_migration/proc/spawn_fish(num_groups, group_size_min = 3, group_size_max = 5)
	var/list/spawn_locations = list()

	spawn_locations = shuffle(landmarks_list["carpspawn"].Copy())
	num_groups = min(num_groups, spawn_locations.len)

	for(var/i in 1 to num_groups)
		var/group_size = rand(group_size_min, group_size_max)
		var/list/turfs = circlerangeturfs(spawn_locations[i], 2)
		for(var/turf/T in turfs)
			if(!isenvironmentturf(T))
				turfs -= T
		group_size = min(group_size, turfs.len)
		for(var/j in 1 to group_size)
			var/carptype = pickweight(spawned_mobs)
			spawned_carp.Add(new carptype(pick_n_take(turfs)))
