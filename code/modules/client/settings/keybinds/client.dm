/datum/pref/keybinds/client
	category = PREF_KEYBINDS_CLIENT
	weight = WEIGHT_HIGHEST

/datum/pref/keybinds/client/screenshot
	name = "Screenshot"
	description = "Take a screenshot."

	legacy_keyname = "screenshot"

/datum/pref/keybinds/client/screenshot/down(client/user)
	winset(user, null, "command=.screenshot [!user.keys_held["shift"] ? "auto" : ""]")
	return TRUE

/datum/pref/keybinds/client/minimal_hud
	name = "Minimal HUD"
	description = "Hide most HUD features"
	value = "F12"

	legacy_keyname = "minimal_hud"

/datum/pref/keybinds/client/minimal_hud/down(client/user)
	user.mob.button_pressed_F12()
	return TRUE

/datum/pref/keybinds/client/toggle_fullscreen
	name = "Toggle Fullscreen"
	description = "Toggle Fullscreen"
	value = "F11"

	legacy_keyname = "toggle_fullscreen"

/datum/pref/keybinds/client/toggle_fullscreen/down(client/user)
	user.toggle_fullscreen()
	return TRUE
