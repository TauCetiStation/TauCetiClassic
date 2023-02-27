/datum/component/cross_teleport
	var/area/area_teleport_to
	var/turf/turf_teleport_to

/datum/component/cross_teleport/Initialize(area/t_area, turf/t_turf, timer_to_del = 0)
	area_teleport_to = t_area
	turf_teleport_to = t_turf
	if(timer_to_del > 0)
		QDEL_IN(src, timer_to_del)

	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED, COMSIG_ATOM_ENTERED), .proc/teleport_start)


/datum/component/cross_teleport/proc/teleport_start(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	var/turf/T = find_teleport_target()
	if(T)
		teleport_to(AM, T)

/datum/component/cross_teleport/proc/find_teleport_target()
	if(turf_teleport_to)
		return turf_teleport_to
	if(area_teleport_to)
		var/list/all_turfs = get_area_turfs(area_teleport_to, black_list=list(/turf/simulated/wall/r_wall, /turf/simulated/wall))
		for(var/turf/sort_turf in all_turfs)
			for(var/atom/A in sort_turf)
				if(A.density)
					all_turfs -= sort_turf
		if(all_turfs.len)
			var/turf/T = pick(all_turfs)
			return T

/datum/component/cross_teleport/proc/teleport_to(atom/movable/AM, turf/target_turf)
	AM.forceMove(target_turf)

/datum/component/cross_teleport/Destroy()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_CROSSED))
	return ..()

/datum/component/cross_teleport/religion
	var/datum/religion/religion
	var/list/whitelist_religions
	var/emp_atom = 1

/datum/component/cross_teleport/religion/Initialize(area/t_area, turf/t_turf, timer_to_del = 0, datum/religion/cur_religion_ref, list/religion_no_tp)
	whitelist_religions = religion_no_tp
	religion = cur_religion_ref
	return ..(t_area, t_turf, timer_to_del)

/datum/component/cross_teleport/religion/teleport_to(atom/movable/AM, turf/target_turf)
	if(ismob(AM))
		var/mob/M = AM
		if(whitelist_religions.len)
			if(M.my_religion in whitelist_religions)
				return
		new /atom/movable/screen/temp/cult_teleportation(M, M)
	if(religion)
		var/turf/atom_turf = get_turf(AM)
		playsound(atom_turf, 'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER)
		new religion.teleport_entry_vis(atom_turf)
		playsound(target_turf, 'sound/magic/Teleport_diss.ogg', VOL_EFFECTS_MASTER)
		new religion.teleport_exit_vis(target_turf)
	if(emp_atom)
		AM.emplode(emp_atom)
	return ..(AM, target_turf)
