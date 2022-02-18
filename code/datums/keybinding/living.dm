
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

/datum/keybinding/living/rest
	hotkey_keys = list("None")
	name = "rest"
	full_name = "Rest"
	description = "You lay down/get up"

/datum/keybinding/living/rest/down(client/user)
	var/mob/living/L = user.mob
	L.lay_down()
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
