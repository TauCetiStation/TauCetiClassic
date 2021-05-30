/*

Passive gate is similar to the regular pump except:
* It doesn't require power
* Can not transfer low pressure to higher pressure (so it's more like a valve where you can control the flow)

*/

#define REGULATE_NONE   0
#define REGULATE_INPUT  1 //shuts off when input side is below the target pressure
#define REGULATE_OUTPUT 2 //shuts off when output side is above the target pressure

/obj/machinery/atmospherics/components/binary/passive_gate
	icon = 'icons/atmos/passive_gate.dmi'
	icon_state = "map_off"

	name = "pressure regulator"
	desc = "A one-way air valve that can be used to regulate input or output pressure, and flow rate. Does not require power."

	can_unwrench = TRUE
	use_power = NO_POWER_USE
	interact_offline = TRUE
	allowed_checks = ALLOWED_CHECK_TOPIC

	var/unlocked = 0 // If 0, then the valve is locked closed, otherwise it is open(-able, it's a one-way valve so it closes if gas would flow backwards).
	var/target_pressure = ONE_ATMOSPHERE
	var/max_pressure_setting = MAX_PUMP_PRESSURE
	var/set_flow_rate = ATMOS_DEFAULT_VOLUME_PUMP * 2.5
	var/regulate_mode = REGULATE_OUTPUT

	var/flowing = FALSE // for icons - becomes zero if the valve closes itself due to regulation mode

	frequency = 0
	var/id = null

/obj/machinery/atmospherics/components/binary/passive_gate/on
	unlocked = 1
	icon_state = "map_on"

/obj/machinery/atmospherics/components/binary/passive_gate/atom_init()
	. = ..()

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	air1.volume = ATMOS_DEFAULT_VOLUME_PUMP * 2.5
	air2.volume = ATMOS_DEFAULT_VOLUME_PUMP * 2.5

/obj/machinery/atmospherics/components/binary/passive_gate/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/binary/passive_gate/update_icon()
	..()
	icon_state = (unlocked && flowing) ? "on" : "off"

/obj/machinery/atmospherics/components/binary/passive_gate/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, NODE1, turn(dir, 180))
		add_underlay(T, NODE2, dir)

/obj/machinery/atmospherics/components/binary/passive_gate/hide(i)
	update_underlays()

/obj/machinery/atmospherics/components/binary/passive_gate/process_atmos()
	last_flow_rate = 0
	last_power_draw = 0

	if(!unlocked)
		return FALSE

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	var/output_starting_pressure = air2.return_pressure()
	var/input_starting_pressure = air1.return_pressure()

	var/pressure_delta
	switch (regulate_mode)
		if (REGULATE_INPUT)
			pressure_delta = input_starting_pressure - target_pressure
		if (REGULATE_OUTPUT)
			pressure_delta = target_pressure - output_starting_pressure

	//-1 if pump_gas() did not move any gas, >= 0 otherwise
	var/returnval = -1
	if((regulate_mode == REGULATE_NONE || pressure_delta > 0.01) && (air1.temperature > 0 || air2.temperature > 0))	//since it's basically a valve, it makes sense to check both temperatures
		flowing = TRUE

		//flow rate limit
		var/transfer_moles = (set_flow_rate/air1.volume)*air1.total_moles

		//Figure out how much gas to transfer to meet the target pressure.
		switch (regulate_mode)
			if (REGULATE_INPUT)
				var/datum/pipeline/parent1 = PARENT1
				transfer_moles = min(transfer_moles, calculate_transfer_moles(air2, air1, pressure_delta, (parent1) ? parent1.air.volume : 0))
			if (REGULATE_OUTPUT)
				var/datum/pipeline/parent2 = PARENT2
				transfer_moles = min(transfer_moles, calculate_transfer_moles(air1, air2, pressure_delta, (parent2) ? parent2.air.volume : 0))

		//pump_gas() will return a negative number if no flow occurred
		returnval = pump_gas_passive(src, air1, air2, transfer_moles)

	if (returnval >= 0)
		update_parents()

	if (last_flow_rate)
		flowing = TRUE

	update_icon()


//Radio remote control

/obj/machinery/atmospherics/components/binary/passive_gate/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/binary/passive_gate/proc/broadcast_status()
	if(!radio_connection)
		return FALSE

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "AGP",
		"power" = unlocked,
		"target_output" = target_pressure,
		"regulate_mode" = regulate_mode,
		"set_flow_rate" = set_flow_rate,
		"sigtype" = "status"
	)

	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return TRUE

/obj/machinery/atmospherics/components/binary/passive_gate/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return FALSE

	if("power" in signal.data)
		unlocked = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		unlocked = !unlocked

	if("set_target_pressure" in signal.data)
		target_pressure = between(
			0,
			text2num(signal.data["set_target_pressure"]),
			max_pressure_setting
		)

	if("set_regulate_mode" in signal.data)
		regulate_mode = text2num(signal.data["set_regulate_mode"])

	if("set_flow_rate" in signal.data)
		regulate_mode = text2num(signal.data["set_flow_rate"])

	if("status" in signal.data)
		broadcast_status()
		return //do not update_icon

	broadcast_status()
	update_icon()
	return

/obj/machinery/atmospherics/components/binary/passive_gate/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui)
	if(stat & (BROKEN|NOPOWER))
		return

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	// this is the data which will be sent to the ui
	var/data[0]

	data = list(
		"on" = unlocked,
		"pressure_set" = round(target_pressure * 100),	//Nano UI can't handle rounded non-integers, apparently.
		"max_pressure" = max_pressure_setting,
		"input_pressure" = round(air1.return_pressure() * 100),
		"output_pressure" = round(air2.return_pressure() * 100),
		"regulate_mode" = regulate_mode,
		"set_flow_rate" = round(set_flow_rate * 10),
		"last_flow_rate" = round(last_flow_rate * 10),
	)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
		// for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "pressure_regulator.tmpl", name, 470, 370)
		ui.set_initial_data(data)	// when the ui is first opened this is the data it will use
		ui.open()					// open the new ui window
		ui.set_auto_update(1)		// auto update every Master Controller tick


/obj/machinery/atmospherics/components/binary/passive_gate/Topic(href, href_list)
	if(!..())
		return FALSE

	if(href_list["toggle_valve"])
		unlocked = !unlocked

	if(href_list["regulate_mode"])
		switch(href_list["regulate_mode"])
			if ("off") regulate_mode = REGULATE_NONE
			if ("input") regulate_mode = REGULATE_INPUT
			if ("output") regulate_mode = REGULATE_OUTPUT

	switch(href_list["set_press"])
		if ("min")
			target_pressure = 0
		if ("max")
			target_pressure = max_pressure_setting
		if ("set")
			var/new_pressure = input(usr,"Enter new output pressure (0-[max_pressure_setting]kPa)","Pressure Control", target_pressure) as num
			target_pressure = between(0, new_pressure, max_pressure_setting)

	var/datum/gas_mixture/air1 = AIR1

	switch(href_list["set_flow_rate"])
		if ("min")
			set_flow_rate = 0
		if ("max")
			set_flow_rate = air1.volume
		if ("set")
			var/new_flow_rate = input(usr,"Enter new flow rate limit (0-[air1.volume]kPa)","Flow Rate Control", set_flow_rate) as num
			set_flow_rate = between(0, new_flow_rate, air1.volume)

	usr.set_machine(src)	//Is this even needed with NanoUI?
	update_icon()
	add_fingerprint(usr)

/obj/machinery/atmospherics/components/binary/passive_gate/can_unwrench(mob/user)
	if(..())
		if(unlocked)
			to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		else
			return TRUE

#undef REGULATE_NONE
#undef REGULATE_INPUT
#undef REGULATE_OUTPUT
