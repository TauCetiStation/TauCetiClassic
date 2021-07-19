/datum/keybinding/client
	category = CATEGORY_CLIENT
	weight = WEIGHT_HIGHEST


/datum/keybinding/client/admin_help
	hotkey_keys = list("F1")
	name = "admin_help"
	full_name = "Admin Help"
	description = "Ask an admin for help."

/datum/keybinding/client/admin_help/down(client/user)
	user.adminhelp()
	return TRUE

/datum/keybinding/client/mentor_help
	hotkey_keys = list("F9")
	name = "mentor_help"
	full_name = "Mentor Help"
	description = "Ask an mentors for help."

/datum/keybinding/client/mentor_help/down(client/user)
	user.get_mentorhelp()
	return TRUE

/datum/keybinding/client/screenshot
	hotkey_keys = list("None")
	name = "screenshot"
	full_name = "Screenshot"
	description = "Take a screenshot."

/datum/keybinding/client/screenshot/down(client/user)
	winset(user, null, "command=.screenshot [!user.keys_held["shift"] ? "auto" : ""]")
	return TRUE

/datum/keybinding/client/minimal_hud
	hotkey_keys = list("F12")
	name = "minimal_hud"
	full_name = "Minimal HUD"
	description = "Hide most HUD features"

/datum/keybinding/client/minimal_hud/down(client/user)
	user.mob.button_pressed_F12()
	return TRUE

/datum/keybinding/client/toggle_fullscreen
	hotkey_keys = list("F11")
	name = "toggle_fullscreen"
	full_name = "Toggle Fullscreen"
	description = "Toggle Fullscreen"

/datum/keybinding/client/toggle_fullscreen/down(client/user)
	user.toggle_fullscreen()
	return TRUE
