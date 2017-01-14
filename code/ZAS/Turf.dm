/turf/simulated/var/zone/zone
/turf/simulated/var/open_directions
/turf/simulated/var/gas_graphic

/turf/var/needs_air_update = 0
/turf/var/datum/gas_mixture/air

/turf/simulated/proc/set_graphic(new_graphic)
	if(isnum(new_graphic))
		if(new_graphic == 1) new_graphic = plmaster
		else if(new_graphic == 2) new_graphic = slmaster
	if(gas_graphic) overlays -= gas_graphic
	if(new_graphic) overlays += new_graphic
	gas_graphic = new_graphic

/turf/proc/update_air_properties()
	var/block = c_airblock(src)
	if(block & AIR_BLOCKED)
		//dbg(blocked)
		return 1

	#ifdef ZLEVELS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/unsim = get_step(src, d)

		if(!unsim)
			continue

		block = unsim.c_airblock(src)

		if(block & AIR_BLOCKED)
			//unsim.dbg(air_blocked, turn(180,d))
			continue

		var/r_block = c_airblock(unsim)

		if(r_block & AIR_BLOCKED)
			continue

		if(istype(unsim, /turf/simulated))

			var/turf/simulated/sim = unsim
			if(SSair.has_valid_zone(sim))

				SSair.connect(sim, src)

/*
	Simple heuristic for determining if removing the turf from it's zone may possibly partition the zone (A very bad thing).
	Instead of analyzing the entire zone, we only check the nearest 3x3 turfs surrounding the src turf.
	This implementation may produce false positives but it (hopefully) will not produce any false negatives.
*/

/turf/simulated/proc/can_safely_remove_from_zone()
	#ifdef ZLEVELS
	return 1 //not sure how to generalize this to multiz at the moment.
	#else

	if(!zone) return 0

	var/check_dirs = get_zone_neighbours(src)
	var/unconnected_dirs = check_dirs

	for(var/dir in list(NORTHWEST, NORTHEAST, SOUTHEAST, SOUTHWEST))

		//for each pair of "adjacent" cardinals (e.g. NORTH and WEST, but not NORTH and SOUTH)
		if((dir & check_dirs) == dir)
			//check that they are connected by the corner turf
			var/connected_dirs = get_zone_neighbours(get_step(src, dir))
			if(connected_dirs && (dir & turn(connected_dirs, 180)) == dir)
				unconnected_dirs &= ~dir //they are, so unflag the cardinals in question

	//it is safe to remove src from the zone if all cardinals are connected by corner turfs
	return !unconnected_dirs

	#endif

//helper for can_safely_remove_from_zone()
/turf/simulated/proc/get_zone_neighbours(turf/simulated/T)
	. = 0
	if(istype(T) && T.zone)
		for(var/dir in cardinal)
			var/turf/simulated/other = get_step(T, dir)
			if(istype(other) && other.zone == T.zone && !(other.c_airblock(T) & AIR_BLOCKED) && get_dist(src, other) <= 1)
				. |= dir

/turf/simulated/update_air_properties()
	if(zone && zone.invalid)
		c_copy_air()
		zone = null //Easier than iterating through the list at the zone.

	var/s_block = c_airblock(src)
	if(s_block & AIR_BLOCKED)
		#ifdef ZASDBG
		if(verbose)
			to_chat(world, "Self-blocked.")
		//dbg(blocked)
		#endif
		if(zone)
			var/zone/z = zone

			if(can_safely_remove_from_zone()) //Helps normal airlocks avoid rebuilding zones all the time
				z.remove(src)
			else
				z.rebuild()

		return 1

	var/previously_open = open_directions
	open_directions = 0

	var/list/postponed
	#ifdef ZLEVELS
	for(var/d = 1, d < 64, d *= 2)
	#else
	for(var/d = 1, d < 16, d *= 2)
	#endif

		var/turf/unsim = get_step(src, d)

		if(!unsim) //edge of map
			continue

		var/block = unsim.c_airblock(src)
		if(block & AIR_BLOCKED)

			#ifdef ZASDBG
			if(verbose)
				to_chat(world, "[d] is blocked.")
			//unsim.dbg(air_blocked, turn(180,d))
			#endif

			continue

		var/r_block = c_airblock(unsim)
		if(r_block & AIR_BLOCKED)

			#ifdef ZASDBG
			if(verbose)
				to_chat(world, "[d] is blocked.")
			//dbg(air_blocked, d)
			#endif

			//Check that our zone hasn't been cut off recently.
			//This happens when windows move or are constructed. We need to rebuild.
			if((previously_open & d) && istype(unsim, /turf/simulated))
				var/turf/simulated/sim = unsim
				if(zone && sim.zone == zone)
					zone.rebuild()
					return

			continue

		open_directions |= d

		if(istype(unsim, /turf/simulated))

			var/turf/simulated/sim = unsim
			sim.open_directions |= reverse_dir[d]

			if(SSair.has_valid_zone(sim))

				//Might have assigned a zone, since this happens for each direction.
				if(!zone)

					//if((block & ZONE_BLOCKED) || (r_block & ZONE_BLOCKED && !(s_block & ZONE_BLOCKED)))
					if(((block & ZONE_BLOCKED) && !(r_block & ZONE_BLOCKED)) || (r_block & ZONE_BLOCKED && !(s_block & ZONE_BLOCKED)))
						#ifdef ZASDBG
						if(verbose)
							to_chat(world, "[d] is zone blocked.")
						//dbg(zone_blocked, d)
						#endif

						//Postpone this tile rather than exit, since a connection can still be made.
						if(!postponed) postponed = list()
						postponed.Add(sim)

					else

						sim.zone.add(src)

						#ifdef ZASDBG
						dbg(assigned)
						if(verbose)
							to_chat(world, "Added to [zone]")
						#endif

				else if(sim.zone != zone)

					#ifdef ZASDBG
					if(verbose)
						to_chat(world, "Connecting to [sim.zone]")
					#endif

					SSair.connect(src, sim)


			#ifdef ZASDBG
				else if(verbose)
					to_chat(world, "[d] has same zone.")

			else if(verbose)
				to_chat(world, "[d] has invalid zone.")
			#endif

		else

			//Postponing connections to tiles until a zone is assured.
			if(!postponed) postponed = list()
			postponed.Add(unsim)

	if(!SSair.has_valid_zone(src)) //Still no zone, make a new one.
		var/zone/newzone = new/zone()
		newzone.add(src)

	#ifdef ZASDBG
		dbg(created)

	ASSERT(zone)
	#endif

	//At this point, a zone should have happened. If it hasn't, don't add more checks, fix the bug.

	for(var/turf/T in postponed)
		SSair.connect(src, T)

/turf/proc/post_update_air_properties()
	if(connections) connections.update_all()

/turf/assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
	return 0

/turf/return_air()
	//Create gas mixture to hold data for passing
	var/datum/gas_mixture/GM = new

	GM.oxygen = oxygen
	GM.carbon_dioxide = carbon_dioxide
	GM.nitrogen = nitrogen
	GM.phoron = phoron

	GM.temperature = temperature
	GM.update_values()

	return GM

/turf/remove_air(amount)
	var/datum/gas_mixture/GM = new

	var/sum = oxygen + carbon_dioxide + nitrogen + phoron
	if(sum>0)
		GM.oxygen = (oxygen/sum)*amount
		GM.carbon_dioxide = (carbon_dioxide/sum)*amount
		GM.nitrogen = (nitrogen/sum)*amount
		GM.phoron = (phoron/sum)*amount

	GM.temperature = temperature
	GM.update_values()

	return GM

/turf/simulated/assume_air(datum/gas_mixture/giver)
	var/datum/gas_mixture/my_air = return_air()
	my_air.merge(giver)

/turf/simulated/remove_air(amount)
	var/datum/gas_mixture/my_air = return_air()
	return my_air.remove(amount)

/turf/simulated/return_air()
	if(zone)
		if(!zone.invalid)
			SSair.mark_zone_update(zone)
			return zone.air
		else
			if(!air)
				make_air()
			c_copy_air()
			return air
	else
		if(!air)
			make_air()
		return air

/turf/proc/make_air()
	air = new/datum/gas_mixture
	air.temperature = temperature
	air.adjust(oxygen, carbon_dioxide, nitrogen, phoron)
	air.group_multiplier = 1
	air.volume = CELL_VOLUME

/turf/simulated/proc/c_copy_air()
	if(!air) air = new/datum/gas_mixture
	air.copy_from(zone.air)
	air.group_multiplier = 1
