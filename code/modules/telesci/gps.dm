var/global/list/GPS_list = list()

#define EMP_DISABLE_TIME 30 SECONDS
#define POS_VECTOR(A) list(A.x, A.y, A.z)

/**
  * # GPS
  *
  * A small item that reports its current location. Has a tag to help distinguish between them.
  */

/obj/item/device/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-com"
	w_class = SIZE_TINY
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "programming=2;engineering=2"
	/// Whether the GPS is on.
	var/tracking = FALSE
	/// The tag that is visible to other GPSes.
	var/gpstag = "COM0"
	/// Whether to only list signals that are on the same Z-level.
	var/same_z = FALSE
	/// Whether the GPS should only show up to GPSes on the same Z-level.
	var/local = FALSE
	var/emped = FALSE
	var/turf/locked_location
	/// if it is set, GPS will filter signals only with same frequency.
	var/frequency

/obj/item/device/gps/atom_init()
	. = ..()
	GPS_list.Add(src)
	name = "global positioning system ([gpstag])"
	update_icon()

/obj/item/device/gps/Destroy()
	GPS_list.Remove(src)
	return ..()

/obj/item/device/gps/update_icon()
	cut_overlays()
	if(emped)
		add_overlay("emp")
	else if(tracking)
		add_overlay("working")

/obj/item/device/gps/emp_act(severity)
	emped = TRUE
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(reboot)), EMP_DISABLE_TIME)

/obj/item/device/gps/AltClick(mob/user)
	if(user.incapacitated() || !user.Adjacent(src))
		return

	if(emped)
		to_chat(user, "<span class='warning'>It's busted!</span>")
		return

	tracking = !tracking
	update_icon()
	if(tracking)
		to_chat(user, "[src] is now tracking, and visible to other GPS devices.")
	else
		to_chat(user, "[src] is no longer tracking, or visible to other GPS devices.")
	SStgui.update_uis(src)

/obj/item/device/gps/tgui_data(mob/user)
	var/list/data = list()
	if(emped)
		data["emped"] = TRUE
		return data

	// General
	data["active"] = tracking
	data["tag"] = gpstag
	data["same_z"] = same_z
	if(!tracking)
		return data
	var/turf/T = get_turf(src)
	data["area"] = get_area(src)
	data["position"] = POS_VECTOR(T)

	// Saved location
	if(locked_location)
		data["saved"] = POS_VECTOR(locked_location)
	else
		data["saved"] = null

	// GPS signals
	var/signals = list()
	for(var/obj/item/device/gps/G as anything in global.GPS_list)
		if(!G.tracking || G == src)
			continue
		if(frequency != G.frequency)
			continue
		var/turf/GT = get_turf(G)
		if((G.local || same_z) && (GT.z != T.z))
			continue

		var/list/signal = list("tag" = G.gpstag, "area" = null, "position" = null)
		if(!G.emped)
			signal["area"] = get_area(G)
			signal["position"] = POS_VECTOR(GT)
		signals += list(signal)
	data["signals"] = signals

	return data

/obj/item/device/gps/attack_self(mob/user)
	tgui_interact(user)

/obj/item/device/gps/tgui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GPS", "GPS", 450, 700)
		ui.open()

/obj/item/device/gps/tgui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	. = TRUE
	switch(action)
		if("tag")
			var/newtag = params["newtag"] || ""
			newtag = uppertext(paranoid_sanitize(copytext(newtag, 1, 5)))
			if(!length(newtag) || gpstag == newtag)
				return
			gpstag = newtag
			name = "global positioning system ([gpstag])"
		if("toggle")
			AltClick(usr)
			return FALSE
		if("same_z")
			same_z = !same_z
		else
			return FALSE


/**
  * Turns off the GPS's EMPed state. Called automatically after an EMP.
  */
/obj/item/device/gps/proc/reboot()
	emped = FALSE
	update_icon()

/obj/item/device/gps/science
	icon_state = "gps-sci"
	gpstag = "SCI0"

/obj/item/device/gps/engineering
	icon_state = "gps-eng"
	gpstag = "ENG0"

/obj/item/device/gps/mining
	icon_state = "gps-mine"
	gpstag = "MIN0"

/obj/item/device/gps/medical
	icon_state = "gps-med"
	gpstag = "MED0"

/obj/item/device/gps/cyborg
	gpstag = "BORG0"
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged cyborg assets, or a collaboration tool for mining teams."
	flags = NODROP

/obj/item/device/gps/internal
	icon_state = null
	flags = ABSTRACT
	local = TRUE
	gpstag = "Eerie Signal"
	desc = "Report to a coder immediately."
	invisibility = INVISIBILITY_MAXIMUM

/obj/item/device/gps/visible_debug
	name = "visible GPS"
	gpstag = "ADMIN"
	desc = "This admin-spawn GPS unit leaves the coordinates visible \
		on any turf that it passes over, for debugging. Especially useful \
		for marking the area around the transition edges."
	var/list/turf/tagged

/obj/item/device/gps/visible_debug/atom_init()
	. = ..()
	tagged = list()
	START_PROCESSING(SSfastprocess, src)

/obj/item/device/gps/visible_debug/process()
	var/turf/T = get_turf(src)
	if(T)
		// I assume it's faster to color,tag and OR the turf in, rather
		// then checking if its there
		T.color = RANDOM_COLOUR
		T.maptext = "[T.x],[T.y],[T.z]"
		tagged |= T

/obj/item/device/gps/visible_debug/proc/clear()
	while(tagged.len)
		var/turf/T = pop(tagged)
		T.color = initial(T.color)
		T.maptext = initial(T.maptext)

/obj/item/device/gps/visible_debug/Destroy()
	if(tagged)
		clear()
	tagged = null
	STOP_PROCESSING(SSfastprocess, src)
	return ..()


/obj/item/device/gps/team_red
	gpstag = "RED"
	frequency = FREQ_TEAM_RED

/obj/item/device/gps/team_red/atom_init()
	var/static/tag_number = 0
	gpstag = "[gpstag][tag_number]"
	tag_number++
	return ..()

/obj/item/device/gps/team_blue
	gpstag = "BLUE"
	frequency = FREQ_TEAM_BLUE

/obj/item/device/gps/team_blue/atom_init()
	var/static/tag_number = 0
	gpstag = "[gpstag][tag_number]"
	tag_number++
	return ..()

#undef EMP_DISABLE_TIME
#undef POS_VECTOR
