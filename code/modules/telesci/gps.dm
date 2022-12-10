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
	var/on = FALSE
	var/track_saving = FALSE
	/// The tag that is visible to other GPSes.
	var/gpstag = "COM0"
	/// Whether the GPS should only show up to GPSes on the same Z-level.
	var/local = FALSE
	var/emped = FALSE

	var/save_slots_number = 3
	var/selected_slot = 1

	var/track_max_length = 150
	var/list/tracks
	var/list/saved_locations

	var/selected_z = 2

	var/color_style = "COM"

/obj/item/device/gps/atom_init()
	. = ..()
	GPS_list.Add(src)
	name = "global positioning system ([gpstag])"
	update_icon()

	setup_slots()

/obj/item/device/gps/Destroy()
	GPS_list.Remove(src)
	stop_tracking()
	return ..()

/obj/item/device/gps/process()
	var/list/Track = tracks[selected_slot]
	if(Track.len > track_max_length || !on || !tracking)
		stop_tracking()
		return

	var/turf/T = get_turf(src)

	var/i = Track.len
	var/list/Pre_Prev_Dot = i > 1 ? Track[i-1] : null
	var/list/Prev_Dot = i > 0 ? Track[i] : null
	var/list/Dot = list("x" = T.x, "y" = T.y, "z" = T.z, "end" = FALSE)
	if(Prev_Dot)
		if(!(Prev_Dot["z"] == Dot["z"]))
			Prev_Dot["end"] = TRUE
		else if(Prev_Dot["x"] == Dot["x"] && Prev_Dot["y"] == Dot["y"])
			return
		else if(Pre_Prev_Dot && !Pre_Prev_Dot["end"] && !Prev_Dot["end"])
			if(OnVector(Pre_Prev_Dot, Prev_Dot, Dot))
				Track[i] = Dot
				return

	Track.len++
	i++
	Track[i] = Dot


/obj/item/device/gps/proc/OnVector(list/First, list/Second, list/Third)
	if( ((Second["x"]-First["x"]) * (Third["y"] - First["y"])) - ((Second["y"]-First["y"]) * (Third["x"]-First["x"])) == 0)
		return TRUE
	return FALSE

/obj/item/device/gps/proc/stop_tracking()
	var/list/Track = tracks[selected_slot]
	if(Track.len)
		Track[Track.len]["end"] = TRUE
	track_saving = FALSE
	STOP_PROCESSING(SSobj, src)

/obj/item/device/gps/proc/setup_slots()
	tracks = new/list(save_slots_number, 0)
	saved_locations = new/list(save_slots_number)

/obj/item/device/gps/update_icon()
	cut_overlays()
	if(emped)
		add_overlay("emp")
	else if(tracking)
		add_overlay("working")

/obj/item/device/gps/emp_act(severity)
	emped = TRUE
	update_icon()
	addtimer(CALLBACK(src, .proc/reboot), EMP_DISABLE_TIME)

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
	data["on"] = on
	data["tag"] = gpstag
	data["style"] = color_style
	if(!on)
		return data
	var/turf/T = get_turf(src)
	if(tracking && (T.z == selected_z))
		data["area"] = get_area(src)
		data["position"] = POS_VECTOR(T)
	else
		data["position"] = null
		data["area"] = null

	// Saved location
	var/turf/Saved = saved_locations[selected_slot]
	if(Saved && (Saved.z == selected_z))
		data["saved"] = POS_VECTOR(Saved)
	else
		data["saved"] = null

	// GPS signals
	if(tracking)
		var/signals = list()
		for(var/g in global.GPS_list)
			var/obj/item/device/gps/G = g
			var/turf/GT = get_turf(G)
			if(!G.tracking || G == src)
				continue
			if((G.local) && (GT.z != T.z))
				continue
			if(G.z != selected_z)
				continue

			var/list/signal = list("tag" = G.gpstag, "area" = null, "position" = null)
			if(!G.emped)
				signal["area"] = get_area(G)
				signal["position"] = POS_VECTOR(GT)
			signals += list(signal)
		data["signals"] = signals

	data["track"] = tracks[selected_slot]
	data["track_saving"] = track_saving
	data["selected_z"] = selected_z

	return data

/obj/item/device/gps/attack_self(mob/user)
	tgui_interact(user)

/obj/item/device/gps/tgui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GPS", "GPS", 400, 650)
		ui.open()

/obj/item/device/gps/tgui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	. = TRUE
	switch(action)
		if("tag")
			var/newtag = input("Имя:", "", gpstag) as text
			newtag = uppertext(paranoid_sanitize(copytext(newtag, 1, 5)))
			if(!length(newtag) || gpstag == newtag)
				return
			gpstag = newtag
			name = "global positioning system ([gpstag])"
		if("toggle")
			on = !on
			stop_tracking()
			return FALSE
		if("tracking")
			AltClick(usr)
		if("z_level")
			selected_z = clamp(params["chosen_level"], 1, 10)
			return FALSE
		if("track_saving")
			if(track_saving)
				STOP_PROCESSING(SSobj, src)
				stop_tracking()
			else
				START_PROCESSING(SSobj, src)
				track_saving = TRUE
		if("choose_track")
			selected_slot++
			if(selected_slot > save_slots_number)
				selected_slot = 1
		if("erase_data")
			stop_tracking()
			tracks[selected_slot] = list()
			saved_locations[selected_slot] = null
		if("save_location")
			if(tracking)
				saved_locations[selected_slot] = get_turf(src)
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
	color_style = "SCI"

/obj/item/device/gps/engineering
	icon_state = "gps-eng"
	gpstag = "ENG0"
	color_style = "ENG"

/obj/item/device/gps/mining
	icon_state = "gps-mine"
	gpstag = "MIN0"
	color_style = "MIN"

/obj/item/device/gps/medical
	icon_state = "gps-med"
	gpstag = "MED0"
	color_style = "MED"

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

#undef EMP_DISABLE_TIME
#undef POS_VECTOR
