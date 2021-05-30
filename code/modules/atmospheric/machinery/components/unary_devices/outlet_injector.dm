//Basically a one way passive valve. If the pressure inside is greater than the environment then gas will flow passively,
//but it does not permit gas to flow back from the environment into the injector. Can be turned off to prevent any gas flow.
//When it receives the "inject" signal, it will try to pump it's entire contents into the environment regardless of pressure, using power.

/obj/machinery/atmospherics/components/unary/outlet_injector
	icon = 'icons/atmos/injector.dmi'
	icon_state = "map_injector"

	name = "air injector"
	desc = "Passively injects air into its surroundings. Has a valve attached to it that can control flow rate."

	can_unwrench = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 150 // internal circuitry, friction losses and stuff
	power_rating = 15000   // 15000 W ~ 20 HP

	var/injecting = FALSE

	var/volume_rate = 50 // flow rate limit

	frequency = 0
	var/id = null

	level = PIPE_HIDDEN_LEVEL
	layer = GAS_SCRUBBER_LAYER

/obj/machinery/atmospherics/components/unary/outlet_injector/on
	use_power = IDLE_POWER_USE
	icon_state = "map_injector_on"

/obj/machinery/atmospherics/components/unary/outlet_injector/atom_init()
	. = ..()
	var/datum/gas_mixture/air1 = AIR1
	air1.volume = ATMOS_DEFAULT_VOLUME_PUMP + 500	//Give it a small reservoir for injecting. Also allows it to have a higher flow rate limit than vent pumps, to differentiate injectors a bit more.

/obj/machinery/atmospherics/components/unary/outlet_injector/atmos_init()
	set_frequency(frequency)
	broadcast_status()
	..()

/obj/machinery/atmospherics/components/unary/outlet_injector/update_icon()
	..()
	if(!powered())
		icon_state = "off"
	else
		icon_state = "[use_power ? "on" : "off"]"

/obj/machinery/atmospherics/components/unary/outlet_injector/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, NODE1, dir)

/obj/machinery/atmospherics/components/unary/outlet_injector/process_atmos()
	last_power_draw = 0
	last_flow_rate = 0

	if((stat & (NOPOWER|BROKEN)) || !use_power)
		return

	var/datum/gas_mixture/air_contents = AIR1

	var/power_draw = -1
	var/datum/gas_mixture/environment = loc.return_air()

	if(environment && air_contents.temperature > 0)
		var/transfer_moles = (volume_rate / air_contents.volume) * air_contents.total_moles // apply flow rate limit
		power_draw = pump_gas(src, air_contents, environment, transfer_moles, power_rating)

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power(power_draw)

		update_parents()

/obj/machinery/atmospherics/components/unary/outlet_injector/proc/inject()
	if(injecting || (stat & NOPOWER))
		return FALSE

	var/datum/gas_mixture/environment = loc.return_air()
	if (!environment)
		return FALSE

	var/datum/gas_mixture/air_contents = AIR1

	injecting = TRUE

	if(air_contents.temperature > 0)
		var/power_used = pump_gas(src, air_contents, environment, air_contents.total_moles, power_rating)
		use_power(power_used)

		update_parents()

	flick("inject", src)

/obj/machinery/atmospherics/components/unary/outlet_injector/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency)

/obj/machinery/atmospherics/components/unary/outlet_injector/proc/broadcast_status()
	if(!radio_connection)
		return FALSE

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id,
		"device" = "AO",
		"power" = use_power,
		"volume_rate" = volume_rate,
		"sigtype" = "status"
	 )

	radio_connection.post_signal(src, signal)

	return TRUE

/obj/machinery/atmospherics/components/unary/outlet_injector/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return FALSE

	if(signal.data["power"])
		set_power_use(text2num(signal.data["power"]))

	if(signal.data["power_toggle"])
		set_power_use(!use_power)

	if(signal.data["inject"])
		inject()
		return

	if(signal.data["set_volume_rate"])
		var/number = text2num(signal.data["set_volume_rate"])
		var/datum/gas_mixture/air_contents = AIR1
		volume_rate = between(0, number, air_contents.volume)

	if(signal.data["status"])
		broadcast_status()
		return //do not update_icon

	broadcast_status()
	update_icon()

/obj/machinery/atmospherics/components/unary/outlet_injector/hide(i)
	update_underlays()

/obj/machinery/atmospherics/components/unary/outlet_injector/can_unwrench(mob/user)
	if(..())
		if (!(stat & NOPOWER|BROKEN) && use_power)
			to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		else
			return TRUE
