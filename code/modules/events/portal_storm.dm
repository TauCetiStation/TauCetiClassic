/datum/event/portal_storm
	startWhen = 1
	announceWhen = 1
	endWhen = 999

	announcement = new /datum/announcement/centcomm/portal_storm

	var/list/hostile_types = list(
		/mob/living/simple_animal/hostile/syndicate/melee/space  = 8,
		/mob/living/simple_animal/hostile/syndicate/ranged/space = 4,
	)
	var/list/boss_types = list(
		/mob/living/simple_animal/hostile/syndicate/ranged/space/elite = 2,
	)
	var/number_of_hostiles = 0
	var/number_of_bosses = 0
	var/next_boss_spawn = 0
	var/spawns_per_tick = 1
	var/list/spawned_mobs = list()

/datum/event/portal_storm/setup()
	for(var/htype in hostile_types)
		number_of_hostiles += hostile_types[htype]
	for(var/btype in boss_types)
		number_of_bosses += boss_types[btype]
	if(number_of_bosses)
		next_boss_spawn = startWhen + CEILING(2 * number_of_hostiles / number_of_bosses, 1)

/datum/event/portal_storm/tick()
	for(var/i in 1 to spawns_per_tick)
		if(length(hostile_types))
			var/htype = pick(hostile_types)
			spawn_mob(htype)
			hostile_types[htype]--
			if(!hostile_types[htype])
				hostile_types -= htype

	if(should_spawn_boss() && length(boss_types))
		var/btype = pick(boss_types)
		spawn_mob(btype)
		boss_types[btype]--
		if(!boss_types[btype])
			boss_types -= btype

	if(!length(hostile_types) && !length(boss_types))
		endWhen = activeFor + 1

/datum/event/portal_storm/proc/should_spawn_boss()
	if(length(boss_types) && activeFor >= next_boss_spawn)
		next_boss_spawn += CEILING(number_of_hostiles / max(number_of_bosses, 1), 1)
		return TRUE
	return FALSE

/datum/event/portal_storm/proc/spawn_mob(mob_type)
	var/turf/T
	for(var/i in 1 to 25)
		var/turf/candidate = get_random_station_turf()
		if(!candidate || candidate.density)
			continue
		var/area/A = get_area(candidate)
		if(!A || !A.valid_territory)	// only normal departments, no maintenance/space/solars/shuttles
			continue
		T = candidate
		break
	if(!T)
		return
	spawn_effects(T)
	spawned_mobs += new mob_type(T)

/datum/event/portal_storm/proc/spawn_effects(turf/T)
	var/datum/effect/effect/system/spark_spread/s = new
	s.set_up(5, 1, T)
	s.start()
	playsound(T, 'sound/magic/lightningbolt.ogg', rand(80, 100), TRUE)
