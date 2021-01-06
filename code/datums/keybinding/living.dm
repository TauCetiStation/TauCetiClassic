
/datum/keybinding/living
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/living/can_use(client/user)
	return isliving(user.mob)

/datum/keybinding/living/resist
	hotkey_keys = list("B")
	name = "resist"
	full_name = "Resist"
	description = "Break free of your current state. Handcuffed? on fire? Resist!"

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
	hotkey_keys = list("Q")
	name = "drop_item"
	full_name = "Drop Item"
	description = ""

/datum/keybinding/living/drop_item/down(client/user)
	if(isrobot(user.mob)) //cyborgs can't drop items
		return FALSE
	var/mob/living/L = user.mob
	if(!L.get_active_hand() && !L.drop_combo_element())
		to_chat(user, "<span class='warning'>You have nothing to drop in your hand!</span>")
	else
		L.drop_item()
	return TRUE
