/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction
	icon = 'icons/atmos/junction.dmi'
	icon_state = "intact"
	pipe_icon = "hejunction"
	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_HE
	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	device_type = BINARY

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/SetInitDirections()
	initialize_directions = dir|reverse_dir[dir]

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/getNodeConnects()
	return list(reverse_dir[dir], dir)

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/can_be_node(obj/machinery/atmospherics/target)
	var/searchDir
	if(istype(target, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
		searchDir = dir
	else
		searchDir = reverse_dir[dir]
	if((searchDir & get_dir(src, target)) && (target.initialize_directions & initialize_directions))
		return TRUE
	return FALSE
