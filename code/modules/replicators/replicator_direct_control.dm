/mob/living/simple_animal/hostile/replicator/Crossed(atom/movable/AM)
	if(!isreplicator(AM))
		return ..()

	if(!set_leader(AM))
		return ..()

	return ..()

/mob/living/simple_animal/hostile/replicator/set_a_intent(new_intent)
	. = ..()
	if(new_intent != INTENT_HARM)
		return

	for(var/mob/living/simple_animal/hostile/replicator/R in loc)
		R.set_leader(src)

/mob/living/simple_animal/hostile/replicator/proc/set_leader(mob/living/simple_animal/hostile/replicator/R, alert=TRUE)
	if(is_controlled())
		return FALSE
	if(state == REPLICATOR_STATE_COMBAT)
		return FALSE
	if(incapacitated())
		return FALSE
	if(R.a_intent != INTENT_HARM)
		return FALSE
	if(!R.is_controlled())
		return FALSE
	if(R.controlling_drones >= REPLICATOR_MAX_CONTROLLED_DRONES)
		if(alert)
			to_chat(R, "<span class='notice'>You are already controlling a max capacity of [REPLICATOR_MAX_CONTROLLED_DRONES] drones.</span>")
		return FALSE
	if(leader)
		if(alert)
			to_chat(R, "<span class='notice'>They are already under an influence of some other presence.</span>")
		return FALSE

	leader = R
	set_last_controller(leader.ckey)

	leader.controlling_drones += 1

	RegisterSignal(R, list(COMSIG_CLIENTMOB_MOVING), PROC_REF(_repeat_leader_move))
	RegisterSignal(R, list(COMSIG_MOB_REGULAR_CLICK), PROC_REF(_repeat_leader_attack))
	RegisterSignal(R, list(COMSIG_MOB_SET_A_INTENT), PROC_REF(on_leader_intent_change))
	RegisterSignal(R, list(COMSIG_MOB_SET_M_INTENT), PROC_REF(on_leader_m_intent_change))
	RegisterSignal(R, list(COMSIG_MOB_DIED, COMSIG_LOGOUT, COMSIG_PARENT_QDELETING), PROC_REF(forget_leader))

	excitement = 30

	set_a_intent(leader.a_intent)
	set_m_intent(leader.m_intent)
	set_state(REPLICATOR_STATE_COMBAT)

	INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living, help_other), leader)

	clear_priority_target()
	LoseTarget()

	return TRUE

/mob/living/simple_animal/hostile/replicator/proc/forget_leader()
	SIGNAL_HANDLER

	leader.controlling_drones -= 1

	UnregisterSignal(leader, list(COMSIG_CLIENTMOB_MOVING, COMSIG_MOB_REGULAR_CLICK, COMSIG_MOB_SET_A_INTENT, COMSIG_MOB_SET_M_INTENT, COMSIG_MOB_DIED, COMSIG_LOGOUT, COMSIG_PARENT_QDELETING))
	leader = null

	set_state(REPLICATOR_STATE_HARVESTING)

/mob/living/simple_animal/hostile/replicator/proc/repeat_leader_move(datum/source, atom/NewLoc, move_dir)
	Move(get_step(get_turf(src), move_dir), move_dir)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living, help_other), leader)

/mob/living/simple_animal/hostile/replicator/proc/_repeat_leader_move(datum/source, atom/NewLoc, move_dir)
	SIGNAL_HANDLER

	var/atom/A = source
	if(loc != A.loc)
		forget_leader()
		return

	if(incapacitated())
		forget_leader()
		return

	if(!isturf(NewLoc))
		forget_leader()
		return

	excitement = 30

	repeat_leader_move(A, NewLoc, move_dir)

/mob/living/simple_animal/hostile/replicator/proc/repeat_leader_attack(datum/source, atom/target, params)
	face_atom(target)
	if(target.Adjacent(src))
		UnarmedAttack(target)
	else
		RangedAttack(target, params)

/mob/living/simple_animal/hostile/replicator/proc/_repeat_leader_attack(datum/source, atom/target, params)
	SIGNAL_HANDLER

	var/atom/A = source
	if(loc != A.loc)
		forget_leader()
		return

	if(!isturf(target) && !isturf(target.loc))
		return

	var/mob/living/simple_animal/hostile/replicator/R = source
	if(R.next_move > world.time)
		return
	if(next_move > world.time)
		return

	if(incapacitated())
		forget_leader()
		return

	excitement = 30

	var/fake_delay = 0
	if(next_pretend_delay_action < world.time && prob(50))
		fake_delay = rand(1, 2)
		next_pretend_delay_action = world.time + fake_delay + 1

	if(fake_delay > 0)
		addtimer(CALLBACK(src, PROC_REF(repeat_leader_attack), source, target, params), fake_delay)
		return
	repeat_leader_attack(source, target, params)

/mob/living/simple_animal/hostile/replicator/proc/on_leader_intent_change(datum/source, new_intent)
	SIGNAL_HANDLER
	if(new_intent != INTENT_HARM)
		forget_leader(source)

/mob/living/simple_animal/hostile/replicator/proc/on_leader_m_intent_change(datum/source, new_m_intent)
	SIGNAL_HANDLER
	set_m_intent(new_m_intent)
