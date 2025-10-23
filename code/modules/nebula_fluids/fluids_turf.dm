// Nebula-dev\code\game\turfs\turf.dm

/turf
	// Fluid flow tracking vars
	var/last_slipperiness = 0
	var/last_flow_strength = 0
	var/last_flow_dir = 0
	var/obj/effect/fluid_overlay/fluid_overlay
