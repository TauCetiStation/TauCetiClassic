/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting flammable items."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter1"
	plane = FLOOR_PLANE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	var/id = null
	var/on = TRUE

/obj/machinery/igniter/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_INTERACT)
	use_power(50)
	on = !on
	icon_state = text("igniter[]", on)

/obj/machinery/igniter/get_current_temperature()
	if(on)
		return 1000
	return ..()

/obj/machinery/igniter/process()	//ugh why is this even in process()?
	if (on && !(stat & NOPOWER))
		var/turf/location = src.loc
		if (isturf(location))
			location.hotspot_expose(1000, 500)
	return 1

/obj/machinery/igniter/atom_init()
	. = ..()
	icon_state = "igniter[on]"

/obj/machinery/igniter/power_change()
	if(!( stat & NOPOWER) )
		icon_state = "igniter[src.on]"
	else
		icon_state = "igniter0"
	update_power_use()

// Wall mounted remote-control igniter.

/obj/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	var/id = null
	var/disable = 0
	var/last_spark = 0
	var/base_state = "migniter"
	anchored = 1

/obj/machinery/sparker/power_change()
	if ( powered() && disable == 0 )
		stat &= ~NOPOWER
		icon_state = "[base_state]"
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]-p"
	update_power_use()

/obj/machinery/sparker/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	if (isscrewdriver(W))
		add_fingerprint(user)
		src.disable = !src.disable
		user.SetNextMove(CLICK_CD_INTERACT)
		if (src.disable)
			user.visible_message("<span class='warning'>[user] has disabled the [src]!</span>", "<span class='warning'>You disable the connection to the [src].</span>")
			icon_state = "[base_state]-d"
		if (!src.disable)
			user.visible_message("<span class='warning'>[user] has reconnected the [src]!</span>", "<span class='warning'>You fix the connection to the [src].</span>")
			if(src.powered())
				icon_state = "[base_state]"
			else
				icon_state = "[base_state]-p"

/obj/machinery/sparker/attack_ai()
	if (anchored)
		return ignite()
	else
		return

/obj/machinery/sparker/proc/ignite()
	if (!powered())
		return

	if (disable || (last_spark && world.time < last_spark + 50))
		return


	flick("[base_state]-spark", src)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(2, 1, src)
	s.start()
	last_spark = world.time
	use_power(1000)
	var/turf/location = loc
	if (isturf(location))
		location.hotspot_expose(1000, 500)
	return 1

/obj/machinery/sparker/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	ignite()
	..(severity)

/obj/machinery/ignition_switch/attackby(obj/item/weapon/W, mob/user)
	return attack_hand(user)

/obj/machinery/ignition_switch/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(active)
		return 1

	use_power(5)
	user.SetNextMove(CLICK_CD_INTERACT)

	active = 1
	icon_state = "launcheract"
	message_admins("Ignition switch was activated at ([x],[y],[z]) [ADMIN_JMP(src)] Last touched by: [key_name(usr)] [ADMIN_JMP(usr)]")
	log_game("Ignition switch was activated at ([x],[y],[z]) Last touched by: [key_name(usr)]")

	for(var/obj/machinery/sparker/M in machines)
		if (M.id == id)
			spawn(0)
				M.ignite()

	for(var/obj/machinery/igniter/M in machines)
		if(M.id == id)
			use_power(50)
			M.on = !M.on
			M.icon_state = text("igniter[]", M.on)

	sleep(50)

	icon_state = "launcherbtt"
	active = 0
