/mob/living/simple_animal/hostile/replicator
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
		REPLICATOR_STATE_AI_COMBAT = "#cc0000",
	)

	var/next_pretend_delay_action = 0

	var/mob/living/simple_animal/hostile/replicator/leader

	var/next_consume_alert = 0

	var/next_combat_alert = 0
	var/combat_alert_cooldown = 1 MINUTE

	var/is_hungry = FALSE

	var/can_starve = FALSE
	var/breath_phoron = FALSE

	var/next_jamming_alert = 0
	var/jamming_alert_cooldown = 30 SECONDS

/mob/living/simple_animal/hostile/replicator/Life()
	. = ..()
	if(!.)
		return

	handle_breath()
	handle_status_updates()

	if(is_controlled())
		walk(src, 0)
		return

	if(incapacitated())
		walk(src, 0)
		return

	if(!disintegrating && excitement <= 0 && next_excitement_alert < world.time)
		next_excitement_alert = excitement_alert_cooldown + world.time

		emote("beep?")
		var/area/A = get_area(src)
		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		FR.drone_message(src, "Idleness value drift detected. Tasks requested at [A.name].", transfer=TRUE, dismantle=TRUE)

	if(state == REPLICATOR_STATE_AI_COMBAT)
		excitement -= 1
		if(excitement <= 0)
			clear_priority_target()
			LoseTarget()
			excitement = 10

	if(stance != HOSTILE_STANCE_IDLE)
		excitement = 30
		set_a_intent(INTENT_HARM)
		set_state(REPLICATOR_STATE_AI_COMBAT)

		if(next_combat_alert < world.time && !is_priority_target(target))
			next_combat_alert = world.time + combat_alert_cooldown

			emote("beep!")
			var/area/A = get_area(src)
			var/datum/faction/replicators/FR = get_or_create_replicators_faction()
			FR.drone_message(src, "Alert! Retreating from combat with [target.name] at: [A.name].", transfer=TRUE)

		return

	if(state == REPLICATOR_STATE_AI_COMBAT)
		set_a_intent(INTENT_HELP)
		set_state(REPLICATOR_STATE_HARVESTING)

	if(state == REPLICATOR_STATE_COMBAT)
		excitement -= 1
		if(excitement <= 0)
			forget_leader(leader)
			excitement = 10

	if(state == REPLICATOR_STATE_COMBAT)
		walk(src, 0)
		return

	if(state == REPLICATOR_STATE_HELPING)
		walk(src, 0)
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
	walk(src, 0)
	process_harvesting()

/mob/living/simple_animal/hostile/replicator/proc/handle_breath()
	if(last_disintegration + 1 MINUTE > world.time)
		return

	var/datum/gas_mixture/environment = loc.return_air()
	can_starve = TRUE
	breath_phoron = FALSE

	if(!environment)
		return

	if(environment.get_gas("fractol") >= 1.0)
		environment.adjust_gas("fractol", -1.0)
		can_starve = FALSE
		last_disintegration = world.time

	if(environment.get_gas("phoron") >= 1.0)
		environment.adjust_gas("phoron", -1.0)
		breath_phoron = TRUE

/mob/living/simple_animal/hostile/replicator/proc/handle_status_updates()
	var/color_to_flash = null

	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	var/datum/replicator_array_info/RAI = FR.ckey2info[last_controller_ckey]
	if(is_controlled() && RAI)
		if(FR.upgrades_amount > length(RAI.acquired_upgrades))
			throw_alert("swarm_upgrade", /atom/movable/screen/alert/swarm_upgrade)
		else
			clear_alert("swarm_upgrade")

	if(health < maxHealth * 0.2 && next_attacked_alert < world.time && !is_controlled() && state != REPLICATOR_STATE_COMBAT)
		emote("beep!")
		var/area/A = get_area(src)
		FR.drone_message(src, "STRUCTURE INTEGRITY CRITICAL. LOCATION: [A.name].", transfer=TRUE)
		next_attacked_alert = world.time + attacked_alert_cooldown

	if(last_update_health - health > 1 && next_attacked_alert < world.time && !sacrifice_powering && !is_controlled() && state != REPLICATOR_STATE_COMBAT)
		emote("beep")
		var/area/A = get_area(src)
		FR.drone_message(src, "Structure integrity under threat. Location: [A.name].", transfer=TRUE)
		next_attacked_alert = world.time + attacked_alert_cooldown

	var/turf/T = get_turf(src)
	if(can_starve && SEND_SIGNAL(T, COMSIG_ATOM_INTERCEPT_TELEPORT))
		if(next_jamming_alert < world.time)
			next_jamming_alert = world.time + jamming_alert_cooldown
			to_chat(src, "<span class='bold warning'>You feel your essence being jammed by a teleportation supressor nearby!</span>")
			color_to_flash = "#0000ff"

		take_bodypart_damage(0.0, maxHealth / 12.5)

		if(stat == DEAD)
			if(!isspaceturf(loc))
				FR.adjust_materials(REPLICATOR_COST_REPLICATE)
			gib()
			return

	// All replicators are slowly dying. Eating obviously fixes them.
	// This fixes a lot of stupid tactics, such as:
	// - hiding a replicator somewhere in vents
	// - yeeting yourself into space
	if(can_starve && last_disintegration + 1 MINUTE < world.time)
		var/taken_damage = FALSE
		if(!has_swarms_gift())
			take_bodypart_damage(0.0, maxHealth / 120)
			taken_damage = TRUE

		if(isspaceturf(loc))
			take_bodypart_damage(0.0, maxHealth / 20)
			taken_damage = TRUE

		if(stat == DEAD)
			if(!isspaceturf(loc))
				FR.adjust_materials(REPLICATOR_COST_REPLICATE)
			gib()
			return

		if(taken_damage)
			is_hungry = TRUE
			throw_alert("swarm_hunger", /atom/movable/screen/alert/swarm_hunger)

		if(next_consume_alert < world.time && taken_damage)
			next_consume_alert = world.time + 20 SECONDS
			playsound_local(null, 'sound/effects/alert.ogg', VOL_EFFECTS_MASTER, 15 + 60 * (maxHealth - health) / maxHealth, null, CHANNEL_MUSIC, vary = FALSE, frequency = null, ignore_environment = TRUE)
			color_to_flash = "#ff0000"
			to_chat(src, "<span class='danger'><font size=2>This world can not support your body for long. You must <b>consume</b> to survive.</font></span>")
	else
		is_hungry = FALSE
		clear_alert("swarm_hunger")

	if(color_to_flash)
		flash_color(src, flash_color=color_to_flash, flash_time=5)

	last_update_health = health

/mob/living/simple_animal/hostile/replicator/proc/set_state(new_state)
	if(new_state == REPLICATOR_STATE_WANDERING)
		global.idle_replicators |= src
	else
		global.idle_replicators -= src

	if(new_state != REPLICATOR_STATE_WANDERING && new_state != REPLICATOR_STATE_GOING_TO_HELP && new_state != REPLICATOR_STATE_AI_COMBAT)
		target_coordinates = null
		walk(src, 0)

	excitement = 10
	state = new_state
	update_icon()

/mob/living/simple_animal/hostile/replicator/get_active_skillset()
	return skills.active

/mob/living/simple_animal/hostile/replicator/on_start_help_other(mob/living/target)
	if(state == REPLICATOR_STATE_COMBAT)
		return
	set_state(REPLICATOR_STATE_HELPING)

/mob/living/simple_animal/hostile/replicator/on_stop_help_other(mob/living/target)
	if(state == REPLICATOR_STATE_COMBAT)
		return
	set_state(REPLICATOR_STATE_HARVESTING)

/mob/living/simple_animal/hostile/replicator/proc/process_going_to_help()
	if(!target_coordinates)
		set_state(REPLICATOR_STATE_HARVESTING)
		return

	if(x != target_coordinates["x"] || y != target_coordinates["y"] || z != target_coordinates["z"])
		var/turf/T = locate(target_coordinates["x"], target_coordinates["y"], target_coordinates["z"])
		Goto(T, move_to_delay, 0)

		help_steps--
		if(help_steps < 0)
			help_steps = 7
			set_state(REPLICATOR_STATE_HARVESTING)
		return

	target_coordinates = null

	for(var/mob/living/simple_animal/hostile/replicator/R in loc)
		if(!R.is_controlled())
			continue
		if(R.request_help_until < world.time)
			continue

		face_atom(R)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living, help_other), R)
		return

/mob/living/simple_animal/hostile/replicator/proc/check_any_auto_disintegratables(turf/T)
	if(can_auto_disintegrate(T))
		return TRUE

	for(var/atom/A in T)
		if(!can_auto_disintegrate(A))
			continue
		return TRUE

	return FALSE

/mob/living/simple_animal/hostile/replicator/proc/move_to_target_coordinates()
	if(!target_coordinates)
		return FALSE

	if(x == target_coordinates["x"] && y == target_coordinates["y"] && z == target_coordinates["z"])
		target_coordinates = null
		return FALSE

	Goto(locate(target_coordinates["x"], target_coordinates["y"], target_coordinates["z"]), move_to_delay, 0)
	return TRUE

/mob/living/simple_animal/hostile/replicator/proc/check_can_move_to(atom/A, max_steps=2)
	var/turf/target = get_turf(A)
	var/turf/curr = get_turf(src)
	for(var/i in 1 to max_steps)
		curr = get_step_to(curr, target, -1)
		if(curr == target || get_dist(curr, target) <= 1)
			return TRUE
	return FALSE

/mob/living/simple_animal/hostile/replicator/proc/process_wandering()
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

	if(move_to_target_coordinates())
		return

	for(var/turf/T in BORDER_TURFS(2, src))
		if(!check_can_move_to(T))
			continue

		if(!check_any_auto_disintegratables(T))
			continue

		target_coordinates = list("x"=T.x, "y"=T.y, "z"=T.z)
		move_to_target_coordinates()
		return

	var/mob/living/simple_animal/hostile/replicator/harvester = get_closest_replicator(harvesting=TRUE)
	if(harvester && get_dist(src, harvester) < 7)
		Goto(get_turf(harvester), move_to_delay, 0)
		return

	var/mob/living/simple_animal/hostile/replicator/R = get_closest_replicator(sentient=TRUE)
	if(R && get_dist(src, R) < 7)
		Goto(get_turf(R), move_to_delay, 0)
		return

	var/closest_replicator_dir = R ? get_dir(src, R) : pick(cardinal)
	var/to_move_dir = pick(list(closest_replicator_dir) + cardinal)
	Move(get_step(src, to_move_dir), to_move_dir)

/mob/living/simple_animal/hostile/replicator/proc/process_harvesting()
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
		INVOKE_ASYNC(src, PROC_REF(disintegrate), to_disintegrate)
		return

	for(var/t in surrounding_turfs)
		var/turf/T = t
		if(T == my_turf)
			continue
		if(!can_auto_disintegrate(T))
			continue
		face_atom(T)
		INVOKE_ASYNC(src, PROC_REF(disintegrate), T)
		return

	var/to_disintegrate = find_most_clickable(my_turf)
	if(to_disintegrate)
		face_atom(to_disintegrate)
		INVOKE_ASYNC(src, PROC_REF(disintegrate), to_disintegrate)
		return

	if(can_auto_disintegrate(my_turf))
		face_atom(my_turf)
		INVOKE_ASYNC(src, PROC_REF(disintegrate), my_turf)
		return

	set_state(REPLICATOR_STATE_WANDERING)

/mob/living/simple_animal/hostile/replicator/proc/get_closest_replicator(harvesting=FALSE, sentient=FALSE)
	. = null
	var/closest_distance = null

	for(var/r in global.alive_replicators)
		var/mob/living/simple_animal/hostile/replicator/R = r
		if(R == src)
			continue
		var/sentient_check_failed = sentient && !R.is_controlled()
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

/mob/living/simple_animal/hostile/replicator/proc/find_most_clickable(turf/T)
	if(!T.contents.len)
		return null

	var/atom/most_clickable

	for(var/C in T.contents)
		var/atom/movable/A = C

		if(!can_auto_disintegrate(A))
			continue

		if(!most_clickable)
			most_clickable = A
			continue

		if(A.plane > most_clickable.plane)
			most_clickable = A

		else if(A.plane == most_clickable.plane && A.layer > most_clickable.layer)
			most_clickable = A

	return most_clickable
