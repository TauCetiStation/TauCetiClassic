// Navigation beacon for AI robots
// Functions as a transponder: looks for incoming signal matching

/obj/machinery/navbeacon

	icon = 'icons/obj/objects.dmi'
	icon_state = "navbeacon0-f"
	name = "Navigation Beacon"
	desc = "A radio beacon used for bot navigation."
	level = 1		// underfloor
	layer = 2.5
	anchored = TRUE
	interact_offline = TRUE
	can_be_unanchored = TRUE

	var/open = 0		// true if cover is open
	var/locked = 1		// true if controls are locked
	var/freq = 1445		// radio frequency
	var/location = ""	// location response text
	var/list/codes		// assoc. list of transponder codes
	var/codes_txt = ""	// codes as set on map: "tag1;tag2" or "tag1=value;tag2=value"

	req_one_access = list(access_engine, access_cargo_bot)

/obj/machinery/navbeacon/atom_init()
	. = ..()
	set_codes()
	var/turf/T = loc
	hide(T.intact)
	radio_controller.add_object(src, freq, RADIO_NAVBEACONS)

/obj/machinery/navbeacon/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, freq)
	return ..()

	// set the transponder codes assoc list from codes_txt
/obj/machinery/navbeacon/proc/set_codes()
	if(!codes_txt)
		return

	codes = new()

	var/list/entries = splittext(codes_txt, ";")	// entries are separated by semicolons

	for(var/e in entries)
		var/index = findtext(e, "=")		// format is "key=value"
		if(index)
			var/key = copytext(e, 1, index)
			var/val = copytext(e, index + 1)
			codes[key] = val
		else
			codes[e] = "1"


	// called when turf state changes
	// hide the object if turf is intact
/obj/machinery/navbeacon/hide(intact)
	invisibility = intact ? 101 : 0
	updateicon()

	// update the icon_state
/obj/machinery/navbeacon/proc/updateicon()
	var/state="navbeacon[open]"

	if(invisibility)
		icon_state = "[state]-f"	// if invisible, set icon to faded version
									// in case revealed by T-scanner
	else
		icon_state = "[state]"


	// look for a signal of the form "findbeacon=X"
	// where X is any
	// or the location
	// or one of the set transponder keys
	// if found, return a signal
/obj/machinery/navbeacon/receive_signal(datum/signal/signal)
	var/request = signal.data["findbeacon"]
	if(request && ((request in codes) || request == "any" || request == location))
		spawn(1)
			post_signal()

	// return a signal giving location and transponder codes

/obj/machinery/navbeacon/proc/post_signal()
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

	if(!frequency)
		return

	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	signal.data["beacon"] = location

	for(var/key in codes)
		signal.data[key] = codes[key]

	frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)


/obj/machinery/navbeacon/attackby(obj/item/I, mob/user)
	var/turf/T = loc
	if(T.intact)
		return		// prevent intraction when T-scanner revealed

	if(isscrewdriver(I))
		open = !open
		user.SetNextMove(CLICK_CD_RAPID)

		user.visible_message("[user] [open ? "opens" : "closes"] the beacon's cover.", "You [open ? "open" : "close"] the beacon's cover.")

		updateicon()

	else if(istype(I, /obj/item/weapon/card/id) || istype(I, /obj/item/device/pda))
		if(open)
			if (src.allowed(user))
				src.locked = !src.locked
				to_chat(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
			updateDialog()
		else
			to_chat(user, "You must open the cover first!")
	else if (default_unfasten_wrench(user, I))
		anchored = !anchored
		to_chat(user, "You [anchored ? "" : "un"]fasten [anchored ? "to" : "from"] the plating")
	return

/obj/machinery/navbeacon/attack_paw()
	return

/obj/machinery/navbeacon/ui_interact(mob/user)
	var/ai = isAI(user) || isobserver(user)

	var/turf/T = loc
	if(T.intact)
		return		// prevent intraction when T-scanner revealed

	if(!open && !ai)	// can't alter controls if not open, unless you're an AI
		to_chat(user, "The beacon's control cover is closed.")
		return

	var/t

	if(locked && !ai)
		t = {"<i>(swipe card to unlock controls)</i><BR>
			Frequency: [format_frequency(freq)]<BR><HR>
			Location: [location ? location : "(none)"]</A><BR>
			Transponder Codes:<UL>"}

		for(var/key in codes)
			t += "<LI>[key] ... [codes[key]]"
		t+= "<UL></TT>"

	else

		t = {"<i>(swipe card to lock controls)</i><BR>
			Frequency:
			<A href='byond://?src=\ref[src];freq=-10'>-</A>
			<A href='byond://?src=\ref[src];freq=-2'>-</A>
			[format_frequency(freq)]
			<A href='byond://?src=\ref[src];freq=2'>+</A>
			<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
			<HR>
			Location: <A href='byond://?src=\ref[src];locedit=1'>[location ? location : "(none)"]</A><BR>
			Transponder Codes:<UL>"}

		for(var/key in codes)
			t += "<LI>[key] ... [codes[key]]"
			t += " <small><A href='byond://?src=\ref[src];edit=1;code=[key]'>(edit)</A>"
			t += " <A href='byond://?src=\ref[src];delete=1;code=[key]'>(delete)</A></small><BR>"
		t += "<small><A href='byond://?src=\ref[src];add=1;'>(add new)</A></small><BR>"
		t+= "<UL></TT>"

	var/datum/browser/popup = new(user, "window=navbeacon", src.name)
	popup.set_content(t)
	popup.open()

/obj/machinery/navbeacon/Topic(href, href_list)
	. = ..()
	if(!. || ((!open || locked) && !issilicon(usr) && !isobserver(usr)))
		return FALSE

	if (href_list["freq"])
		freq = sanitize_frequency(freq + text2num(href_list["freq"]))

	else if(href_list["locedit"])
		var/newloc = sanitize_safe(input("Enter New Location", "Navigation Beacon", input_default(location)) as text|null)
		if(newloc)
			location = newloc

	else if(href_list["edit"])
		var/codekey = href_list["code"]

		var/newkey = sanitize_safe(input("Enter Transponder Code Key", "Navigation Beacon", input_default(codekey)) as text|null)
		if(!newkey)
			return FALSE

		var/codeval = codes[codekey]
		var/newval = sanitize_safe(input("Enter Transponder Code Value", "Navigation Beacon", input_default(codeval)) as text|null)
		if(!newval)
			return FALSE

		codes.Remove(codekey)
		codes[newkey] = newval

		updateDialog()

	else if(href_list["delete"])
		var/codekey = href_list["code"]
		codes.Remove(codekey)

	else if(href_list["add"])
		var/newkey = sanitize(input("Enter New Transponder Code Key", "Navigation Beacon") as text|null)
		if(!newkey)
			return FALSE

		var/newval = sanitize(input("Enter New Transponder Code Value", "Navigation Beacon") as text|null)
		if(!newval)
			return FALSE

		if(!codes)
			codes = new()

		codes[newkey] = newval

	updateDialog()
