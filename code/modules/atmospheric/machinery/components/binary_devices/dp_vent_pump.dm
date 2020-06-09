/*
	Acts like a normal vent, but has an input AND output.
*/
#define DEFAULT_PRESSURE_DELTA 10000

#define EXTERNAL_PRESSURE_BOUND ONE_ATMOSPHERE
#define INTERNAL_PRESSURE_BOUND 0
#define PRESSURE_CHECKS 1

#define PRESSURE_CHECK_EXTERNAL 1
#define PRESSURE_CHECK_INPUT 2
#define PRESSURE_CHECK_OUTPUT 4

/obj/machinery/atmospherics/components/binary/dp_vent_pump
	icon = 'icons/atmos/vent_pump.dmi'
	icon_state = "map_dp_vent"

	//node2 is output port
	//node1 is input port

	name = "dual-port air vent"
	desc = "Has a valve and pump attached to it. There are two ports."

	level = PIPE_HIDDEN_LEVEL

	use_power = NO_POWER_USE
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	power_rating = 7500			//7500 W ~ 10 HP

	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_SUPPLY|CONNECT_TYPE_SCRUBBER //connects to regular, supply and scrubbers pipes

	var/pump_direction = 1 //0 = siphoning, 1 = releasing

	var/external_pressure_bound = EXTERNAL_PRESSURE_BOUND
	var/input_pressure_min = INTERNAL_PRESSURE_BOUND
	var/output_pressure_max = DEFAULT_PRESSURE_DELTA

	frequency = 0
	var/id = null

	var/pressure_checks = PRESSURE_CHECK_EXTERNAL
	//1: Do not pass external_pressure_bound
	//2: Do not pass input_pressure_min
	//4: Do not pass output_pressure_max

/obj/machinery/atmospherics/components/binary/dp_vent_pump/atom_init()
	. = ..()

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	air1.volume = ATMOS_DEFAULT_VOLUME_PUMP
	air2.volume = ATMOS_DEFAULT_VOLUME_PUMP
	icon = null

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume
	name = "Large Dual Port Air Vent"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/atom_init()
	. = ..()

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	air1.volume = ATMOS_DEFAULT_VOLUME_PUMP + 800
	air2.volume = ATMOS_DEFAULT_VOLUME_PUMP + 800

/obj/machinery/atmospherics/components/binary/dp_vent_pump/update_icon(safety = FALSE)
	if(!check_icon_cache())
		return

	cut_overlays()

	var/vent_icon = "vent"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	..()

	var/obj/machinery/atmospherics/node1 = NODE1
	var/obj/machinery/atmospherics/node2 = NODE2

	if(!T.is_plating() && node1 && node2 && node1.level == PIPE_HIDDEN_LEVEL && node2.level == PIPE_HIDDEN_LEVEL && istype(node1, /obj/machinery/atmospherics/pipe) && istype(node2, /obj/machinery/atmospherics/pipe))
		vent_icon += "h"

	if(!powered())
		vent_icon += "off"
	else
		vent_icon += "[use_power ? "[pump_direction ? "out" : "in"]" : "off"]"

	add_overlay(icon_manager.get_atmos_icon("device", , , vent_icon))

/obj/machinery/atmospherics/components/binary/dp_vent_pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		var/obj/machinery/atmospherics/node1 = NODE1
		var/obj/machinery/atmospherics/node2 = NODE2

		if(!T.is_plating() && node1 && node2 && node1.level == PIPE_HIDDEN_LEVEL && node2.level == PIPE_HIDDEN_LEVEL && istype(node1, /obj/machinery/atmospherics/pipe) && istype(node2, /obj/machinery/atmospherics/pipe))
			return
		else
			if (node1)
				add_underlay(T, node1, turn(dir, -180), node1.icon_connect_type)
			else
				add_underlay(T, node1, turn(dir, -180))
			if (node2)
				add_underlay(T, node2, dir, node2.icon_connect_type)
			else
				add_underlay(T, node2, dir)

/obj/machinery/atmospherics/components/binary/dp_vent_pump/hide(i)
	update_icon()
	update_underlays()

/obj/machinery/atmospherics/components/binary/dp_vent_pump/process_atmos()
	last_flow_rate = 0
	last_power_draw = 0

	if(stat & (NOPOWER|BROKEN) || !use_power)
		return

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	var/datum/gas_mixture/environment = loc.return_air()

	var/power_draw = -1

	//Figure out the target pressure difference
	var/pressure_delta = get_pressure_delta(environment)

	if(pressure_delta > 0.5)
		if(pump_direction) //internal -> external
			if (environment.temperature || air1.temperature)
				var/transfer_moles = calculate_transfer_moles(air1, environment, pressure_delta)
				power_draw = pump_gas(src, air1, environment, transfer_moles, power_rating)

				if(power_draw >= 0)
					var/datum/pipeline/parent1 = PARENT1
					parent1.update = 1
		else //external -> internal
			if (environment.temperature || air2.temperature)
				var/datum/pipeline/parent2 = PARENT2
				var/transfer_moles = calculate_transfer_moles(environment, air2, pressure_delta, (parent2) ? parent2.air.volume : 0)

				//limit flow rate from turfs
				transfer_moles = min(transfer_moles, environment.total_moles * air2.volume / environment.volume)	//group_multiplier gets divided out here
				power_draw = pump_gas(src, environment, air2, transfer_moles, power_rating)

				if(power_draw >= 0)
					parent2.update = 1

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power(power_draw)

/obj/machinery/atmospherics/components/binary/dp_vent_pump/proc/get_pressure_delta(datum/gas_mixture/environment)
	var/pressure_delta = DEFAULT_PRESSURE_DELTA
	var/environment_pressure = environment.return_pressure()
	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	if(pump_direction) //internal -> external
		if(pressure_checks & PRESSURE_CHECK_EXTERNAL)
			pressure_delta = min(pressure_delta, external_pressure_bound - environment_pressure) //increasing the pressure here
		if(pressure_checks & PRESSURE_CHECK_INPUT)
			pressure_delta = min(pressure_delta, air1.return_pressure() - input_pressure_min) //decreasing the pressure here
	else //external -> internal
		if(pressure_checks & PRESSURE_CHECK_EXTERNAL)
			pressure_delta = min(pressure_delta, environment_pressure - external_pressure_bound) //decreasing the pressure here
		if(pressure_checks & PRESSURE_CHECK_OUTPUT)
			pressure_delta = min(pressure_delta, output_pressure_max - air2.return_pressure()) //increasing the pressure here

	return pressure_delta


//Radio remote control

/obj/machinery/atmospherics/components/binary/dp_vent_pump/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/binary/dp_vent_pump/proc/broadcast_status()
	if(!radio_connection)
		return FALSE

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "ADVP",
		"power" = use_power,
		"direction" = pump_direction?("release"):("siphon"),
		"checks" = pressure_checks,
		"input" = input_pressure_min,
		"output" = output_pressure_max,
		"external" = external_pressure_bound,
		"sigtype" = "status"
	)
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return TRUE

/obj/machinery/atmospherics/components/binary/dp_vent_pump/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)
	broadcast_status()

/obj/machinery/atmospherics/components/binary/dp_vent_pump/examine(mob/user)
	if(..(user, 1))
		to_chat(user, "A small gauge in the corner reads [round(last_flow_rate, 0.1)] L/s; [round(last_power_draw)] W")

/obj/machinery/atmospherics/components/binary/dp_vent_pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return FALSE

	if(signal.data["power"])
		set_power_use(text2num(signal.data["power"]))

	if(signal.data["power_toggle"])
		set_power_use(!use_power)

	if(signal.data["direction"])
		pump_direction = text2num(signal.data["direction"])

	if(signal.data["checks"])
		pressure_checks = text2num(signal.data["checks"])

	if(signal.data["purge"])
		pressure_checks &= ~1
		pump_direction = 0

	if(signal.data["stabalize"])
		pressure_checks |= 1
		pump_direction = 1

	if(signal.data["set_input_pressure"])
		input_pressure_min = between(
			0,
			text2num(signal.data["set_input_pressure"]),
			ONE_ATMOSPHERE * 50
		)

	if(signal.data["set_output_pressure"])
		output_pressure_max = between(
			0,
			text2num(signal.data["set_output_pressure"]),
			ONE_ATMOSPHERE * 50
		)

	if(signal.data["set_external_pressure"])
		external_pressure_bound = between(
			0,
			text2num(signal.data["set_external_pressure"]),
			ONE_ATMOSPHERE * 50
		)

	if(signal.data["status"])
		broadcast_status()
		return //do not update_icon

	broadcast_status()
	update_icon()

#undef DEFAULT_PRESSURE_DELTA

#undef EXTERNAL_PRESSURE_BOUND
#undef INTERNAL_PRESSURE_BOUND
#undef PRESSURE_CHECKS

#undef PRESSURE_CHECK_EXTERNAL
#undef PRESSURE_CHECK_INPUT
#undef PRESSURE_CHECK_OUTPUT
