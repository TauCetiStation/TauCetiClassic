/datum/component/bell_death_alarm
	// the ring force
	var/force = 1

/datum/component/bell_death_alarm/Initialize(force = src.force)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	src.force = force
	RegisterSignal(parent, COMSIG_MOB_DIED, PROC_REF(on_parent_death))

/datum/component/bell_death_alarm/proc/on_parent_death()
	SIGNAL_HANDLER
	var/area/A = get_area(parent)
	var/mob/M = parent
	var/msg
	if(is_type_in_list(A, global.death_alarm_stealth_areas))
		//give the syndies a bit of stealth
		msg = "[M.real_name] has died in Space!"
	else
		msg = "[M.real_name] has died in [A.name]!"
	for(var/obj/effect/effect/bell/B as anything in global.bells)
		B.announce_global(msg, force)
	qdel(src)
