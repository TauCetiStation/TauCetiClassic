// Nebula-dev\code\game\turfs\turf_fluids.dm

/turf/proc/displace_all_reagents()
	UPDATE_FLUID_BLOCKED_DIRS(src)
	var/list/spread_into_neighbors
	var/turf/neighbor
	var/coming_from
	for(var/spread_dir in global.cardinal)
		if(fluid_blocked_dirs & spread_dir)
			continue
		neighbor = get_step(src, spread_dir)
		if(!neighbor)
			continue
		UPDATE_FLUID_BLOCKED_DIRS(neighbor)
		coming_from = global.reverse_dir[spread_dir]
		if((neighbor.fluid_blocked_dirs & coming_from) || !neighbor.CanFluidPass(coming_from) || neighbor.is_flooded(absolute = TRUE) || !neighbor.CanFluidPass(global.reverse_dir[spread_dir]))
			continue
		LAZYDISTINCTADD(spread_into_neighbors, neighbor)
	if(length(spread_into_neighbors))
		var/spreading = round(reagents.total_volume / length(spread_into_neighbors))
		if(spreading > 0)
			for(var/turf/spread_into_turf as anything in spread_into_neighbors)
				reagents.trans_to_turf(spread_into_turf, spreading)
	reagents?.clear_reagents()

/turf/proc/set_flooded(new_flooded, force = FALSE, skip_vis_contents_update = FALSE, mapload = FALSE)

	// Don't do unnecessary work.
	if(!simulated || (!force && new_flooded == flooded))
		return

	// Remove our old overlay if necessary.
	if(flooded && new_flooded != flooded && !skip_vis_contents_update)
		var/flood_object = get_flood_overlay(flooded)
		if(flood_object)
			vis_contents -= flood_object

	// Set our flood state.
	flooded = new_flooded
	if(flooded)
		QDEL_NULL(reagents)
		ADD_ACTIVE_FLUID_SOURCE(src)
		if(!skip_vis_contents_update)
			var/flood_object = get_flood_overlay(flooded)
			if(flood_object)
				vis_contents |= flood_object
	else if(!mapload)
		REMOVE_ACTIVE_FLUID_SOURCE(src)
		fluid_update() // We are now floodable, so wake up our neighbors.

/turf/is_flooded(lying_mob, absolute)
	if(flooded)
		return TRUE
	if(absolute)
		return FALSE
	var/required_depth = lying_mob ? FLUID_OVER_MOB_HEAD : FLUID_DEEP
	return check_fluid_depth(required_depth)

/turf/check_fluid_depth(var/min = 1)
	. = (get_fluid_depth() >= min)

/turf/get_fluid_depth()
	if(is_flooded(absolute=1))
		return FLUID_MAX_DEPTH
	return reagents?.total_volume || 0

/turf/fluid_update(ignore_neighbors)
	fluid_blocked_dirs = null
	fluid_can_pass = null
	if(!ignore_neighbors)
		for(var/checkdir in global.cardinal)
			var/turf/T = get_step(src, checkdir)
			if(T)
				T.fluid_update(TRUE)
	if(flooded)
		ADD_ACTIVE_FLUID_SOURCE(src)
	else if(reagents?.total_volume > FLUID_QDEL_POINT)
		ADD_ACTIVE_FLUID(src)

/turf/add_to_reagents(reagent_id, amount, data, safety = FALSE, datum/religion/_religion, defer_update = FALSE, phase = null)
	var/datum/reagent/fluid = GET_ABSTRACT_REAGENT(reagent_id)
	if(fluid.reagent_state != LIQUID)
		CRASH("proc tried to add non liquid reagent to turf. reagent:[fluid] reagent_state:[fluid.reagent_state]")
		return
	if(!reagents)
		create_reagents(FLUID_MAX_DEPTH)
	return ..()

/turf/proc/remove_fluids(amount, defer_update)
	if(!reagents?.total_liquid_volume)
		return
	remove_any_reagents(amount, defer_update = defer_update, removed_phases = MAT_PHASE_LIQUID)
	if(defer_update && !QDELETED(reagents))
		SSfluids.holders_to_update[reagents] = TRUE

/turf/proc/transfer_fluids_to(turf/target, amount, defer_update = TRUE)
	// No flowing of reagents without liquids, but this proc should not be called if liquids are not present regardless.
	if(!reagents?.total_liquid_volume)
		return
	if(!target.reagents)
		target.create_reagents(FLUID_MAX_DEPTH)

	// We reference total_volume instead of total_liquid_volume here because the maximum volume limits of the turfs still respect solid volumes, and depth is still determined by total volume.
	reagents.trans_to_turf(target, min(reagents.total_volume, min(target.reagents.maximum_volume - target.reagents.total_volume, amount)), defer_update = defer_update)
	if(defer_update)
		if(!QDELETED(reagents))
			SSfluids.holders_to_update[reagents] = TRUE
		if(!QDELETED(target.reagents))
			SSfluids.holders_to_update[target.reagents] = TRUE

/turf/simulated/on_reagent_change()

	if(!(. = ..()))
		return

	if(reagents?.total_volume > FLUID_QDEL_POINT)
		ADD_ACTIVE_FLUID(src)
		var/datum/reagent/primary_reagent = reagents.get_master_reagent()
		if(primary_reagent && primary_reagent.volume >= primary_reagent.slippery_amount)
			last_slipperiness = primary_reagent.slipperiness
		else
			last_slipperiness = 0
		if(!fluid_overlay)
			fluid_overlay = new(src, TRUE)
		fluid_overlay.update_icon()
		make_dry_floor()
	else
		QDEL_NULL(fluid_overlay)
		reagents?.clear_reagents()
		REMOVE_ACTIVE_FLUID(src)
		SSfluids.pending_flows -= src
		if(last_slipperiness > 0)
			make_wet_floor(last_slipperiness)
		last_slipperiness = 0

	for(var/checkdir in global.cardinal)
		var/turf/neighbor = get_step(src, checkdir)
		if(neighbor?.reagents?.total_volume > FLUID_QDEL_POINT)
			ADD_ACTIVE_FLUID(neighbor)
