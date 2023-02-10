/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction
	icon = 'icons/atmos/junction.dmi'
	icon_state = "intact"
	pipe_icon = "hejunction"
	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_HE
	minimum_temperature_difference = 300
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

	device_type = BINARY

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/SetInitDirections()
	switch(dir)
		if(SOUTH)
			initialize_directions = NORTH
			initialize_directions_he = SOUTH
		if(NORTH)
			initialize_directions = SOUTH
			initialize_directions_he = NORTH
		if(EAST)
			initialize_directions = WEST
			initialize_directions_he = EAST
		if(WEST)
			initialize_directions = EAST
			initialize_directions_he = WEST

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/getNodeConnects()
	return list(turn(dir, 180), dir)

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/can_be_node(obj/machinery/atmospherics/target, iteration)
	var/init_dir
	switch(iteration)
		if(1)
			init_dir = target.initialize_directions
		if(2)
			var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/H = target
			if(!istype(H))
				return 0
			init_dir = H.initialize_directions_he
	if(init_dir & get_dir(target,src))
		return 1
