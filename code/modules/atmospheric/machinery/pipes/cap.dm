/obj/machinery/atmospherics/pipe/cap
	name = "pipe endcap"
	desc = "An endcap for pipes."
	icon = 'icons/atmos/pipes.dmi'
	icon_state = ""

	volume = 35

	device_type = UNARY

	dir = SOUTH
	initialize_directions = SOUTH

/obj/machinery/atmospherics/pipe/cap/atom_init()
	. = ..()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/cap/process_atmos()
	return PROCESS_KILL

/obj/machinery/atmospherics/pipe/cap/update_icon(safety = FALSE)
	if(!check_icon_cache())
		return

	alpha = 255

	cut_overlays()
	add_overlay(icon_manager.get_atmos_icon("pipe", , pipe_color, "cap[icon_connect_type]"))

/obj/machinery/atmospherics/pipe/cap/visible
	level = PIPE_VISIBLE_LEVEL
	icon_state = "cap"

/obj/machinery/atmospherics/pipe/cap/visible/scrubbers
	name = "scrubbers pipe endcap"
	desc = "An endcap for scrubbers pipes."
	icon_state = "cap-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/cap/visible/supply
	name = "supply pipe endcap"
	desc = "An endcap for supply pipes."
	icon_state = "cap-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/cap/visible/fuel
	name = "fuel pipe endcap"
	desc = "An endcap for fuel pipes."
	color = PIPE_COLOR_ORANGE

/obj/machinery/atmospherics/pipe/cap/hidden
	level = PIPE_HIDDEN_LEVEL
	icon_state = "cap"
	alpha = 128

/obj/machinery/atmospherics/pipe/cap/hidden/scrubbers
	name = "scrubbers pipe endcap"
	desc = "An endcap for scrubbers pipes."
	icon_state = "cap-f-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED
	layer = GAS_PIPE_HIDDEN_SCRUBBER_LAYER

/obj/machinery/atmospherics/pipe/cap/hidden/supply
	name = "supply pipe endcap"
	desc = "An endcap for supply pipes."
	icon_state = "cap-f-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE
	layer = GAS_PIPE_HIDDEN_SUPPLY_LAYER

/obj/machinery/atmospherics/pipe/cap/hidden/fuel
	name = "fuel pipe endcap"
	desc = "An endcap for fuel pipes."
	color = PIPE_COLOR_ORANGE
