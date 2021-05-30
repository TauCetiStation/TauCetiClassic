/obj/effect/fluid/var/list/equalizing_fluids = list()
/obj/effect/fluid/var/equalize_avg_depth = 0
/obj/effect/fluid/var/equalize_avg_temp = 0

/obj/effect/fluid/proc/spread()
	if(!loc || loc != start_loc || !loc.CanFluidPass())
		qdel(src)
		return

	if(fluid_amount <= FLUID_EVAPORATION_POINT)
		return

	equalizing_fluids = list(src)
	for(var/spread_dir in cardinal)
		if(start_loc.get_fluid_blocking_dirs() & spread_dir)
			continue
		var/turf/T = get_step(start_loc, spread_dir)
		if(!istype(T) || T.flooded || (T.get_fluid_blocking_dirs() & reverse_dir[spread_dir]) || !T.CanFluidPass(spread_dir))
			continue
		var/obj/effect/fluid/F = locate() in T.contents
		if(F)
			if(QDELETED(F) || F.fluid_amount <= FLUID_DELETING)
				continue
		if(!F)
			F = new /obj/effect/fluid(T)
			F.temperature = temperature
		equalizing_fluids += F

/obj/effect/fluid/proc/equalize()

	if(!loc || loc != start_loc || fluid_amount <= FLUID_EVAPORATION_POINT)
		return

	equalize_avg_depth = 0
	equalize_avg_temp = 0
	for(var/obj/effect/fluid/F in equalizing_fluids)
		if(!istype(F) || QDELETED(F) || F.fluid_amount <= FLUID_DELETING)
			equalizing_fluids -= F
			continue
		equalize_avg_depth += F.fluid_amount
		equalize_avg_temp += F.temperature

	if(islist(equalizing_fluids) && equalizing_fluids.len > 1)
		equalize_avg_depth = FLOOR(equalize_avg_depth / equalizing_fluids.len, 1)
		equalize_avg_temp = FLOOR(equalize_avg_temp / equalizing_fluids.len, 1)
		for(var/obj/effect/fluid/F in equalizing_fluids)
			if(QDELETED(F))
				continue
			F.set_depth(equalize_avg_depth)
			F.temperature = equalize_avg_temp

	equalizing_fluids.Cut()

	if(istype(loc, /turf/space))
		lose_fluid(max((FLUID_EVAPORATION_POINT - 1), fluid_amount * 0.5))
		return

