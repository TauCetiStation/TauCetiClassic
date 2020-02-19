#define DEFAULT_PRESSURE_DELTA 10000

#define EXTERNAL_PRESSURE_BOUND ONE_ATMOSPHERE
#define INTERNAL_PRESSURE_BOUND 0
#define PRESSURE_CHECKS 1

#define PRESSURE_CHECK_EXTERNAL 1
#define PRESSURE_CHECK_INTERNAL 2

/obj/machinery/atmospherics/components/unary/vent_pump
	icon = 'icons/atmos/vent_pump.dmi'
	icon_state = "map_vent"

	name = "Air Vent"
	desc = "Has a valve and pump attached to it."

	can_unwrench = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	power_rating = 7500			//7500 W ~ 10 HP

	level = PIPE_HIDDEN_LEVEL
	layer = GAS_SCRUBBER_LAYER

	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_SUPPLY //connects to regular and supply pipes
	frequency = 1439

	var/area/initial_loc
	var/area_uid
	var/id_tag = null

	var/hibernate = 0 //Do we even process?
	var/pump_direction = 1 //0 = siphoning, 1 = releasing

	var/external_pressure_bound = EXTERNAL_PRESSURE_BOUND
	var/internal_pressure_bound = INTERNAL_PRESSURE_BOUND

	var/pressure_checks = PRESSURE_CHECKS
	//1: Do not pass external_pressure_bound
	//2: Do not pass internal_pressure_bound
	//3: Do not pass either

	// Used when handling incoming radio signals requesting default settings
	var/external_pressure_bound_default = EXTERNAL_PRESSURE_BOUND
	var/internal_pressure_bound_default = INTERNAL_PRESSURE_BOUND
	var/pressure_checks_default = PRESSURE_CHECKS

/obj/machinery/atmospherics/components/unary/vent_pump/on
	use_power = IDLE_POWER_USE
	icon_state = "map_vent_out"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon
	pump_direction = 0

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on
	use_power = IDLE_POWER_USE
	icon_state = "map_vent_in"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on/atmos
	use_power = IDLE_POWER_USE
	icon_state = "map_vent_in"
	external_pressure_bound = 0
	external_pressure_bound_default = 0
	internal_pressure_bound = 2000
	internal_pressure_bound_default = 2000
	pressure_checks = 2
	pressure_checks_default = 2

/obj/machinery/atmospherics/components/unary/vent_pump/atom_init()
	. = ..()

	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = ATMOS_DEFAULT_VOLUME_PUMP

	icon = null
	initial_loc = get_area(loc)
	area_uid = initial_loc.uid
	if (!id_tag)
		assign_uid()
		id_tag = num2text(uid)

/obj/machinery/atmospherics/components/unary/vent_pump/Destroy()
	if(initial_loc)
		initial_loc.air_vent_info -= id_tag
		initial_loc.air_vent_names -= id_tag
	return ..()

/obj/machinery/atmospherics/components/unary/vent_pump/atmos_init()
	//some vents work his own special way
	radio_filter_in = frequency == 1439 ? (RADIO_FROM_AIRALARM) : null
	radio_filter_out = frequency == 1439 ? (RADIO_TO_AIRALARM) : null
	if(frequency)
		set_frequency(frequency)
	broadcast_status()
	..()

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume
	name = "Large Air Vent"
	power_channel = STATIC_EQUIP
	power_rating = 15000	//15 kW ~ 20 HP

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/on
	icon_state = "map_vent_out"
	use_power = IDLE_POWER_USE

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/atom_init()
	. = ..()

	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = ATMOS_DEFAULT_VOLUME_PUMP + 800

/obj/machinery/atmospherics/components/unary/vent_pump/engine
	name = "Engine Core Vent"
	power_channel = STATIC_ENVIRON
	power_rating = 30000	//15 kW ~ 20 HP

/obj/machinery/atmospherics/components/unary/vent_pump/engine/atom_init()
	. = ..()

	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = ATMOS_DEFAULT_VOLUME_PUMP + 500 //meant to match air injector

/obj/machinery/atmospherics/components/unary/vent_pump/update_icon(safety = 0)
	if(!check_icon_cache())
		return

	cut_overlays()

	var/vent_icon = "vent"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	..()

	var/obj/machinery/atmospherics/node = NODE1

	if(!T.is_plating() && node && node.level == PIPE_HIDDEN_LEVEL && istype(node, /obj/machinery/atmospherics/pipe))
		vent_icon += "h"

	if(welded)
		vent_icon += "weld"
	else if(!powered())
		vent_icon += "off"
	else
		vent_icon += "[use_power ? "[pump_direction ? "out" : "in"]" : "off"]"

	add_overlay(icon_manager.get_atmos_icon("device", , , vent_icon))

/obj/machinery/atmospherics/components/unary/vent_pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		var/obj/machinery/atmospherics/node = NODE1

		if(!T.is_plating() && node && node.level == PIPE_HIDDEN_LEVEL && istype(node, /obj/machinery/atmospherics/pipe))
			return
		else
			if(node)
				add_underlay(T, node, dir, node.icon_connect_type)
			else
				add_underlay(T,, dir)

/obj/machinery/atmospherics/components/unary/vent_pump/hide()
	update_icon()
	update_underlays()

/obj/machinery/atmospherics/components/unary/vent_pump/proc/can_pump()
	if(stat & (NOPOWER|BROKEN))
		return FALSE
	if(!use_power)
		return FALSE
	if(welded)
		return FALSE
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_pump/process_atmos()
	last_power_draw = 0
	last_flow_rate = 0

	if (hibernate > world.time)
		return
	if (!NODE1)
		set_power_use(NO_POWER_USE)
	if(!can_pump())
		return

	var/datum/gas_mixture/air_contents = AIR1
	var/datum/gas_mixture/environment = loc.return_air()

	var/power_draw = -1

	//Figure out the target pressure difference
	var/pressure_delta = get_pressure_delta(environment)
	//src.visible_message("DEBUG >>> [src]: pressure_delta = [pressure_delta]")

	if((environment.temperature || air_contents.temperature) && pressure_delta > 0.5)
		if(pump_direction) //internal -> external
			var/transfer_moles = calculate_transfer_moles(air_contents, environment, pressure_delta)
			power_draw = pump_gas(src, air_contents, environment, transfer_moles, power_rating)
		else //external -> internal
			var/datum/pipeline/parent1 = PARENT1
			var/transfer_moles = calculate_transfer_moles(environment, air_contents, pressure_delta, (parent1) ? parent1.air.volume : 0)

			//limit flow rate from turfs
			transfer_moles = min(transfer_moles, environment.total_moles * air_contents.volume / environment.volume)	//group_multiplier gets divided out here
			power_draw = pump_gas(src, environment, air_contents, transfer_moles, power_rating)

	else
		//If we're in an area that is fucking ideal, and we don't have to do anything, chances are we won't next tick either so why redo these calculations?
		//JESUS FUCK.  THERE ARE LITERALLY 250 OF YOU MOTHERFUCKERS ON ZLEVEL ONE AND YOU DO THIS SHIT EVERY TICK WHEN VERY OFTEN THERE IS NO REASON TO
		if(pump_direction && pressure_checks == PRESSURE_CHECK_EXTERNAL) //99% of all vents
			hibernate = world.time + (rand(100, 200))


	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power(power_draw)
		update_parents()

/obj/machinery/atmospherics/components/unary/vent_pump/proc/get_pressure_delta(datum/gas_mixture/environment)
	var/pressure_delta = DEFAULT_PRESSURE_DELTA
	var/environment_pressure = environment.return_pressure()
	var/datum/gas_mixture/air_contents = AIR1

	if(pump_direction) //internal -> external
		if(pressure_checks & PRESSURE_CHECK_EXTERNAL)
			pressure_delta = min(pressure_delta, external_pressure_bound - environment_pressure) //increasing the pressure here
		if(pressure_checks & PRESSURE_CHECK_INTERNAL)
			pressure_delta = min(pressure_delta, air_contents.return_pressure() - internal_pressure_bound) //decreasing the pressure here
	else //external -> internal
		if(pressure_checks & PRESSURE_CHECK_EXTERNAL)
			pressure_delta = min(pressure_delta, environment_pressure - external_pressure_bound) //decreasing the pressure here
		if(pressure_checks & PRESSURE_CHECK_INTERNAL)
			pressure_delta = min(pressure_delta, internal_pressure_bound - air_contents.return_pressure()) //increasing the pressure here

	return pressure_delta

/obj/machinery/atmospherics/components/unary/vent_pump/proc/broadcast_status()
	if(!radio_connection)
		return FALSE

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"area" = src.area_uid,
		"tag" = src.id_tag,
		"device" = "AVP",
		"power" = use_power,
		"direction" = pump_direction?("release"):("siphon"),
		"checks" = pressure_checks,
		"internal" = internal_pressure_bound,
		"external" = external_pressure_bound,
		"timestamp" = world.time,
		"sigtype" = "status",
		"power_draw" = last_power_draw,
		"flow_rate" = last_flow_rate,
	)

	if(!initial_loc.air_vent_names[id_tag])
		var/new_name = "[initial_loc.name] Vent Pump #[initial_loc.air_vent_names.len+1]"
		initial_loc.air_vent_names[id_tag] = new_name
		src.name = new_name
	initial_loc.air_vent_info[id_tag] = signal.data

	radio_connection.post_signal(src, signal, radio_filter_out)

	return TRUE

/obj/machinery/atmospherics/components/unary/vent_pump/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return

	hibernate = 0

	//log_admin("DEBUG \[[world.timeofday]\]: /obj/machinery/atmospherics/components/unary/vent_pump/receive_signal([signal.debug_print()])")
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return FALSE

	if(signal.data["purge"] != null)
		pressure_checks &= ~1
		pump_direction = 0

	if(signal.data["stabalize"] != null)
		pressure_checks |= 1
		pump_direction = 1

	if(signal.data["power"] != null)
		set_power_use(text2num(signal.data["power"]))

	if(signal.data["power_toggle"] != null)
		set_power_use(!use_power)

	if(signal.data["checks"] != null)
		if (signal.data["checks"] == "default")
			pressure_checks = pressure_checks_default
		else
			pressure_checks = text2num(signal.data["checks"])

	if(signal.data["checks_toggle"] != null)
		pressure_checks = (pressure_checks?0:3)

	if(signal.data["direction"] != null)
		pump_direction = text2num(signal.data["direction"])

	if(signal.data["set_internal_pressure"] != null)
		if (signal.data["set_internal_pressure"] == "default")
			internal_pressure_bound = internal_pressure_bound_default
		else
			internal_pressure_bound = between(
				0,
				text2num(signal.data["set_internal_pressure"]),
				MAX_PUMP_PRESSURE//ONE_ATMOSPHERE*50
			)

	if(signal.data["set_external_pressure"] != null)
		if (signal.data["set_external_pressure"] == "default")
			external_pressure_bound = external_pressure_bound_default
		else
			external_pressure_bound = between(
				0,
				text2num(signal.data["set_external_pressure"]),
				ONE_ATMOSPHERE * 50
			)

	if(signal.data["reset_internal_pressure"] != null)
		internal_pressure_bound = internal_pressure_bound_default

	if(signal.data["reset_external_pressure"] != null)
		external_pressure_bound = external_pressure_bound_default

	if(signal.data["adjust_internal_pressure"] != null)
		internal_pressure_bound = between(
			0,
			internal_pressure_bound + text2num(signal.data["adjust_internal_pressure"]),
			ONE_ATMOSPHERE * 50
		)

	if(signal.data["adjust_external_pressure"] != null)


		external_pressure_bound = between(
			0,
			external_pressure_bound + text2num(signal.data["adjust_external_pressure"]),
			ONE_ATMOSPHERE * 50
		)

	if(signal.data["init"] != null)
		name = signal.data["init"]
		return

	if(signal.data["status"] != null)
		broadcast_status()
		return //do not update_icon

		//log_admin("DEBUG \[[world.timeofday]\]: vent_pump/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
	broadcast_status()
	update_icon()

/obj/machinery/atmospherics/components/unary/vent_pump/attackby(obj/item/W, mob/user)
	if(iswelder(W))
		if(user.is_busy(src))
			return

		var/obj/item/weapon/weldingtool/WT = W

		if(!WT.isOn())
			to_chat(user, "<span class='notice'>The welding tool needs to be on to start this task.</span>")
			return

		if(!WT.use(0, user))
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return
		to_chat(user, "<span class='notice'>Now welding \the [src].</span>")
		if(!WT.use_tool(src, user, 20, volume = 50))
			to_chat(user, "<span class='notice'>You must remain close to finish this task.</span>")
			return

		if(!WT.isOn())
			to_chat(user, "<span class='notice'>The welding tool needs to be on to finish this task.</span>")
			return

		welded = !welded
		update_icon()
		user.visible_message("<span class='notice'>\The [user] [welded ? "welds \the [src] shut" : "unwelds \the [src]"].</span>", \
			"<span class='notice'>You [welded ? "weld \the [src] shut" : "unweld \the [src]"].</span>", \
			"You hear welding.")
		return

	else
		return ..()

/obj/machinery/atmospherics/components/unary/vent_pump/can_unwrench(mob/user)
	if(..())
		if(!(stat & NOPOWER) && use_power)
			to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		else
			return TRUE

/obj/machinery/atmospherics/components/unary/vent_pump/examine(mob/user)
	if(..(user, 1))
		to_chat(user, "A small gauge in the corner reads [round(last_flow_rate, 0.1)] L/s; [round(last_power_draw)] W")
	else
		to_chat(user, "You are too far away to read the gauge.")
	if(welded)
		to_chat(user, "It seems welded shut.")

#undef DEFAULT_PRESSURE_DELTA

#undef EXTERNAL_PRESSURE_BOUND
#undef INTERNAL_PRESSURE_BOUND
#undef PRESSURE_CHECKS

#undef PRESSURE_CHECK_EXTERNAL
#undef PRESSURE_CHECK_INTERNAL
