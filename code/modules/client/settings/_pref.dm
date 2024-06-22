/datum/pref
	// related to json name (or table in DB)
	var/domain // player | character | keybinds | meta 
	// first key in JSON and category name in menu
	var/category
	// second key in JSON and option name in menu
	var/key

	var/name

	var/description

	// value and also default value with initial()
	var/value

	// for frontend
	var/value_type // = COLOR | NUMBER | LIST | BOOLEAN | TEXT
	// ambivalent value depending on value_type
	// For PREF_TYPE_RANGE it's list(min, max, step (optional), unit (optional))
	// For PREF_TYPE_SELECT it's list(value, value, value) or list(value = "human name", value = "human name", value = "human name")
	// todo TEXT min max
	// not used for other types
	var/list/value_parameters


// валидация значения - по типу?

// todo:
// /datum/pref/character
// 	type = "character"

// default sanitize procedures, override it if you need something more
/datum/pref/proc/sanitize_value(new_value)
	PRIVATE_PROC(TRUE)

	world.log << "SANITIZE: [new_value], | type: [value_type] | params: [json_encode(value_parameters)] | default: [initial(value)] | current: [value]"
	// todo: warning if reset happened
	switch(value_type)
		//if(PREF_TYPE_TEXT)
		if(PREF_TYPE_RANGE)
			. = sanitize_integer(new_value, value_parameters[1], value_parameters[2], initial(value))
		if(PREF_TYPE_SELECT)
			. = sanitize_inlist(new_value, value_parameters, initial(value))
		if(PREF_TYPE_HEX)
			. = sanitize_hexcolor(new_value, initial(value))
		if(PREF_TYPE_BOOLEAN)
			. = !!new_value
		else
			CRASH("Not implemented sanitize for [src.type]!")

/*	if(!.)
		stack_trace("Reset at")
		. = initial(value)
*/

	return .

/datum/pref/proc/update_value(new_value, client/client)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/old_value = value
	value = sanitize_value(new_value)

	world.log << "[type] new value: [value]"

	if(old_value != value)
		on_update(client, old_value)
		return TRUE

	return FALSE

// override if you need to trigger any special updates after setting changed (reload planes, update sound volume, etc.)
/datum/pref/proc/on_update(client/client, old_value) // apply_change
	PRIVATE_PROC(TRUE)

	return FALSE
