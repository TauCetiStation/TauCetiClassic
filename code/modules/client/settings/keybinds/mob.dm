/datum/pref/keybinds/mob
	category = PREF_KEYBINDS_HUMAN
	weight = WEIGHT_MOB

/datum/pref/keybinds/mob/stop_pulling
	name = "Stop pulling"
	value = "Delete"

	legacy_keyname = "stop_pulling"

/datum/pref/keybinds/mob/stop_pulling/down(client/user)
	var/mob/M = user.mob
	if(!M.pulling)
		to_chat(user, "<span class='notice'>You are not pulling anything.</span>")
	else
		M.stop_pulling()
	return TRUE

/datum/pref/keybinds/mob/cycle_intent_right
	name = "Cycle intent right"
	value = "G Insert"

	legacy_keyname = "cycle_intent_right"

/datum/pref/keybinds/mob/cycle_intent_right/down(client/user)
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_RIGHT)
	return TRUE

/datum/pref/keybinds/mob/cycle_intent_left
	name = "Cycle intent left"
	value = "F"

	legacy_keyname = "cycle_intent_left"

/datum/pref/keybinds/mob/cycle_intent_left/down(client/user)
	var/mob/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE

/datum/pref/keybinds/mob/activate_inhand
	name = "Activate in-hand"
	description = "Uses whatever item you have inhand"
	value = "Z Y Southeast" // Southeast - PAGEDOWN

	legacy_keyname = "activate_inhand"

/datum/pref/keybinds/mob/activate_inhand/down(client/user)
	var/mob/M = user.mob
	M.mode()
	return TRUE

/datum/pref/keybinds/mob/target_head_cycle
	name = "Target: Cycle head"
	value = "Numpad8"

	legacy_keyname = "target_head_cycle"

/datum/pref/keybinds/mob/target_head_cycle/down(client/user)
	user.body_toggle_head()
	return TRUE

/datum/pref/keybinds/mob/target_r_arm
	name = "Target: right arm"
	value = "Numpad4"

	legacy_keyname = "target_r_arm"

/datum/pref/keybinds/mob/target_r_arm/down(client/user)
	user.body_r_arm()
	return TRUE

/datum/pref/keybinds/mob/target_body_chest
	name = "Target: Body"
	value = "Numpad5"

	legacy_keyname = "target_body_chest"

/datum/pref/keybinds/mob/target_body_chest/down(client/user)
	user.body_chest()
	return TRUE

/datum/pref/keybinds/mob/target_left_arm
	name = "Target: left arm"
	value = "Numpad6"

	legacy_keyname = "target_left_arm"

/datum/pref/keybinds/mob/target_left_arm/down(client/user)
	user.body_l_arm()
	return TRUE

/datum/pref/keybinds/mob/target_right_leg
	name = "Target: Right leg"
	value = "Numpad1"

	legacy_keyname = "target_right_leg"

/datum/pref/keybinds/mob/target_right_leg/down(client/user)
	user.body_r_leg()
	return TRUE

/datum/pref/keybinds/mob/target_body_groin
	name = "Target: Groin"
	value = "Numpad2"

	legacy_keyname = "target_body_groin"

/datum/pref/keybinds/mob/target_body_groin/down(client/user)
	user.body_groin()
	return TRUE

/datum/pref/keybinds/mob/target_left_leg
	name = "Target: left leg"
	value = "Numpad3"

	legacy_keyname = "target_left_leg"

/datum/pref/keybinds/mob/target_left_leg/down(client/user)
	user.body_l_leg()
	return TRUE

/datum/pref/keybinds/mob/prevent_movement
	name = "Block movement"
	description = "Prevents you from moving"
	value = "Ctrl"

	legacy_keyname = "block_movement"

/datum/pref/keybinds/mob/prevent_movement/down(client/user)
	user.movement_locked = TRUE

/datum/pref/keybinds/mob/prevent_movement/up(client/user)
	user.movement_locked = FALSE

/datum/pref/keybinds/mob/click_on_self
	name = "Click On Self"
	value = "B"

	legacy_keyname = "click_on_self"

/datum/pref/keybinds/mob/click_on_self/down(client/user)
	var/mob/M = user.mob
	M.click_on_self()
