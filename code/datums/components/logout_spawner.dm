/datum/component/logout_spawner
	var/timer_id = null
	var/wait_logout
	var/wait_ghost
	var/spawner_type

/datum/component/logout_spawner/Initialize(_spawner_type, logout_timeout = 5 MINUTES, ghost_timeout = 10 SECONDS)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	spawner_type = _spawner_type
	wait_logout = logout_timeout
	wait_ghost = ghost_timeout

	RegisterSignal(parent, list(COMSIG_LOGIN, COMSIG_MOB_DIED), PROC_REF(del_timer))
	RegisterSignal(parent, COMSIG_LOGOUT, PROC_REF(logout))

/datum/component/logout_spawner/proc/del_timer()
	SIGNAL_HANDLER
	if(timer_id)
		deltimer(timer_id)
	timer_id = null

/datum/component/logout_spawner/Destroy()
	UnregisterSignal(parent, list(COMSIG_LOGIN, COMSIG_MOB_DIED, COMSIG_LOGOUT))
	del_timer()
	return ..()

/datum/component/logout_spawner/proc/logout(datum/source, logout_reason)
	SIGNAL_HANDLER
	var/mob/M = parent

	if(M.stat == DEAD)
		return

	var/wait = -1
	switch(logout_reason)
		if(LOGOUT_USER)
			wait = wait_logout
		if(LOGOUT_GHOST)
			wait = wait_ghost

	if(wait > 0)
		timer_id = addtimer(CALLBACK(src, PROC_REF(setup_spawner)), wait, TIMER_STOPPABLE)
	else if(wait == 0)
		setup_spawner()

/datum/component/logout_spawner/proc/setup_spawner()
	timer_id = null
	var/mob/M = parent

	if(M.stat == DEAD)
		return

	create_spawner(spawner_type, parent)
