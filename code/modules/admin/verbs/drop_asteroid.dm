/client/proc/drop_asteroid()
	if(!check_rights(R_EVENT))
		return

	var/side_x = input(usr, "Please input the width for asteroid", "Width" , "") as num|null
	var/side_y = input(usr, "Please input the height for asteroid", "Height" , "") as num|null

	if(!side_x || !side_y)
		return

	var/turf/T = get_turf(usr)

	message_admins("<span class='notice'>[key_name_admin(usr)] creates the [side_x]x[side_y] asteroid on [T.x],[T.y],[T.z] [ADMIN_JMP(T)]</span>")
	log_admin("[key_name(usr)] creates the [side_x]x[side_y] asteroid on [T.x],[T.y],[T.z]")

	var/datum/map_template/asteroid = new(map = generate_asteroid_mapfile(side_x, side_y))


	T = locate(T.x - round(asteroid.width/2), T.y - round(asteroid.height/2) , T.z)
	var/list/bounds = list(T.x, T.y, T.z, T.x + asteroid.width + 1, T.y + asteroid.height + 1, T.z)

	for(var/mob/M in player_list)
		if(M.z == T.z)
			M.playsound_local(null, 'sound/effects/Explosion3.ogg', VOL_EFFECTS_MASTER, vary = FALSE)

	//shake the station!
	for(var/mob/living/carbon/C in carbon_list)
		if(C.z == T.z)
			if(C.buckled)
				shake_camera(C, 4, 1)
			else
				shake_camera(C, 10, 2)
				C.Weaken(8)
				C.throw_at(get_step(C,pick(1,2,4,8)),16,3)

	var/list/targetAtoms = list()
	for(var/L in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
		                   locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
		for(var/A in L)
			targetAtoms += A

	for(var/atom/movable/M in targetAtoms)
		if(istype(M, /obj/machinery/atmospherics) || istype(M,/obj/structure/cable))
			qdel(M)
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(prob(5))
				H.gib()
		else
			M.ex_act(pick(1,3))

	asteroid.load(T)

	sleep(max(side_x*side_y/100, 10))
	//fix for basetypes coped from old turfs in mapload
	for(var/turf/T2 in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
		                   locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
		if(istype(T, /turf/simulated/floor/plating/airless/asteroid) || istype(T, /turf/simulated/mineral))
			T2.basetype = /turf/simulated/floor/plating/airless/asteroid

#define SPACETURF    "a"
#define FLOORTURF    "b"
#define CAVETURF     "c"
#define RESCAVETURF  "d"
#define MOBTURF      "e"
#define ARTTURF      "f"

/proc/generate_asteroid_mapfile(size_x, size_y)
	var/map = "\
		\"[SPACETURF]\" = (/turf/space,/area/space)\n\
		\"[FLOORTURF]\" = (/turf/simulated/floor/plating/airless/asteroid,/area/asteroid/mine/unexplored)\n\
		\"[CAVETURF]\" = (/turf/simulated/mineral/random/caves,/area/asteroid/mine/unexplored)\n\
		\"[RESCAVETURF]\" = (/turf/simulated/mineral/random/high_chance,/area/asteroid/mine/unexplored)\n\
		\"[MOBTURF]\" = (/mob/living/simple_animal/hostile/asteroid/goliath,/turf/simulated/floor/plating/airless/asteroid,/area/asteroid/mine/unexplored)\n\
		\"[ARTTURF]\" = (/obj/machinery/artifact,/turf/simulated/floor/plating/airless/asteroid,/area/asteroid/mine/unexplored)\n\
		(1,1,1) = {\""

	var/side_x = round(size_x / 10)//10% space from side
	var/side_y = round(size_y / 10)
	var/corner_rad = sqrt(side_x**2+side_y**2)

	for(var/i = 1 to size_x)
		map += "\n"
		for(var/j = 1 to size_y)
			var/xy = sqrt(min(size_x - i, i)**2 + min(size_y - j, j)**2)

			//corners
			if(xy<=corner_rad)
				map += SPACETURF
			//center
			else if (i < size_x/2+side_x && i > size_x/2-side_x && j < size_y/2+side_y && j > size_y/2-side_y)
				if(prob(10))
					map += ARTTURF
				else
					map += prob(80) ? FLOORTURF : MOBTURF
			//sides
			else if (min(size_x - i, i) <= side_x || min(size_y - j, j) <= side_y)
				map += prob(40) ? FLOORTURF : CAVETURF
			else
				if(prob(5))
					map += FLOORTURF
				else
					map += prob(40) ? RESCAVETURF : CAVETURF

	map += "\n\"}"

	return map

#undef SPACETURF
#undef FLOORTURF
#undef CAVETURF
#undef RESCAVETURF
#undef MOBTURF
#undef ARTTURF
