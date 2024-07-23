/datum/pref/keybinds/communication
	category = PREF_KEYBINDS_COMMUNICATION
	weight = WEIGHT_HIGHEST

/datum/pref/keybinds/communication/admin_help
	name = "Admin Help"
	description = "Ask an admin for help."
	value = "F1"

	legacy_keyname = "admin_help"

/datum/pref/keybinds/communication/admin_help/down(client/user)
	user.adminhelp()
	return TRUE

/datum/pref/keybinds/communication/mentor_help
	name = "Mentor Help"
	description = "Ask an mentors for help."
	value = "F9"

	legacy_keyname = "mentor_help"

/datum/pref/keybinds/communication/mentor_help/down(client/user)
	user.get_mentorhelp()
	return TRUE

/datum/pref/keybinds/communication/say
	name = "IC Say"
	value = "F3 T"

	legacy_keyname = "Say"

/datum/pref/keybinds/communication/say/down(client/user)
	user.mob.say_wrapper()
	return TRUE

/datum/pref/keybinds/communication/ooc
	name = "Out Of Character Say (OOC)"
	value = "F2 O"

	legacy_keyname = "OOC"

/datum/pref/keybinds/communication/ooc/down(client/user)
	user.ooc_wrapper()
	return TRUE

/datum/pref/keybinds/communication/looc
	name = "Local Out Of Character Say (LOOC)"
	value = "L"

	legacy_keyname = "LOOC"

/datum/pref/keybinds/communication/looc/down(client/user)
	user.looc_wrapper()
	return TRUE

/datum/pref/keybinds/communication/me
	name = "Custom Emote (/Me)"
	value = "F4 M"

	legacy_keyname = "Me"

/datum/pref/keybinds/communication/me/down(client/user)
	user.mob.me_wrapper()
	return TRUE
