/obj/effect/decal/point/crystal
	name = "crystal"
	desc = "It's a crystal hanging in mid-air. Foreboding."
	icon = 'icons/mob/replicator.dmi'
	icon_state = "arrow"

/mob/living/simple_animal/hostile/replicator/point_at(atom/pointed_atom, arrow_type = /obj/effect/decal/point)
	for(var/mob/living/simple_animal/hostile/replicator/R as anything in global.alive_replicators)
		if(get_dist(src, R) > 7)
			continue
		R.set_priority_target(pointed_atom)

	return ..(pointed_atom, /obj/effect/decal/point/crystal)


/mob/living/simple_animal/hostile/replicator
	a_intent = INTENT_HELP

	attack_same = FALSE
	ranged = TRUE
	amount_shoot = 1

	move_to_delay = 4

	stop_automated_movement_when_pulled = FALSE

	mouse_opacity = MOUSE_OPACITY_ICON

	vision_range = 9

	aggro_vision_range = 9
	idle_vision_range = 9

	retreat_distance = 9
	minimum_distance = 9

	stat_attack = 1

	var/priority_target_ref

/mob/living/simple_animal/hostile/replicator/handle_combat_ai()
	if(state == REPLICATOR_STATE_COMBAT)
		return
	return ..()

/mob/living/simple_animal/hostile/replicator/AttackingTarget()
	SEND_SIGNAL(src, COMSIG_MOB_HOSTILE_ATTACKINGTARGET, target)

	if(can_disintegrate(target))
		INVOKE_ASYNC(src, .proc/disintegrate, target)
		return

	UnarmedAttack(target)

/mob/living/simple_animal/hostile/replicator/OpenFire(the_target)
	// TO-DO: randomize params so that all shots not in one spot on the walls.
	RangedAttack(the_target)

/mob/living/simple_animal/hostile/replicator/EscapeConfinement()
	if(buckled && can_disintegrate(buckled))
		INVOKE_ASYNC(src, .proc/disintegrate, buckled)
		return

	if(isturf(loc))
		return

	if(!can_disintegrate(loc))
		return

	INVOKE_ASYNC(src, .proc/disintegrate, loc)

/mob/living/simple_animal/hostile/replicator/proc/set_priority_target(atom/target)
	priority_target_ref = "\ref[target]"
	brave_up()

/mob/living/simple_animal/hostile/replicator/proc/clear_priority_target()
	priority_target_ref = null
	chill_down()

/mob/living/simple_animal/hostile/replicator/Found(atom/A)
	return "\ref[A]" == priority_target_ref

/mob/living/simple_animal/hostile/replicator/proc/brave_up()
	retreat_distance = null
	minimum_distance = 0

/mob/living/simple_animal/hostile/replicator/proc/chill_down()
	retreat_distance = 9
	minimum_distance = 9

/*
	Results in a somewhat stupid behavior, as the mobs don't know how to navigate the web after they get to the portal.

/mob/living/simple_animal/hostile/replicator/proc/get_closest_web_entry()
	. = null
	for(var/obj/machinery/swarm_powered/bluespace_transponder/BT as anything in global.active_transponders)
		if(get_dist(src, BT) > 7)
			continue
		if(!(locate(/obj/structure/bluespace_corridor) in BT.loc))
			continue
		if(!.)
			. = BT
		if(get_dist(src, .) >= get_dist(src, BT))
			continue
		. = BT

/mob/living/simple_animal/hostile/replicator/Retreat(target_distance)
	var/obj/machinery/swarm_powered/bluespace_transponder/BT = get_closest_web_entry()
	if(!BT)
		return ..()

	walk_to(src, BT, 0)
*/

/mob/living/simple_animal/hostile/replicator/LoseAggro()
	vision_range = idle_vision_range
