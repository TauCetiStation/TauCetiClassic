// see also: /datum/component/zoom

// fetches prefs and reloads client zoom settings 
// note: this has nothing to do with zoom component, zoom component works with change_view
/client/proc/update_map_zoom()
	var/autozoom = prefs.get_pref(/datum/pref/player/display/auto_zoom)
	var/zoom = autozoom ? 0 : prefs.get_pref(/datum/pref/player/display/zoom) * 0.01
	var/zoom_mode = prefs.get_pref(/datum/pref/player/display/zoom_mode)
	winset(src, "tcmapwindow.map", "zoom=[zoom];zoom-mode=[zoom_mode]")

// changes tiles count client can see
/client/proc/change_view(new_size)
	if (isnull(new_size))
		CRASH("change_view called without argument.")

	view = new_size
	mob.reload_fullscreen()

/client/verb/toggle_fullscreen()
	set name = "Toggle Fullscreen"
	set category = "OOC"

	var/fullscreen = prefs.get_pref(/datum/pref/player/display/fullscreen)
	prefs.set_pref(/datum/pref/player/display/fullscreen, !fullscreen)

	update_fullscreen()

/client/proc/update_fullscreen()
	set name = "Toggle Fullscreen"
	set category = "OOC"

	if(prefs.get_pref(/datum/pref/player/display/fullscreen))
		winset(src, "tcmainwindow", "menu=")
		winset(src, "tcmainwindow", "is-fullscreen=true")
	else
		winset(src, "tcmainwindow", "menu=menu")
		winset(src, "tcmainwindow", "is-fullscreen=false")

// basically, resizes right column so that map windows don't have black bars
/client/verb/fit_viewport()
	set name = "Fit viewport"
	set category = "OOC"
	set desc = "Fit the width of the map window to match the viewport"

	if(isnewplayer(mob)) // no tcmapwindow in lobby
		to_chat(usr, "<span class='warning'>You can't fix viewport while in lobby.</span>")
		return

	// Fetch aspect ratio
	var/view_size = getviewsize(view)
	var/aspect_ratio = view_size[1] / view_size[2]

	// Calculate desired pixel width using window size and aspect ratio
	var/list/sizes = params2list(winget(src, "tcmainwindow.split;tcmapwindow", "size"))

	// Client closed the window? Some other error? This is unexpected behaviour, let's
	// CRASH with some info.
	if(!sizes["tcmapwindow.size"])
		CRASH("sizes does not contain tcmapwindow.size key. This means a winget failed to return what we wanted. --- sizes var: [sizes] --- sizes length: [length(sizes)]")

	var/list/map_size = splittext(sizes["tcmapwindow.size"], "x")

	// Looks like we expect tcmapwindow.size to be "ixj" where i and j are numbers.
	// If we don't get our expected 2 outputs, let's give some useful error info.
	if(length(map_size) != 2)
		CRASH("map_size of incorrect length --- map_size var: [map_size] --- map_size length: [length(map_size)]")

	var/height = text2num(map_size[2])
	var/desired_width = round(height * aspect_ratio)
	if (text2num(map_size[1]) == desired_width)
		// Nothing to do
		return

	var/split_size = splittext(sizes["tcmainwindow.split.size"], "x")
	var/split_width = text2num(split_size[1])

	// Avoid auto-resizing the statpanel and chat into nothing.
	desired_width = min(desired_width, split_width - 300)

	// Calculate and apply a best estimate
	// +4 pixels are for the width of the splitter's handle
	var/pct = 100 * (desired_width + 4) / split_width
	winset(src, "tcmainwindow.split", "splitter=[pct]")

	// Apply an ever-lowering offset until we finish or fail
	var/delta
	for(var/safety in 1 to 10)
		var/after_size = winget(src, "tcmapwindow", "size")
		map_size = splittext(after_size, "x")
		var/got_width = text2num(map_size[1])

		if (got_width == desired_width)
			// success
			return
		else if (isnull(delta))
			// calculate a probable delta value based on the difference
			delta = 100 * (desired_width - got_width) / split_width
		else if ((delta > 0 && got_width > desired_width) || (delta < 0 && got_width < desired_width))
			// if we overshot, halve the delta and reverse direction
			delta = -delta/2

		pct += delta
		winset(src, "tcmainwindow.split", "splitter=[pct]")

// called automatically from skin on any columns resize, 
/client/verb/handle_autofit()
	set name = ".handleautofit"
	set hidden = TRUE

	if(prefs.get_pref(/datum/pref/player/display/auto_fit_viewport) && !isnewplayer(mob))
		fit_viewport()
