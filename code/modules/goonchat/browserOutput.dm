var/global/savefile/iconCache = new /savefile("data/iconCache.sav")

var/global/list/bicon_cache = list()

/icon
	var/icon_info

/icon/New(icon,icon_state,dir,frame,moving)
	..()
	// A link to yourself, otherwise a file. A kind of guarantee.
	if(istype(icon, /icon))
		icon_info = "\ref[src]#[icon_state]"
	else
		icon_info = "\ref[icon]#[icon_state]"

//Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
// exporting it as text, and then parsing the base64 from that.
// (This relies on byond automatically storing icons in savefiles as base64)
/proc/icon2base64(icon/icon, iconKey = "misc")
	if (!isicon(icon)) return 0

	iconCache[iconKey] << icon
	var/iconData = iconCache.ExportText(iconKey)
	var/list/partial = splittext(iconData, "{")
	var/list/almost_partial = splittext(partial[2], "}")
	return replacetext(copytext(almost_partial[1], 3, -5), "\n", "")

/proc/bicon(obj, css = "class='icon'", time_stamp = -1) // if you don't want any styling just pass null to css
	if (!obj)
		return

	if(SSlag_switch.measures[DISABLE_BICON] && usr && !HAS_TRAIT(usr, TRAIT_BYPASS_MEASURES)) // todo: bypass for round end stat
		return

	return "<img [css] src='data:image/png;base64,[bicon_raw(obj, time_stamp)]'>"

/proc/timestamp_cache_add(key, element)
	global.bicon_cache[key] = list(element, world.time)
	return element

/proc/timestamp_cache_get(key, time_stamp)
	if(!global.bicon_cache[key])
		return null

	if(time_stamp >= 0 && global.bicon_cache[key][2] < time_stamp)
		return null

	return global.bicon_cache[key][1]

/proc/bicon_raw(obj, time_stamp)
	if (!obj)
		return

	// This check will check for an icon object that already has a cool key.
	if (istype(obj, /icon))
		var/icon/I = obj
		var/bicon_obj = timestamp_cache_get(I.icon_info, time_stamp)
		if (!bicon_obj)
			bicon_obj = timestamp_cache_add(I.icon_info, icon2base64(obj))
		return bicon_obj

	// This check will check if you pass it to this proc 'foo/bar.dmi', or something from your computer in game
	if(isicon(obj))
		var/key = "\ref[obj]"
		var/bicon_obj = timestamp_cache_get(key, time_stamp)
		if(!bicon_obj)
			bicon_obj = timestamp_cache_add(key, icon2base64(obj))
		return bicon_obj

	if(!isatom(obj) && !istype(obj, /image)) // we don't need datums here. no runtimes :<
		return

	// Thanks to dynamic typing, this atom can be both an image and a mutable_appearance
	var/atom/A = obj
	var/key = "\ref[A.icon]#[A.icon_state]"
	var/bicon_obj = timestamp_cache_get(key, time_stamp)
	if (!bicon_obj) // Doesn't exist, make it.
		var/icon/I
		if(!A.icon || !A.icon_state || !(A.icon_state in icon_states(A.icon))) // fixes freeze when client uses examine or anything else, when there is something wrong with icon data.
			I = icon('icons/misc/buildmode.dmi', "buildhelp")                  // there is no logic with this icon choice, i just like it.
		else
			I = icon(A.icon, A.icon_state, SOUTH, 1)
		if (ishuman(obj)) // Shitty workaround for a BYOND issue.
			var/icon/temp = I
			I = icon()
			I.Insert(temp, dir = SOUTH)
		bicon_obj = timestamp_cache_add(key, icon2base64(I, key))

	return bicon_obj
