/*

	All telecommunications interactions:

*/

/obj/machinery/telecomms
	var/temp = "" // output message

/obj/machinery/telecomms/attackby(obj/item/P, mob/user)

	// Using a multitool lets you access the receiver's interface
	if(ispulsing(P))
		attack_hand(user)

	if(default_deconstruction_screwdriver(user, on ? "[initial(icon_state)]_o" : "[initial(icon_state)]_o_off",  on ? initial(icon_state) : "[initial(icon_state)]_off" , P))
		return
	if(default_deconstruction_crowbar(P))
		return

/obj/machinery/telecomms/ui_interact(mob/user)
	// You need a multitool to use this, or be silicon/ghost
	if(!issilicon(user) && !isobserver(user))
		// get_quality returns false if the value is null
		var/obj/item/I = user.get_active_hand()
		if(I && !ispulsing(I))
			return

	var/obj/item/device/multitool/P = get_multitool(user)
	var/dat
	dat = "<font face = \"Courier\">"
	dat += "<br>[temp]<br>"
	dat += "<br>Power Status: <a href='?src=\ref[src];input=toggle'>[src.toggled ? "On" : "Off"]</a>"
	if(on && toggled)
		if(id != "" && id)
			dat += "<br>Identification String: <a href='?src=\ref[src];input=id'>[id]</a>"
		else
			dat += "<br>Identification String: <a href='?src=\ref[src];input=id'>NULL</a>"
		dat += "<br>Network: <a href='?src=\ref[src];input=network'>[network]</a>"
		dat += "<br>Prefabrication: [autolinkers.len ? "TRUE" : "FALSE"]"
		if(hide)
			dat += "<br>Shadow Link: ACTIVE</a>"

		//Show additional options for certain machines.
		dat += Options_Menu()

		dat += "<br>Linked Network Entities: <ol>"

		var/i = 0
		for(var/obj/machinery/telecomms/T in links)
			i++
			if(T.hide && !src.hide)
				continue
			dat += "<li>\ref[T] [T.name] ([T.id])  <a href='?src=\ref[src];unlink=[i]'>\[X\]</a></li>"
		dat += "</ol>"

		dat += "<br>Filtering Frequencies: "

		i = 0
		if(length(freq_listening))
			for(var/x in freq_listening)
				i++
				if(i < length(freq_listening))
					dat += "[format_frequency(x)] GHz<a href='?src=\ref[src];delete=[x]'>\[X\]</a>; "
				else
					dat += "[format_frequency(x)] GHz<a href='?src=\ref[src];delete=[x]'>\[X\]</a>"
		else
			dat += "NONE"

		dat += "<br>  <a href='?src=\ref[src];input=freq'>\[Add Filter\]</a>"
		dat += "<hr>"

		if(P)
			if(P.buffer)
				dat += "<br><br>MULTITOOL BUFFER: [P.buffer] ([P.buffer.id]) <a href='?src=\ref[src];link=1'>\[Link\]</a> <a href='?src=\ref[src];flush=1'>\[Flush\]"
			else
				dat += "<br><br>MULTITOOL BUFFER: <a href='?src=\ref[src];buffer=1'>\[Add Machine\]</a>"

	dat += "</font>"
	temp = ""

	var/datum/browser/popup = new(user, "tcommachine", "[src.name] Access", 520, 500)
	popup.set_content(dat)
	popup.open()


// Returns a multitool from a user depending on their mobtype.

/obj/machinery/telecomms/proc/get_multitool(mob/user)

	var/obj/item/device/multitool/P = null
	var/obj/item/I = user.get_active_hand()
	// Let's double check
	if(!issilicon(user) && !isobserver(user) && (I && ispulsing(I)))
		P = user.get_active_hand()
	else if(isAI(user))
		var/mob/living/silicon/ai/U = user
		P = U.aiMulti
	else if(isrobot(user) && Adjacent(user))
		if(ispulsing(I))
			P = user.get_active_hand()
	else if(isobserver(user))
		var/mob/dead/observer/O = user
		if(!O.adminMulti)
			O.adminMulti = new(O)
		P = O.adminMulti
	return P

// Additional Options for certain machines. Use this when you want to add an option to a specific machine.
// Example of how to use below.

/obj/machinery/telecomms/proc/Options_Menu()
	return ""

/*
// Add an option to the processor to switch processing mode. (COMPRESS -> UNCOMPRESS or UNCOMPRESS -> COMPRESS)
/obj/machinery/telecomms/processor/Options_Menu()
	var/dat = "<br>Processing Mode: <A href='?src=\ref[src];process=1'>[process_mode ? "UNCOMPRESS" : "COMPRESS"]</a>"
	return dat
*/
// The topic for Additional Options. Use this for checking href links for your specific option.
// Example of how to use below.
/obj/machinery/telecomms/proc/Options_Topic(href, href_list)
	return

/*
/obj/machinery/telecomms/processor/Options_Topic(href, href_list)

	if(href_list["process"])
		temp = "<font color='#666633'>-% Processing mode changed. %-</font>"
		src.process_mode = !src.process_mode
*/

// RELAY

/obj/machinery/telecomms/relay/Options_Menu()
	return "<br>Broadcasting: <A href='?src=\ref[src];broadcast=1'>[broadcasting ? "YES" : "NO"]</a>" + \
		 "<br>Receiving:    <A href='?src=\ref[src];receive=1'>[receiving ? "YES" : "NO"]</a>"

/obj/machinery/telecomms/relay/Options_Topic(href, href_list)

	if(href_list["receive"])
		receiving = !receiving
		temp = "<font color='#666633'>-% Receiving mode changed. %-</font>"
	if(href_list["broadcast"])
		broadcasting = !broadcasting
		temp = "<font color='#666633'>-% Broadcasting mode changed. %-</font>"

// BUS

/obj/machinery/telecomms/bus/Options_Menu()
	var/dat = "<br>Change Signal Frequency: <A href='?src=\ref[src];change_freq=1'>[change_frequency ? "YES ([change_frequency])" : "NO"]</a>"
	return dat

/obj/machinery/telecomms/bus/Options_Topic(href, href_list)

	if(href_list["change_freq"])

		var/newfreq = input(usr, "Specify a new frequency for new signals to change to. Enter null to turn off frequency changing. Decimals assigned automatically.", src, network) as null|num
		if(canAccess(usr))
			if(newfreq)
				if(findtext(num2text(newfreq), "."))
					newfreq *= 10 // shift the decimal one place
				if(newfreq < 10000)
					change_frequency = newfreq
					temp = "<font color='#666633'>-% New frequency to change to assigned: \"[newfreq] GHz\" %-</font>"
			else
				change_frequency = 0
				temp = "<font color='#666633'>-% Frequency changing deactivated %-</font>"


/obj/machinery/telecomms/Topic(href, href_list)
	if(!issilicon(usr) && !isobserver(usr))
		var/obj/item/I = usr.get_active_hand()
		if(I && !ispulsing(I))
			return FALSE

	. = ..()
	if(!.)
		return

	var/obj/item/device/multitool/P = get_multitool(usr)

	if(href_list["input"])
		switch(href_list["input"])

			if("toggle")

				src.toggled = !src.toggled
				temp = "<font color='#666633'>-% [src] has been [src.toggled ? "activated" : "deactivated"].</font>"
				update_power()

			/*
			if("hide")
				src.hide = !hide
				temp = "<font color='#666633'>-% Shadow Link has been [src.hide ? "activated" : "deactivated"].</font>"
			*/

			if("id")
				var/newid = sanitize_safe(input(usr, "Specify the new ID for this machine", src, input_default(id)) as null|text)
				if(newid && canAccess(usr))
					id = newid
					temp = "<font color='#666633'>-% New ID assigned: \"[id]\" %-</font>"

			if("network")
				var/newnet = sanitize_safe(input(usr, "Specify the new network for this machine. This will break all current links.", src, input_default(network)) as null|text, MAX_LNAME_LEN)
				if(newnet && canAccess(usr))

					if(length(newnet) > 15)
						temp = "<font color='#666633'>-% Too many characters in new network tag %-</font>"

					else
						for(var/obj/machinery/telecomms/T in links)
							T.links.Remove(src)

						network = newnet
						links = list()
						temp = "<font color='#666633'>-% New network tag assigned: \"[network]\" %-</font>"


			if("freq")
				var/newfreq = input(usr, "Specify a new frequency to filter (GHz). Decimals assigned automatically.", src, network) as null|num
				if(newfreq && canAccess(usr))
					if(findtext(num2text(newfreq), "."))
						newfreq *= 10 // shift the decimal one place
					if(!(newfreq in freq_listening) && newfreq < 10000)
						freq_listening.Add(newfreq)
						temp = "<font color='#666633'>-% New frequency filter assigned: \"[newfreq] GHz\" %-</font>"

	if(href_list["delete"])

		// changed the layout about to workaround a pesky runtime -- Doohl

		var/x = text2num(href_list["delete"])
		temp = "<font color='#666633'>-% Removed frequency filter [x] %-</font>"
		freq_listening.Remove(x)

	if(href_list["unlink"])

		if(text2num(href_list["unlink"]) <= length(links))
			var/obj/machinery/telecomms/T = links[text2num(href_list["unlink"])]
			temp = "<font color='#666633'>-% Removed \ref[T] [T.name] from linked entities. %-</font>"

			// Remove link entries from both T and src.

			if(src in T.links)
				T.links.Remove(src)
			links.Remove(T)

	if(href_list["link"])

		if(P)
			if(P.buffer && P.buffer != src)
				if(!(src in P.buffer.links))
					P.buffer.links.Add(src)

				if(!(P.buffer in src.links))
					links.Add(P.buffer)

				temp = "<font color='#666633'>-% Successfully linked with \ref[P.buffer] [P.buffer.name] %-</font>"

			else
				temp = "<font color='#666633'>-% Unable to acquire buffer %-</font>"

	if(href_list["buffer"])

		P.buffer = src
		temp = "<font color='#666633'>-% Successfully stored \ref[P.buffer] [P.buffer.name] in buffer %-</font>"


	if(href_list["flush"])

		temp = "<font color='#666633'>-% Buffer successfully flushed. %-</font>"
		P.buffer = null

	Options_Topic(href, href_list)

	usr.set_machine(src)

	updateUsrDialog()

/obj/machinery/telecomms/proc/canAccess(mob/user)
	if(issilicon(user) || isobserver(user) || Adjacent(user))
		return TRUE
	return FALSE
