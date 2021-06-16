// Set a client's focus to an object and override these procs on that object to let it handle keypresses

/datum/proc/key_down(key, client/user) // Called when a key is pressed down initially
	return
/datum/proc/key_up(key, client/user) // Called when a key is released
	return
/datum/proc/keyLoop(client/user) // Called once every frame
	set waitfor = FALSE
	return

/client/proc/set_macros()
	set waitfor = FALSE

	//Reset the buffer
	reset_held_keys()

	erase_all_macros()

	var/list/macro_set = SSinput.macro_set
	for(var/k in 1 to length(macro_set))
		var/key = macro_set[k]
		var/command = macro_set[key]
		winset(src, "default-\ref[key]", "parent=default;name=[key];command=[command]")

	winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED]")

	update_special_keybinds()

/**
 * Manually clears any held keys, in case due to lag or other undefined behavior a key gets stuck.
 *
 * Hardcoded to the ESC key.
 */
/client/verb/reset_held_keys()
	set name = "Reset Held Keys"
	set hidden = TRUE

	for(var/key in keys_held)
		keyUp(key)

	//In case one got stuck and the previous loop didn't clean it, somehow.
	for(var/key in key_combos_held)
		keyUp(key_combos_held[key])

// removes all the existing macros
/client/proc/erase_all_macros()
	var/erase_output = ""
	var/list/macro_set = params2list(winget(src, "default.*", "command")) // The third arg doesnt matter here as we're just removing them all
	for(var/k in 1 to length(macro_set))
		var/list/split_name = splittext(macro_set[k], ".")
		var/macro_name = "[split_name[1]].[split_name[2]]" // [3] is "command"
		erase_output = "[erase_output];[macro_name].parent=null"
	winset(src, null, erase_output)

