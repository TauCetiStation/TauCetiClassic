/obj/machinery/meter
	name = "meter"
	desc = "It measures something."
	icon = 'icons/obj/meter.dmi'
	icon_state = "meterX"
	var/obj/machinery/atmospherics/pipe/target = null
	anchored = 1.0
	power_channel = STATIC_ENVIRON
	frequency = 0
	var/id
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 5

/obj/machinery/meter/atom_init()
	. = ..()
	SSair.atmos_machinery += src
	if (!target)
		src.target = locate(/obj/machinery/atmospherics/pipe) in loc

/obj/machinery/meter/Destroy()
	SSair.atmos_machinery -= src
	src.target = null
	return ..()

/obj/machinery/meter/singularity_pull(S, current_size)
	..()

	if(current_size >= STAGE_FIVE)
		new /obj/item/pipe_meter(loc)
		qdel(src)

/obj/machinery/meter/process_atmos()
	if(!target)
		icon_state = "meterX"
		return 0

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return 0

	//use_power(5)

	var/datum/gas_mixture/environment = target.return_air()
	if(!environment)
		icon_state = "meterX"
		return 0

	var/env_pressure = environment.return_pressure()
	if(env_pressure <= 0.15 * ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8 * ONE_ATMOSPHERE)
		var/val = round(env_pressure / (ONE_ATMOSPHERE * 0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30 * ONE_ATMOSPHERE)
		var/val = round(env_pressure / (ONE_ATMOSPHERE * 5) - 0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59 * ONE_ATMOSPHERE)
		var/val = round(env_pressure / (ONE_ATMOSPHERE * 5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"

	if(frequency)
		var/datum/radio_frequency/radio_connection = radio_controller.return_frequency(frequency)

		if(!radio_connection)
			return

		var/datum/signal/signal = new
		signal.source = src
		signal.transmission_method = 1
		signal.data = list(
			"tag" = id,
			"device" = "AM",
			"pressure" = round(env_pressure),
			"sigtype" = "status"
		)
		radio_connection.post_signal(src, signal)

/obj/machinery/meter/examine(mob/user)
	. = ..()

	if(get_dist(user, src) > 3 && !(isAI(user) || isobserver(user)))
		to_chat(user, "<span class='warning'>You are too far away to read it.</span>")

	else if(stat & (NOPOWER|BROKEN))
		to_chat(user, "<span class='warning'>The display is off.</span>")

	else if(src.target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			to_chat(user, "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)]K ([round(environment.temperature-T0C,0.01)]&deg;C)")
		else
			to_chat(user, "The sensor error light is blinking.")
	else
		to_chat(user, "The connect error light is blinking.")



/obj/machinery/meter/Click()

	if(isAI(usr)) // ghosts can call ..() for examine
		usr.examinate(src)
		return 1

	return ..()

/obj/machinery/meter/attackby(obj/item/weapon/W, mob/user)
	if (!iswrench(W))
		return ..()
	if(user.is_busy(src))
		return
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if (W.use_tool(src, user, 40, volume = 50))
		user.visible_message(
			"<span class='notice'>\The [user] unfastens \the [src].</span>",
			"<span class='notice'>You have unfastened \the [src].</span>",
			"You hear ratchet.")
		new /obj/item/pipe_meter(src.loc)
		qdel(src)

// TURF METER - REPORTS A TILE'S AIR CONTENTS

/obj/machinery/meter/turf/atom_init()
	src.target = loc
	. = ..()
