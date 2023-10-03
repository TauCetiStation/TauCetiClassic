
/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/resist
	hotkey_keys = list("N")
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffed? On fire? Resist!"

/datum/keybinding/living/resist/down(client/user)
	var/mob/living/L = user.mob
	L.resist()
	return TRUE

/datum/keybinding/living/toggle_move_intent
	hotkey_keys = list("C")
	name = "toggle_move_intent"
	full_name = "Hold to toggle move intent"
	description = "Held down to cycle to the other move intent, release to cycle back"

/datum/keybinding/living/toggle_move_intent/down(client/user)
	var/mob/living/L = user.mob
	L.set_m_intent(L.m_intent == MOVE_INTENT_WALK ? MOVE_INTENT_RUN : MOVE_INTENT_WALK)
	return TRUE

/datum/keybinding/living/toggle_move_intent/up(client/user)
	var/mob/living/L = user.mob
	L.set_m_intent(L.m_intent == MOVE_INTENT_WALK ? MOVE_INTENT_RUN : MOVE_INTENT_WALK)
	return TRUE

/datum/keybinding/living/drop_item
	hotkey_keys = list("Q", "Northwest") // HOME
	name = "drop_item"
	full_name = "Drop Item"
	description = ""

/datum/keybinding/living/drop_item/down(client/user)
	var/mob/living/L = user.mob
	L.drop_item()
	return TRUE

/datum/keybinding/living/crawl
	hotkey_keys = list("None")
	name = "crawl"
	full_name = "Crawl"
	description = "You lay down/get up"

/datum/keybinding/living/crawl/down(client/user)
	var/mob/living/L = user.mob
	L.crawl()
	return TRUE

/datum/keybinding/living/swap_hands
	hotkey_keys = list("X", "Northeast") // PAGEUP
	name = "swap_hands"
	full_name = "Swap hands"
	description = ""

/datum/keybinding/living/swap_hands/down(client/user)
	var/mob/living/L = user.mob
	L.swap_hand()
	return TRUE

/datum/keybinding/living/select_help_intent
	hotkey_keys = list("1")
	name = "select_help_intent"
	full_name = "Select help intent"
	description = ""

/datum/keybinding/living/select_help_intent/down(client/user)
	if(issilicon(user.mob))
		return
	user.mob?.a_intent_change(INTENT_HELP)
	return TRUE

/datum/keybinding/living/select_disarm_intent
	hotkey_keys = list("2")
	name = "select_push_intent"
	full_name = "Select push intent"
	description = ""

/datum/keybinding/living/select_disarm_intent/down(client/user)
	if(issilicon(user.mob))
		return
	user.mob?.a_intent_change(INTENT_PUSH)
	return TRUE

/datum/keybinding/living/select_grab_intent
	hotkey_keys = list("3")
	name = "select_grab_intent"
	full_name = "Select grab intent"
	description = ""

/datum/keybinding/living/select_grab_intent/down(client/user)
	if(issilicon(user.mob))
		return
	user.mob?.a_intent_change(INTENT_GRAB)
	return TRUE

/datum/keybinding/living/select_harm_intent
	hotkey_keys = list("4")
	name = "select_harm_intent"
	full_name = "Select harm intent"
	description = ""

/datum/keybinding/living/select_harm_intent/down(client/user)
	if(issilicon(user.mob))
		return
	user.mob?.a_intent_change(INTENT_HARM)
	return TRUE
