/turf/simulated/floor/replicator_forcefield

/turf/simulated/wall/replicator_forcefield

/mob/living/simple_animal/replicator
	var/state = REPLICATOR_STATE_HARVESTING

	var/list/target_coordinates

	var/request_help_until = 0

	var/help_steps = 7

	var/excitement = 10
	var/next_excitement_alert = 0
	var/excitement_alert_cooldown = 30 SECONDS

/mob/living/simple_animal/replicator/Life()
	. = ..()
	if(!.)
		return

	if(health < last_update_health && next_attacked_alert < world.time)
		global.replicators_faction.drone_message(src, "I am taking damage.", transfer=TRUE)
		next_attacked_alert = world.time + attacked_alert_cooldown

	last_update_health = health

	if(ckey)
		return

	if(excitement <= 0 && next_excitement_alert < world.time)
		global.replicators_faction.drone_message(src, pick("I have no purpose.", "I am bored.", "Why am I still here."), transfer=TRUE, dismantle=TRUE)
		next_excitement_alert = excitement_alert_cooldown

	if(state == REPLICATOR_STATE_HELPING)
		return

	if(state == REPLICATOR_STATE_GOING_TO_HELP)
		process_going_to_help()
		return

	// TO-DO: if wandering for too long, send a signal of idleness, and cease all activity. Perhaps try to hide?
	if(state == REPLICATOR_STATE_WANDERING)
		process_wandering()
		return

	if(disintegrating)
		return
	process_harvesting()

/mob/living/simple_animal/replicator/Topic(href, href_list)
	if(incapacitated())
		return ..()
	if(!mind)
		return ..()

	if(href_list["replicator_jump"])
		var/mob/living/simple_animal/replicator/target = locate(href_list["replicator_kill"])
		if(transfer_control(target, alert=FALSE))
			return

		for(var/r in global.replicators)
			var/mob/living/simple_animal/replicator/R = r
			if(R.ckey)
				continue
			if(get_dist(src, R) > 7)
				continue
			if(!transfer_control(R, alert=FALSE))
				continue

		to_chat(src, "<span class='notice'>Other presence is already attending this situation.</span>")
		return

	if(href_list["replicator_kill"])
		var/mob/living/simple_animal/replicator/target = locate(href_list["replicator_kill"])
		if(!istype(target))
			return

		if(target.incapacitated())
			return

		if(target.excitement > 0)
			return

		// TO-DO: sound
		target.last_controller_ckey = ckey
		INVOKE_ASYNC(target, .proc/disintegrate, target)
		return

/mob/living/simple_animal/replicator/proc/set_state(new_state)
	excitement = 10
	state = new_state
	update_icon()

/mob/living/simple_animal/replicator/get_active_skillset()
	return skills.active

/mob/living/simple_animal/replicator/on_start_help_other(mob/living/target)
	set_state(REPLICATOR_STATE_HELPING)

/mob/living/simple_animal/replicator/on_stop_help_other(mob/living/target)
	set_state(REPLICATOR_STATE_HARVESTING)

/mob/living/simple_animal/replicator/proc/process_going_to_help()
	if(!target_coordinates)
		set_state(REPLICATOR_STATE_HARVESTING)
		return

	if(x != target_coordinates["x"] || y != target_coordinates["y"] || z != target_coordinates["z"])
		var/turf/T = get_step_to(
			src,
			locate(target_coordinates["x"], target_coordinates["y"], target_coordinates["z"])
			)
		var/move_dir = get_dir(src, T)
		Move(get_step(src, move_dir), move_dir)
		help_steps--
		if(help_steps < 0)
			help_steps = 7
			set_state(REPLICATOR_STATE_HARVESTING)
		return

	target_coordinates = null

	for(var/mob/living/simple_animal/replicator/R in loc)
		if(!R.ckey)
			continue
		if(R.request_help_until < world.time)
			continue

		face_atom(R)
		INVOKE_ASYNC(src, /mob/living.proc/help_other, R)
		return

/mob/living/simple_animal/replicator/proc/process_wandering()
	var/list/wander_directions = list() + cardinal
	for(var/wander_dir in wander_directions)
		var/turf/T = get_step(src, wander_dir)
		if(istype(T, /turf/simulated/floor/plating/airless/catwalk/forcefield))
			wander_directions -= wander_dir

	if(length(wander_directions) > 0)
		var/move_dir = pick(wander_directions)
		Move(get_step(src, move_dir), move_dir)
		set_state(REPLICATOR_STATE_HARVESTING)
		return

	var/mob/living/simple_animal/replicator/harvester = get_closest_harvesting_replicator()
	if(harvester && get_dist(src, harvester) < 7)
		var/turf/closer_turf = get_step_to(src, harvester)
		var/closer_dir = get_dir(src, closer_turf)
		Move(closer_turf, closer_dir)
		return

	var/mob/living/simple_animal/replicator/R = get_closest_sentient_replicator()
	if(R && get_dist(src, R) < 7)
		var/turf/closer_turf = get_step_to(src, R)
		var/closer_dir = get_dir(src, closer_turf)
		Move(closer_turf, closer_dir)
		return

	excitement -= 1

	var/closest_replicator_dir = R ? get_dir(src, R) : pick(cardinal)
	var/to_move_dir = pick(list(closest_replicator_dir) + cardinal)
	Move(get_step(src, to_move_dir), to_move_dir)

/mob/living/simple_animal/replicator/proc/process_harvesting()
	var/turf/my_turf = get_turf(src)

	var/list/turf/surrounding_turfs = RANGE_TURFS(1, src)
	for(var/t in surrounding_turfs)
		var/turf/T = t
		if(T == my_turf)
			continue
		var/to_disintegrate = find_most_clickable(T)
		if(!to_disintegrate)
			continue

		face_atom(to_disintegrate)
		INVOKE_ASYNC(src, .proc/disintegrate, to_disintegrate)
		return

	for(var/t in surrounding_turfs)
		var/turf/T = t
		if(T == my_turf)
			continue
		if(!is_auto_disintegratable(T))
			continue
		face_atom(T)
		INVOKE_ASYNC(src, .proc/disintegrate, T)
		return

	var/to_disintegrate = find_most_clickable(my_turf)
	if(to_disintegrate)
		face_atom(to_disintegrate)
		INVOKE_ASYNC(src, .proc/disintegrate, to_disintegrate)
		return

	if(is_auto_disintegratable(my_turf))
		face_atom(my_turf)
		INVOKE_ASYNC(src, .proc/disintegrate, my_turf)
		return

	set_state(REPLICATOR_STATE_WANDERING)

/mob/living/simple_animal/replicator/proc/get_closest_harvesting_replicator()
	. = null
	var/closest_distance = null

	for(var/r in replicators)
		var/mob/living/simple_animal/replicator/R = r
		if(R == src)
			continue
		if(R.ckey)
			continue
		if(R.state != REPLICATOR_STATE_HARVESTING)
			continue

		var/dist = get_dist(src, R)

		if(closest_distance == null)
			. = R
			closest_distance = dist
			continue
		else if(dist < closest_distance)
			. = R
			closest_distance = dist

/mob/living/simple_animal/replicator/proc/get_closest_sentient_replicator()
	. = null
	var/closest_distance = null

	for(var/r in replicators)
		var/mob/living/simple_animal/replicator/R = r
		if(R == src)
			continue
		if(!R.ckey)
			continue

		var/dist = get_dist(src, R)

		if(closest_distance == null)
			. = R
			closest_distance = dist
			continue
		else if(dist < closest_distance)
			. = R
			closest_distance = dist

/mob/living/simple_animal/replicator/proc/is_auto_disintegratable(atom/A)
	if(A.name == "")
		return FALSE

	if(!A.simulated)
		return FALSE

	if(A.flags & NODECONSTRUCT)
		return FALSE

	if(A.invisibility > see_invisible)
		return FALSE

	if(!A.can_be_auto_disintegrated())
		return FALSE

	if(A.get_replicator_material_amount() < 0)
		return FALSE

	if(A.is_disintegrating)
		return FALSE

	if((locate(/mob/living) in A) && !isturf(A))
		return FALSE

	return TRUE

/mob/living/simple_animal/replicator/proc/find_most_clickable(turf/T)
	if(!T.contents.len)
		return null

	var/atom/most_clickable

	for(var/C in T.contents)
		var/atom/movable/A = C

		if(istype(A, /mob/living/simple_animal/replicator)) // && A.broken -> return A to repair
			continue

		if(!is_auto_disintegratable(A))
			continue

		if(!most_clickable)
			most_clickable = A
			continue

		if(A.plane > most_clickable.plane)
			most_clickable = A

		else if(A.plane == most_clickable.plane && A.layer > most_clickable.layer)
			most_clickable = A

	return most_clickable
