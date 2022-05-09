/**********************Mine areas**************************/

/area/asteroid
	name = "Asteroid"
	icon_state = "unexplored"
	ambience = list('sound/ambience/cave.ogg')
	is_force_ambience = TRUE
	outdoors = TRUE


/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/asteroid/mine/explored
	name = "Mine"
	icon_state = "explored"
	is_force_ambience = TRUE
	ambience = null


/area/asteroid/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"
	ambience = list('sound/ambience/cave.ogg')
	is_force_ambience = TRUE
	var/list/mob_spawn_list = list(
		/mob/living/simple_animal/hostile/troglodit = 1,
		/mob/living/simple_animal/hostile/beholder = 2
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
		CALLBACK(src, .proc/Spawn),
		CALLBACK(src, .proc/Despawn),
		CALLBACK(src, .proc/CheckSpawn),
		8,
		16,
		1.2 MINUTES,
		1 MINUTE,
	)

/area/asteroid/mine/unexplored/proc/Spawn(turf/T)
	if(istype(T, /turf/simulated/floor/plating/ironsand))
		var/turf/simulated/floor/plating/ironsand/AT = T
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
	if(!istype(T, /turf/simulated/floor/plating/ironsand))
		return FALSE
	if(T.icon_state == "asteroid_dug")
		return FALSE
	return T.is_mob_placeable(null)

// Because people didn't want for mobs to spawn on one part of the asteroid I guess
/area/asteroid/mine/unexplored/safe
	icon_state = "unexplored_safe"

/area/asteroid/mine/unexplored/safe/InitSpawnArea()
	return

/area/asteroid/mine/production
	name = "Mining Station Starboard Wing"
	icon_state = "mining_production"

	outdoors = FALSE

/area/asteroid/mine/abandoned
	name = "Abandoned Mining Station"
	looped_ambience = 'sound/ambience/loop_space.ogg'

	outdoors = FALSE

/area/asteroid/mine/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

	outdoors = FALSE

/area/asteroid/mine/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

	outdoors = FALSE

/area/asteroid/mine/maintenance
	name = "Mining Station Communications"

	outdoors = FALSE

/area/asteroid/mine/west_outpost
	name = "West Mining Outpost"

	outdoors = FALSE

/area/asteroid/mine/dwarf
	name = "Dwarf"
	icon_state = "dwarf"

	outdoors = FALSE
