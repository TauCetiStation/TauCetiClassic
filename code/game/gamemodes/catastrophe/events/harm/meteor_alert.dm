/datum/catastrophe_event/meteor_alert
	name = "Meteor alert"

	one_time_event = TRUE

	weight = 100

	event_type = "harmful"
	steps = 5

	var/meteor_timer = 20
	var/active_timer = 0

	var/bigmeteor_side

/datum/catastrophe_event/meteor_alert/on_step()
	switch(step)
		if(1)
			announce(CYRILLIC_EVENT_METEOR_ALERT_1)
		if(2)
			bigmeteor_side = pick(cardinal)
			var/side_text
			switch(bigmeteor_side)
				if(WEST)
					side_text = CYRILLIC_EVENT_METEOR_ALERT_WEST
				if(EAST)
					side_text = CYRILLIC_EVENT_METEOR_ALERT_EAST
				if(NORTH)
					side_text = CYRILLIC_EVENT_METEOR_ALERT_NORTH
				if(SOUTH)
					side_text = CYRILLIC_EVENT_METEOR_ALERT_SOUTH
			announce(CYRILLIC_EVENT_METEOR_ALERT_2)

			addtimer(CALLBACK(src, .proc/huge_asteroid_warning), 15 MINUTES)
			addtimer(CALLBACK(src, .proc/huge_asteroid_last_warning), 20 MINUTES)
			addtimer(CALLBACK(src, .proc/huge_asteroid_spawn), 20 MINUTES + 3 SECONDS)
		//if(3)
			//
		if(4)
			announce(CYRILLIC_EVENT_METEOR_ALERT_5)
			meteor_timer = 10000
			active_timer = 200

/datum/catastrophe_event/meteor_alert/process_event()
	..()

	meteor_timer -= 1
	if(meteor_timer <= 0)
		meteor_timer = 300
		active_timer = 50


	if(active_timer > 0)
		if(active_timer % 10 == 0)
			spawn_meteors(number = meteors_in_small_wave)
		active_timer -= 1

/datum/catastrophe_event/meteor_alert/proc/huge_asteroid_warning()
	announce(CYRILLIC_EVENT_METEOR_ALERT_3)

/datum/catastrophe_event/meteor_alert/proc/huge_asteroid_last_warning()
	announce(CYRILLIC_EVENT_METEOR_ALERT_4)

// 119 141 center
// 33 141 west corner 86
// 201 141 east corner 82
// 119 199 north corner 58
// 119 51 south corner 90

/datum/catastrophe_event/meteor_alert/proc/huge_asteroid_spawn()
	// copy-paste from /client/proc/drop_asteroid()

	var/turf/T
	switch(bigmeteor_side)
		if(WEST)
			T = locate(33 + rand(0, 40), 141 + rand(-50, 50), ZLEVEL_STATION)
		if(EAST)
			T = locate(201 - rand(0, 40), 141 + rand(-50, 50), ZLEVEL_STATION)
		if(NORTH)
			T = locate(119 + rand(-50, 50), 199 - rand(0, 40), ZLEVEL_STATION)
		if(SOUTH)
			T = locate(119 + rand(-50, 50), 51 + rand(0, 40), ZLEVEL_STATION)

	if(!T)
		return

	var/side_x = rand(20, 40)
	var/side_y = rand(20, 40)


	message_admins("GAMEMODE creates the [side_x]x[side_y] asteroid on [T.x],[T.y],[T.z] [ADMIN_JMP(T)]")
	log_admin("GAMEMODE creates the [side_x]x[side_y] asteroid on [T.x],[T.y],[T.z]")

	var/datum/map_template/asteroid = new(map = generate_asteroid_mapfile(side_x, side_y))


	T = locate(T.x - round(asteroid.width / 2), T.y - round(asteroid.height / 2) , T.z)
	var/list/bounds = list(T.x, T.y, T.z, T.x + asteroid.width + 1, T.y + asteroid.height + 1, T.z)

	for(var/mob/M in player_list)
		if(M.z == T.z)
			M << sound('sound/effects/Explosion3.ogg')

	//shake the station!
	for(var/mob/living/carbon/C in carbon_list)
		if(C.z == T.z)
			if(C.buckled)
				shake_camera(C, 4, 1)
			else
				shake_camera(C, 10, 2)
				C.Weaken(8)
				C.throw_at(get_step(C,pick(1, 2, 4, 8)), 16, 3)

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
			M.ex_act(pick(1, 3))

	asteroid.load(T)

	sleep(max(side_x * side_y / 100, 10))
	//fix for basetypes coped from old turfs in mapload
	for(var/turf/T2 in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
		                   locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
		if(istype(T, /turf/simulated/floor/plating/airless/asteroid) || istype(T, /turf/simulated/mineral))
			T2.basetype = /turf/simulated/floor/plating/airless/asteroid
