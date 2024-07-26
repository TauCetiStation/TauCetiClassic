// for special cases where we handle some prefs differently
// these settings are hidden from client settings menu

/datum/pref/player/meta

/datum/pref/player/meta/lastchangelog
	name = "lastchangelog"
	value = ""
	value_type = PREF_TYPE_TEXT

/datum/pref/player/meta/default_slot
	name = "default_slot"
	value = 1
	value_type = PREF_TYPE_CUSTOM

/datum/pref/player/meta/default_slot/sanitize_value(new_value, client/client)
	if(!client) // for automatic clientless updates in the future
		return 1

	return sanitize_integer(new_value, 1, GET_MAX_SAVE_SLOTS(client), initial(new_value))

/datum/pref/player/meta/random_slot
	name = "random_slot"
	value = FALSE
	value_type = PREF_TYPE_BOOLEAN
