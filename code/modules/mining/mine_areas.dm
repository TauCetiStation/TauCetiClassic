/**********************Mine areas**************************/

/area/asteroid
	name = "Asteroid"
	icon_state = "unexplored"

	outdoors = TRUE

/area/asteroid/artifactroom
	name = "Asteroid - Artifact"
	icon_state = "cave"
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

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
	var/to_spawn = pickweight(mob_spawn_list)
	var/atom/A = new to_spawn(T)
	if(A)
		return list(A)
	return null

/area/asteroid/mine/unexplored/proc/Despawn(atom/movable/instance)
	qdel(instance)

/area/asteroid/mine/unexplored/proc/CheckSpawn(turf/T)
	if(!istype(T, /turf/simulated/floor/plating/airless/asteroid))
		return FALSE
	return T.is_mob_placeable(null)

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
