/datum/pref/keybinds/admin
	category = PREF_KEYBINDS_CLIENT
	weight = WEIGHT_ADMIN

	admins_only = TRUE

/datum/pref/keybinds/admin/can_use(client/user)
	return user.holder ? TRUE : FALSE

/datum/pref/keybinds/admin/admin_say
	name = "Admin say"
	description = "Talk with other admins."
	value = "F5"

	legacy_keyname = "admin_say"

/datum/pref/keybinds/admin/admin_say/down(client/user)
	user.get_admin_say()
	return TRUE

/datum/pref/keybinds/admin/admin_ghost
	name = "Aghost"
	description = "Go ghost"

	legacy_keyname = "admin_ghost"

/datum/pref/keybinds/admin/admin_ghost/down(client/user)
	user.admin_ghost()
	return TRUE

/datum/pref/keybinds/admin/player_panel_new
	name = "Player Panel New"
	description = "Opens up the new player panel"
	value = "F6"

	legacy_keyname = "player_panel_new"

/datum/pref/keybinds/admin/player_panel_new/down(client/user)
	user.holder.player_panel_new()
	return TRUE

/datum/pref/keybinds/admin/toggle_buildmode_self
	name = "Toggle Buildmode Self"
	description = "Toggles buildmode"
	value = "F7"

	legacy_keyname = "toggle_buildmode_self"

/datum/pref/keybinds/admin/toggle_buildmode_self/down(client/user)
	user.togglebuildmodeself()
	return TRUE

/datum/pref/keybinds/admin/stealthmode
	name = "Stealth mode"
	description = "Enters stealth mode"
	value = "Ctrl+F8"

	legacy_keyname = "stealth_mode"

/datum/pref/keybinds/admin/stealthmode/down(client/user)
	user.stealth()
	return TRUE

/datum/pref/keybinds/admin/invisimin
	name = "Admin invisibility"
	description = "Toggles ghost-like invisibility (Don't abuse this)"
	value = "F8"

	legacy_keyname = "invisimin"

/datum/pref/keybinds/admin/invisimin/down(client/user)
	user.invisimin()
	return TRUE

/datum/pref/keybinds/admin/deadsay
	name = "deadsay"
	description = "Allows you to send a message to dead chat"
	value = "F10"

	legacy_keyname = "dsay"

/datum/pref/keybinds/admin/deadsay/down(client/user)
	user.get_dead_say()
	return TRUE

/datum/pref/keybinds/admin/deadmin
	name = "Deadmin"
	description = "Shed your admin powers"

	legacy_keyname = "deadmin"

/datum/pref/keybinds/admin/deadmin/down(client/user)
	user.deadmin_self()
	return TRUE

/datum/pref/keybinds/admin/readmin
	name = "Readmin"
	description = "Regain your admin powers"

	legacy_keyname = "readmin"

/datum/pref/keybinds/admin/readmin/down(client/user)
	user.readmin_self()
	return TRUE

/datum/pref/keybinds/admin/toggle_combo_hud
	name = "Toggle Combo HUD"

	legacy_keyname = "toggle_combo_hud"

/datum/pref/keybinds/admin/toggle_combo_hud/down(client/user)
	user.toggle_combo_hud()
	return TRUE
