/datum/pref/keybinds/carbon
	category = PREF_KEYBINDS_CARBON
	weight = WEIGHT_MOB

/datum/pref/keybinds/carbon/can_use(client/user)
	return iscarbon(user.mob)

/datum/pref/keybinds/carbon/toggle_throw_mode
	name = "Toggle throw mode"
	description = "Toggle throwing the current item or not."
	value = "R Southwest" // Southwest - PAGEDOWN

	legacy_keyname = "toggle_throw_mode"

/datum/pref/keybinds/carbon/toggle_throw_mode/down(client/user)
	var/mob/living/carbon/C = user.mob
	C.toggle_throw_mode()
	return TRUE


/datum/pref/keybinds/carbon/give
	name = "Give item"
	description = "Give the item you're currently holding"

	legacy_keyname = "Give_Item"

/datum/pref/keybinds/carbon/give/down(client/user)
	var/mob/living/carbon/C = user.mob
	C.give()
	return TRUE

/datum/pref/keybinds/carbon/crawl
	name = "Crawl"

	legacy_keyname = "crawl"

/datum/pref/keybinds/carbon/crawl/down(client/user)
	var/mob/living/carbon/C = user.mob
	C.crawl()
	return TRUE
