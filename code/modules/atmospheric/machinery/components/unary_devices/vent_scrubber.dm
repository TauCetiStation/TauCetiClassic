#define SIPHONING	0
#define SCRUBBING	1

/obj/machinery/atmospherics/components/unary/vent_scrubber
	icon = 'icons/atmos/vent_scrubber.dmi'
	icon_state = "map_scrubber_off"

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it."

	can_unwrench = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	power_rating = 7500			//7500 W ~ 10 HP

	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_SCRUBBER //connects to regular and scrubber pipes

	undertile = FALSE
	layer = GAS_SCRUBBER_LAYER
	frequency = 1439

	var/area/initial_loc
	var/id_tag = null

	var/hibernate = 0 //Do we even process?
	var/scrubbing = SCRUBBING
	var/list/scrubbing_gas

	var/panic = 0 //is this scrubber panicked?

	var/area_uid

/obj/machinery/atmospherics/components/unary/vent_scrubber/on
	use_power = IDLE_POWER_USE
	icon_state = "map_scrubber_on"

/obj/machinery/atmospherics/components/unary/vent_scrubber/atom_init()
	. = ..()

	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = ATMOS_DEFAULT_VOLUME_FILTER

	icon = null
	initial_loc = get_area(loc)
	area_uid = initial_loc.uid
	if (!id_tag)
		assign_uid()
		id_tag = num2text(uid)

/obj/machinery/atmospherics/components/unary/vent_scrubber/Destroy()
	if(initial_loc)
		initial_loc.air_scrub_info -= id_tag
		initial_loc.air_scrub_names -= id_tag
	return ..()

/obj/machinery/atmospherics/components/unary/vent_scrubber/atmos_init()
	radio_filter_in = frequency == initial(frequency) ? (RADIO_FROM_AIRALARM) : null
	radio_filter_out = frequency == initial(frequency) ? (RADIO_TO_AIRALARM) : null

	if (frequency)
		set_frequency(frequency)

	if(!scrubbing_gas)
		scrubbing_gas = list()
		for(var/g in gas_data.gases)
			if(g != "oxygen" && g != "nitrogen")
				scrubbing_gas += g

	broadcast_status()

	..()

/obj/machinery/atmospherics/components/unary/vent_scrubber/update_icon(safety = FALSE)
	if(!check_icon_cache())
		return

	cut_overlays()


	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	..()

	var/scrubber_icon = "scrubber"
	if(welded)
		scrubber_icon += "weld"
	else
		if(!powered())
			scrubber_icon += "off"
		else
			scrubber_icon += "[use_power ? "[scrubbing ? "on" : "in"]" : "off"]"

	add_overlay(icon_manager.get_atmos_icon("device", , , scrubber_icon))
	update_underlays()

/obj/machinery/atmospherics/components/unary/vent_scrubber/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		var/obj/machinery/atmospherics/node = NODE1

		if(T.underfloor_accessibility < UNDERFLOOR_VISIBLE && node && node.undertile && istype(node, /obj/machinery/atmospherics/pipe))
			return
		else
			if(node)
				add_underlay(T, node, dir, node.icon_connect_type)
			else
				add_underlay(T,, dir)

/obj/machinery/atmospherics/components/unary/vent_scrubber/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, radio_filter_in)

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/broadcast_status()
	if(!radio_connection)
		return FALSE

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src
	signal.data = list(
		"area" = area_uid,
		"tag" = id_tag,
		"device" = "AScr",
		"timestamp" = world.time,
		"power" = use_power,
		"scrubbing" = scrubbing,
		"panic" = panic,
		"filter_o2" = ("oxygen" in scrubbing_gas),
		"filter_n2" = ("nitrogen" in scrubbing_gas),
		"filter_co2" = ("carbon_dioxide" in scrubbing_gas),
		"filter_phoron" = ("phoron" in scrubbing_gas),
		"filter_n2o" = ("sleeping_agent" in scrubbing_gas),
		"sigtype" = "status"
	)
	if(!initial_loc.air_scrub_names[id_tag])
		var/new_name = "[initial_loc.name] Air Scrubber #[initial_loc.air_scrub_names.len+1]"
		initial_loc.air_scrub_names[id_tag] = new_name
		src.name = new_name
	initial_loc.air_scrub_info[id_tag] = signal.data
	radio_connection.post_signal(src, signal, radio_filter_out)

	return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/process_atmos()
	last_power_draw = 0
	last_flow_rate = 0

	if (hibernate > world.time)
		return
	if (!NODE1)
		set_power_use(NO_POWER_USE)
	//broadcast_status()
	if(!use_power || (stat & (NOPOWER|BROKEN)))
		return
	if(welded)
		return

	var/datum/gas_mixture/environment = loc.return_air()
	var/datum/gas_mixture/air_contents = AIR1

	var/power_draw = -1
	if(scrubbing)
		//limit flow rate from turfs
		var/transfer_moles = min(environment.total_moles, environment.total_moles * MAX_SCRUBBER_FLOWRATE / environment.volume)	//group_multiplier gets divided out here

		power_draw = scrub_gas(src, scrubbing_gas, environment, air_contents, transfer_moles, power_rating)
	else //Just siphon all air
		//limit flow rate from turfs
		var/transfer_moles = min(environment.total_moles, environment.total_moles * MAX_SIPHON_FLOWRATE / environment.volume)	//group_multiplier gets divided out here

		power_draw = pump_gas(src, environment, air_contents, transfer_moles, power_rating)

	if(scrubbing && power_draw <= 0)	//99% of all scrubbers
		//Fucking hibernate because you ain't doing shit.
		hibernate = world.time + (rand(100, 200))

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power(power_draw)

	update_parents()

/obj/machinery/atmospherics/components/unary/vent_scrubber/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return FALSE

	if(signal.data["power"] != null)
		set_power_use(text2num(signal.data["power"]))
	if(signal.data["power_toggle"] != null)
		set_power_use(!use_power)

	if(signal.data["panic_siphon"]) //must be before if("scrubbing" thing
		panic = text2num(signal.data["panic_siphon"])
		if(panic)
			set_power_use(IDLE_POWER_USE)
			scrubbing = SIPHONING
		else
			scrubbing = SCRUBBING
	if(signal.data["toggle_panic_siphon"] != null)
		panic = !panic
		if(panic)
			set_power_use(IDLE_POWER_USE)
			scrubbing = SIPHONING
		else
			scrubbing = SCRUBBING

	if(signal.data["scrubbing"] != null)
		scrubbing = text2num(signal.data["scrubbing"])
		if(scrubbing)
			panic = 0
	if(signal.data["toggle_scrubbing"])
		scrubbing = !scrubbing
		if(scrubbing)
			panic = 0

	var/list/toggle = list()

	if(!isnull(signal.data["o2_scrub"]) && text2num(signal.data["o2_scrub"]) != ("oxygen" in scrubbing_gas))
		toggle += "oxygen"
	else if(signal.data["toggle_o2_scrub"])
		toggle += "oxygen"

	if(!isnull(signal.data["n2_scrub"]) && text2num(signal.data["n2_scrub"]) != ("nitrogen" in scrubbing_gas))
		toggle += "nitrogen"
	else if(signal.data["toggle_n2_scrub"])
		toggle += "nitrogen"

	if(!isnull(signal.data["co2_scrub"]) && text2num(signal.data["co2_scrub"]) != ("carbon_dioxide" in scrubbing_gas))
		toggle += "carbon_dioxide"
	else if(signal.data["toggle_co2_scrub"])
		toggle += "carbon_dioxide"

	if(!isnull(signal.data["tox_scrub"]) && text2num(signal.data["tox_scrub"]) != ("phoron" in scrubbing_gas))
		toggle += "phoron"
	else if(signal.data["toggle_tox_scrub"])
		toggle += "phoron"

	if(!isnull(signal.data["n2o_scrub"]) && text2num(signal.data["n2o_scrub"]) != ("sleeping_agent" in scrubbing_gas))
		toggle += "sleeping_agent"
	else if(signal.data["toggle_n2o_scrub"])
		toggle += "sleeping_agent"

	scrubbing_gas ^= toggle

	if(signal.data["init"] != null)
		name = signal.data["init"]
		return

	if(signal.data["status"] != null)
		broadcast_status()
		return //do not update_icon

//			log_admin("DEBUG \[[world.timeofday]\]: vent_scrubber/receive_signal: unknown command \"[signal.data["command"]]\"\n[signal.debug_print()]")
	broadcast_status()
	update_icon()

/obj/machinery/atmospherics/components/unary/vent_scrubber/attackby(obj/item/weapon/W, mob/user)
	if(iswelding(W))
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

/obj/machinery/atmospherics/components/unary/vent_scrubber/can_unwrench(mob/user)
	if(..())
		if (!(stat & NOPOWER) && use_power)
			to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		else
			return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/examine(mob/user)
	if(..(user, 1))
		to_chat(user, "A small gauge in the corner reads [round(last_flow_rate, 0.1)] L/s; [round(last_power_draw)] W")
	else
		to_chat(user, "You are too far away to read the gauge.")
	if(welded)
		to_chat(user, "It seems welded shut.")
