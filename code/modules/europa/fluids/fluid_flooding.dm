/turf/proc/make_flooded()
	if(!flooded)
		flooded = 1
		for(var/obj/effect/fluid/F in src)
			qdel(F)
		update_icon()

/turf/proc/flood_neighbors(dry_run)
	var/flooded_a_neighbor
	for(var/spread_dir in cardinal)
		if(get_fluid_blocking_dirs() & spread_dir)
			continue
		var/turf/T = get_step(src, spread_dir)
		if(!istype(T) || T.flooded || (T.get_fluid_blocking_dirs() & reverse_dir[spread_dir]) || !T.CanFluidPass(spread_dir))
			continue
		var/obj/effect/fluid/F = locate() in T
		if(!F && !dry_run)
			F = new /obj/effect/fluid(T)
			var/datum/gas_mixture/GM = return_air()
			if(GM)
				F.temperature = GM.temperature
		if(F)
			if(F.fluid_amount >= FLUID_MAX_DEPTH)
				continue
			if(!dry_run)
				F.set_depth(FLUID_MAX_DEPTH)

		flooded_a_neighbor = 1

	if(!flooded_a_neighbor)
		SSfluids.remove_active_source(src)

	return flooded_a_neighbor

/atom/movable/is_flooded(lying_mob, absolute)
	var/turf/T = get_turf(src)
	return T.is_flooded(lying_mob)

/turf/is_flooded(lying_mob, absolute)
	return (flooded || (!absolute && check_fluid_depth(lying_mob ? FLUID_SHALLOW : FLUID_DEEP)))
