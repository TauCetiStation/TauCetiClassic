#define AIRLOCK_CONTROL_RANGE 5

#define LEFT  1
#define RIGHT 2

// This code allows for airlocks to be controlled externally by setting an id_tag and comm frequency (disables ID access)
/obj/machinery/door/airlock
	var/id_tag
	var/suppres_next_status_send = FALSE
	var/obj/machinery/embedded_controller/radio/controller

/obj/machinery/door/airlock/receive_signal(datum/signal/signal)
	if(!signal || signal.encryption) return

	if(src != signal.data["signal_target"] || !signal.data["command"]) return

	switch(signal.data["command"])
		if("open")
			suppres_next_status_send = TRUE
			open()

		if("close")
			suppres_next_status_send = TRUE
			close()

		if("unlock")
			unbolt()

		if("lock")
			bolt()

		if("secure_open")

			unbolt()

			sleep(2)
			suppres_next_status_send = TRUE
			open()

			bolt()

		if("secure_close")
			unbolt()

			sleep(2)
			suppres_next_status_send = TRUE
			close()

			bolt()

	send_status()

/obj/machinery/door/airlock/proc/send_status_if_allowed()
	if(suppres_next_status_send)
		suppres_next_status_send = FALSE
	else
		send_status()

/obj/machinery/door/airlock/proc/send_status()
	if(radio_connection)
		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["signal_source"] = src
		signal.data["timestamp"] = world.time

		signal.data["door_status"] = density?("closed"):("open")
		signal.data["lock_status"] = locked?("locked"):("unlocked")

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

/obj/machinery/door/airlock/Bumped(atom/AM)
	if(ishuman(AM) && prob(40) && src.density)
		var/mob/living/carbon/human/H = AM
		if(H.getBrainLoss() >= 60)
			playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				visible_message("\red [H] headbutts the airlock.")
				var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
				H.Stun(8)
				H.Weaken(5)
				BP.take_damage(10, 0)
			else
				visible_message("\red [H] headbutts the airlock. Good thing they're wearing a helmet.")
				H.Stun(8)
				H.Weaken(5)
			return
	..(AM)
	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(density && radio_connection && mecha.occupant && (src.allowed(mecha.occupant) || src.check_access_list(mecha.operation_req_access)))
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["signal_source"] = src
			signal.data["timestamp"] = world.time

			signal.data["door_status"] = density?("closed"):("open")
			signal.data["lock_status"] = locked?("locked"):("unlocked")

			signal.data["bumped_with_access"] = 1

			radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)
	return

/obj/machinery/door/airlock/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	if(new_frequency)
		frequency = new_frequency
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)


/obj/machinery/door/airlock/atom_init()
	. = ..()
	if(frequency)
		set_frequency(frequency)

	update_icon()


/obj/machinery/door/airlock/atom_init()
	. = ..()

	if(radio_controller)
		set_frequency(frequency)

/obj/machinery/door/airlock/Destroy()
	if(controller)
		controller.disconnect_door(src)
		controller = null

	if(frequency && radio_controller)
		radio_controller.remove_object(src,frequency)
	return ..()

/obj/machinery/airlock_sensor
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_off"
	name = "airlock sensor"
	layer = 3.3

	anchored = TRUE
	interact_offline = TRUE // this is very strange that power_channel is defined, use_power = 1 (parent), when this element has no unpowered features and sprites.

	var/id_tag
	var/master_tag
	var/obj/machinery/embedded_controller/radio/controller
	frequency = 1379
	var/const/connection_range = 5

	var/alert = 0
	var/previousPressure

/obj/machinery/airlock_sensor/atom_init(mapload, dir)
	. = ..()
	if(!mapload)
		src.dir = dir
		pixel_x = (dir & 3) ? 0 : (dir == 4 ? -25 : 25)
		pixel_y = (dir & 3) ? (dir == 1 ? -25 : 25) : 0
		update_icon()
	set_frequency(frequency)

/obj/machinery/airlock_sensor/update_icon()
	if(controller && !(controller.stat & NOPOWER))
		if(alert)
			icon_state = "airlock_sensor_alert"
		else
			icon_state = "airlock_sensor_standby"
	else
		icon_state = "airlock_sensor_off"

/obj/machinery/airlock_sensor/process()
	if(controller && !(controller.stat & NOPOWER) && controller.has_all_connections)
		var/datum/gas_mixture/air_sample = return_air()
		var/pressure = round(air_sample.return_pressure(),0.1)

		if(abs(pressure - previousPressure) > 0.001 || previousPressure == null)
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["signal_source"] = src
			signal.data["timestamp"] = world.time
			signal.data["pressure"] = num2text(pressure)

			radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

			previousPressure = pressure

		alert = ((pressure < ONE_ATMOSPHERE*0.8) || (controller.program.state == STATE_EXTERMINATING))
	else
		alert = FALSE
	update_icon()

/obj/machinery/airlock_sensor/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		if(!controller)
			to_chat(user, "<span class='notice'>You detach the airlock sensor</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			var/obj/item/airlock_sensor_assembly/assembly = new
			assembly.loc = user.loc
			qdel(src)
		else
			to_chat(user, "<span class='warning'>Disconnect from the controller first!</span>")
			return
	else if(istype(W, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter the new name for the [src].", name, name), MAX_LNAME_LEN)
		if(!in_range(src, user))
			return
		name = t
	else if(ismultitool(W))
		var/obj/item/device/multitool/M = W
		if(controller)
			to_chat(usr, "<span class='warning'>This sensor already has a connection!</span>")
		else if(src in M.sensors_buffer)
			to_chat(usr, "<span class='warning'>This sensor is already in the buffer!</span>")
		else if(M.sensors_buffer.len >= M.buffer_limit)
			to_chat(usr, "<span class='warning'>The sensors buffer of multitool is full!</span>")
		else
			M.sensors_buffer += src
			to_chat(usr, "<span class='notice'>You save this sensor to the buffer of your multitool.</span>")

/obj/machinery/airlock_sensor/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)

/obj/item/airlock_sensor_assembly
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "airlock_sensor_assembly"
	name = "airlock sensor"

/obj/item/airlock_sensor_assembly/attackby(obj/item/weapon/W, mob/user)
	..()
	if(iswrench(W))
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal(get_turf(src.loc), 1)
		qdel(src)

/obj/item/airlock_sensor_assembly/afterattack(atom/target, mob/user, inrange, params)
	if(!inrange)
		return

	var/T = target
	if(!istype(T, /turf/simulated/wall) && !istype(T, /obj/structure/window))
		return

	var/ndir = get_dir(T, usr)
	if(!(ndir in cardinal))
		return

	var/turf/loc = get_turf_loc(usr)

	if(gotwallitem(loc, ndir) && !gotwallitem_exact(loc, ndir, /obj/machinery/access_button))
		to_chat(usr, "<span class='warning'>There's already an item on this wall!</span>")
		return

	new /obj/machinery/airlock_sensor(loc, ndir)

	qdel(src)



/obj/machinery/access_button
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_standby"
	name = "access button"

	layer = 3.3	//Above windows
	anchored = TRUE
	interact_offline = TRUE

	var/master_tag
	var/obj/machinery/embedded_controller/radio/controller
	frequency = 1379
	var/command = "cycle"
	var/const/connection_range = 5
	var/side

/obj/machinery/access_button/update_icon()
	if(controller && !(controller.stat & NOPOWER))
		icon_state = "access_button_standby"
	else
		icon_state = "access_button_off"

/obj/machinery/access_button/allowed_fail()
	flick("access_button_cycle", src)

/obj/machinery/access_button/attack_hand(mob/user)
	if(controller.program.state == STATE_EXTERMINATING)
		to_chat(user, "<span class='warning'>ERROR</span>")
		flick("access_button_cycle", src)
		return

	. = ..()
	if(.)
		return

	if(radio_connection && controller && !(controller.stat & NOPOWER) && controller.has_all_connections)
		flick("access_button_cycle", src)

		var/datum/signal/signal = new
		signal.transmission_method = 1 //radio signal
		signal.data["signal_source"] = controller
		signal.data["command"] = command

		radio_connection.post_signal(src, signal, range = AIRLOCK_CONTROL_RANGE, filter = RADIO_AIRLOCK)

/obj/machinery/access_button/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		if(!controller)
			to_chat(user, "<span class='notice'>You detach the access button</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			var/obj/item/access_button_assembly/assembly = new
			assembly.loc = user.loc
			qdel(src)
		else
			to_chat(user, "<span class='warning'>Disconnect from the controller first!</span>")
	else if(istype(W, /obj/item/weapon/pen))
		var/t = sanitize_safe(input(user, "Enter the new name for the access button.", name, name), MAX_LNAME_LEN)
		if(!in_range(src, user))
			return
		name = t
	else if(ismultitool(W))
		var/obj/item/device/multitool/M = W
		if(controller)
			to_chat(usr, "<span class='warning'>This button already has a connection!</span>")
		else if(src in M.buttons_buffer)
			to_chat(usr, "<span class='warning'>This button is already in the buffer!</span>")
		else if(M.buttons_buffer.len >= M.buffer_limit)
			to_chat(usr, "<span class='warning'>The buttons buffer of multitool is full!</span>")
		else
			M.buttons_buffer += src
			to_chat(usr, "<span class='notice'>You save this button to the buffer of your multitool.</span>")
	else if(istype(W, /obj/item/weapon/card/id))
		to_chat(usr, "<span class='warning'>Access checks disabled!</span>")
		playsound(src, "sparks", 100, 1)
		emagged = TRUE

/obj/machinery/access_button/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_AIRLOCK)

/obj/machinery/access_button/atom_init(mapload, dir, side)
	. = ..()
	if(!mapload)
		src.dir = dir
		src.side = side
		if(side == LEFT)
			pixel_x = (dir & 3) ? (dir == 1 ? 12 : -12) : (dir == 4 ? -20 : 20)
			pixel_y = (dir & 3) ? (dir == 1 ? -20 : 20) : (dir == 4 ? -12 : 12)
		else if(side == RIGHT)
			pixel_x = (dir & 3) ? (dir == 1 ? -10 : 10) : (dir == 4 ? -20 : 20)
			pixel_y = (dir & 3) ? (dir == 1 ? -20 : 20) : (dir == 4 ? 10 : -10)
		update_icon()
	set_frequency(frequency)

/obj/machinery/access_button/airlock_interior
	frequency = 1379
	command = "cycle_interior"

/obj/machinery/access_button/airlock_exterior
	frequency = 1379
	command = "cycle_exterior"

/obj/item/access_button_assembly
	icon = 'icons/obj/airlock_machines.dmi'
	icon_state = "access_button_assembly"
	name = "access button - left"
	var/side = LEFT

/obj/item/access_button_assembly/attack_self(mob/user)
	side = (side == LEFT ? RIGHT : LEFT)
	name = "access button - [side == LEFT ? "left" : "right"]"
	to_chat(user, "<span class='notice'>You will place the button on the [side == LEFT ? "left" : "right"] now</span>")

/obj/item/access_button_assembly/attackby(obj/item/weapon/W, mob/user)
	..()
	if(iswrench(W))
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		new /obj/item/stack/sheet/metal(get_turf(src.loc), 1)
		qdel(src)

/obj/item/access_button_assembly/afterattack(atom/target, mob/user, inrange, params)
	if(!inrange)
		return

	var/T = target
	if(!istype(T, /turf/simulated/wall) && !istype(T, /obj/structure/window))
		return

	var/ndir = get_dir(T, usr)
	if(!(ndir in cardinal))
		return

	var/turf/loc = get_turf_loc(usr)
	var/obj/machinery/access_button/another_button = gotwallitem_exact(loc, ndir, /obj/machinery/access_button)

	if(!another_button && gotwallitem(loc, ndir) && !gotwallitem_exact(loc, ndir, /obj/machinery/airlock_sensor))
		to_chat(usr, "<span class='warning'>There's already an item on this wall!</span>")
		return
	else if(another_button)
		if(!another_button.side)
			to_chat(usr, "<span class='warning'>There's already an item on this wall!</span>")
			return
		else if(another_button.side == side)
			to_chat(usr, "<span class='warning'>There's already a button on this side of wall!</span>")
			return

	new /obj/machinery/access_button(loc, ndir, side)

	qdel(src)

#undef LEFT
#undef RIGHT