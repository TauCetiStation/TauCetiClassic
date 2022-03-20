/datum/component/self_spawners
	var/timer_id = null
	var/wait
	var/spawner_id
	var/callback

/datum/component/self_spawners/Initialize(id, timeout)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	spawner_id = id
	wait = timeout
	callback = CALLBACK(src, .proc/setup_spawner)

	RegisterSignal(parent, COMSIG_LOGIN, .proc/del_timer)
	RegisterSignal(parent, COMSIG_LOGOUT, .proc/logout)

/datum/component/self_spawners/proc/del_timer()
	SIGNAL_HANDLER
	deltimer(timer_id)
	timer_id = null

/datum/component/self_spawners/Destroy()
	del_timer()
	callback = null
	return ..()

/datum/component/self_spawners/proc/logout()
	SIGNAL_HANDLER
	timer_id = addtimer(callback, wait, TIMER_STOPPABLE)

/datum/component/self_spawners/proc/setup_spawner()
	timer_id = null

	create_spawner(/datum/spawner/living, spawner_id, parent)
