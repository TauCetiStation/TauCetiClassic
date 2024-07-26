/datum/pref
	// related to json name (or table in DB)
	var/domain // player | character | keybinds | meta 

	// mostly for sorting prefs in settings menu
	var/category

	var/name

	var/description

	// current value and also default value with initial()
	var/value

	// one of PREF_TYPE_*, defines how we show preference at frontend and how we validate it
	var/value_type = PREF_TYPE_CUSTOM // = COLOR | NUMBER | LIST | BOOLEAN | TEXT

	// ambivalent value depending on value_type:
	// PREF_TYPE_RANGE - list(min, max, step (optional), unit (optional))
	// PREF_TYPE_SELECT - list(value, value, value) or list(value = "humanised name", value = "humanised name", value = "humanised name")
	// PREF_TYPE_TEXT - list(max_length)
	// not used for other types
	var/list/value_parameters

	// just so we can filter and not confuse players with preferences that they can't use
	var/admins_only = FALSE
	var/supporters_only = FALSE


// todo:
// /datum/pref/character
// 	type = "character"

// default sanitize procedures, override it if you need something more
/datum/pref/proc/sanitize_value(new_value, client/client)

	//world.log << "SANITIZE: [new_value], | type: [value_type] | params: [json_encode(value_parameters)] | default: [initial(value)] | current: [value]"
	switch(value_type)
		if(PREF_TYPE_TEXT)
			var/max_length = (length(value_parameters) ? value_parameters[1] : MAX_PAPER_MESSAGE_LEN)
			. = sanitize(new_value, max_length)
		if(PREF_TYPE_RANGE)
			var/min = value_parameters[1]
			var/max = value_parameters[2]
			if(isnum(new_value) && new_value >= min && new_value <= max)
				. = new_value
			else
				. = initial(value)
				stack_trace("Can't sanitize [type], fallback to default.") // todo: remove them later, just for debug now
		if(PREF_TYPE_SELECT)
			if(new_value in value_parameters)
				. = new_value
			else
				. = initial(value)
				stack_trace("Can't sanitize [type], fallback to default.")
		if(PREF_TYPE_HEX)
			var/hex = sanitize_hexcolor(new_value, null)
			if(hex)
				. = hex
			else
				. = initial(value)
				stack_trace("Can't sanitize [type], fallback to default.")
		if(PREF_TYPE_BOOLEAN)
			. = !!new_value
		else // any custom types
			CRASH("Not implemented sanitize for [src.type]!")

	return .

/datum/pref/proc/update_value(new_value, client/client)
	var/old_value = value
	value = sanitize_value(new_value, client)

	world.log << "[type] new value: [value]"

	if(old_value != value) // && client
		on_update(client, old_value)
		return TRUE

	return FALSE

// override if you need to trigger any special updates after value change (reload planes, update sound volume, etc.)
/datum/pref/proc/on_update(client/client, old_value)
	return FALSE
