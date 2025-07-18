/*
	The broadcaster sends processed messages to all radio devices in the game. They
	do not have to be headsets; intercoms and station-bounced radios suffice.

	They receive their message from a server after the message has been logged.
*/

var/global/list/recentmessages = list() // global list of recent messages broadcasted : used to circumvent massive radio spam
var/global/message_delay = 0 // To make sure restarting the recentmessages list is kept in sync

/obj/machinery/telecomms/broadcaster
	name = "Subspace Broadcaster"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcaster"
	desc = "A dish-shaped machine used to broadcast processed subspace signals."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 25
	machinetype = 5
	heatgen = 0
	delay = 7

/obj/machinery/telecomms/broadcaster/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/telecomms/broadcaster(null)
	component_parts += new /obj/item/weapon/stock_parts/subspace/filter(null)
	component_parts += new /obj/item/weapon/stock_parts/subspace/crystal(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/high(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/high(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)

/obj/machinery/telecomms/broadcaster/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	// Don't broadcast rejected signals
	if(signal.data["reject"])
		return

	if(signal.data["message"])

		// Prevents massive radio spam
		signal.data["done"] = 1 // mark the signal as being broadcasted
		// Search for the original signal and mark it as done as well
		var/datum/signal/original = signal.data["original"]
		if(original)
			original.data["done"] = 1
			original.data["compression"] = signal.data["compression"]
			original.data["level"] = signal.data["level"]

		var/signal_message = "[signal.frequency]:[signal.data["message"]]:[signal.data["realname"]]"
		if(signal_message in recentmessages)
			return
		recentmessages.Add(signal_message)

		if(signal.data["slow"] > 0)
			sleep(signal.data["slow"]) // simulate the network lag if necessary

		signal.data["level"] |= listening_level

	   /** #### - Normal Broadcast - #### **/

		if(signal.data["type"] == 0)

			/* ###### Broadcast a message using signal.data ###### */
			Broadcast_Message(signal.data["connection"], signal.data["mob"],
							  signal.data["vmask"], signal.data["vmessage"],
							  signal.data["radio"], signal.data["message"],
							  signal.data["name"], signal.data["job"],
							  signal.data["realname"], signal.data["vname"],,
							  signal.data["compression"], signal.data["level"], signal.frequency,
							  signal.data["verb"], signal.data["language"]	)


	   /** #### - Simple Broadcast - #### **/

		if(signal.data["type"] == 1)

			/* ###### Broadcast a message using signal.data ###### */
			Broadcast_SimpleMessage(signal.data["name"], signal.frequency,
								  signal.data["message"],null, null,
								  signal.data["compression"], listening_level)


	   /** #### - Artificial Broadcast - #### **/
	   			// (Imitates a mob)

		if(signal.data["type"] == 2)

			/* ###### Broadcast a message using signal.data ###### */
				// Parameter "data" as 4: AI can't track this person/mob

			Broadcast_Message(signal.data["connection"], signal.data["mob"],
							  signal.data["vmask"], signal.data["vmessage"],
							  signal.data["radio"], signal.data["message"],
							  signal.data["name"], signal.data["job"],
							  signal.data["realname"], signal.data["vname"], 4, signal.data["compression"], signal.data["level"], signal.frequency,
							  signal.data["verb"], signal.data["language"])

		if(!message_delay)
			message_delay = 1
			spawn(10)
				message_delay = 0
				recentmessages = list()

		/* --- Do a snazzy animation! --- */
		flick("broadcaster_send", src)

/obj/machinery/telecomms/broadcaster/Destroy()
	// In case message_delay is left on 1, otherwise it won't reset the list and people can't say the same thing twice anymore.
	if(message_delay)
		message_delay = 0
	return ..()


/*
	Basically just an empty shell for receiving and broadcasting radio messages. Not
	very flexible, but it gets the job done.
*/

/obj/machinery/telecomms/allinone
	name = "Telecommunications Mainframe"
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "comm_server"
	desc = "A compact machine used for portable subspace telecommuniations processing."
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	machinetype = 6
	heatgen = 0
	var/intercept = FALSE // if TRUE, broadcasts all messages to syndicate channel

/obj/machinery/telecomms/allinone/receive_signal(datum/signal/signal)

	if(!on) // has to be on to receive messages
		return

	if(is_freq_listening(signal)) // detect subspace signals

		signal.data["done"] = 1 // mark the signal as being broadcasted
		signal.data["compression"] = 0

		// Search for the original signal and mark it as done as well
		var/datum/signal/original = signal.data["original"]
		if(original)
			original.data["done"] = 1

		if(signal.data["slow"] > 0)
			sleep(signal.data["slow"]) // simulate the network lag if necessary

		/* ###### Broadcast a message using signal.data ###### */

		var/datum/radio_frequency/connection = signal.data["connection"]

		if(connection.frequency == SYND_FREQ || connection.frequency == HEIST_FREQ) // if syndicate broadcast, just
			Broadcast_Message(signal.data["connection"], signal.data["mob"],
							  signal.data["vmask"], signal.data["vmessage"],
							  signal.data["radio"], signal.data["message"],
							  signal.data["name"], signal.data["job"],
							  signal.data["realname"], signal.data["vname"],, signal.data["compression"], list(0), connection.frequency,
							  signal.data["verb"], signal.data["language"])
		else
			if(intercept)
				Broadcast_Message(signal.data["connection"], signal.data["mob"],
							  signal.data["vmask"], signal.data["vmessage"],
							  signal.data["radio"], signal.data["message"],
							  signal.data["name"], signal.data["job"],
							  signal.data["realname"], signal.data["vname"], 3, signal.data["compression"], list(0), connection.frequency,
							  signal.data["verb"], signal.data["language"])



/**

	Here is the big, bad function that broadcasts a message given the appropriate
	parameters.

	@param connection:
		The datum generated in radio.dm, stored in signal.data["connection"].

	@param M:
		Reference to the mob/speaker, stored in signal.data["mob"]

	@param vmask:
		Boolean value if the mob is "hiding" its identity via voice mask, stored in
		signal.data["vmask"]

	@param vmessage:
		If specified, will display this as the message; such as "chimpering"
		for monkies if the mob is not understood. Stored in signal.data["vmessage"].

	@param radio:
		Reference to the radio broadcasting the message, stored in signal.data["radio"]

	@param message:
		The actual string message to display to mobs who understood mob M. Stored in
		signal.data["message"]

	@param name:
		The name to display when a mob receives the message. signal.data["name"]

	@param job:
		The name job to display for the AI when it receives the message. signal.data["job"]

	@param realname:
		The "real" name associated with the mob. signal.data["realname"]

	@param vname:
		If specified, will use this name when mob M is not understood. signal.data["vname"]

	@param data:
		If specified:
				BROADCAST_MODE_INTERCOMS -- Will only broadcast to intercoms
				BROADCAST_MODE_INTERCOMS_AND_RADIOS -- Will only broadcast to intercoms and station-bounced radios
				BROADCAST_MODE_SYNDICATE -- Broadcast to syndicate frequency
				BROADCAST_MODE_NO_TRACK_AI -- AI can't track down this person. Useful for imitation broadcasts where you can't find the actual mob

	@param compression:
		If 0, the signal is audible
		If nonzero, the signal may be partially inaudible or just complete gibberish.

	@param level:
		The list of Z levels that the sending radio is broadcasting to. Having 0 in the list broadcasts on all levels

	@param freq
		The frequency of the signal

**/

/proc/Broadcast_Message(datum/radio_frequency/connection, mob/M,
						vmask, vmessage, obj/item/device/radio/radio,
						message, name, job, realname, vname,
						data, compression, list/level, freq, verbage = "says", datum/language/speaking = null)


  /* ###### Prepare the radio connection ###### */

	var/display_freq = freq

	var/list/obj/item/device/radio/radios = list()

	// --- Broadcast only to intercom devices ---

	if(data == BROADCAST_MODE_INTERCOMS)

		for (var/obj/item/device/radio/intercom/R in connection.devices["[RADIO_CHAT]"])
			if(R.receive_range(display_freq, level) > -1)
				radios += R

	// --- Broadcast only to intercoms and station-bounced radios ---

	else if(data == BROADCAST_MODE_INTERCOMS_AND_RADIOS)

		for (var/obj/item/device/radio/R in connection.devices["[RADIO_CHAT]"])

			if(R.subspace_transmission)
				continue

			if(R.receive_range(display_freq, level) > -1)
				radios += R

	// --- Broadcast to syndicate radio! ---

	else if(data == BROADCAST_MODE_SYNDICATE)

		var/datum/radio_frequency/syndicateconnection = radio_controller.return_frequency(SYND_FREQ)

		for (var/obj/item/device/radio/R in syndicateconnection.devices["[RADIO_CHAT]"])

			if(R.receive_range(SYND_FREQ, level) > -1)
				radios += R

		var/datum/radio_frequency/heistconnection = radio_controller.return_frequency(HEIST_FREQ)

		for (var/obj/item/device/radio/R in heistconnection.devices["[RADIO_CHAT]"])

			if(R.receive_range(HEIST_FREQ, level) > -1)
				radios += R


	// --- Broadcast to ALL radio devices ---

	else

		for (var/obj/item/device/radio/R in connection.devices["[RADIO_CHAT]"])
			if(R.receive_range(display_freq, level) > -1)
				radios += R

	// Get a list of mobs who can hear from the radios we collected.
	var/list/receive = get_mobs_in_radio_ranges(radios)

  /* ###### Organize the receivers into categories for displaying the message ###### */

  	// Understood the message:
	var/list/heard_masked 	= list() // masked name or no real name
	var/list/heard_normal 	= list() // normal message

	// Did not understand the message:
	var/list/heard_voice 	= list() // voice message	(ie "chimpers")
	var/list/heard_garbled	= list() // garbled message (ie "f*c* **u, **i*er!")
	var/list/heard_gibberish= list() // completely screwed over message (ie "F%! (O*# *#!<>&**%!")

	for (var/mob/R in receive)

	  /* --- Loop through the receivers and categorize them --- */

		if (R.client && !(R.client.prefs.chat_toggles & CHAT_RADIO)) //Adminning with 80 people on can be fun when you're trying to talk and all you can hear is radios.
			continue

		if(isnewplayer(R)) // we don't want new players to hear messages. rare but generates runtimes.
			continue

		// Ghosts hearing all radio chat don't want to hear syndicate intercepts, they're duplicates
		if(data == BROADCAST_MODE_SYNDICATE && isobserver(R) && R.client && (R.client.prefs.chat_toggles & CHAT_GHOSTRADIO))
			continue

		// --- Check for compression ---
		if(compression > 0)
			heard_gibberish += R
			continue

		// --- Can understand the speech ---

		if (!M || R.say_understands(M))

			// - Not human or wearing a voice mask -
			if (!M || !ishuman(M) || vmask)
				heard_masked += R

			// - Human and not wearing voice mask -
			else
				heard_normal += R

		// --- Can't understand the speech ---

		else
			// - The speaker has a prespecified "voice message" to display if not understood -
			if (vmessage)
				heard_voice += R

			// - Just display a garbled message -
			else
				heard_garbled += R


  /* ###### Begin formatting and sending the message ###### */
	if (length(heard_masked) || length(heard_normal) || length(heard_voice) || length(heard_garbled) || length(heard_gibberish))

	  /* --- Some miscellaneous variables to format the string output --- */
		var/freq_text // the name of the channel

		// --- Set the name of the channel ---
		switch(display_freq)

			if(SYND_FREQ)
				freq_text = "#unkn"
			if(HEIST_FREQ)
				freq_text = "Shoal"
			if(COMM_FREQ)
				freq_text = "Command"
			if(SCI_FREQ)
				freq_text = "Science"
			if(MED_FREQ)
				freq_text = "Medical"
			if(ENG_FREQ)
				freq_text = "Engineering"
			if(SEC_FREQ)
				freq_text = "Security"
			if(SUP_FREQ)
				freq_text = "Supply"
			if(1341)
				freq_text = "Special Ops"
			if(1245)
				freq_text = "Velocity"
			if(1345)
				freq_text = "Response Team"
			if(1447)
				freq_text = "AI Private"
		//There's probably a way to use the list var of channels in code\game\communications.dm to make the dept channels non-hardcoded, but I wasn't in an experimentive mood. --NEO


		// --- If the frequency has not been assigned a name, just use the frequency as the name ---

		if(!freq_text)
			freq_text = format_frequency(display_freq)

		// --- Some more pre-message formatting ---

		var/part_a_span = "radio"
		// syndies!
		if (display_freq == SYND_FREQ)
			part_a_span = "syndradio"
		// heist
		else if(display_freq == HEIST_FREQ)
			part_a_span = "voxradio"
		// centcomm channels (deathsquid and ert)
		else if (display_freq in CENT_FREQS)
			part_a_span = "centradio"

		// command channel
		else if (display_freq == COMM_FREQ)
			part_a_span = "comradio"

		// AI private channel
		else if (display_freq == 1447)
			part_a_span = "airadio"

		// department radio formatting (poorly optimized, ugh)
		else if (display_freq == SEC_FREQ)
			part_a_span = "secradio"

		else if (display_freq == ENG_FREQ)
			part_a_span = "engradio"

		else if (display_freq == SCI_FREQ)
			part_a_span = "sciradio"

		else if (display_freq == MED_FREQ)
			part_a_span = "medradio"

		else if (display_freq == SUP_FREQ) // cargo
			part_a_span = "supradio"

		// If all else fails and it's a dept_freq, color me purple!
		else if (display_freq in DEPT_FREQS)
			part_a_span = "deptradio"

		var/part_a = "<span class='[part_a_span]'><span class='name'>" // goes in the actual output
		var/part_b_extra = ""
		if(data == BROADCAST_MODE_SYNDICATE) // intercepted radio message
			part_b_extra = " <i>(Intercepted)</i>"
		var/part_b = "</span><b> \[[freq_text]\][part_b_extra]</b> <span class='message'>" // Tweaked for security headsets -- TLE
		var/part_c = "</span></span>"

		// --- Filter the message; place it in quotes apply a verb ---

		var/quotedmsg = null
		if(M)
			quotedmsg = M.say_quote(message)
		else
			quotedmsg = "says, \"[message]\""

		// --- This following recording is intended for research and feedback in the use of department radio channels ---

		var/part_blackbox_b = "</span><b> \[[freq_text]\]</b> <span class='message'>" // Tweaked for security headsets -- TLE
		var/blackbox_msg = "[part_a][name][part_blackbox_b][quotedmsg][part_c]"
		//var/blackbox_admin_msg = "[part_a][M.name] (Real name: [M.real_name])[part_blackbox_b][quotedmsg][part_c]"

		//BR.messages_admin += blackbox_admin_msg
		if(istype(blackbox))
			switch(display_freq)
				if(1459)
					blackbox.msg_common += blackbox_msg
				if(1351)
					blackbox.msg_science += blackbox_msg
				if(1353)
					blackbox.msg_command += blackbox_msg
				if(1355)
					blackbox.msg_medical += blackbox_msg
				if(1357)
					blackbox.msg_engineering += blackbox_msg
				if(1359)
					blackbox.msg_security += blackbox_msg
				if(1441)
					blackbox.msg_deathsquad += blackbox_msg
				if(1213)
					blackbox.msg_syndicate += blackbox_msg
				if(1206)
					blackbox.msg_heist += blackbox_msg
				if(1347)
					blackbox.msg_cargo += blackbox_msg
				else
					blackbox.messages += blackbox_msg

		//End of research and feedback code.

	 /* ###### Send the message ###### */


	  	/* --- Process all the mobs that heard a masked voice (understood) --- */

		if (length(heard_masked))
			for (var/mob/R in heard_masked)
				R.hear_radio(message,verbage, speaking, part_a, part_b, part_c, M, 0, name)

		/* --- Process all the mobs that heard the voice normally (understood) --- */

		if (length(heard_normal))
			for (var/mob/R in heard_normal)
				R.hear_radio(message, verbage, speaking, part_a, part_b, part_c, M, 0, realname)

		/* --- Process all the mobs that heard the voice normally (did not understand) --- */

		if (length(heard_voice))
			for (var/mob/R in heard_voice)
				R.hear_radio(message,verbage, speaking, part_a, part_b, part_c, M,0, vname)

		/* --- Process all the mobs that heard a garbled voice (did not understand) --- */
			// Displays garbled message (ie "f*c* **u, **i*er!")

		if (length(heard_garbled))
			for (var/mob/R in heard_garbled)
				R.hear_radio(message, verbage, speaking, part_a, part_b, part_c, M, 1, vname)


		/* --- Complete gibberish. Usually happens when there's a compressed message --- */

		if (length(heard_gibberish))
			for (var/mob/R in heard_gibberish)
				R.hear_radio(message, verbage, speaking, part_a, part_b, part_c, M, 1)


/proc/Broadcast_SimpleMessage(source, frequency, text, data, mob/M, compression, level)

  /* ###### Prepare the radio connection ###### */

	if(!M)
		var/mob/living/carbon/human/H = new
		M = H

	var/datum/radio_frequency/connection = radio_controller.return_frequency(frequency)

	var/display_freq = connection.frequency

	var/list/receive = list()


	// --- Broadcast only to intercom devices ---

	if(data == BROADCAST_MODE_INTERCOMS)
		for (var/obj/item/device/radio/intercom/R in connection.devices["[RADIO_CHAT]"])
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(display_freq, level)


	// --- Broadcast only to intercoms and station-bounced radios ---

	else if(data == BROADCAST_MODE_INTERCOMS_AND_RADIOS)
		for (var/obj/item/device/radio/R in connection.devices["[RADIO_CHAT]"])

			if(istype(R, /obj/item/device/radio/headset))
				continue
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(display_freq)


	// --- Broadcast to syndicate radio! ---

	else if(data == BROADCAST_MODE_SYNDICATE)
		var/datum/radio_frequency/syndicateconnection = radio_controller.return_frequency(SYND_FREQ)

		for (var/obj/item/device/radio/R in syndicateconnection.devices["[RADIO_CHAT]"])
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(SYND_FREQ)

		var/datum/radio_frequency/heistconnection = radio_controller.return_frequency(HEIST_FREQ)
		for (var/obj/item/device/radio/R in heistconnection.devices["[RADIO_CHAT]"])
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(HEIST_FREQ)

	// --- Broadcast to ALL radio devices ---

	else
		for (var/obj/item/device/radio/R in connection.devices["[RADIO_CHAT]"])
			var/turf/position = get_turf(R)
			if(position && position.z == level)
				receive |= R.send_hear(display_freq)


  /* ###### Organize the receivers into categories for displaying the message ###### */

	// Understood the message:
	var/list/heard_normal 	= list() // normal message

	// Did not understand the message:
	var/list/heard_garbled	= list() // garbled message (ie "f*c* **u, **i*er!")
	var/list/heard_gibberish= list() // completely screwed over message (ie "F%! (O*# *#!<>&**%!")

	for (var/mob/R in receive)

	  /* --- Loop through the receivers and categorize them --- */

		if (R.client && !(R.client.prefs.chat_toggles & CHAT_RADIO)) //Adminning with 80 people on can be fun when you're trying to talk and all you can hear is radios.
			continue


		// --- Check for compression ---
		if(compression > 0)

			heard_gibberish += R
			continue

		// --- Can understand the speech ---

		if (R.say_understands(M))

			heard_normal += R

		// --- Can't understand the speech ---

		else
			// - Just display a garbled message -

			heard_garbled += R


  /* ###### Begin formatting and sending the message ###### */
	if (length(heard_normal) || length(heard_garbled) || length(heard_gibberish))

	  /* --- Some miscellaneous variables to format the string output --- */
		var/freq_text // the name of the channel

		// --- Set the name of the channel ---
		switch(display_freq)

			if(SYND_FREQ)
				freq_text = "#unkn"
			if(HEIST_FREQ)
				freq_text = "Shoal"
			if(COMM_FREQ)
				freq_text = "Command"
			if(1351)
				freq_text = "Science"
			if(1355)
				freq_text = "Medical"
			if(1357)
				freq_text = "Engineering"
			if(1359)
				freq_text = "Security"
			if(1347)
				freq_text = "Supply"
		//There's probably a way to use the list var of channels in code\game\communications.dm to make the dept channels non-hardcoded, but I wasn't in an experimentive mood. --NEO


		// --- If the frequency has not been assigned a name, just use the frequency as the name ---

		if(!freq_text)
			freq_text = format_frequency(display_freq)

		// --- Some more pre-message formatting ---

		var/part_a_span = "radio"

		if (display_freq == SYND_FREQ)
			part_a_span = "syndradio"
		else if(display_freq == HEIST_FREQ)
			part_a_span = "voxradio"
		else if (display_freq == COMM_FREQ)
			part_a_span = "comradio"
		else if (display_freq in DEPT_FREQS)
			part_a_span = "deptradio"

		var/part_a = "<span class='[part_a_span]'><span class='name'>" // goes in the actual output
		var/part_b_extra = ""
		if(data == BROADCAST_MODE_SYNDICATE) // intercepted radio message
			part_b_extra = " <i>(Intercepted)</i>"
		var/part_b = "</span><b> \[[freq_text]\][part_b_extra]</b> <span class='message'>" // Tweaked for security headsets -- TLE
		var/part_c = "</span></span>"

		// --- This following recording is intended for research and feedback in the use of department radio channels ---

		var/part_blackbox_b = "</span><b> \[[freq_text]\]</b> <span class='message'>" // Tweaked for security headsets -- TLE
		var/blackbox_msg = "[part_a][source][part_blackbox_b]\"[text]\"[part_c]"
		//var/blackbox_admin_msg = "[part_a][M.name] (Real name: [M.real_name])[part_blackbox_b][quotedmsg][part_c]"

		//BR.messages_admin += blackbox_admin_msg
		if(istype(blackbox))
			switch(display_freq)
				if(1459)
					blackbox.msg_common += blackbox_msg
				if(1351)
					blackbox.msg_science += blackbox_msg
				if(1353)
					blackbox.msg_command += blackbox_msg
				if(1355)
					blackbox.msg_medical += blackbox_msg
				if(1357)
					blackbox.msg_engineering += blackbox_msg
				if(1359)
					blackbox.msg_security += blackbox_msg
				if(1441)
					blackbox.msg_deathsquad += blackbox_msg
				if(1213)
					blackbox.msg_syndicate += blackbox_msg
				if(1206)
					blackbox.msg_heist += blackbox_msg
				if(1347)
					blackbox.msg_cargo += blackbox_msg
				else
					blackbox.messages += blackbox_msg

		//End of research and feedback code.

	 /* ###### Send the message ###### */

		/* --- Process all the mobs that heard the voice normally (understood) --- */

		if (length(heard_normal))
			var/rendered = "[part_a][source][part_b]\"[text]\"[part_c]"

			for (var/mob/R in heard_normal)
				R.show_message(rendered, SHOWMSG_AUDIO)

		/* --- Process all the mobs that heard a garbled voice (did not understand) --- */
			// Displays garbled message (ie "f*c* **u, **i*er!")

		if (length(heard_garbled))
			var/quotedmsg = "\"[stars(text)]\""
			var/rendered = "[part_a][source][part_b][quotedmsg][part_c]"

			for (var/mob/R in heard_garbled)
				R.show_message(rendered, SHOWMSG_AUDIO)


		/* --- Complete gibberish. Usually happens when there's a compressed message --- */

		if (length(heard_gibberish))
			var/quotedmsg = "\"[Gibberish(text, compression + 50)]\""
			var/rendered = "[part_a][Gibberish(source, compression + 50)][part_b][quotedmsg][part_c]"

			for (var/mob/R in heard_gibberish)
				R.show_message(rendered, SHOWMSG_AUDIO)

//Use this to test if an obj can communicate with a Telecommunications Network

/atom/proc/test_telecomms()
	var/datum/signal/signal = telecomms_process()
	var/turf/position = get_turf(src)
	return (position.z in signal.data["level"]) && signal.data["done"]

/atom/proc/telecomms_process()

	// First, we want to generate a new radio signal
	var/datum/signal/signal = new
	signal.transmission_method = 2 // 2 would be a subspace transmission.
	var/turf/pos = get_turf(src)

	// --- Finally, tag the actual signal with the appropriate values ---
	signal.data = list(
		"slow" = 0, // how much to sleep() before broadcasting - simulates net lag
		"message" = "TEST",
		"compression" = rand(45, 50), // If the signal is compressed, compress our message too.
		"traffic" = 0, // dictates the total traffic sum that the signal went through
		"type" = 4, // determines what type of radio input it is: test broadcast
		"reject" = 0,
		"done" = 0,
		"level" = pos.z // The level it is being broadcasted at.
	)
	signal.frequency = 1459// Common channel

  //#### Sending the signal to all subspace receivers ####//
	for(var/obj/machinery/telecomms/receiver/R in telecomms_list)
		R.receive_signal(signal)

	sleep(rand(10,25))

	//world.log << "Level: [signal.data["level"]] - Done: [signal.data["done"]]"

	return signal
