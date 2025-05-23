/obj/item/radio/integrated
	name = "PDA radio module"
	desc = "An electronic radio system of nanotrasen origin."
	icon = 'icons/obj/module.dmi'
	icon_state = "power_mod"
	item_state_world = "power_mod_w"
	var/obj/item/device/pda/hostpda = null

	var/on = 0 //Are we currently active??
	var/menu_message = ""

/obj/item/radio/integrated/atom_init()
	. = ..()
	if (istype(loc.loc, /obj/item/device/pda))
		hostpda = loc.loc

/obj/item/radio/integrated/proc/post_signal(freq, key, value, key2, value2, key3, value3, s_filter)

	//world << "Post: [freq]: [key]=[value], [key2]=[value2]"
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

	if(!frequency) return

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	signal.data[key] = value
	if(key2)
		signal.data[key2] = value2
	if(key3)
		signal.data[key3] = value3

	frequency.post_signal(src, signal, filter = s_filter)

	return

/obj/item/radio/integrated/proc/generate_menu()

/obj/item/radio/integrated/beepsky
	var/list/botlist = null		// list of bots
	var/obj/machinery/bot/secbot/active 	// the active bot; if null, show bot list
	var/list/botstatus			// the status signal sent by the bot

	var/control_freq = 1447

	// create a new QM cartridge, and register to receive bot control & beacon message
/obj/item/radio/integrated/beepsky/atom_init()
	. = ..()
	radio_controller.add_object(src, control_freq, filter = RADIO_SECBOT)

	// receive radio signals
	// can detect bot status signals
	// create/populate list as they are recvd

/obj/item/radio/integrated/beepsky/receive_signal(datum/signal/signal)
//		var/obj/item/device/pda/P = src.loc

	/*
	to_chat(world, "recvd:[P] : [signal.source]")
	for(var/d in signal.data)
		to_chat(world, "- [d] = [signal.data[d]]")
	*/
	if (signal.data["type"] == "secbot")
		if(!botlist)
			botlist = new()

		if(!(signal.source in botlist))
			botlist += signal.source

		if(active == signal.source)
			var/list/b = signal.data
			botstatus = b.Copy()

//		if (istype(P)) P.updateSelfDialog()

/obj/item/radio/integrated/beepsky/Topic(href, href_list)
	..()
	var/obj/item/device/pda/PDA = src.hostpda

	switch(href_list["op"])

		if("control")
			active = locate(href_list["bot"])
			post_signal(control_freq, "command", "bot_status", "active", active, s_filter = RADIO_SECBOT)

		if("scanbots")		// find all bots
			botlist = null
			post_signal(control_freq, "command", "bot_status", s_filter = RADIO_SECBOT)

		if("botlist")
			active = null

		if("stop", "go")
			post_signal(control_freq, "command", href_list["op"], "active", active, s_filter = RADIO_SECBOT)
			post_signal(control_freq, "command", "bot_status", "active", active, s_filter = RADIO_SECBOT)

		if("summon")
			post_signal(control_freq, "command", "summon", "active", active, "target", get_turf(PDA) , s_filter = RADIO_SECBOT)
			post_signal(control_freq, "command", "bot_status", "active", active, s_filter = RADIO_SECBOT)

/obj/item/radio/integrated/beepsky/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, control_freq)
	active = null
	return ..()

/obj/item/radio/integrated/mule
	var/list/botlist = null		// list of bots
	var/obj/machinery/bot/mulebot/active 	// the active bot; if null, show bot list
	var/list/botstatus			// the status signal sent by the bot
	var/list/beacons

	var/beacon_freq = 1400
	var/control_freq = 1447

	// create a new QM cartridge, and register to receive bot control & beacon message
/obj/item/radio/integrated/mule/atom_init()
	..()
	radio_controller.add_object(src, control_freq, filter = RADIO_MULEBOT)
	radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)
	return INITIALIZE_HINT_LATELOAD

/obj/item/radio/integrated/mule/atom_init_late() // if this even necessary
	post_signal(beacon_freq, "findbeacon", "delivery", s_filter = RADIO_NAVBEACONS)

/obj/item/radio/integrated/mule/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, control_freq)
		radio_controller.remove_object(src, beacon_freq)
	active = null
	return ..()

	// receive radio signals
	// can detect bot status signals
	// and beacon locations
	// create/populate lists as they are recvd

/obj/item/radio/integrated/mule/receive_signal(datum/signal/signal)
//		var/obj/item/device/pda/P = src.loc

	/*
	to_chat(world, "recvd:[P] : [signal.source]")
	for(var/d in signal.data)
		to_chat(world, "- [d] = [signal.data[d]]")
	*/
	if(signal.data["type"] == "mulebot")
		if(!botlist)
			botlist = new()

		if(!(signal.source in botlist))
			botlist += signal.source

		if(active == signal.source)
			var/list/b = signal.data
			botstatus = b.Copy()

	else if(signal.data["beacon"])
		if(!beacons)
			beacons = new()

		beacons[signal.data["beacon"] ] = signal.source


//		if(istype(P)) P.updateSelfDialog()

/obj/item/radio/integrated/mule/Topic(href, href_list)
	..()
	var/cmd = "command"
	if(active) cmd = "command [active.suffix]"

	switch(href_list["op"])

		if("control")
			active = locate(href_list["bot"])
			post_signal(control_freq, cmd, "bot_status", s_filter = RADIO_MULEBOT)

		if("scanbots")		// find all bots
			botlist = null
			post_signal(control_freq, "command", "bot_status", s_filter = RADIO_MULEBOT)

		if("botlist")
			active = null


		if("unload")
			post_signal(control_freq, cmd, "unload", s_filter = RADIO_MULEBOT)
			post_signal(control_freq, cmd, "bot_status", s_filter = RADIO_MULEBOT)
		if("setdest")
			if(beacons)
				var/dest = input("Select Bot Destination", "Mulebot [active.suffix] Interlink", active.destination) as null|anything in beacons
				if(dest)
					post_signal(control_freq, cmd, "target", "destination", dest, s_filter = RADIO_MULEBOT)
					post_signal(control_freq, cmd, "bot_status", s_filter = RADIO_MULEBOT)

		if("retoff")
			post_signal(control_freq, cmd, "autoret", "value", 0, s_filter = RADIO_MULEBOT)
			post_signal(control_freq, cmd, "bot_status", s_filter = RADIO_MULEBOT)
		if("reton")
			post_signal(control_freq, cmd, "autoret", "value", 1, s_filter = RADIO_MULEBOT)
			post_signal(control_freq, cmd, "bot_status", s_filter = RADIO_MULEBOT)

		if("pickoff")
			post_signal(control_freq, cmd, "autopick", "value", 0, s_filter = RADIO_MULEBOT)
			post_signal(control_freq, cmd, "bot_status", s_filter = RADIO_MULEBOT)
		if("pickon")
			post_signal(control_freq, cmd, "autopick", "value", 1, s_filter = RADIO_MULEBOT)
			post_signal(control_freq, cmd, "bot_status", s_filter = RADIO_MULEBOT)

		if("stop", "go", "home")
			post_signal(control_freq, cmd, href_list["op"], s_filter = RADIO_MULEBOT)
			post_signal(control_freq, cmd, "bot_status", s_filter = RADIO_MULEBOT)



/*
 *	Radio Cartridge, essentially a signaler.
 */


/obj/item/radio/integrated/signal
	var/frequency = 1457
	var/code = 30.0
	var/last_transmission
	var/datum/radio_frequency/radio_connection

/obj/item/radio/integrated/signal/atom_init()
	. = ..()
	if (src.frequency < 1441 || src.frequency > 1489)
		src.frequency = sanitize_frequency(src.frequency)

	set_frequency(frequency)

/obj/item/radio/integrated/signal/proc/set_frequency(new_frequency)
	radio_controller.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = radio_controller.add_object(src, frequency)

/obj/item/radio/integrated/signal/proc/send_signal(message="ACTIVATE")

	if(last_transmission && world.time < (last_transmission + 5))
		return
	last_transmission = world.time

	var/time = time2text(world.realtime,"hh:mm:ss")
	var/turf/T = get_turf(src)
	lastsignalers.Add("[time] <B>:</B> [usr.key] used [src] @ location [COORD(T)] <B>:</B> [format_frequency(frequency)]/[code]")
	message_admins("[key_name_admin(usr)] used [src], location [COORD(T)] <B>:</B> [format_frequency(frequency)]/[code] [ADMIN_JMP(usr)]")
	log_game("[key_name(usr)] used [src], location [COORD(T)],frequency: [format_frequency(frequency)], code:[code]")

	var/datum/signal/signal = new
	signal.source = src
	signal.encryption = code
	signal.data["message"] = message

	radio_connection.post_signal(src, signal)

	return

/obj/item/radio/integrated/signal/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, frequency)
	return ..()
