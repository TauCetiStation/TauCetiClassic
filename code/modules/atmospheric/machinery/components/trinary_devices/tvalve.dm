/obj/machinery/atmospherics/components/trinary/tvalve
	icon = 'icons/atmos/tvalve.dmi'
	icon_state = "map_tvalve0"

	name = "manual switching valve"
	desc = "A pipe valve."

	can_unwrench = TRUE
	ghost_must_be_admin = TRUE

	var/state = 0 // 0 = go straight, 1 = go to side

/obj/machinery/atmospherics/components/trinary/tvalve/bypass
	icon_state = "map_tvalve1"
	state = 1

/obj/machinery/atmospherics/components/trinary/tvalve/update_icon(animation)
	if(animation)
		flick("tvalve[src.state][!src.state]", src)
	else
		icon_state = "tvalve[state]"

/obj/machinery/atmospherics/components/trinary/tvalve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, NODE1, turn(dir, -180))

		if(istype(src, /obj/machinery/atmospherics/components/trinary/tvalve/mirrored))
			add_underlay(T, NODE2, turn(dir, 90))
		else
			add_underlay(T, NODE2, turn(dir, -90))

		add_underlay(T, NODE3, dir)

/obj/machinery/atmospherics/components/trinary/tvalve/hide(i)
	update_underlays()

/obj/machinery/atmospherics/components/trinary/tvalve/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = SOUTH|NORTH|EAST
		if(SOUTH)
			initialize_directions = NORTH|SOUTH|WEST
		if(EAST)
			initialize_directions = WEST|EAST|SOUTH
		if(WEST)
			initialize_directions = EAST|WEST|NORTH

/obj/machinery/atmospherics/components/trinary/tvalve/proc/go_to_side()

	if(state)
		return FALSE

	state = 1
	update_icon()

	update_parents()
	var/datum/pipeline/parent1 = PARENT1
	parent1.reconcile_air()
	investigate_log("was switched to side by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)

	return TRUE

/obj/machinery/atmospherics/components/trinary/tvalve/proc/go_straight()

	if(!state)
		return FALSE

	state = 0
	update_icon()

	update_parents()
	var/datum/pipeline/parent1 = PARENT1
	parent1.reconcile_air()
	investigate_log("was swiched to straight by [usr ? key_name(usr) : "a remote signal"]", INVESTIGATE_ATMOS)

	return TRUE

/obj/machinery/atmospherics/components/trinary/tvalve/attack_ai(mob/user)
	return

/obj/machinery/atmospherics/components/trinary/tvalve/attack_hand(mob/user)
	src.add_fingerprint(usr)
	update_icon(1)
	sleep(10)
	if (src.state)
		src.go_straight()
	else
		src.go_to_side()

/obj/machinery/atmospherics/components/trinary/tvalve/process_atmos()
	return PROCESS_KILL

/obj/machinery/atmospherics/components/trinary/tvalve/digital		// can be controlled by AI
	name = "digital switching valve"
	desc = "A digitally controlled valve."
	icon = 'icons/atmos/digital_tvalve.dmi'

	frequency = 0
	var/id = null

/obj/machinery/atmospherics/components/trinary/tvalve/digital/bypass
	icon_state = "map_tvalve1"
	state = 1

/obj/machinery/atmospherics/components/trinary/tvalve/digital/update_icon()
	..()
	if(!powered())
		icon_state = "tvalvenopower"

/obj/machinery/atmospherics/components/trinary/tvalve/digital/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/atmospherics/components/trinary/tvalve/digital/attack_hand(mob/user as mob)
	if(!powered())
		return
	if(!src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	..()

//Radio remote control

/obj/machinery/atmospherics/components/trinary/tvalve/digital/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/trinary/tvalve/digital/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/trinary/tvalve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id))
		return FALSE

	switch(signal.data["command"])
		if("valve_open")
			if(!state)
				go_to_side()

		if("valve_close")
			if(state)
				go_straight()

		if("valve_toggle")
			if(state)
				go_straight()
			else
				go_to_side()

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored
	icon_state = "map_tvalvem0"

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/bypass
	icon_state = "map_tvalvem1"
	state = 1

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions = SOUTH|NORTH|WEST
		if(SOUTH)
			initialize_directions = NORTH|SOUTH|EAST
		if(EAST)
			initialize_directions = WEST|EAST|NORTH
		if(WEST)
			initialize_directions = EAST|WEST|SOUTH

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/update_icon(animation)
	if(animation)
		flick("tvalvem[src.state][!src.state]",src)
	else
		icon_state = "tvalvem[state]"

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/digital		// can be controlled by AI
	name = "digital switching valve"
	desc = "A digitally controlled valve."
	icon = 'icons/atmos/digital_tvalve.dmi'

	frequency = 0
	var/id = null

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/digital/bypass
	icon_state = "map_tvalvem1"
	state = 1

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/digital/update_icon()
	..()
	if(!powered())
		icon_state = "tvalvemnopower"

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/digital/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/digital/attack_hand(mob/user)
	if(!powered())
		return
	if(!src.allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	..()

//Radio remote control -eh?

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/digital/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = radio_controller.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/digital/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/trinary/tvalve/mirrored/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id))
		return FALSE

	switch(signal.data["command"])
		if("valve_open")
			if(!state)
				go_to_side()

		if("valve_close")
			if(state)
				go_straight()

		if("valve_toggle")
			if(state)
				go_straight()
			else
				go_to_side()
