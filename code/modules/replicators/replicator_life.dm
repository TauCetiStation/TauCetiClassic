/mob/living/simple_animal/replicator
	var/state = REPLICATOR_STATE_HARVESTING

	var/list/target_coordinates

	var/request_help_until = 0

	var/help_steps = 7

	var/excitement = 10
	var/next_excitement_alert = 0
	var/excitement_alert_cooldown = 30 SECONDS

	var/next_attacked_alert = 0
	var/attacked_alert_cooldown = 30 SECONDS

	var/list/state2color = list(
		REPLICATOR_STATE_HARVESTING = "#ccff00",
		REPLICATOR_STATE_HELPING = "#00ffcc",
		REPLICATOR_STATE_WANDERING = "#cc00ff",
		REPLICATOR_STATE_GOING_TO_HELP = "#00ccff",
		REPLICATOR_STATE_COMBAT = "#cc0000",
	)

	var/next_pretend_delay_action = 0

	var/mob/living/simple_animal/replicator/leader

	var/next_consume_alert = 0

/mob/living/simple_animal/replicator/Life()
	. = ..()
	if(!.)
		return

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/RAI = FR.ckey2info[last_controller_ckey]
	if(ckey && RAI)
		if(FR.upgrades_amount > length(RAI.acquired_upgrades))
			throw_alert("swarm_upgrade", /atom/movable/screen/alert/swarm_upgrade)
		else
			clear_alert("swarm_upgrade")

	if(health < maxHealth * 0.2 && next_attacked_alert < world.time)
		emote("beep")
		var/area/A = get_area(src)
		FR.drone_message(src, "STRUCTURE INTEGRITY CRITICAL. LOCATION: [A.name].", transfer=TRUE)
		next_attacked_alert = world.time + attacked_alert_cooldown

	if(last_update_health - health > 1 && next_attacked_alert < world.time && !sacrifice_powering)
		emote("beep")
		var/area/A = get_area(src)
		FR.drone_message(src, "Structure integrity under threat. Location: [A.name].", transfer=TRUE)
		next_attacked_alert = world.time + attacked_alert_cooldown

	// All replicators are slowly dying. Eating obviously fixes them.
	// This fixes a lot of stupid tactics, such as:
	// - hiding a replicator somewhere in vents
	// - yeeting yourself into space
	if(last_disintegration + 1 MINUTE < world.time)
		var/taken_damage = FALSE
		if(!has_swarms_gift())
			take_bodypart_damage(0.0, 0.5)
			taken_damage = TRUE

		if(isspaceturf(loc))
			take_bodypart_damage(0.0, 1.5)
			taken_damage = TRUE

		if(stat == DEAD)
			FR.adjust_materials(REPLICATOR_COST_REPLICATE)
			gib()
			return

		if(taken_damage)
			throw_alert("swarm_hunger", /atom/movable/screen/alert/swarm_hunger)

		if(next_consume_alert < world.time && taken_damage)
			next_consume_alert = world.time + 20 SECONDS
			playsound_local(null, 'sound/effects/alert.ogg', VOL_EFFECTS_MASTER, 30 + 70 * (maxHealth - health) / maxHealth, null, CHANNEL_MUSIC, vary = FALSE, frequency = null, ignore_environment = TRUE)
			flash_color(src, flash_color="#ff0000", flash_time=5)
			to_chat(src, "<span class='danger'><font size=2>This world can not support your body for long. You must <b>consume</b> to survive.</font></span>")
	else
		clear_alert("swarm_hunger")

	last_update_health = health

	if(ckey)
		return

	if(!disintegrating && excitement <= 0 && next_excitement_alert < world.time)
		emote("beep")
		var/area/A = get_area(src)
		FR.drone_message(src, "Idleness value drift detected. Tasks requested at [A.name].", transfer=TRUE, dismantle=TRUE)
		next_excitement_alert = excitement_alert_cooldown + world.time

	if(state == REPLICATOR_STATE_COMBAT)
		excitement -= 1
		if(excitement <= 0)
			forget_leader(leader)
			excitement = 10

	if(state == REPLICATOR_STATE_COMBAT)
		return

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

/mob/living/simple_animal/replicator/proc/set_state(new_state)
	if(new_state == REPLICATOR_STATE_WANDERING)
		global.idle_replicators |= src
	else
		global.idle_replicators -= src

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
			locate(target_coordinates["x"], target_coordinates["y"], target_coordinates["z"]),
			-1
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

	excitement -= 1

	var/mob/living/simple_animal/replicator/harvester = get_closest_replicator(harvesting=TRUE)
	if(harvester && get_dist(src, harvester) < 7)
		var/turf/closer_turf = get_step_to(src, get_turf(harvester), -1)
		var/closer_dir = get_dir(src, closer_turf)
		Move(closer_turf, closer_dir)
		return

	var/mob/living/simple_animal/replicator/R = get_closest_replicator(sentient=TRUE)
	if(R && get_dist(src, R) < 7)
		var/turf/closer_turf = get_step_to(src, get_turf(R), -1)
		var/closer_dir = get_dir(src, closer_turf)
		Move(closer_turf, closer_dir)
		return

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

/mob/living/simple_animal/replicator/proc/get_closest_replicator(harvesting=FALSE, sentient=FALSE)
	. = null
	var/closest_distance = null

	for(var/r in global.alive_replicators)
		var/mob/living/simple_animal/replicator/R = r
		if(R == src)
			continue
		var/sentient_check_failed = sentient && !R.ckey
		if(sentient_check_failed)
			continue

		var/harvest_check_failed = harvesting && R.stat != REPLICATOR_STATE_HARVESTING
		if(harvest_check_failed)
			continue

		var/dist = get_dist(src, R)
		if(closest_distance == null)
			. = R
			closest_distance = dist
			continue
		else if(dist < closest_distance)
			. = R
			closest_distance = dist

/mob/living/simple_animal/replicator/proc/find_most_clickable(turf/T)
	if(!T.contents.len)
		return null

	var/atom/most_clickable

	for(var/C in T.contents)
		var/atom/movable/A = C

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
