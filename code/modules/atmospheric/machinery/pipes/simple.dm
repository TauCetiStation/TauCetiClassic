/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/atmos/pipes.dmi'
	icon_state = ""
	var/pipe_icon = "" //what kind of pipe it is and from which dmi is the icon manager getting its icons, "" for simple pipes, "hepipe" for HE pipes, "hejunction" for HE junctions
	name = "pipe"
	desc = "A one meter section of regular pipe."

	volume = ATMOS_DEFAULT_VOLUME_PIPE

	dir = SOUTH
	initialize_directions = SOUTH|NORTH

	device_type = BINARY

	var/minimum_temperature_difference = 300
	var/thermal_conductivity = 0 //WALL_HEAT_TRANSFER_COEFFICIENT No

	var/maximum_pressure = 210 * ONE_ATMOSPHERE
	var/fatigue_pressure = 170 * ONE_ATMOSPHERE
	alert_pressure = 170 * ONE_ATMOSPHERE

/obj/machinery/atmospherics/pipe/simple/atom_init()
	. = ..()

	// Pipe colors and icon states are handled by an image cache - so color and icon should
	//  be null. For mapping purposes color is defined in the object definitions.
	icon = null
	alpha = 255

/obj/machinery/atmospherics/pipe/simple/SetInitDirections()
	if(dir in cornerdirs)
		initialize_directions = dir
	switch(dir)
		if(NORTH,SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST,WEST)
			initialize_directions = EAST|WEST

/*/obj/machinery/atmospherics/pipe/simple/process()
	if(leaking)
		parent.mingle_with_turf(loc, volume)
	else
		. = PROCESS_KILL*/

/obj/machinery/atmospherics/pipe/simple/check_pressure(pressure)
	// Don't ask me, it happened somehow.
	if (!istype(loc, /turf))
		return TRUE

	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_difference = pressure - environment.return_pressure()

	if(pressure_difference > maximum_pressure)
		burst()

	else if(pressure_difference > fatigue_pressure)
		//TODO: leak to turf, doing pfshhhhh
		if(prob(5))
			burst()

	else
		return TRUE

/obj/machinery/atmospherics/pipe/simple/proc/burst()
	ASSERT(parent)
	parent.temporarily_store_air()
	visible_message("<span class='danger'>\The [src] bursts!</span>");
	playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER, 25)
	var/datum/effect/effect/system/smoke_spread/smoke = new
	smoke.set_up(1, 0, loc, 0)
	smoke.start()
	qdel(src)

/obj/machinery/atmospherics/pipe/simple/proc/normalize_dir()
	if(dir == 3)
		set_dir(1)
	else if(dir == 12)
		set_dir(4)

/obj/machinery/atmospherics/pipe/simple/update_icon(safety = 0)
	if(!atmos_initalized)
		return
	if(!check_icon_cache())
		return

	alpha = 255

	cut_overlays()

	var/obj/machinery/atmospherics/node1 = NODE1
	var/obj/machinery/atmospherics/node2 = NODE2

	if(node1 && node2)
		add_overlay(icon_manager.get_atmos_icon("pipe", , pipe_color, "[pipe_icon]intact[icon_connect_type]"))
		//if(leaking)
		//	leaking = FALSE
	else
		add_overlay(icon_manager.get_atmos_icon("pipe", , pipe_color, "[pipe_icon]exposed[node1?1:0][node2?1:0][icon_connect_type]"))
		//if(!leaking)
		//	leaking = TRUE
		//	START_PROCESSING(SSmachines, src)

/obj/machinery/atmospherics/pipe/simple/update_underlays()
	return

/obj/machinery/atmospherics/pipe/simple/atmos_init()
	normalize_dir()
	..()

/obj/machinery/atmospherics/pipe/simple/visible
	icon_state = "intact"
	level = PIPE_VISIBLE_LEVEL
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/simple/visible/scrubbers
	name = "Scrubbers pipe"
	desc = "A one meter section of scrubbers pipe."
	icon_state = "intact-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/simple/visible/supply
	name = "Air supply pipe"
	desc = "A one meter section of supply pipe."
	icon_state = "intact-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/simple/visible/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/simple/visible/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/simple/visible/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/simple/visible/black
	color = PIPE_COLOR_BLACK

/obj/machinery/atmospherics/pipe/simple/visible/red
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/simple/visible/blue
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/simple/visible/fuel
	name = "Fuel pipe"
	color = PIPE_COLOR_ORANGE
	maximum_pressure = 420 * ONE_ATMOSPHERE
	fatigue_pressure = 350 * ONE_ATMOSPHERE
	alert_pressure = 350 * ONE_ATMOSPHERE

/obj/machinery/atmospherics/pipe/simple/hidden
	icon_state = "intact"
	level = PIPE_HIDDEN_LEVEL
	alpha = 128		//set for the benefit of mapping - this is reset to opaque when the pipe is spawned in game

/obj/machinery/atmospherics/pipe/simple/hidden/scrubbers
	name = "Scrubbers pipe"
	desc = "A one meter section of scrubbers pipe."
	icon_state = "intact-scrubbers"
	connect_types = CONNECT_TYPE_SCRUBBER
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED
	layer = GAS_PIPE_HIDDEN_SCRUBBER_LAYER

/obj/machinery/atmospherics/pipe/simple/hidden/supply
	name = "Air supply pipe"
	desc = "A one meter section of supply pipe."
	icon_state = "intact-supply"
	connect_types = CONNECT_TYPE_SUPPLY
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE
	layer = GAS_PIPE_HIDDEN_SUPPLY_LAYER

/obj/machinery/atmospherics/pipe/simple/hidden/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/simple/hidden/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/simple/hidden/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/simple/hidden/black
	color = PIPE_COLOR_BLACK

/obj/machinery/atmospherics/pipe/simple/hidden/red
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/simple/hidden/blue
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/simple/hidden/fuel
	name = "Fuel pipe"
	color = PIPE_COLOR_ORANGE
	maximum_pressure = 420 * ONE_ATMOSPHERE
	fatigue_pressure = 350 * ONE_ATMOSPHERE
	alert_pressure = 350 * ONE_ATMOSPHERE
