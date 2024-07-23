/datum/pref/keybinds/robot
	category = PREF_KEYBINDS_ROBOT
	weight = WEIGHT_ROBOT

/datum/pref/keybinds/robot/can_use(client/user)
	return isrobot(user.mob)

/datum/pref/keybinds/robot/moduleone
	name = "Toggle module 1"
	description = "Equips or unequips the first module"
	value = "1"

	legacy_keyname = "module_one"

/datum/pref/keybinds/robot/moduleone/down(client/user)
	var/mob/living/silicon/robot/R = user.mob
	R.toggle_module(1)
	return TRUE

/datum/pref/keybinds/robot/moduletwo
	name = "Toggle module 2"
	description = "Equips or unequips the second module"
	value = "2"

	legacy_keyname = "module_two"

/datum/pref/keybinds/robot/moduletwo/down(client/user)
	var/mob/living/silicon/robot/R = user.mob
	R.toggle_module(2)
	return TRUE

/datum/pref/keybinds/robot/modulethree
	name = "Toggle module 3"
	description = "Equips or unequips the third module"
	value = "3"

	legacy_keyname = "module_three"

/datum/pref/keybinds/robot/modulethree/down(client/user)
	var/mob/living/silicon/robot/R = user.mob
	R.toggle_module(3)
	return TRUE

/datum/pref/keybinds/robot/intent_cycle
	name = "Cycle intent left"
	description = "Cycles the intent left"
	value = "4"

	legacy_keyname = "cycle_intent"

/datum/pref/keybinds/robot/intent_cycle/down(client/user)
	var/mob/living/silicon/robot/R = user.mob
	R.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE

/datum/pref/keybinds/robot/unequip_module
	name = "Unequip module"
	description = "Unequips the active module"
	value = "Q"

	legacy_keyname = "unequip_module"

/datum/pref/keybinds/robot/unequip_module/down(client/user)
	var/mob/living/silicon/robot/R = user.mob
	if(R.module)
		R.uneq_active()
	return TRUE
