// these settings are hidden from client
// for things that don't belong to player settings or character settings

// todo: pref/player/meta
/datum/pref/meta
	domain = PREF_DOMAIN_META

/datum/pref/meta/lastchangelog
	name = "lastchangelog"
	value = ""
	value_type = PREF_TYPE_TEXT

/datum/pref/meta/default_slot
	name = "default_slot"
	value = 1
	value_type = PREF_TYPE_CUSTOM

/datum/pref/meta/default_slot/sanitize_value(new_value, client/client)
	if(!client) // for automatic clientless updates in the future
		return 1

	return sanitize_integer(new_value, 1, GET_MAX_SAVE_SLOTS(client), initial(new_value))

/datum/pref/meta/random_slot
	name = "random_slot"
	value = FALSE
	value_type = PREF_TYPE_BOOLEAN
