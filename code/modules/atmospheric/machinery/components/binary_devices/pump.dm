/*
Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.

node1, air1, network1 correspond to input
node2, air2, network2 correspond to output

Thus, the two variables affect pump operation are set in New():
	air1.volume
		This is the volume of gas available to the pump that may be transfered to the output
	air2.volume
		Higher quantities of this cause more air to be perfected later
			but overall network volume is also increased as this increases...
*/

/obj/machinery/atmospherics/components/binary/pump
	icon = 'icons/atmos/pump.dmi'
	icon_state = "map_off"

	name = "gas pump"
	desc = "A pump that moves gas by pressure."

	can_unwrench = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 150 // internal circuitry, friction losses and stuff
	power_rating = 7500    // 7500 W ~ 10 HP
	allowed_checks = ALLOWED_CHECK_TOPIC

	var/target_pressure = ONE_ATMOSPHERE
	var/max_pressure_setting = MAX_PUMP_PRESSURE

	frequency = 0
	var/id = null

/obj/machinery/atmospherics/components/binary/pump/atom_init()
	. = ..()

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	air1.volume = ATMOS_DEFAULT_VOLUME_PUMP
	air2.volume = ATMOS_DEFAULT_VOLUME_PUMP

/obj/machinery/atmospherics/components/binary/pump/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/binary/pump/on
	icon_state = "map_on"
	use_power = IDLE_POWER_USE


/obj/machinery/atmospherics/components/binary/pump/update_icon()
	..()
	if(!powered())
		icon_state = "off"
	else
		icon_state = "[use_power ? "on" : "off"]"

/obj/machinery/atmospherics/components/binary/pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, NODE1, turn(dir, -180))
		add_underlay(T, NODE2, dir)

/obj/machinery/atmospherics/components/binary/pump/process_atmos()
	last_flow_rate = 0
	last_power_draw = 0

	if((stat & (NOPOWER|BROKEN)) || !use_power)
		return

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	var/power_draw = -1
	var/pressure_delta = target_pressure - air2.return_pressure()

	if(pressure_delta > 0.01 && air1.temperature > 0)
		//Figure out how much gas to transfer to meet the target pressure.
		var/datum/pipeline/parent2 = PARENT2
		var/transfer_moles = calculate_transfer_moles(air1, air2, pressure_delta, (parent2) ? parent2.air.volume : 0)
		power_draw = pump_gas(src, air1, air2, transfer_moles, power_rating)

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power(power_draw)

		update_parents()

//Radio remote control

/obj/machinery/atmospherics/components/binary/pump/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/binary/pump/proc/broadcast_status()
	if(!radio_connection)
		return FALSE

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "AGP",
		"power" = use_power,
		"target_output" = target_pressure,
		"sigtype" = "status"
	)

	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return TRUE

/obj/machinery/atmospherics/components/binary/pump/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/atmospherics/components/binary/pump/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GasPump", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/pump/tgui_data(mob/user)
	var/list/data = list(
		"on" = use_power,
		"pressure_set" = target_pressure,
		"max_pressure" = max_pressure_setting,
		"last_power_draw" = last_power_draw,
		"max_power_draw" = power_rating,
	)
	return data

/obj/machinery/atmospherics/components/binary/pump/tgui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	if(isnull(user))
		return

	switch(action)
		if("power")
			set_power_use(!use_power)
		if("min")
			target_pressure = 0
		if("max")
			target_pressure = max_pressure_setting
		if("set")
			target_pressure = between(0, params["rate"], max_pressure_setting)

	user.set_machine(src)
	add_fingerprint(user)
	update_icon()

/obj/machinery/atmospherics/components/binary/pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"] != "command"))
		return FALSE

	if(signal.data["power"])
		if(text2num(signal.data["power"]))
			set_power_use(IDLE_POWER_USE)
		else
			set_power_use(NO_POWER_USE)

	if("power_toggle" in signal.data)
		set_power_use(!use_power)

	if(signal.data["set_output_pressure"])
		target_pressure = between(
			0,
			text2num(signal.data["set_output_pressure"]),
			ONE_ATMOSPHERE * 50
		)

	if(signal.data["status"])
		broadcast_status()
		return //do not update_icon

	broadcast_status()
	update_icon()

/obj/machinery/atmospherics/components/binary/pump/can_unwrench(mob/user)
	if(..())
		if(!(stat & NOPOWER) && use_power)
			to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		else
			return TRUE
