/datum/component/slippery
	var/weaken_time = 0
	var/lube_flags
	var/datum/callback/callback

/datum/component/slippery/Initialize(_weaken, _lube_flags = NONE, datum/callback/_callback)
	weaken_time = max(_weaken, 0)
	lube_flags = _lube_flags
	callback = _callback
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), .proc/Slip)

/datum/component/slippery/proc/Slip(datum/source, atom/movable/AM)
	var/mob/victim = AM
	if(istype(victim) && victim.slip(weaken_time, parent, lube_flags) && callback)
		callback.Invoke(victim)
