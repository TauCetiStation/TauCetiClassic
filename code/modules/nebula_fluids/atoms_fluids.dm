// Nebula-dev\code\game\atoms_fluids.dm

/atom/proc/is_flooded(lying_mob, absolute)
	return

/atom/proc/fluid_act(datum/reagents/fluids)
	SHOULD_CALL_PARENT(TRUE)
	if(reagents && reagents != fluids && fluids?.total_volume >= FLUID_SHALLOW && !is_watertight())
		reagents.trans_to(fluids, reagents.total_volume)
		fluids.trans_to(reagents, min(fluids.total_volume, reagents.maximum_volume))

/atom/proc/check_fluid_depth(min = 1)
	return 0

/atom/movable/proc/try_fluid_push(volume, strength)
	return simulated && !anchored

/atom/proc/get_fluid_depth()
	return 0

/atom/movable/is_flooded(lying_mob, absolute)
	var/turf/T = get_turf(src)
	return T?.is_flooded(lying_mob, absolute)

/atom/proc/submerged(depth, above_turf)
	var/turf/T = get_turf(src)
	if(isnull(depth))
		if(!istype(T))
			return FALSE
		depth = T.get_fluid_depth()
	if(ismob(loc))
		return depth >= FLUID_SHALLOW
	if(isturf(loc))
		if(locate(/obj/structure/table))
			return depth >= FLUID_SHALLOW
		return depth >= 3
	return depth >= FLUID_OVER_MOB_HEAD

// This override exists purely because throwing is movable-level and not atom-level,
// for obvious reasons (that being that non-movable atoms cannot move).
/atom/movable/submerged(depth, above_turf)
	above_turf ||= immune_to_floor_hazards()
	return ..()

/obj/item/submerged(depth, above_turf)
	// we're in a mob and have a slot, so we bail early
	if(slot_equipped)
		var/mob/owner = loc // get_any_equipped_slot checks istype already
		if(owner.lying || owner.crawling)
			return ..() // treat us like an atom sitting on the ground (or table), really
		if(isnull(depth)) // copied from base proc, since we aren't calling parent in this block
			var/turf/T = get_turf(src)
			if(!istype(T))
				return FALSE
			depth = T.get_fluid_depth()
		return depth >= owner.get_item_fluid_height_slot(slot_equipped)
	return ..()

/mob/submerged(depth, above_turf)
	above_turf ||= immune_to_floor_hazards() // check throwing here because of the table check coming before parent call
	var/obj/structure/table/standing_on = locate(/obj/structure/table) in loc
	// can't stand on a table if we're floating
	if(!above_turf && standing_on && IS_ABOVE(src, standing_on))//standing_on.mob_offset > 0) // standing atop a table that is a meaningful amount above the ground (not a bench)
		if(isnull(depth)) // duplicated from atom because we don't call parent in this block
			var/turf/T = get_turf(src)
			if(!istype(T))
				return FALSE
			depth = T.get_fluid_depth()
		// assuming default tables are at waist height, this is a simple adjustment to scale it for taller/shorter ones
		return depth >= FLUID_SHALLOW//floor(FLUID_SHALLOW * (standing_on.mob_offset / /obj/structure/table::mob_offset))
	return ..()

// above_turf is nonsensical for turfs but I don't want the linter to complain
/turf/submerged(depth, above_turf)
	if(isnull(depth))
		depth = get_fluid_depth()
	return depth >= FLUID_OVER_MOB_HEAD

/atom/proc/fluid_update(ignore_neighbors)
	var/turf/T = get_turf(src)
	if(istype(T))
		T.fluid_update(ignore_neighbors)
