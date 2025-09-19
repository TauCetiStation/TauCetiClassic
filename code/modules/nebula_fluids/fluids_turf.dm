// Nebula-dev\code\game\turfs\turf.dm

/turf
	// Fluid flow tracking vars
	var/last_slipperiness = 0
	var/last_flow_strength = 0
	var/last_flow_dir = 0
	var/obj/effect/fluid_overlay/fluid_overlay

/*/turf/proc/get_supporting_platform()
	if(isnull(supporting_platform))
		if(is_catwalk())
			supporting_platform = src
		//for(var/obj/structure/platform in get_contained_external_atoms())
		//	if(platform.is_platform())
		//		supporting_platform = platform
		//		break
	return supporting_platform*/