/datum/pref/keybinds/living
	category = PREF_KEYBINDS_HUMAN
	weight = WEIGHT_MOB

/datum/pref/keybinds/living/can_use(client/user)
	return isliving(user.mob)

/datum/pref/keybinds/living/resist
	name = "Resist"
	description = "Break free of your current state. Handcuffed? On fire? Resist!"
	value = "N"

	legacy_keyname = "resist"

/datum/pref/keybinds/living/resist/down(client/user)
	var/mob/living/L = user.mob
	L.resist()
	return TRUE

/datum/pref/keybinds/living/toggle_move_intent
	name = "Hold to toggle move intent"
	description = "Held down to cycle to the other move intent, release to cycle back"
	value = "C"

	legacy_keyname = "toggle_move_intent"

/datum/pref/keybinds/living/toggle_move_intent/down(client/user)
	var/mob/living/L = user.mob
	L.set_m_intent(L.m_intent == MOVE_INTENT_WALK ? MOVE_INTENT_RUN : MOVE_INTENT_WALK)
	return TRUE

/datum/pref/keybinds/living/toggle_move_intent/up(client/user)
	var/mob/living/L = user.mob
	L.set_m_intent(L.m_intent == MOVE_INTENT_WALK ? MOVE_INTENT_RUN : MOVE_INTENT_WALK)
	return TRUE

/datum/pref/keybinds/living/drop_item
	name = "Drop Item"
	value = "Q Northwest" // Northwest - HOME

	legacy_keyname = "drop_item"

/datum/pref/keybinds/living/drop_item/down(client/user)
	var/mob/living/L = user.mob
	L.drop_item()
	return TRUE

/datum/pref/keybinds/living/crawl
	name = "Crawl"
	description = "You lay down/get up"

	legacy_keyname = "crawl"

/datum/pref/keybinds/living/crawl/down(client/user)
	var/mob/living/L = user.mob
	L.crawl()
	return TRUE

/datum/pref/keybinds/living/swap_hands
	name = "Swap hands"
	value = "X Northeast" // Northeast - PAGEUP

	legacy_keyname = "swap_hands"

/datum/pref/keybinds/living/swap_hands/down(client/user)
	var/mob/living/L = user.mob
	L.swap_hand()
	return TRUE

/datum/pref/keybinds/living/select_help_intent
	name = "Select help intent"
	value = "1"

	legacy_keyname = "select_help_intent"

/datum/pref/keybinds/living/select_help_intent/down(client/user)
	if(issilicon(user.mob))
		return
	user.mob?.a_intent_change(INTENT_HELP)
	return TRUE

/datum/pref/keybinds/living/select_disarm_intent
	name = "Select push intent"
	value = "2"

	legacy_keyname = "select_push_intent"

/datum/pref/keybinds/living/select_disarm_intent/down(client/user)
	if(issilicon(user.mob))
		return
	user.mob?.a_intent_change(INTENT_PUSH)
	return TRUE

/datum/pref/keybinds/living/select_grab_intent
	name = "Select grab intent"
	value = "3"

	legacy_keyname = "select_grab_intent"

/datum/pref/keybinds/living/select_grab_intent/down(client/user)
	if(issilicon(user.mob))
		return
	user.mob?.a_intent_change(INTENT_GRAB)
	return TRUE

/datum/pref/keybinds/living/select_harm_intent
	name = "Select harm intent"
	value = "4"

	legacy_keyname = "select_harm_intent"

/datum/pref/keybinds/living/select_harm_intent/down(client/user)
	if(issilicon(user.mob))
		return
	user.mob?.a_intent_change(INTENT_HARM)
	return TRUE
