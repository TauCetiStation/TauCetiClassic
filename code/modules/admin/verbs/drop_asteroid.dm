#define SPACETURF    "a"
#define FLOORTURF    "b"
#define CAVETURF     "c"
#define MOBTURF      "d"
#define ARTTURF      "e"

/client/proc/drop_asteroid()
	if(!check_rights(R_EVENT))
		return

	///Unique ID for this spawner
	var/string_gen = null
	///Chance of cells starting closed
	var/initial_closed_chance = 45
	///Amount of smoothing iterations
	var/smoothing_iterations = 10
	///How much neighbours does a dead cell need to become alive
	var/birth_limit = 4
	///How little neighbours does a alive cell need to die
	var/death_limit = 3
	///Generating asteroid width
	var/side_x = input(usr, "Please input the width for asteroid", "Width" , "") as num|null
	///Generating asteroid Height
	var/side_y = input(usr, "Please input the height for asteroid", "Height" , "") as num|null
	///Map template map
	var/map = "\
	\"[SPACETURF]\" = (/turf/space,/area/space)\n\
	\"[FLOORTURF]\" = (/turf/simulated/floor/plating/airless/asteroid,/area/asteroid/mine/unexplored)\n\
	\"[CAVETURF]\" = (/turf/simulated/mineral/random/caves,/area/asteroid/mine/unexplored)\n\
	\"[MOBTURF]\" = (/mob/living/simple_animal/hostile/asteroid/goliath,/turf/simulated/floor/plating/airless/asteroid,/area/asteroid/mine/unexplored)\n\
	\"[ARTTURF]\" = (/obj/machinery/artifact,/turf/simulated/floor/plating/airless/asteroid,/area/asteroid/mine/unexplored)\n\
	(1,1,1) = {\""

	//10% space from side
	var/corner_x = round(side_x / 10)
	var/corner_y = round(side_y / 10)
	var/corner_rad = sqrt(corner_x**2 + corner_y**2)

	if(!side_x || !side_y)
		return

	string_gen = world.ext_python("noise_generate.py", "[smoothing_iterations] [birth_limit] [death_limit] [initial_closed_chance] [side_x] [side_y]")//Generate the raw CA data
	if(!string_gen)
		var/message = "Asteroid failed to load!"
		message_admins("<span class='notice'>[key_name_admin(usr)] tried to create the [side_x]x[side_y] asteroid but it failed to load</span>")
		log_admin("[key_name(usr)] tried to creates the [side_x]x[side_y] asteroid but it failed to load]")
		return log_game(message)

	//Map filling
	for(var/gen_turf_x in 1 to side_x)
		map += "\n"
		for(var/gen_turf_y in 1 to side_y)
			var/xy = sqrt(min(corner_x - gen_turf_x, gen_turf_x)**2 + min(corner_y - gen_turf_y, gen_turf_y)**2)
			//corners
			if(xy <= corner_rad)
				map += SPACETURF
				continue
			//center
			var/closed = text2num(string_gen[side_x * (gen_turf_y - 1) + gen_turf_x])
			if(closed)
				map += CAVETURF
				continue
			map += prob(0.2) ? ARTTURF : prob(2) ? MOBTURF : FLOORTURF
	map += "\n\"}"

	var/datum/map_template/asteroid = new(map = map)

	var/turf/T = get_turf(usr)
	message_admins("<span class='notice'>[key_name_admin(usr)] creates the [side_x]x[side_y] asteroid on [COORD(T)] [ADMIN_JMP(T)]</span>")
	log_admin("[key_name(usr)] creates the [side_x]x[side_y] asteroid on [COORD(T)]")
	T = locate(T.x - round(asteroid.width/2), T.y - round(asteroid.height/2) , T.z)
	var/list/bounds = list(T.x, T.y, T.z, T.x + asteroid.width + 1, T.y + asteroid.height + 1, T.z)

	for(var/mob/M as anything in player_list)
		if(M.z != T.z)
			continue
		M.playsound_local(null, 'sound/effects/Explosion3.ogg', VOL_EFFECTS_MASTER, vary = FALSE)

	//shake the station!
	for(var/mob/living/carbon/C as anything in carbon_list)
		if(C.z != T.z)
			continue
		if(C.buckled)
			shake_camera(C, 4, 1)
		else
			shake_camera(C, 10, 2)
			C.AdjustWeakened(8)
			C.throw_at(get_step(C,pick(1, 2, 4, 8)), 16, 3)

	var/list/targetAtoms = list()
	for(var/L in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
		                   locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
		for(var/A in L)
			targetAtoms += A

	for(var/atom/movable/M in targetAtoms)
		if(istype(M, /obj/machinery/atmospherics) || istype(M,/obj/structure/cable))
			qdel(M)
			continue
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(prob(5))
				H.gib()
			else
				H.ex_act(pick(1,3))

	asteroid.load(T)

	addtimer(CALLBACK(src, .proc/fix_basetypes, bounds, T), max(side_x * side_y / 100, 1 SECOND))

/proc/fix_basetypes(bounds, starting_turf)
	for(var/turf/T2 in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
		                   locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
		if(istype(starting_turf, /turf/simulated/floor/plating/airless/asteroid) || istype(starting_turf, /turf/simulated/mineral))
			T2.basetype = /turf/simulated/floor/plating/airless/asteroid


#undef SPACETURF
#undef FLOORTURF
#undef CAVETURF
#undef MOBTURF
#undef ARTTURF
