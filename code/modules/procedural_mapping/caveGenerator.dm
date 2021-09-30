/datum/map_generator/cave_generator
	var/name = "Cave Generator"
	///Weighted list of the types that spawns if the turf is open
	var/open_turf_types = list(/turf/simulated/floor/plating/airless/asteroid = 1)
	///Weighted list of the types that spawns if the turf is closed
	var/closed_turf_types =  list(/turf/simulated/mineral/random/caves = 1)
	///Weighted list of extra features that can spawn in the area, such as geysers.
	var/list/feature_spawn_list = list(/obj/machinery/artifact/bluespace_crystal = 1)
	///Weighted list of mobs that can spawn in the area.
	var/list/mob_spawn_list = list(
        /mob/living/simple_animal/hostile/asteroid/goliath = 50, /mob/living/simple_animal/hostile/asteroid/basilisk = 40,\
        /mob/living/simple_animal/hostile/asteroid/hivelord = 30, /mob/living/simple_animal/hostile/asteroid/goldgrub = 20,\
        /mob/living/simple_animal/hostile/retaliate/malf_drone/mining = 10
	)

	///Base chance of spawning a mob
	var/mob_spawn_chance = 6
	///Base chance of spawning features
	var/feature_spawn_chance = 0.1

	///Unique ID for this spawner
	var/string_gen
	///Chance of cells starting closed
	var/initial_closed_chance = 45
	///Amount of smoothing iterations
	var/smoothing_iterations = 13
	///How much neighbours does a dead cell need to become alive
	var/birth_limit = 4
	///How little neighbours does a alive cell need to die
	var/death_limit = 3

/datum/map_generator/cave_generator/generate_terrain(list/turfs)
	. = ..()
	var/start_time = REALTIMEOFDAY
	string_gen = world.ext_python("noise_generate.py", "[smoothing_iterations] [birth_limit] [death_limit] [initial_closed_chance]")//Generate the raw CA data

	for(var/i as anything in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = i

		var/closed = text2num(string_gen[world.maxx * (gen_turf.y-1) + gen_turf.x])

		var/turf/new_turf = pickweight(closed ? closed_turf_types : open_turf_types)

		new_turf = gen_turf.ChangeTurf(new_turf)


		if(!closed)

			//FEATURE SPAWNING
			var/atom/spawned_feature
			if(feature_spawn_list && prob(feature_spawn_chance))
				var/can_spawn = TRUE
				var/atom/picked_feature = pickweight(feature_spawn_list)
				for(var/obj/O in range(7, new_turf))
					if(istype(O, picked_feature))
						can_spawn = FALSE
				if(can_spawn)
					spawned_feature = new picked_feature(new_turf)

			//MOB SPAWNING
			if(mob_spawn_list && !spawned_feature && prob(mob_spawn_chance))
				var/can_spawn = TRUE
				var/atom/picked_mob = pickweight(mob_spawn_list)
				for(var/thing in urange(12, new_turf)) //prevents mob clumps
					if(!istype(thing, /mob/living/simple_animal/hostile))
						continue
					if(ispath(picked_mob, /mob/living/simple_animal/hostile/asteroid) || istype(thing, /mob/living/simple_animal/hostile/asteroid))
						can_spawn = FALSE //if the random is a standard mob, avoid spawning if there's another one within 12 tiles
						break
				if(can_spawn)
					new picked_mob(new_turf)
		CHECK_TICK

	var/message = "[name] finished in [(REALTIMEOFDAY - start_time)/10]s!"
	log_game(message)
