//shuttle moving state defines are in code/__DEFINES/shuttles.dm

/datum/shuttle
	var/name = ""
	var/warmup_time = 0
	var/moving_status = SHUTTLE_IDLE
	var/process_state = IDLE_STATE

	var/area/shuttle_area //can be both single area type or a list of areas
	var/obj/effect/shuttle_landmark/current_location
	var/obj/effect/shuttle_landmark/landmark_transition
	var/obj/effect/shuttle_landmark/next_location
	var/move_time = 240 //the time spent in the transition area. In seconds

	var/arrive_time = 0 //the time at which the shuttle arrives when long jumping
	var/flags = SHUTTLE_FLAGS_PROCESS

	var/knockdown = TRUE //whether shuttle downs non-buckled people when it moves

	var/sound_takeoff = 'sound/effects/shuttle_takeoff.ogg'
	var/sound_landing = 'sound/effects/shuttle_landing.ogg'

/datum/shuttle/New(_name, obj/effect/shuttle_landmark/initial_location)
	if(_name)
		name = _name

	var/list/areas = list()
	if(!islist(shuttle_area))
		shuttle_area = list(shuttle_area)
	for(var/T in shuttle_area)
		var/area/A = locate(T)
		if(!istype(A))
			CRASH("Shuttle \"[name]\" couldn't locate area [T].")
		areas += A
	shuttle_area = areas

	if(initial_location)
		current_location = initial_location
	else
		current_location = locate(current_location)

	if(!istype(current_location))
		CRASH("Shuttle \"[name]\" could not find its starting location.")

	if(name in SSshuttle.shuttles)
		CRASH("A shuttle with the name '[name]' is already defined.")

	//Optional transition area
	if(landmark_transition)
		landmark_transition = locate(landmark_transition)

	SSshuttle.shuttles[name] = src
	if(flags & SHUTTLE_FLAGS_PROCESS)
		START_PROCESSING(SSshuttle, src)
	/*if(flags & SHUTTLE_FLAGS_SUPPLY)
		if(SSshuttle.shuttle)
			CRASH("A supply shuttle is already defined.")*/

/datum/shuttle/Destroy()
	current_location = null
	landmark_transition = null
	next_location = null

	SSshuttle.shuttles -= name
	if(flags & SHUTTLE_FLAGS_PROCESS)
		STOP_PROCESSING(SSshuttle, src)
	/*shuttle_controller.process_shuttles -= src
	if(supply_controller.shuttle == src)
		supply_controller.shuttle = null*/

	return ..()

/datum/shuttle/process()
	return

/datum/shuttle/proc/jump(jump_dist, obj/effect/shuttle_landmark/destination, obj/effect/shuttle_landmark/interim, travel_time)
	if(moving_status != SHUTTLE_IDLE)
		return

	if(!destination)
		if(!next_location)
			CRASH("[src.name] initiated jump from [current_location.name] without destination.")
		destination = next_location

	moving_status = SHUTTLE_WARMUP
	if(sound_takeoff)
		playsound(current_location, sound_takeoff, 100, 20, 0.2)
	if(jump_dist == SHUTTLE_JUMP_SHORT)
		addtimer(CALLBACK(src, .proc/jump_process, jump_dist, destination), warmup_time * 10)
	else
		if(!interim)
			if(!landmark_transition)
				CRASH("[src.name] initiated long jump from [current_location.name] to [destination.name] without transit location.")
			interim = landmark_transition
		
		if(!travel_time)
			if(!move_time)
				CRASH("[src.name] initiated long jump from [current_location.name] to [destination.name] without correct travel time.")
			travel_time = move_time

		addtimer(CALLBACK(src, .proc/jump_process, jump_dist, destination, interim, travel_time), warmup_time * 10)

/datum/shuttle/proc/jump_process(jump_dist, obj/effect/shuttle_landmark/destination, obj/effect/shuttle_landmark/interim, travel_time)
	if(moving_status == SHUTTLE_IDLE)
		return //someone cancelled the launch

	moving_status = SHUTTLE_INTRANSIT
	if(jump_dist == SHUTTLE_JUMP_SHORT)
		attempt_move(destination)
		moving_status = SHUTTLE_IDLE
	else
		arrive_time = world.time + travel_time*10
		var/obj/effect/shuttle_landmark/start_location = current_location
		if(attempt_move(interim))
			if(sound_landing)
				addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, destination, sound_landing, 100, 0, 7), max(travel_time * 10 - 100, 5))
			addtimer(CALLBACK(src, .proc/long_jump_end, destination, start_location), travel_time * 10)


/datum/shuttle/proc/long_jump_end(obj/effect/shuttle_landmark/destination, obj/effect/shuttle_landmark/start)
	if(!attempt_move(destination))
		attempt_move(start) //try to go back to where we started. If that fails, I guess we're stuck in the interim location
	moving_status = SHUTTLE_IDLE


/datum/shuttle/proc/attempt_move(obj/effect/shuttle_landmark/destination)
	if(!destination || !destination.is_valid(src) || current_location == destination)
		return FALSE

	var/list/translation = list()
	for(var/area/A in shuttle_area)
		translation += get_turf_translation(get_turf(current_location), get_turf(destination), A.contents)

	INVOKE_ASYNC(src, .proc/move, destination, translation)
	return TRUE


/datum/shuttle/proc/pre_move(obj/effect/shuttle_landmark/destination)
	return


/datum/shuttle/proc/move(obj/effect/shuttle_landmark/destination, list/turf_translation)
	pre_move(destination)

	for(var/turf/src_turf in turf_translation)
		var/turf/dst_turf = turf_translation[src_turf]
		if(src_turf.is_solid_structure()) //in case someone put a hole in the shuttle and you were lucky enough to be under it
			for(var/atom/movable/AM in dst_turf)
				if(!AM.simulated)
					continue
				if(isliving(AM))
					var/mob/living/bug = AM
					bug.gib()
				else
					qdel(AM) //it just gets atomized I guess? TODO throw it into space somewhere, prevents people from using shuttles as an atom-smasher

	var/list/powernets = list()
	for(var/area/A in shuttle_area)
		if(knockdown)
			for(var/mob/M in A)
				if(M.client)
					if(M.buckled)
						to_chat(M, "<span class='warning'>Sudden acceleration presses you into your chair!</span>")
						INVOKE_ASYNC(GLOBAL_PROC, .proc/shake_camera, M, 3, 1) // buckled, not a lot of shaking
					else
						to_chat(M, "<span class='warning'>The floor lurches beneath you!</span>")
						INVOKE_ASYNC(GLOBAL_PROC, .proc/shake_camera, M, 10, 1) // unbuckled, HOLY SHIT SHAKE THE ROOM
				if(iscarbon(M) && !M.buckled)
					M.Weaken(3)

		for(var/obj/structure/cable/C in A)
			powernets |= C.powernet

	translate_turfs(turf_translation, current_location.base_area, current_location.base_turf)

	// Remove all powernets that were affected, and rebuild them.
	var/list/cables = list()
	for(var/datum/powernet/P in powernets)
		cables |= P.cables
		qdel(P)
	for(var/obj/structure/cable/C in cables)
		if(!C.powernet)
			var/datum/powernet/NewPN = new()
			NewPN.add_cable(C)
			propagate_network(C, C.powernet)

	post_move(destination)
	current_location = destination


/datum/shuttle/proc/post_move(obj/effect/shuttle_landmark/destination)
	return

//returns 1 if the shuttle has a valid arrive time
/datum/shuttle/proc/has_arrive_time()
	return moving_status == SHUTTLE_INTRANSIT
