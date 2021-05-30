#define SLIPPERY_TIP "Is slippery."

/datum/mechanic_tip/slippery
	tip_name = SLIPPERY_TIP
	description = "This object will cause you to slip up if stepped on."



/datum/component/slippery
	var/weaken_time = 0
	var/lube_flags
	var/datum/callback/callback

/datum/component/slippery/Initialize(_weaken, _lube_flags = NONE, datum/callback/_callback)
	weaken_time = max(_weaken, 0)
	lube_flags = _lube_flags
	callback = _callback
	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), .proc/Slip)

	var/datum/mechanic_tip/slippery/slip_tip = new
	parent.AddComponent(/datum/component/mechanic_desc, list(slip_tip))

/datum/component/slippery/Destroy()
	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(SLIPPERY_TIP))
	return ..()

/datum/component/slippery/proc/Slip(datum/source, atom/movable/AM)
	var/mob/victim = AM
	if(istype(victim) && victim.slip(weaken_time, parent, lube_flags) && callback)
		callback.Invoke(victim)

#undef SLIPPERY_TIP
