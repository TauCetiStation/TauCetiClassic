// keybinds value formatted as list of binds separated by space
// maximum 3 (KEYBINDS_MAXIMUM) binds and two spaces (or leading space) means empty bind in between
// combinations with alt/ctrl/shift use "+"
//
// "+" is chosen because it should not be possible (i think) to use
// as a key: "+" key is basically "Shift+=", and byond uses "Add" for numpad "+"

/datum/pref/keybinds
	domain = PREF_DOMAIN_KEYBINDS
	value_type = PREF_TYPE_KEYBIND

	value = ""

	category = PREF_KEYBINDS_MISC
	var/weight = WEIGHT_LOWEST

	// legacy name for migration of old savefiles, you should not use it with new keybindings
	var/legacy_keyname

/datum/pref/keybinds/sanitize_value(new_value, client/client)
	var/list/new_keybinds = splittext(new_value, " ")

	if(!length(new_keybinds))
		return ""

	// skip any validation madness if it's just default
	if(value == new_value)
		return value

	new_value = ""

	// I hate this part
	for(var/i in 1 to min(KEYBINDS_MAXIMUM, new_keybinds.len))
		var/raw_key = new_keybinds[i]
		var/key

		var/altMod = FALSE
		if(endswith(raw_key, "Alt"))
			key = "Alt"
		else if(findtext(raw_key, "Alt"))
			altMod = TRUE

		var/ctrlMod = FALSE
		if(endswith(raw_key, "Ctrl"))
			key = "Ctrl"
		else if(findtext(raw_key, "Ctrl"))
			ctrlMod = TRUE

		var/shiftMod = FALSE
		if(endswith(raw_key, "Shift"))
			key = "Shift"
		else if(findtext(raw_key, "Shift"))
			shiftMod = TRUE

		if(!key)
			// old saves keybind mods don't have separator, new keybind mods separated with +
			var/static/list/filter_list = list("Alt", "Ctrl", "Shift", "+")
			key = replace_characters(raw_key, filter_list)

		key = satinize_key(key, altMod, ctrlMod, shiftMod)

		new_value += "[key] "

	return trim_right(new_value)

/datum/pref/keybinds/on_update(client/client, old_value)
	if(!client || !client.prefs) // offline update or prefs still initialising
		return

	client.reset_held_keys()

	var/list/old_keybinds = splittext(old_value, " ")
	for(var/key in old_keybinds)
		client.prefs.key_bindings_by_key[key] -= list(src)

	var/list/new_keybinds = splittext(value, " ")
	for(var/key in new_keybinds)
		client.prefs.key_bindings_by_key[key] += list(src)

/datum/pref/keybinds/proc/satinize_key(key, altMod, ctrlMod, shiftMod)
	if(!length(key))
		return ""
	if(!(key in global.byond_valid_keys))
		return ""
	return "[altMod ? "Alt+" : ""][ctrlMod ? "Ctrl+" : ""][shiftMod ? "Shift+" : ""][key]"

/datum/pref/keybinds/proc/down(client/user)
	return FALSE

/datum/pref/keybinds/proc/up(client/user)
	return FALSE

/datum/pref/keybinds/proc/can_use(client/user)
	return TRUE
