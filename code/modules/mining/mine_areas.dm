/**********************Mine areas**************************/

/area/asteroid
	name = "Asteroid"
	icon_state = "unexplored"
	sound_environment = SOUND_AREA_ASTEROID
	outdoors = TRUE

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"
	requires_power = 0
	dynamic_lighting = TRUE

/area/asteroid/mine/explored
	name = "Mine"
	icon_state = "explored"
	looped_ambience = 'sound/ambience/loop_space.ogg'
	ambience = list(
		'sound/ambience/space_1.ogg',
		'sound/ambience/space_2.ogg',
		'sound/ambience/space_3.ogg',
		'sound/ambience/space_4.ogg',
		'sound/ambience/space_5.ogg',
		'sound/ambience/space_6.ogg',
		'sound/ambience/space_7.ogg',
		'sound/ambience/space_8.ogg',
		'sound/music/dwarf_fortress.ogg'
	)


/area/asteroid/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"
	looped_ambience = 'sound/ambience/loop_space.ogg'
	ambience = list(
		'sound/ambience/space_1.ogg',
		'sound/ambience/space_2.ogg',
		'sound/ambience/space_3.ogg',
		'sound/ambience/space_4.ogg',
		'sound/ambience/space_5.ogg',
		'sound/ambience/space_6.ogg',
		'sound/ambience/space_7.ogg',
		'sound/ambience/space_8.ogg',
		'sound/music/dwarf_fortress.ogg'
	)

	var/static/list/mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath = 5,
		/mob/living/simple_animal/hostile/asteroid/basilisk = 4,
		/mob/living/simple_animal/hostile/asteroid/hivelord = 3,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 2,
		/mob/living/simple_animal/hostile/retaliate/malf_drone/mining = 1
	)

/area/asteroid/mine/unexplored/atom_init()
	. = ..()
	InitSpawnArea()

// Creates the spawn area component for this area.
/area/asteroid/mine/unexplored/proc/InitSpawnArea()
	// 8 is 1 more than client's view. So mobs spawn right after the view's border
	// 16 is the entire screen diameter + 1. So mobs don't spawn on one side of the screen
	AddComponent(/datum/component/spawn_area,
		"asteroid",
		CALLBACK(src, PROC_REF(Spawn)),
		CALLBACK(src, PROC_REF(Despawn)),
		CALLBACK(src, PROC_REF(CheckSpawn)),
		8,
		16,
		1.2 MINUTES,
		1 MINUTE,
	)

/area/asteroid/mine/unexplored/proc/Spawn(turf/T)
	if(istype(T, /turf/simulated/floor/plating/airless/asteroid))
		var/turf/simulated/floor/plating/airless/asteroid/AT = T
		AT.gets_dug()

	var/to_spawn = pickweight(mob_spawn_list)
	var/atom/A = new to_spawn(T)
	if(A)
		return list(A)
	return null

/area/asteroid/mine/unexplored/proc/Despawn(atom/movable/instance)
	var/mob/M = instance
	if(M.stat == DEAD)
		return
	qdel(M)

/area/asteroid/mine/unexplored/proc/CheckSpawn(turf/T)
	if(!istype(T, /turf/simulated/floor/plating/airless/asteroid))
		return FALSE
	if(T.icon_state == "asteroid_dug")
		return FALSE
	return T.is_mob_placeable(null)

// Because people didn't want for mobs to spawn on one part of the asteroid I guess
/area/asteroid/mine/unexplored/safe
	icon_state = "unexplored_safe"

/area/asteroid/mine/unexplored/safe/InitSpawnArea()
	return

/area/asteroid/mine/unexplored/dangerous
	icon_state = "unexplored_dangerous"

// More mobs at one time, ~3 fauna around player always
/area/asteroid/mine/unexplored/dangerous/InitSpawnArea()
	AddComponent(/datum/component/spawn_area,
		"asteroid",
		CALLBACK(src, PROC_REF(Spawn)),
		CALLBACK(src, PROC_REF(Despawn)),
		CALLBACK(src, PROC_REF(CheckSpawn)),
		8,
		16,
		15 SECONDS,
		2 MINUTES,
	)

/area/asteroid/mine/unexplored/dangerous/Entered(atom/movable/A, atom/OldLoc)
	. = ..()
	if(!ismob(A) || istype(A, /mob/living/simple_animal/hostile/asteroid))
		return
	var/mob/M = A
	M.overlay_fullscreen("mine_veil", /atom/movable/screen/fullscreen/oxy, 7)
	to_chat(A, "<span class='warning'>Suspension of particles obstructs the view. This area are more dangerous.</span>")

/area/asteroid/mine/unexplored/dangerous/Exited(atom/movable/A, atom/NewLoc)
	. = ..()
	if(!ismob(A) || istype(A, /mob/living/simple_animal/hostile/asteroid))
		return
	var/mob/M = A
	M.clear_fullscreen("mine_veil")

/area/asteroid/mine/production
	name = "Mining Station Starboard Wing"
	icon_state = "mining_production"
	sound_environment = SOUND_AREA_STATION_HALLWAY
	outdoors = FALSE

/area/asteroid/mine/abandoned
	name = "Abandoned Mining Station"
	looped_ambience = 'sound/ambience/loop_space.ogg'
	sound_environment = SOUND_AREA_STATION_HALLWAY
	outdoors = FALSE

/area/asteroid/mine/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"
	sound_environment = SOUND_AREA_DEFAULT
	outdoors = FALSE

/area/asteroid/mine/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"
	looped_ambience = 'sound/ambience/loop_mineeva.ogg'
	sound_environment = SOUND_AREA_DEFAULT
	outdoors = FALSE

/area/asteroid/mine/maintenance
	name = "Mining Station Communications"
	is_force_ambience = TRUE
	ambience = list('sound/ambience/tcomms_1.ogg', 'sound/ambience/tcomms_2.ogg')
	sound_environment = SOUND_AREA_SMALL_METALLIC
	outdoors = FALSE

/area/asteroid/mine/west_outpost
	name = "West Mining Outpost"
	looped_ambience = 'sound/ambience/loop_mineoutpost.ogg'
	sound_environment = SOUND_AREA_DEFAULT
	outdoors = FALSE

/area/asteroid/mine/dwarf
	name = "Dwarf"
	icon_state = "dwarf"
	sound_environment = SOUND_AREA_DEFAULT
	outdoors = FALSE
