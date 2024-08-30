// even tho keybinds prefs domain are part compatible with other pref types, using this in mix was not planed first
// should be ok, but need to keep it in mind while working with keybinds
/datum/pref/keybinds/emote_select
	category = PREF_KEYBINDS_EMOTE
	weight = WEIGHT_MOB
	value_type = PREF_TYPE_SELECT
	value = "None"

/datum/pref/keybinds/emote_select/New()
	// will use all currently existing emotes keys in build as possible values
	// prefs automatically fallback to default if value is not valid anymore
	var/static/list/possible_values
	if(!possible_values)
		possible_values = list("None") + global.all_emotes_keys // all datums reference one static value instead of list per datum
	value_parameters = possible_values

/datum/pref/keybinds/emote_key
	category = PREF_KEYBINDS_EMOTE
	weight = WEIGHT_MOB

	var/emote_pref_type

/datum/pref/keybinds/emote_key/down(client/user)
	var/emote = user.prefs.prefs_keybinds[emote_pref_type].value
	if(emote == "None")
		return
	user.mob.emote(emote, intentional = TRUE, fallback_notice = TRUE)

// copypaste below

/datum/pref/keybinds/emote_select/num_1
	name = "Emote 1"

/datum/pref/keybinds/emote_key/num_1
	name = "Emote key 1"
	emote_pref_type = /datum/pref/keybinds/emote_select/num_1

/datum/pref/keybinds/emote_select/num_2
	name = "Emote 2"

/datum/pref/keybinds/emote_key/num_2
	name = "Emote key 2"
	emote_pref_type = /datum/pref/keybinds/emote_select/num_2

/datum/pref/keybinds/emote_select/num_3
	name = "Emote 3"

/datum/pref/keybinds/emote_key/num_3
	name = "Emote key 3"
	emote_pref_type = /datum/pref/keybinds/emote_select/num_3

/datum/pref/keybinds/emote_select/num_4
	name = "Emote 4"

/datum/pref/keybinds/emote_key/num_4
	name = "Emote key 4"
	emote_pref_type = /datum/pref/keybinds/emote_select/num_4

/datum/pref/keybinds/emote_select/num_5
	name = "Emote 5"

/datum/pref/keybinds/emote_key/num_5
	name = "Emote key 5"
	emote_pref_type = /datum/pref/keybinds/emote_select/num_5
