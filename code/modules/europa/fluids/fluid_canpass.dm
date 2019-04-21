
/atom/proc/CanFluidPass(coming_from)
	return TRUE

/turf/var/fluid_can_pass
/turf/CanFluidPass(coming_from)
	if(density)
		return FALSE
	if(isnull(fluid_can_pass))
		fluid_can_pass = 1
		for(var/atom/movable/AM in src)
			if(AM.simulated && !AM.CanFluidPass(coming_from))
				fluid_can_pass = 0
				break
	return fluid_can_pass

/obj/structure/inflatable/CanFluidPass(coming_from)
	return !density

/obj/structure/mineral_door/CanFluidPass(coming_from)
	return !density

/obj/structure/window/CanFluidPass(coming_from)
	if(coming_from == dir)
		return !density
	return TRUE

/obj/machinery/door/CanFluidPass(coming_from)
	return !density

/obj/machinery/door/window/CanFluidPass(coming_from)
	if(coming_from == dir || dir == SOUTHWEST || dir == SOUTHEAST || dir == NORTHWEST || dir == NORTHEAST)
		return !density
	return TRUE
