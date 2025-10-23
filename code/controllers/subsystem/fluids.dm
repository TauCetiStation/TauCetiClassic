SUBSYSTEM_DEF(fluids)
	name = "Fluids"

	init_order    = SS_INIT_FLUIDS
	priority      = SS_PRIORITY_FLUIDS
	wait          = SS_WAIT_FLUIDS

	flags = SS_NO_INIT | SS_BACKGROUND | SS_POST_FIRE_TIMING | SS_SHOW_IN_MC_TAB
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT // So we can flush our queued activity during lobby setup on ocean maps.

	var/tmp/list/water_sources =       list()
	var/tmp/fluid_sources_copied_yet = FALSE
	var/tmp/list/processing_sources

	var/tmp/list/pending_flows =       list()
	var/tmp/flows_copied_yet =         FALSE
	var/tmp/list/processing_flows

	var/tmp/list/holders_to_update =   list()
	var/tmp/holders_copied_yet =       FALSE
	var/tmp/list/processing_holders

	var/tmp/list/active_fluids =       list()
	var/tmp/active_fluids_copied_yet = FALSE
	var/tmp/list/processing_fluids

	var/tmp/list/checked_targets =     list()
	var/tmp/list/gurgles =             list(
		'sound/effects/gurgle1.ogg',
		'sound/effects/gurgle2.ogg',
		'sound/effects/gurgle3.ogg',
		'sound/effects/gurgle4.ogg'
	)

/datum/controller/subsystem/fluids/stat_entry()
	..("AF:[active_fluids.len]|FS:[water_sources.len]")

/datum/controller/subsystem/fluids/fire(resumed = 0)
	if(!resumed)
		active_fluids_copied_yet = FALSE
		holders_copied_yet =       FALSE
		flows_copied_yet =         FALSE
		fluid_sources_copied_yet = FALSE
		checked_targets.Cut()

	if(!fluid_sources_copied_yet)
		fluid_sources_copied_yet = TRUE
		processing_sources = water_sources.Copy()

	// Predeclaring a bunch of vars for performance purposes.
	var/flooded_a_neighbor            = FALSE
	var/spread_dir                    = 0
	var/i                             = 0
	var/turf/current_fluid_holder     = null
	var/datum/reagents/reagent_holder = null
	var/turf/neighbor                 = null
	var/turf/lowest_neighbor          = null

	while(i < processing_sources.len)
		i++
		current_fluid_holder = processing_sources[i]

		flooded_a_neighbor = FALSE
		UPDATE_FLUID_BLOCKED_DIRS(current_fluid_holder)
		for(spread_dir in global.cardinal)
			if(current_fluid_holder.fluid_blocked_dirs & spread_dir)
				continue
			neighbor = get_step(current_fluid_holder, spread_dir)
			if(!istype(neighbor) || neighbor.flooded)
				continue
			UPDATE_FLUID_BLOCKED_DIRS(neighbor)
			if((neighbor.fluid_blocked_dirs & global.reverse_dir[spread_dir]) || !neighbor.CanFluidPass(spread_dir) || checked_targets[neighbor])
				continue
			checked_targets[neighbor] = TRUE
			flooded_a_neighbor = TRUE
			neighbor.add_to_reagents(current_fluid_holder.flooded, FLUID_MAX_DEPTH)

		if(!flooded_a_neighbor)
			REMOVE_ACTIVE_FLUID_SOURCE(current_fluid_holder)

		if (MC_TICK_CHECK)
			processing_sources.Cut(1, i+1)
			return
	processing_sources.Cut()

	if(!active_fluids_copied_yet)
		active_fluids_copied_yet = TRUE
		processing_fluids = active_fluids.Copy()

	var/removing                = 0
	var/coming_from             = 0
	var/flow_amount             = 0
	var/current_depth           = 0
	var/current_turf_depth      = 0
	var/neighbor_depth          = 0
	var/lowest_neighbor_flow    = 0
	var/lowest_neighbor_depth   = INFINITY
	var/turf/other_fluid_holder = null

	i = 0
	while(i < processing_fluids.len)
		i++
		current_fluid_holder = processing_fluids[i]

		if(QDELETED(current_fluid_holder) || !current_fluid_holder.reagents?.total_volume)
			REMOVE_ACTIVE_FLUID(current_fluid_holder)
			continue

		if(!current_fluid_holder.CanFluidPass())
			current_fluid_holder.displace_all_reagents()
			continue

		reagent_holder = current_fluid_holder.reagents
		UPDATE_FLUID_BLOCKED_DIRS(current_fluid_holder)
		current_depth = reagent_holder?.total_volume || 0

		// How is this happening
		if(QDELETED(reagent_holder) || current_depth == -1.#IND || current_depth == 1.#IND)
			REMOVE_ACTIVE_FLUID(current_fluid_holder)
			continue

		// Evaporation: todo, move liquid into current_fluid_holder.zone air contents if applicable.
		if(current_depth <= FLUID_PUDDLE && prob(60))
			current_fluid_holder.remove_fluids(min(current_depth, 1), defer_update = TRUE)
			current_depth = current_fluid_holder.get_fluid_depth()

		if(current_depth <= FLUID_QDEL_POINT)
			current_fluid_holder.reagents?.clear_reagents()
			REMOVE_ACTIVE_FLUID(current_fluid_holder)
			continue

		// Wash our turf.
		current_fluid_holder.fluid_act(reagent_holder)

		if(isspaceturf(current_fluid_holder) || (isfloorturf(current_fluid_holder) && (current_fluid_holder.turf_flags & TURF_FLAG_ABSORB_LIQUID) && (current_fluid_holder.reagents?.total_volume) > 0))
			removing = round(current_depth * 0.5)
			if(removing > 0)
				current_fluid_holder.remove_fluids(removing, defer_update = TRUE)
			else
				reagent_holder.clear_reagents()
			current_depth = current_fluid_holder.get_fluid_depth()
			if(current_depth <= FLUID_QDEL_POINT)
				current_fluid_holder.reagents?.clear_reagents()
				REMOVE_ACTIVE_FLUID(current_fluid_holder)
				continue

		// Flow into the lowest level neighbor.
		lowest_neighbor_depth = INFINITY
		lowest_neighbor_flow =  0
		current_turf_depth = current_depth/* + current_fluid_holder.get_physical_height()*/
		for(spread_dir in global.cardinal)
			if(current_fluid_holder.fluid_blocked_dirs & spread_dir)
				continue
			neighbor = get_step(current_fluid_holder, spread_dir)
			if(!neighbor)
				continue
			UPDATE_FLUID_BLOCKED_DIRS(neighbor)
			coming_from = global.reverse_dir[spread_dir]
			if((neighbor.fluid_blocked_dirs & coming_from) || !neighbor.CanFluidPass(coming_from) || neighbor.is_flooded(absolute = TRUE) || !neighbor.CanFluidPass(global.reverse_dir[spread_dir]))
				continue
			other_fluid_holder = neighbor
			neighbor_depth = (other_fluid_holder?.reagents?.total_volume || 0)// + neighbor.get_physical_height()
			flow_amount = round((current_turf_depth - neighbor_depth)*0.5)
			// TODO: multiply flow amount or minimum transfer amount by some
			// viscosity calculation to allow for piles of jelly vs piles of water.
			if(flow_amount <= FLUID_MINIMUM_TRANSFER)
				continue
			ADD_ACTIVE_FLUID(neighbor)
			if(neighbor_depth < lowest_neighbor_depth || (neighbor_depth == lowest_neighbor_depth && prob(50)))
				lowest_neighbor = neighbor
				lowest_neighbor_depth = neighbor_depth
				lowest_neighbor_flow = flow_amount

		if(current_depth <= FLUID_PUDDLE)
			continue

		if(lowest_neighbor && lowest_neighbor_flow)
			current_fluid_holder.transfer_fluids_to(lowest_neighbor, lowest_neighbor_flow)
			pending_flows[current_fluid_holder] = TRUE
			if(lowest_neighbor_flow >= FLUID_PUSH_THRESHOLD)
				current_fluid_holder.last_flow_strength = lowest_neighbor_flow
				current_fluid_holder.last_flow_dir = get_dir(current_fluid_holder, lowest_neighbor)
			else
				current_fluid_holder.last_flow_strength = 0
				current_fluid_holder.last_flow_dir = 0
		else
			// We aren't interacting with a neighbor this time, so we can likely sleep.
			REMOVE_ACTIVE_FLUID(current_fluid_holder)

		if (MC_TICK_CHECK)
			processing_fluids.Cut(1, i+1)
			return
	processing_fluids.Cut()

	if(!holders_copied_yet)
		holders_copied_yet = TRUE
		processing_holders = holders_to_update.Copy()

	i = 0
	while(i < processing_holders.len)
		i++
		reagent_holder = processing_holders[i]
		reagent_holder.handle_update()
		if(MC_TICK_CHECK)
			processing_holders.Cut(1, i+1)
			return
	processing_holders.Cut()

	if(!flows_copied_yet)
		flows_copied_yet = TRUE
		processing_flows = pending_flows.Copy()

	i = 0
	while(i < processing_flows.len)
		i++
		current_fluid_holder = processing_flows[i]
		if(!istype(current_fluid_holder) || QDELETED(current_fluid_holder))
			continue
		var/pushed_something = FALSE

		if(current_fluid_holder.last_flow_strength >= 10)
			// Catwalks mean items will be above the turf; subtract the turf height from our volume.
			// TODO: somehow handle stuff that is on a catwalk or on the turf within the same turf.
			var/effective_volume = current_fluid_holder.reagents?.total_volume
			//if(current_fluid_holder.get_supporting_platform())
				// Depth is negative height, hence +=. TODO: positive heights? No idea how to handle that.
			//	effective_volume += current_fluid_holder.get_physical_height()
			if(effective_volume > FLUID_SHALLOW)
				for(var/atom/movable/AM as anything in current_fluid_holder.contents)//get_contained_external_atoms())
					if(!QDELETED(AM) && AM.try_fluid_push(effective_volume, current_fluid_holder.last_flow_strength))
						AM.pushed(current_fluid_holder.last_flow_dir)
						pushed_something = TRUE
			if(pushed_something && prob(1))
				playsound(current_fluid_holder, 'sound/effects/slosh.ogg', 25, 1)
		if(MC_TICK_CHECK)
			processing_flows.Cut(1, i+1)
			return
	processing_flows.Cut()
