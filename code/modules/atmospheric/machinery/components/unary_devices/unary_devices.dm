/obj/machinery/atmospherics/components/unary
	dir = SOUTH
	initialize_directions = SOUTH
	device_type = UNARY

/obj/machinery/atmospherics/components/unary/atom_init()
	. = ..()

	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = 200

/obj/machinery/atmospherics/components/unary/SetInitDirections()
	initialize_directions = dir
