/datum/keybinding/carbon
	category = CATEGORY_CARBON
	weight = WEIGHT_MOB

/datum/keybinding/carbon/can_use(client/user)
	return iscarbon(user.mob)

/datum/keybinding/carbon/toggle_throw_mode
	hotkey_keys = list("R", "Southwest") // PAGEDOWN
	name = "toggle_throw_mode"
	full_name = "Toggle throw mode"
	description = "Toggle throwing the current item or not."

/datum/keybinding/carbon/toggle_throw_mode/down(client/user)
	var/mob/living/carbon/C = user.mob
	C.toggle_throw_mode()
	return TRUE


/datum/keybinding/carbon/give
	hotkey_keys = list("None")
	name = "Give_Item"
	full_name = "Give item"
	description = "Give the item you're currently holding"

/datum/keybinding/carbon/give/down(client/user)
	var/mob/living/carbon/C = user.mob
	C.give()
	return TRUE


/datum/keybinding/carbon/crawl
	hotkey_keys = list("None")
	name = "crawl"
	full_name = "Crawl"
	description = ""

/datum/keybinding/carbon/crawl/down(client/user)
	var/mob/living/carbon/C = user.mob
	C.crawl()
	return TRUE
