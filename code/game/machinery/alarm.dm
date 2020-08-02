////////////////////////////////////////
//CONTAINS: Air Alarms and Fire Alarms//
////////////////////////////////////////

#define AALARM_SCREEN_MAIN		1
#define AALARM_SCREEN_VENT		2
#define AALARM_SCREEN_SCRUB		3
#define AALARM_SCREEN_MODE		4
#define AALARM_SCREEN_SENSORS	5

#define AALARM_REPORT_TIMEOUT 100

#define RCON_NO		1
#define RCON_AUTO	2
#define RCON_YES	3

#define MAX_TEMPERATURE 90
#define MIN_TEMPERATURE -40

//all air alarms in area are connected via magic
/area
	var/obj/machinery/alarm/master_air_alarm
	var/list/air_vent_names = list()
	var/list/air_scrub_names = list()
	var/list/air_vent_info = list()
	var/list/air_scrub_info = list()

/obj/machinery/alarm
	name = "alarm"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm0"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 80
	active_power_usage = 1000 // For heating/cooling rooms. 1000 joules equates to about 1 degree every 2 seconds for a single tile of air.
	power_channel = STATIC_ENVIRON
	req_one_access = list(access_atmospherics, access_engine_equip)
	frequency = 1439
	allowed_checks = ALLOWED_CHECK_NONE
	unacidable = TRUE

	var/breach_detection = TRUE // Whether to use automatic breach detection or not
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = 1437
	var/remote_control = FALSE
	var/rcon_setting = 2
	var/rcon_time = 0
	var/locked = TRUE
	var/wiresexposed = FALSE // If it's been screwdrivered open.
	var/aidisabled = FALSE
	var/shorted = FALSE
	var/hidden_from_console = FALSE

	var/datum/wires/alarm/wires = null

	var/mode = AALARM_MODE_SCRUBBING
	var/screen = AALARM_SCREEN_MAIN
	var/area_uid
	var/area/alarm_area
	var/buildstage = 2 //2 is built, 1 is building, 0 is frame.

	var/target_temperature = T0C+20
	var/regulating_temperature = 0
	var/allow_regulate = 0 //Is thermoregulation enabled?

	var/list/TLV = list()
	var/list/trace_gas = list("sleeping_agent") //list of other gases that this air alarm is able to detect

	var/danger_level = 0
	var/pressure_dangerlevel = 0
	var/oxygen_dangerlevel = 0
	var/co2_dangerlevel = 0
	var/phoron_dangerlevel = 0
	var/temperature_dangerlevel = 0
	var/other_dangerlevel = 0

/obj/machinery/alarm/server/atom_init()
	. = ..()
	req_access = list(access_rd, access_atmospherics, access_engine_equip)
	TLV["oxygen"] =			list(-1.0, -1.0,-1.0,-1.0) // Partial pressure, kpa
	TLV["carbon dioxide"] = list(-1.0, -1.0,   5,  10) // Partial pressure, kpa
	TLV["phoron"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
	TLV["other"] =			list(-1.0, -1.0, 0.5, 1.0) // Partial pressure, kpa
	TLV["pressure"] =		list(0,ONE_ATMOSPHERE*0.10,ONE_ATMOSPHERE*1.40,ONE_ATMOSPHERE*1.60) /* kpa */
	TLV["temperature"] =	list(20, 40, 140, 160) // K
	target_temperature = 90


/obj/machinery/alarm/atom_init(mapload, dir, building = 0)
	. = ..()
	alarm_list += src
	set_frequency(frequency)

	if(building)
		if(loc)
			src.loc = loc

		if(dir)
			src.dir = dir

		buildstage = 0
		wiresexposed = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0
		update_icon()
		return // not sure about this, is constructing initializing it same as first_run()?

	if (!master_is_operating())
		elect_master()
	first_run()

/obj/machinery/alarm/proc/first_run()
	alarm_area = get_area(src)
	area_uid = alarm_area.uid
	if (name == "alarm")
		name = "[alarm_area.name] Air Alarm"
	if(!wires)
		wires = new(src)

	// breathable air according to human/Life()
	TLV["oxygen"] =			list(16, 19, 135, 140) // Partial pressure, kpa
	TLV["carbon dioxide"] = list(-1.0, -1.0, 5, 10) // Partial pressure, kpa
	TLV["phoron"] =			list(-1.0, -1.0, 0.2, 0.5) // Partial pressure, kpa
	TLV["other"] =			list(-1.0, -1.0, 0.5, 1.0) // Partial pressure, kpa
	TLV["pressure"] =		list(ONE_ATMOSPHERE*0.80,ONE_ATMOSPHERE*0.90,ONE_ATMOSPHERE*1.10,ONE_ATMOSPHERE*1.20) /* kpa */
	TLV["temperature"] =	list(T0C-26, T0C, T0C+40, T0C+66) // K

/obj/machinery/alarm/Destroy()
	alarm_list -= src
	if(wires)
		QDEL_NULL(wires)
	if(alarm_area && alarm_area.master_air_alarm == src)
		alarm_area.master_air_alarm = null
	alarm_area = null
	return ..()

/obj/machinery/alarm/process()
	if((stat & (NOPOWER|BROKEN)) || shorted || buildstage != 2)
		return

	var/turf/simulated/location = loc
	if(!istype(location))	return//returns if loc is not simulated

	var/datum/gas_mixture/environment = location.return_air()

	//Handle temperature adjustment here.
	handle_heating_cooling(environment)

	var/old_level = danger_level
	var/old_pressurelevel = pressure_dangerlevel
	danger_level = overall_danger_level()

	if (old_level != danger_level)
		apply_danger_level(danger_level)

	if (old_pressurelevel != pressure_dangerlevel)
		if (breach_detected())
			mode = AALARM_MODE_OFF
			apply_mode()

	if (mode==AALARM_MODE_CYCLE && environment.return_pressure()<ONE_ATMOSPHERE*0.05)
		mode=AALARM_MODE_FILL
		apply_mode()


	//atmos computer remote controll stuff
	switch(rcon_setting)
		if(RCON_NO)
			remote_control = 0
		if(RCON_AUTO)
			if(danger_level == 2)
				remote_control = 1
			else
				remote_control = 0
		if(RCON_YES)
			remote_control = 1

/obj/machinery/alarm/proc/handle_heating_cooling(datum/gas_mixture/environment)
	if(!regulating_temperature)
		//check for when we should start adjusting temperature
		if(allow_regulate && !get_danger_level(target_temperature, TLV["temperature"]) && abs(environment.temperature - target_temperature) > 2.0)
			set_power_use(ACTIVE_POWER_USE)
			regulating_temperature = 1
			visible_message(
				"\The [src] clicks as it starts [environment.temperature > target_temperature ? "cooling" : "heating"] the room.",
				"You hear a click and a faint electronic hum.")
	else
		//check for when we should stop adjusting temperature
		if (!allow_regulate || get_danger_level(target_temperature, TLV["temperature"]) || abs(environment.temperature - target_temperature) <= 0.5)
			set_power_use(IDLE_POWER_USE)
			regulating_temperature = 0
			visible_message(
				"\The [src] clicks quietly as it stops [environment.temperature > target_temperature ? "cooling" : "heating"] the room.",
				"You hear a click as a faint electronic humming stops.")

	if (regulating_temperature)
		if(target_temperature > T0C + MAX_TEMPERATURE)
			target_temperature = T0C + MAX_TEMPERATURE

		if(target_temperature < T0C + MIN_TEMPERATURE)
			target_temperature = T0C + MIN_TEMPERATURE

		var/datum/gas_mixture/gas = environment.remove(0.25 * environment.total_moles)

		if(gas)

			if (gas.temperature <= target_temperature)	//gas heating
				var/energy_used = min(gas.get_thermal_energy_change(target_temperature) , active_power_usage)

				gas.add_thermal_energy(energy_used)
				//use_power(energy_used, ENVIRON) //handle by update_use_power instead
			else	//gas cooling
				var/heat_transfer = min(abs(gas.get_thermal_energy_change(target_temperature)), active_power_usage)

				//Assume the heat is being pumped into the hull which is fixed at 20 C
				//none of this is really proper thermodynamics but whatever

				var/cop = gas.temperature / T20C	//coefficient of performance -> power used = heat_transfer/cop

				heat_transfer = min(heat_transfer, cop * active_power_usage)	//this ensures that we don't use more than active_power_usage amount of power

				heat_transfer = -gas.add_thermal_energy(-heat_transfer)	//get the actual heat transfer

				//use_power(heat_transfer / cop, ENVIRON)	//handle by update_use_power instead

			environment.merge(gas)

/obj/machinery/alarm/proc/overall_danger_level()
	var/turf/simulated/location = loc
	if(!istype(location))	return//returns if loc is not simulated

	var/datum/gas_mixture/environment = location.return_air()

	var/partial_pressure = R_IDEAL_GAS_EQUATION*environment.temperature/environment.volume
	var/environment_pressure = environment.return_pressure()

	var/other_moles = 0
	for(var/g in trace_gas)
		other_moles += environment.gas[g] //this is only going to be used in a partial pressure calc, so we don't need to worry about group_multiplier here.

	pressure_dangerlevel = get_danger_level(environment_pressure, TLV["pressure"])
	oxygen_dangerlevel = get_danger_level(environment.gas["oxygen"] * partial_pressure, TLV["oxygen"])
	co2_dangerlevel = get_danger_level(environment.gas["carbon_dioxide"] * partial_pressure, TLV["carbon dioxide"])
	phoron_dangerlevel = get_danger_level(environment.gas["phoron"] * partial_pressure, TLV["phoron"])
	temperature_dangerlevel = get_danger_level(environment.temperature, TLV["temperature"])
	other_dangerlevel = get_danger_level(other_moles*partial_pressure, TLV["other"])

	return max(
		pressure_dangerlevel,
		oxygen_dangerlevel,
		co2_dangerlevel,
		phoron_dangerlevel,
		other_dangerlevel,
		temperature_dangerlevel
		)

// Returns whether this air alarm thinks there is a breach, given the sensors that are available to it.
/obj/machinery/alarm/proc/breach_detected()
	var/turf/simulated/location = loc

	if(!istype(location))
		return 0

	if(!breach_detection)
		return 0

	var/datum/gas_mixture/environment = location.return_air()
	var/environment_pressure = environment.return_pressure()
	var/pressure_levels = TLV["pressure"]

	if (environment_pressure <= pressure_levels[1])		//low pressures
		if (!(mode == AALARM_MODE_PANIC || mode == AALARM_MODE_CYCLE))
			playsound(src, 'sound/machines/alarm_air.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			return 1

	return 0


/obj/machinery/alarm/proc/master_is_operating()
	if(!alarm_area) return
	return alarm_area.master_air_alarm && !(alarm_area.master_air_alarm.stat & (NOPOWER|BROKEN))


/obj/machinery/alarm/proc/elect_master()
	if(!alarm_area) return
	for (var/obj/machinery/alarm/AA in alarm_area)
		if (!(AA.stat & (NOPOWER|BROKEN)))
			alarm_area.master_air_alarm = AA
			return 1
	return 0

/obj/machinery/alarm/proc/get_danger_level(current_value, list/danger_levels)
	if((current_value >= danger_levels[4] && danger_levels[4] > 0) || current_value <= danger_levels[1])
		return 2
	if((current_value >= danger_levels[3] && danger_levels[3] > 0) || current_value <= danger_levels[2])
		return 1
	return 0

/obj/machinery/alarm/update_icon()
	if(wiresexposed)
		icon_state="alarm_build[buildstage]"
		return

	if((stat & NOPOWER) || shorted)
		icon_state = "alarm_unpowered"
		return
	if(stat & BROKEN)
		icon_state = "alarm_broken"
		return

	var/icon_level = danger_level
	if (alarm_area.atmosalm)
		icon_level = max(icon_level, 1)	//if there's an atmos alarm but everything is okay locally, no need to go past yellow
	icon_state = "alarm[icon_level]"

/obj/machinery/alarm/receive_signal(datum/signal/signal)
	if(stat & (NOPOWER|BROKEN))
		return
	if (alarm_area.master_air_alarm != src)
		if (master_is_operating())
			return
		elect_master()
		if (alarm_area.master_air_alarm != src)
			return
	if(!signal || signal.encryption)
		return
	var/id_tag = signal.data["tag"]
	if (!id_tag)
		return
	if (signal.data["area"] != area_uid)
		return
	if (signal.data["sigtype"] != "status")
		return

	var/dev_type = signal.data["device"]
	if(!(id_tag in alarm_area.air_scrub_names) && !(id_tag in alarm_area.air_vent_names))
		register_env_machine(id_tag, dev_type)
	if(dev_type == "AScr")
		alarm_area.air_scrub_info[id_tag] = signal.data
	else if(dev_type == "AVP")
		alarm_area.air_vent_info[id_tag] = signal.data

/obj/machinery/alarm/proc/register_env_machine(m_id, device_type)
	var/new_name
	if (device_type=="AVP")
		new_name = "[alarm_area.name] Vent Pump #[alarm_area.air_vent_names.len+1]"
		alarm_area.air_vent_names[m_id] = new_name
	else if (device_type=="AScr")
		new_name = "[alarm_area.name] Air Scrubber #[alarm_area.air_scrub_names.len+1]"
		alarm_area.air_scrub_names[m_id] = new_name
	else
		return
	spawn (10)
		send_signal(m_id, list("init" = new_name) )

/obj/machinery/alarm/proc/refresh_all()
	for(var/id_tag in alarm_area.air_vent_names)
		var/list/I = alarm_area.air_vent_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )
	for(var/id_tag in alarm_area.air_scrub_names)
		var/list/I = alarm_area.air_scrub_info[id_tag]
		if (I && I["timestamp"]+AALARM_REPORT_TIMEOUT/2 > world.time)
			continue
		send_signal(id_tag, list("status") )

/obj/machinery/alarm/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_TO_AIRALARM)

/obj/machinery/alarm/proc/send_signal(target, list/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = command
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"

	radio_connection.post_signal(src, signal, RADIO_FROM_AIRALARM)
//			world << text("Signal [] Broadcasted to []", command, target)

	return 1

/obj/machinery/alarm/proc/apply_mode()
	//propagate mode to other air alarms in the area
	for (var/obj/machinery/alarm/AA in alarm_area)
		AA.mode = mode

	switch(mode)
		if(AALARM_MODE_SCRUBBING)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 1, "co2_scrub"= 1, "scrubbing"= 1, "panic_siphon"= 0) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= "default", "set_external_pressure"= "default") )

		if(AALARM_MODE_PANIC, AALARM_MODE_CYCLE)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 1, "panic_siphon"= 1) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 0) )

		if(AALARM_MODE_REPLACEMENT)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 1, "panic_siphon"= 1) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= "default", "set_external_pressure"= "default") )

		if(AALARM_MODE_FILL)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 0) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 1, "checks"= "default", "set_external_pressure"= "default") )

		if(AALARM_MODE_OFF)
			for(var/device_id in alarm_area.air_scrub_names)
				send_signal(device_id, list("power"= 0) )
			for(var/device_id in alarm_area.air_vent_names)
				send_signal(device_id, list("power"= 0) )

/obj/machinery/alarm/proc/apply_danger_level(new_danger_level)
	if (alarm_area.atmosalert(new_danger_level))
		post_alert(new_danger_level)

	update_icon()

/obj/machinery/alarm/proc/post_alert(alert_level)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(alarm_frequency)
	if(!frequency)
		return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = alarm_area.name
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level==2)
		alert_signal.data["alert"] = "severe"
	else if (alert_level==1)
		alert_signal.data["alert"] = "minor"
	else if (alert_level==0)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal)

/obj/machinery/alarm/proc/shock(mob/user, prb)
	if((stat & (NOPOWER)))		// unpowered, no shock
		return 0
	if(!prob(prb))
		return 0 //you lucked out, no shock for you
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, src)
	s.start() //sparks always.
	if (electrocute_mob(user, get_area(src), src))
		return 1
	else
		return 0
///////////////
//END HACKING//
///////////////

/obj/machinery/alarm/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, master_ui = null, datum/topic_state/custom_state)
	var/data[0]
	var/remote_connection = 0
	var/remote_access = 0

	if(custom_state)
		var/list/href = custom_state.href_list(user)
		remote_connection = href["remote_connection"]	// Remote connection means we're non-adjacent/connecting from another computer
		remote_access = href["remote_access"]			// Remote access means we also have the privilege to alter the air alarm.

	data["locked"] = locked && !issilicon(user) && !isobserver(user)
	data["remote_connection"] = remote_connection
	data["remote_access"] = remote_access
	data["rcon"] = rcon_setting
	data["screen"] = screen

	populate_status(data)

	if(!(locked && !remote_connection) || remote_access || issilicon(user))
		populate_controls(data)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if(!ui)
		ui = new(user, src, ui_key, "air_alarm.tmpl", name, 450, 625, master_ui = master_ui, custom_state = custom_state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/alarm/proc/populate_status(var/data)
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	var/total = environment.total_moles

	var/list/environment_data = new
	data["has_environment"] = total
	if(total)
		var/pressure = environment.return_pressure()
		environment_data[++environment_data.len] = list("name" = "Pressure", "value" = pressure, "unit" = "kPa", "danger_level" = pressure_dangerlevel)
		environment_data[++environment_data.len] = list("name" = "Oxygen", "value" = environment.gas["oxygen"] / total * 100, "unit" = "%", "danger_level" = oxygen_dangerlevel)
		environment_data[++environment_data.len] = list("name" = "Carbon dioxide", "value" = environment.gas["carbon_dioxide"] / total * 100, "unit" = "%", "danger_level" = co2_dangerlevel)
		environment_data[++environment_data.len] = list("name" = "Toxins", "value" = environment.gas["phoron"] / total * 100, "unit" = "%", "danger_level" = phoron_dangerlevel)
		environment_data[++environment_data.len] = list("name" = "Temperature", "value" = environment.temperature, "unit" = "K ([round(environment.temperature - T0C, 0.1)]C)", "danger_level" = temperature_dangerlevel)
	data["total_danger"] = danger_level
	data["environment"] = environment_data
	data["atmos_alarm"] = alarm_area.atmosalm
	data["fire_alarm"] = alarm_area.fire != null
	data["target_temperature"] = "[target_temperature - T0C]C"
	data["thermoregulation"] = allow_regulate

/obj/machinery/alarm/proc/populate_controls(var/list/data)
	switch(screen)
		if(AALARM_SCREEN_MAIN)
			data["mode"] = mode
		if(AALARM_SCREEN_VENT)
			var/vents[0]
			for(var/id_tag in alarm_area.air_vent_names)
				var/long_name = alarm_area.air_vent_names[id_tag]
				var/list/info = alarm_area.air_vent_info[id_tag]
				if(!info)
					continue
				vents[++vents.len] = list(
						"id_tag"    = id_tag,
						"long_name" = sanitize(long_name),
						"power"     = info["power"],
						"checks"    = info["checks"],
						"direction" = info["direction"],
						"external"  = info["external"],
						"internal"  = info["internal"]
					)
			data["vents"] = vents
		if(AALARM_SCREEN_SCRUB)
			var/scrubbers[0]
			for(var/id_tag in alarm_area.air_scrub_names)
				var/long_name = alarm_area.air_scrub_names[id_tag]
				var/list/info = alarm_area.air_scrub_info[id_tag]
				if(!info)
					continue
				scrubbers[++scrubbers.len] = list(
						"id_tag"    = id_tag,
						"long_name" = sanitize(long_name),
						"power"     = info["power"],
						"scrubbing" = info["scrubbing"],
						"panic"     = info["panic"],
						"filters"   = list()
					)
				scrubbers[scrubbers.len]["filters"] += list(list("name" = "Oxygen",         "command" = "o2_scrub",  "val" = info["filter_o2"]))
				scrubbers[scrubbers.len]["filters"] += list(list("name" = "Nitrogen",       "command" = "n2_scrub",  "val" = info["filter_n2"]))
				scrubbers[scrubbers.len]["filters"] += list(list("name" = "Carbon Dioxide", "command" = "co2_scrub", "val" = info["filter_co2"]))
				scrubbers[scrubbers.len]["filters"] += list(list("name" = "Toxin",          "command" = "tox_scrub", "val" = info["filter_phoron"]))
				scrubbers[scrubbers.len]["filters"] += list(list("name" = "Nitrous Oxide",  "command" = "n2o_scrub", "val" = info["filter_n2o"]))
			data["scrubbers"] = scrubbers
		if(AALARM_SCREEN_MODE)
			var/modes[0]
			modes[++modes.len] = list("name" = "Filtering - Scrubs out contaminants",           "mode" = AALARM_MODE_SCRUBBING,   "selected" = mode == AALARM_MODE_SCRUBBING,   "danger" = 0)
			modes[++modes.len] = list("name" = "Replace Air - Siphons out air while replacing", "mode" = AALARM_MODE_REPLACEMENT, "selected" = mode == AALARM_MODE_REPLACEMENT, "danger" = 0)
			modes[++modes.len] = list("name" = "Panic - Siphons air out of the room",           "mode" = AALARM_MODE_PANIC,       "selected" = mode == AALARM_MODE_PANIC,       "danger" = 1)
			modes[++modes.len] = list("name" = "Cycle - Siphons air before replacing",          "mode" = AALARM_MODE_CYCLE,       "selected" = mode == AALARM_MODE_CYCLE,       "danger" = 1)
			modes[++modes.len] = list("name" = "Fill - Shuts off scrubbers and opens vents",    "mode" = AALARM_MODE_FILL,        "selected" = mode == AALARM_MODE_FILL,        "danger" = 0)
			modes[++modes.len] = list("name" = "Off - Shuts off vents and scrubbers",           "mode" = AALARM_MODE_OFF,         "selected" = mode == AALARM_MODE_OFF,         "danger" = 0)
			data["modes"] = modes
			data["mode"] = mode
		if(AALARM_SCREEN_SENSORS)
			var/list/selected
			var/thresholds[0]

			var/list/gas_names = list(
				"oxygen"         = "O<sub>2</sub>",
				"carbon dioxide" = "CO<sub>2</sub>",
				"phoron"         = "Toxin",
				"other"          = "Other")
			for (var/g in gas_names)
				thresholds[++thresholds.len] = list("name" = gas_names[g], "settings" = list())
				selected = TLV[g]
				for (var/i in 1 to 4)
					thresholds[thresholds.len]["settings"] += list(list("env" = g, "val" = i, "selected" = selected[i]))

			selected = TLV["pressure"]
			thresholds[++thresholds.len] = list("name" = "Pressure", "settings" = list())
			for (var/i in 1 to 4)
				thresholds[thresholds.len]["settings"] += list(list("env" = "pressure", "val" = i, "selected" = selected[i]))

			selected = TLV["temperature"]
			thresholds[++thresholds.len] = list("name" = "Temperature", "settings" = list())
			for (var/i in 1 to 4)
				thresholds[thresholds.len]["settings"] += list(list("env" = "temperature", "val" = i, "selected" = selected[i]))

			data["thresholds"] = thresholds

/obj/machinery/alarm/CanUseTopic(mob/user, href_list, datum/topic_state/custom_state)
	if(buildstage != 2)
		return STATUS_CLOSE

	if(aidisabled && isAI(user))
		to_chat(user, "<span class='warning'>AI control for \the [src] interface has been disabled.</span>")
		return STATUS_CLOSE

	. = shorted ? STATUS_DISABLED : STATUS_INTERACTIVE

	if(. == STATUS_INTERACTIVE)
		var/extra_href = custom_state.href_list(usr)
		// Prevent remote users from altering RCON settings unless they already have access
		if(href_list && href_list["rcon"] && extra_href["remote_connection"] && !extra_href["remote_access"])
			. = STATUS_UPDATE

	return min(..(), .)

/obj/machinery/alarm/Topic(href, href_list)
	. = ..()
	if(!.) // dont forget calling super in machine Topics -walter0o
		return

	// hrefs that can always be called -walter0o
	if(href_list["rcon"])
		var/attempted_rcon_setting = text2num(href_list["rcon"])

		switch(attempted_rcon_setting)
			if(RCON_NO)
				rcon_setting = RCON_NO
			if(RCON_AUTO)
				rcon_setting = RCON_AUTO
			if(RCON_YES)
				rcon_setting = RCON_YES
			else
				return FALSE

	if(href_list["temperature"])
		var/list/selected = TLV["temperature"]
		var/max_temperature = min(selected[3] - T0C-1, MAX_TEMPERATURE) // (-/+ 1) required because it won't heat/cool, if (target_temperature == TLV)
		var/min_temperature = max(selected[2] - T0C+1, MIN_TEMPERATURE)
		var/input_temperature = input("What temperature would you like the system to mantain? (Capped between [min_temperature] and [max_temperature]C)", "Thermostat Controls", target_temperature - T0C) as num|null
		if(isnum(input_temperature))
			if(input_temperature > max_temperature || input_temperature < min_temperature)
				to_chat(usr, "Temperature must be between [min_temperature]C and [max_temperature]C")
			else
				target_temperature = input_temperature + T0C
		return FALSE

	if(href_list["allow_regulate"])
		allow_regulate = !allow_regulate

	// hrefs that need the AA unlocked -walter0o
	if(!locked || issilicon_allowed(usr) || isobserver(usr))

		if(href_list["command"])
			var/device_id = href_list["id_tag"]
			switch(href_list["command"])

				if("set_external_pressure")
					var/input_pressure = input("What pressure you like the system to mantain?", "Pressure Controls") as num|null
					if(isnum(input_pressure))
						send_signal(device_id, list(href_list["command"] = input_pressure))
					return FALSE

				if("reset_external_pressure")
					send_signal(device_id, list(href_list["command"] = TRUE))
					return FALSE

				if("set_internal_pressure")
					var/input_pressure = input("What pressure you like the system to mantain?", "Pressure Controls") as num|null
					if(isnum(input_pressure))
						send_signal(device_id, list(href_list["command"] = input_pressure))
					return FALSE

				if("reset_internal_pressure")
					send_signal(device_id, list(href_list["command"] = TRUE))
					return FALSE

				if( "power",
					"adjust_external_pressure",
					"set_external_pressure",
					"checks",
					"o2_scrub",
					"n2_scrub",
					"co2_scrub",
					"tox_scrub",
					"n2o_scrub",
					"panic_siphon",
					"scrubbing")

					send_signal(device_id, list(href_list["command"] = text2num(href_list["val"]) ) )
					if(href_list["command"] == "adjust_external_pressure")
						var/new_val = text2num(href_list["val"])
						log_investigate("[key_name(usr)] has changed adjust_external_pressure > added [new_val], id_tag = [device_id]",INVESTIGATE_ATMOS)
					if(href_list["command"] == "checks")
						var/new_val = text2num(href_list["val"])
						log_investigate("[key_name(usr)] has changed pressure_checks > now [new_val](1 = ext, 2 = int, 3 = both), id_tag = [device_id]",INVESTIGATE_ATMOS)

				if("set_threshold")
					var/env = href_list["env"]
					var/threshold = text2num(href_list["var"])
					var/list/selected = TLV[env]
					var/list/thresholds = list("lower bound", "low warning", "high warning", "upper bound")
					var/newval = input("Enter [thresholds[threshold]] for [env]", "Alarm triggers", selected[threshold]) as null|num
					if (isnull(newval))
						return TRUE
					if (newval < 0)
						selected[threshold] = -1.0
					else if (env == "temperature" && newval > 5000)
						selected[threshold] = 5000
					else if (env == "pressure" && newval > 50 * ONE_ATMOSPHERE)
						selected[threshold] = 50 * ONE_ATMOSPHERE
					else if (env != "temperature" && env != "pressure" && newval > 200)
						selected[threshold] = 200
					else
						newval = round(newval, 0.01)
						selected[threshold] = newval
					if(threshold == 1)
						if(selected[1] > selected[2])
							selected[2] = selected[1]
						if(selected[1] > selected[3])
							selected[3] = selected[1]
						if(selected[1] > selected[4])
							selected[4] = selected[1]
					if(threshold == 2)
						if(selected[1] > selected[2])
							selected[1] = selected[2]
						if(selected[2] > selected[3])
							selected[3] = selected[2]
						if(selected[2] > selected[4])
							selected[4] = selected[2]
					if(threshold == 3)
						if(selected[1] > selected[3])
							selected[1] = selected[3]
						if(selected[2] > selected[3])
							selected[2] = selected[3]
						if(selected[3] > selected[4])
							selected[4] = selected[3]
					if(threshold == 4)
						if(selected[1] > selected[4])
							selected[1] = selected[4]
						if(selected[2] > selected[4])
							selected[2] = selected[4]
						if(selected[3] > selected[4])
							selected[3] = selected[4]

					apply_mode()
					return FALSE

		if(href_list["screen"])
			screen = text2num(href_list["screen"])
			return FALSE

		if(href_list["atmos_unlock"])
			switch(href_list["atmos_unlock"])
				if("0")
					alarm_area.air_doors_close()
				if("1")
					alarm_area.air_doors_open()
			return FALSE

		if(href_list["atmos_alarm"])
			if (alarm_area.atmosalert(2, src))
				apply_danger_level(2)
			update_icon()
			return FALSE

		if(href_list["atmos_reset"])
			if (alarm_area.atmosalert(0, src))
				apply_danger_level(0)
			update_icon()
			return FALSE

		if(href_list["mode"])
			mode = text2num(href_list["mode"])
			apply_mode()
			return FALSE


/obj/machinery/alarm/attack_alien(mob/living/carbon/xenomorph/humanoid/user)
	to_chat(user, "You don't want to break these things");
	return

/obj/machinery/alarm/attackby(obj/item/W, mob/user)

	add_fingerprint(user)

	switch(buildstage)
		if(2)
			if(isscrewdriver(W))  // Opening that Air Alarm up.
				wiresexposed = !wiresexposed
				to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"]")
				update_icon()
				return

			if (iswirecutter(W) && wiresexposed && wires.is_all_cut())
				user.visible_message("<span class='warning'>[user] has cut the wires inside \the [src]!</span>", "You have cut the wires inside \the [src].")
				playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
				new /obj/item/stack/cable_coil/random(loc, 5)
				buildstage = 1
				update_icon()
				return

			if (istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))// trying to unlock the interface with an ID card
				if(stat & (NOPOWER|BROKEN))
					to_chat(user, "It does nothing")
					return
				else
					if(allowed(usr) && !wires.is_index_cut(AALARM_WIRE_IDSCAN))
						locked = !locked
						to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the Air Alarm interface.</span>")
						updateUsrDialog()
					else
						to_chat(user, "<span class='warning'>Access denied.</span>")

			if(wiresexposed && is_wire_tool(W))
				wires.interact(user)
				return

			return

		if(1)
			if(iscoil(W))
				var/obj/item/stack/cable_coil/coil = W
				if(!coil.use(5))
					to_chat(user, "<span class='warning'>You need 5 pieces of cable to do wire \the [src].</span>")
					return

				to_chat(user, "You wire \the [src]!")

				buildstage = 2
				update_icon()
				first_run()
				wires.repair()
				return

			else if(iscrowbar(W))
				if(user.is_busy())
					return
				to_chat(user, "You start prying out the circuit.")
				if(W.use_tool(src, user, 20, volume = 50))
					to_chat(user, "You pry out the circuit!")
					var/obj/item/weapon/airalarm_electronics/circuit = new /obj/item/weapon/airalarm_electronics()
					circuit.loc = user.loc
					buildstage = 0
					update_icon()
				return
		if(0)
			if(istype(W, /obj/item/weapon/airalarm_electronics))
				to_chat(user, "You insert the circuit!")
				qdel(W)
				buildstage = 1
				update_icon()
				return

			else if(iswrench(W))
				to_chat(user, "You remove the fire alarm assembly from the wall!")
				var/obj/item/alarm_frame/frame = new /obj/item/alarm_frame()
				frame.loc = user.loc
				playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
				qdel(src)

	return ..()

/obj/machinery/alarm/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	spawn(rand(0,15))
		update_icon()
	update_power_use()

/obj/machinery/alarm/examine(mob/user)
	..()
	if (buildstage < 2)
		to_chat(user, "It is not wired.")
	if (buildstage < 1)
		to_chat(user, "The circuit is missing.")
/*
AIR ALARM CIRCUIT
Just a object used in constructing air alarms
*/
/obj/item/weapon/airalarm_electronics
	name = "air alarm electronics"
	icon = 'icons/obj/doors/door_electronics.dmi'
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = ITEM_SIZE_SMALL
	m_amt = 50
	g_amt = 50


/*
AIR ALARM ITEM
Handheld air alarm frame, for placing on walls
Code shamelessly copied from apc_frame
*/
/obj/item/alarm_frame
	name = "air alarm frame"
	desc = "Used for building Air Alarms"
	icon = 'icons/obj/monitors.dmi'
	icon_state = "alarm_bitem"
	flags = CONDUCT

/obj/item/alarm_frame/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		user.SetNextMove(CLICK_CD_RAPID)
		new /obj/item/stack/sheet/metal(loc, 2)
		qdel(src)
		return
	return ..()

/obj/item/alarm_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return

	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf_loc(usr)
	var/area/A = loc.loc
	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, "<span class='warning'>Air Alarm cannot be placed on this spot.</span>")
		return
	if (A.requires_power == 0 || A.name == "Space")
		to_chat(usr, "<span class='warning'>Air Alarm cannot be placed in this area.</span>")
		return

	if(gotwallitem(loc, ndir))
		to_chat(usr, "<span class='warning'>There's already an item on this wall!</span>")
		return

	new /obj/machinery/alarm(loc, ndir, 1)
	qdel(src)

/*
FIRE ALARM
*/
/obj/machinery/firealarm
	name = "Fire Alarm"
	desc = "<i>\"Pull this in case of emergency\"</i>. Thus, keep pulling it forever."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire0"
	var/detecting = 1.0
	var/working = 1.0
	var/time = 10.0
	var/timing = 0.0
	var/lockdownbyai = 0
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = STATIC_ENVIRON
	allowed_checks = ALLOWED_CHECK_NONE
	var/last_process = 0
	var/wiresexposed = 0
	var/buildstage = 2 // 2 = complete, 1 = no wires,  0 = circuit gone

/obj/machinery/firealarm/update_icon()
	if(wiresexposed)
		icon_state="fire_build[buildstage]"
		return

	if(stat & BROKEN)
		icon_state = "fire_broken"
	else if(stat & NOPOWER)
		icon_state = "fire_unpowered"
	else if(!detecting)
		icon_state = "fire1"
	else
		icon_state = "fire0"

/obj/machinery/firealarm/fire_act(datum/gas_mixture/air, temperature, volume)
	if(detecting)
		if(temperature > T0C+200)
			alarm()			// added check of detector status here
	return

/obj/machinery/firealarm/bullet_act(BLAH)
	return alarm()

/obj/machinery/firealarm/emp_act(severity)
	if(prob(50/severity))
		alarm()
	..()

/obj/machinery/firealarm/attackby(obj/item/W, mob/user)
	add_fingerprint(user)

	if (isscrewdriver(W) && buildstage == 2)
		wiresexposed = !wiresexposed
		update_icon()
		return

	if(wiresexposed)
		switch(buildstage)
			if(2)
				if (ismultitool(W))
					detecting = !detecting
					if (detecting)
						user.visible_message("<span class='warning'>[user] has reconnected [src]'s detecting unit!</span>", "You have reconnected [src]'s detecting unit.")
					else
						user.visible_message("<span class='warning'>[user] has disconnected [src]'s detecting unit!</span>", "You have disconnected [src]'s detecting unit.")
				else if (iswirecutter(W))
					user.visible_message("<span class='warning'>[user] has cut the wires inside \the [src]!</span>", "You have cut the wires inside \the [src].")
					new /obj/item/stack/cable_coil/random(loc, 5)
					playsound(src, 'sound/items/Wirecutter.ogg', VOL_EFFECTS_MASTER)
					buildstage = 1
					update_icon()
			if(1)
				if(iscoil(W))
					var/obj/item/stack/cable_coil/coil = W
					if(!coil.use(5))
						to_chat(user, "<span class='warning'>You need 5 pieces of cable to do wire \the [src].</span>")
						return

					buildstage = 2
					to_chat(user, "You wire \the [src]!")
					update_icon()

				else if(iscrowbar(W))
					to_chat(user, "You start prying out the circuit.")
					if(W.use_tool(src, user, 20, volume = 50))
						to_chat(user, "You pry out the circuit!")
						var/obj/item/weapon/firealarm_electronics/circuit = new /obj/item/weapon/firealarm_electronics()
						circuit.loc = user.loc
						buildstage = 0
						update_icon()

			if(0)
				if(istype(W, /obj/item/weapon/firealarm_electronics))
					to_chat(user, "You insert the circuit!")
					qdel(W)
					buildstage = 1
					update_icon()

				else if(iswrench(W))
					if(user.is_busy())
						return
					to_chat(user, "You remove the fire alarm assembly from the wall!")
					var/obj/item/firealarm_frame/frame = new /obj/item/firealarm_frame()
					frame.loc = user.loc
					playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
					qdel(src)
		return

	alarm()
	return

/obj/machinery/firealarm/process()//Note: this processing was mostly phased out due to other code, and only runs when needed
	if(stat & (NOPOWER|BROKEN))
		return

	if(timing)
		if(time > 0)
			time = time - ((world.timeofday - last_process)/10)
		else
			alarm()
			time = 0
			timing = 0
			STOP_PROCESSING(SSobj, src)
		updateDialog()
	last_process = world.timeofday

	if(locate(/obj/fire) in loc)
		alarm()

	return

/obj/machinery/firealarm/power_change()
	if(powered(power_channel))
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0,15))
			stat |= NOPOWER
			update_icon()
			update_power_use()
	update_power_use()

/obj/machinery/firealarm/ui_interact(mob/user)
	if (buildstage != 2)
		return

	user.set_machine(src)
	var/area/A = get_area(src)
	var/d1
	var/d2
	if (ishuman(user) || issilicon(user) || isobserver(user))
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = round(time) % 60
		var/minute = (round(time) - second) / 60
		var/dat = "[d1]\n<HR><b>The current alert level is: [get_security_level()]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? "[minute]:" : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n"

		var/datum/browser/popup = new(user, "window=firealarm", src.name)
		popup.set_content(dat)
		popup.open()

	else
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("Reset - Lockdown"))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("Alarm - Lockdown"))
		if (timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = round(time) % 60
		var/minute = (round(time) - second) / 60
		var/dat = "[d1]\n<HR><b>The current alert level is: [stars(get_security_level())]</b><br><br>\nTimer System: [d2]<BR>\nTime Left: [(minute ? text("[]:", minute) : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>\n"

		var/datum/browser/popup = new(user, "window=firealarm", stars(src.name))
		popup.set_content(dat)
		popup.open()

/obj/machinery/firealarm/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if (buildstage != 2)
		return FALSE

	if (href_list["reset"])
		reset()
	else if (href_list["alarm"])
		alarm()
	else if (href_list["time"])
		timing = text2num(href_list["time"])
		last_process = world.timeofday
		START_PROCESSING(SSobj, src)
	else if (href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 0), 120)

	updateUsrDialog()

/obj/machinery/firealarm/proc/reset()
	if (!working)
		return
	var/area/A = get_area(src)
	A.firereset()
	for(var/obj/machinery/firealarm/FA in A)
		FA.detecting = TRUE
		FA.update_icon()

/obj/machinery/firealarm/proc/alarm()
	if (!working)
		return
	var/area/A = get_area(src)
	A.firealert()
	for(var/obj/machinery/firealarm/FA in A)
		FA.detecting = FALSE
		FA.update_icon()
		playsound(src, 'sound/machines/alarm_fire.ogg', VOL_EFFECTS_MASTER, null, FALSE)

/obj/machinery/firealarm/examine(mob/user)
	. = ..()
	var/msg
	switch(get_security_level())
		if("green")
			msg = "<font color='green'><b>Green</b></font>"
		if("blue")
			msg = "<font color='blue'><b>Blue</b></font>"
		if("red")
			msg = "<font color='red'><b>Red</b></font>"
		if("delta")
			msg = "<font color='purple'><b>Delta</b></font>"
	to_chat(user, "The small light indicates [msg] security level.")

/obj/machinery/firealarm/atom_init(mapload, dir, building)
	. = ..()

	firealarm_list += src

	if(loc)
		src.loc = loc

	if(dir)
		src.dir = dir

	if(building)
		buildstage = 0
		wiresexposed = 1
		pixel_x = (dir & 3)? 0 : (dir == 4 ? -24 : 24)
		pixel_y = (dir & 3)? (dir ==1 ? -24 : 24) : 0

	if(is_station_level(z) || is_mining_level(z))
		if(security_level)
			add_overlay(image('icons/obj/monitors.dmi', "overlay_[get_security_level()]"))
		else
			add_overlay(image('icons/obj/monitors.dmi', "overlay_green"))

	update_icon()

/obj/machinery/firealarm/Destroy()
	firealarm_list -= src
	return ..()

/*
FIRE ALARM CIRCUIT
Just a object used in constructing fire alarms
*/
/obj/item/weapon/firealarm_electronics
	name = "fire alarm electronics"
	icon = 'icons/obj/doors/door_electronics.dmi'
	icon_state = "door_electronics"
	desc = "A circuit. It has a label on it, it says \"Can handle heat levels up to 40 degrees celsius!\""
	w_class = ITEM_SIZE_SMALL
	m_amt = 50
	g_amt = 50


/*
FIRE ALARM ITEM
Handheld fire alarm frame, for placing on walls
Code shamelessly copied from apc_frame
*/
/obj/item/firealarm_frame
	name = "fire alarm frame"
	desc = "Used for building Fire Alarms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "fire_bitem"
	flags = CONDUCT

/obj/item/firealarm_frame/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		user.SetNextMove(CLICK_CD_RAPID)
		new /obj/item/stack/sheet/metal(loc, 2)
		qdel(src)
		return
	return ..()

/obj/item/firealarm_frame/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr) > 1)
		return

	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in cardinal))
		return

	var/turf/loc = get_turf_loc(usr)
	var/area/A = get_area(src)
	if (!istype(loc, /turf/simulated/floor))
		to_chat(usr, "<span class='warning'>Fire Alarm cannot be placed on this spot.</span>")
		return
	if (A.requires_power == 0 || A.name == "Space")
		to_chat(usr, "<span class='warning'>Fire Alarm cannot be placed in this area.</span>")
		return

	if(gotwallitem(loc, ndir))
		to_chat(usr, "<span class='warning'>There's already an item on this wall!</span>")
		return

	new /obj/machinery/firealarm(loc, ndir, 1)

	qdel(src)
