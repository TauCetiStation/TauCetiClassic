// Nebula-dev\code\game\atoms_fluids.dm

/atom/proc/is_flooded(var/lying_mob, var/absolute)
	return

/atom/proc/fluid_act(var/datum/reagents/fluids)
	SHOULD_CALL_PARENT(TRUE)
	//if(reagents && reagents != fluids && fluids?.total_volume >= FLUID_SHALLOW && !is_watertight())
	//	reagents.trans_to_holder(fluids, reagents.total_volume)
	//	fluids.trans_to_holder(reagents, min(fluids.total_volume, reagents.maximum_volume))

/atom/proc/check_fluid_depth(var/min = 1)
	return 0

/atom/movable/proc/try_fluid_push(volume, strength)
	return simulated && !anchored

/atom/proc/get_fluid_depth()
	return 0

/atom/proc/fluid_update(var/ignore_neighbors)
	var/turf/T = get_turf(src)
	if(istype(T))
		T.fluid_update(ignore_neighbors)

/atom/movable/is_flooded(var/lying_mob, var/absolute)
	var/turf/T = get_turf(src)
	return T?.is_flooded(lying_mob, absolute)
