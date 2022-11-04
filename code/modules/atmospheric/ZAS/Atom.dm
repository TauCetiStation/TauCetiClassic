
/atom/proc/CanPass(atom/movable/mover, turf/target, height = 1.5)
	//Purpose: Determines if the object (or airflow) can pass this atom.
	//Called by: Movement, airflow.
	//Inputs: The moving atom (optional), target turf, "height" and air group
	//Outputs: Boolean if can pass.
	var/retVal = SEND_SIGNAL(src, COMSIG_ATOM_CANPASS, mover, target, height)
	if(retVal & COMPONENT_CANTPASS)
		return FALSE
	else if(retVal & COMPONENT_CANPASS)
		return TRUE
	return (!density || !height)

#define CanPassFast(source, mover, target) (!source.density || source.CanPass(mover, target))
#define CanFlowFast(source, target, height) (!source.can_block_air || source.CanPass(null, target, height))

/turf/CanPass(atom/movable/mover, turf/target, height = 1.5)
	if(!target)
		return FALSE

	var/retVal = SEND_SIGNAL(src, COMSIG_ATOM_CANPASS, mover, target, height)
	if(retVal & COMPONENT_CANTPASS)
		return FALSE
	else if(retVal & COMPONENT_CANPASS)
		return TRUE

	if(istype(mover)) // turf/Enter(...) will perform more advanced checks
		return !density

	else // Now, doing more detailed checks for air movement and air group formation
		if(target.blocks_air||blocks_air)
			return FALSE

		for(var/obj/obstacle in src)
			if(!CanFlowFast(obstacle, target, height))
				return FALSE
		if(target != src)
			for(var/obj/obstacle in target)
				if(!CanFlowFast(obstacle, src, height))
					return FALSE

		return TRUE

//Convenience function for atoms to update turfs they occupy
/atom/movable/proc/update_nearby_tiles(need_rebuild)
	if(!SSair)
		return FALSE

	for(var/turf/simulated/turf in locs)
		SSair.mark_for_update(turf)

	return TRUE

//Basically another way of calling CanPass(null, other, 0, 0) and CanPass(null, other, 1.5, 1).
//Returns:
// 0 - Not blocked
// ZONE_BLOCKED - Not blocked, but zone boundaries will not cross.
// BLOCKED - Blocked
/atom/var/can_block_air = FALSE
/atom/proc/c_airblock(turf/other)
	#ifdef ZASDBG
	ASSERT(isturf(other))
	#endif
	if(CanPass(null, other, 0, 0))
		return ZONE_BLOCKED * !CanPass(null, other, 1.5, 1)
	return BLOCKED


/turf/c_airblock(turf/other)
	#ifdef ZASDBG
	ASSERT(isturf(other))
	#endif
	if(((blocks_air & AIR_BLOCKED) || (other.blocks_air & AIR_BLOCKED)))
		return BLOCKED

	//Z-level handling code. Always block if there isn't an open space.
	#ifdef MULTIZAS
	if(other.z != src.z)
		if(other.z < src.z)
			if(!istype(src, /turf/simulated/open))
				return BLOCKED
		else
			if(!istype(other, /turf/simulated/open))
				return BLOCKED
	#endif

	if(((blocks_air & ZONE_BLOCKED) || (other.blocks_air & ZONE_BLOCKED)))
		if(z == other.z)
			return ZONE_BLOCKED
		else
			return BLOCKED

	var/result = 0
	for(var/atom/movable/M in contents)
		if(M.can_block_air)
			result |= M.c_airblock(other)
			if(result == BLOCKED)
				return BLOCKED
	return result
