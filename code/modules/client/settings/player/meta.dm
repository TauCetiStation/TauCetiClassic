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

// i don't want to create pref for every emote, and don't want to update prefs with any changes to emotes / emote panel
// emotes in panel are opt-out so this is a list of disabled emotes for the emote panel, empty by default,
// and we don't need to touch this in the future - sanitize will update it with any changes
//
// i don't like how this looks, but i have no better idea how to rewrite it
/datum/pref/player/meta/disabled_emotes_emote_panel
	name = "disabled_emotes"
	value = ""
	value_type = PREF_TYPE_CUSTOM

/datum/pref/player/meta/disabled_emotes_emote_panel/sanitize_value(new_value, client/client)
	var/list/new_list
	if(islist(new_value))
		new_list = new_value
	else
		new_list = params2list(new_value)

	if(!length(new_list))
		return ""

	var/list/valid_emotes
	// clean any not valid (probably removed) emotes
	for(var/emote in new_list)
		if(emote in global.emotes_for_emote_panel)
			valid_emotes += emote

	return list2params(valid_emotes)
