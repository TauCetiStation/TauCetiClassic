/area/asteroid/mine/unexplored/tatalia
	name = "Tatalia"
	icon_state = "unexplored"
	ambience = list(
		'sound/ambience/tatalia.ogg',)
	is_force_ambience = TRUE
	mob_spawn_list = list(
		/mob/living/simple_animal/hostile/gorgona = 1,
		/mob/living/simple_animal/hostile/dragonfly = 2
	)

/area/asteroid/mine/unexplored/tatalia/Spawn(turf/T)
	var/to_spawn = pickweight(mob_spawn_list)
	var/atom/A = new to_spawn(T)
	if(A)
		return list(A)
	return null

/area/asteroid/mine/unexplored/tatalia/CheckSpawn(turf/T)
	if(!istype(T, /turf/simulated/floor/grass))
		return FALSE
	if(T.icon_state == "asteroid_dug")
		return FALSE
	return T.is_mob_placeable(null)