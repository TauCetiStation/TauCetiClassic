/obj/machinery/atmospherics/components/trinary
	dir = SOUTH
	initialize_directions = SOUTH|NORTH|WEST
	use_power = NO_POWER_USE

	device_type = TRINARY
	layer = GAS_FILTER_LAYER

/obj/machinery/atmospherics/components/trinary/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = EAST|NORTH|SOUTH
		if(SOUTH)
			initialize_directions = SOUTH|WEST|NORTH
		if(EAST)
			initialize_directions = EAST|WEST|SOUTH
		if(WEST)
			initialize_directions = WEST|NORTH|EAST

/*
	Housekeeping and pipe network stuff
*/

/obj/machinery/atmospherics/components/trinary/getNodeConnects()

	//Mixer:
	//1 and 2 is input
	//Node 3 is output
	//For mirrored or other version refer with icons.

	//Filter:
	//Node 1 is input
	//Node 2 is filtered output
	//Node 3 is rest output
	//For mirrored or other version refer with icons.

	var/node1_connect = turn(dir, -180)
	var/node2_connect = turn(dir, -90)
	var/node3_connect = dir

	return list(node1_connect, node2_connect, node3_connect)

/obj/machinery/atmospherics/components/trinary/filter/m_filter/getNodeConnects()
	var/node1_connect = turn(dir, 180)
	var/node2_connect = turn(dir, 90)
	var/node3_connect = dir

	return list(node1_connect, node2_connect, node3_connect)

/obj/machinery/atmospherics/components/trinary/mixer/m_mixer/getNodeConnects()
	var/node1_connect = turn(dir, 180)
	var/node2_connect = turn(dir, 90)
	var/node3_connect = dir

	return list(node1_connect, node2_connect, node3_connect)

/obj/machinery/atmospherics/components/trinary/mixer/t_mixer/getNodeConnects()
	var/node1_connect = turn(dir, -90)
	var/node2_connect = dir
	var/node3_connect = turn(dir, 90)

	return list(node1_connect, node2_connect, node3_connect)

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/getNodeConnects()
	var/node1_connect = turn(dir, 180)
	var/node2_connect = turn(dir, 90)
	var/node3_connect = dir

	return list(node1_connect, node2_connect, node3_connect)
