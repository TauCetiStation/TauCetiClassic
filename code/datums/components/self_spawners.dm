/datum/component/self_spawners
	var/timer_id = null
	var/wait_short
	var/wait_long
	var/spawner_type
	var/callback

/datum/component/self_spawners/Initialize(_spawner_type, logout_timeout = 5 MINUTES, ghost_timeout = 10 SECONDS)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	spawner_type = _spawner_type
	wait_short = ghost_timeout
	wait_long = logout_timeout
	callback = CALLBACK(src, .proc/setup_spawner)

	RegisterSignal(parent, list(COMSIG_LOGIN, COMSIG_MOB_DIED), .proc/del_timer)
	RegisterSignal(parent, COMSIG_LOGOUT, .proc/logout)

/datum/component/self_spawners/proc/del_timer()
	SIGNAL_HANDLER
	if(timer_id)
		deltimer(timer_id)
	timer_id = null

/datum/component/self_spawners/Destroy()
	del_timer()
	callback = null
	return ..()

/datum/component/self_spawners/proc/logout()
	SIGNAL_HANDLER
	var/mob/M = parent

	if(M.stat == DEAD)
		return

	var/wait = -1
	switch(M.logout_reason)
		if(LOGOUT_USER)
			wait = wait_long
		if(LOGOUT_GHOST)
			wait = wait_short

	if(wait > 0)
		timer_id = addtimer(callback, wait, TIMER_STOPPABLE)
	else if(wait == 0)
		setup_spawner()

/datum/component/self_spawners/proc/setup_spawner()
	timer_id = null
	var/mob/M = parent

	if(M.stat == DEAD)
		return

	create_spawner(spawner_type, parent)
