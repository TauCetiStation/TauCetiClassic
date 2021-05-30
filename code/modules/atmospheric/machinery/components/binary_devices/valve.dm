/*
	It's like a regular ol' straight pipe, but you can turn it on and off.
*/
/obj/machinery/atmospherics/components/binary/valve
	icon = 'icons/atmos/valve.dmi'
	icon_state = "map_valve0"

	name = "manual valve"
	desc = "A pipe valve."

	can_unwrench = TRUE
	interact_offline = TRUE

	var/open = FALSE

/obj/machinery/atmospherics/components/binary/valve/open
	open = TRUE
	icon_state = "map_valve1"

/obj/machinery/atmospherics/components/binary/valve/update_icon(animation)
	..()
	if(animation)
		flick("valve[src.open][!src.open]",src)
	else
		icon_state = "valve[open]"

/obj/machinery/atmospherics/components/binary/valve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		var/obj/machinery/atmospherics/node1 = NODE1
		var/obj/machinery/atmospherics/node2 = NODE2
		add_underlay(T, node1, get_dir(src, node1), node1 ? node1.icon_connect_type : "")
		add_underlay(T, node2, get_dir(src, node2), node2 ? node2.icon_connect_type : "")

/obj/machinery/atmospherics/components/binary/valve/hide(i)
	update_underlays()

/obj/machinery/atmospherics/components/binary/valve/proc/open(logging = TRUE) // false used by shutoff valve inside proccess_atmos() proc to mitigate log spam.
	if(open)
		return FALSE

	open = TRUE
	update_icon()

	update_parents()
	var/datum/pipeline/parent1 = PARENT1
	parent1.reconcile_air()

	if(logging)
		log_investigate("was opened by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)

	return TRUE

/obj/machinery/atmospherics/components/binary/valve/proc/close(logging = TRUE)
	if(!open)
		return FALSE

	open = FALSE
	update_icon()

	if(logging)
		log_investigate("was closed by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)

	return TRUE

/obj/machinery/atmospherics/components/binary/valve/proc/normalize_dir()
	if(dir == 3)
		set_dir(1)
	else if(dir == 12)
		set_dir(4)

/obj/machinery/atmospherics/components/binary/valve/attack_ai(mob/user)
	if(interact_offline && IsAdminGhost(user) || !interact_offline)
		return ..()

/obj/machinery/atmospherics/components/binary/valve/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	update_icon(1)
	user.SetNextMove(CLICK_CD_RAPID)
	sleep(10)
	if (open)
		close()
	else
		open()

/obj/machinery/atmospherics/components/binary/valve/process_atmos()
	return PROCESS_KILL

/obj/machinery/atmospherics/components/binary/valve/digital		// can be controlled by AI
	name = "digital valve"
	desc = "A digitally controlled valve."
	icon = 'icons/atmos/digital_valve.dmi'
	interact_offline = FALSE

	frequency = 0
	var/id = null

/obj/machinery/atmospherics/components/binary/valve/digital/open
	open = TRUE
	icon_state = "map_valve1"

/obj/machinery/atmospherics/components/binary/valve/digital/update_icon()
	..()
	if(!powered())
		icon_state = "valve[open]nopower"

/obj/machinery/atmospherics/components/binary/valve/digital/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/binary/valve/digital/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/binary/valve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id))
		return FALSE

	switch(signal.data["command"])
		if("valve_open")
			if(!open)
				open()

		if("valve_close")
			if(open)
				close()

		if("valve_toggle")
			if(open)
				close()
			else
				open()

/obj/machinery/atmospherics/components/binary/valve/examine(mob/user)
	. = ..()
	to_chat(user, "It is [open ? "open" : "closed"].")
