/atom/proc/CanFluidPass(coming_from)
	return TRUE

/obj/machinery/door/CanFluidPass(coming_from)
	return !density

/obj/machinery/door/window/CanFluidPass(coming_from)
	if(get_dir(loc, coming_from) & dir)
		return !density
	return TRUE

/obj/structure/girder/CanFluidPass(coming_from)
	return TRUE

/obj/structure/inflatable/CanFluidPass(coming_from)
	return !density

/obj/structure/mineral_door/CanFluidPass(coming_from)
	return !density

/obj/structure/window/CanFluidPass(coming_from)
	return !density

/obj/structure/window/thin/CanFluidPass(coming_from)
	if(get_dir(loc, coming_from) & dir)
		return !density
	return TRUE

/turf/CanFluidPass(coming_from)
	if(flooded || density)
		return FALSE
	if(isnull(fluid_can_pass))
		fluid_can_pass = TRUE
		for(var/atom/movable/AM in src)
			if(AM.simulated && !AM.CanFluidPass(coming_from))
				fluid_can_pass = FALSE
				break
	return fluid_can_pass
