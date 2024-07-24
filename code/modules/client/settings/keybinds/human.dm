/datum/pref/keybinds/human
	category = PREF_KEYBINDS_HUMAN
	weight = WEIGHT_MOB

/datum/pref/keybinds/human/can_use(client/user)
	return ishuman(user.mob)

/datum/pref/keybinds/human/quick_equip
	name = "Quick Equip"
	description = "Quickly puts an item in the best slot available"
	value = "E"

	legacy_keyname = "quick_equip"

/datum/pref/keybinds/human/quick_equip/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.quick_equip()
	return TRUE

/datum/pref/keybinds/human/holster
	name = "Holster"
	description = "Draw or holster weapon."
	value = "H"

	legacy_keyname = "holster"

/datum/pref/keybinds/human/holster/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.holster_weapon()

/datum/pref/keybinds/human/emote_panel
	name = "Emote Panel"
	description = "Shows you emote panel."
	value = "J"

	legacy_keyname = "emote_panel"

/datum/pref/keybinds/human/emote_panel/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.emote_panel()

/datum/pref/keybinds/human/leap
	name = "Leap Switch"
	description = "Switches leap mode."
	value = "U"

	legacy_keyname = "leap"

/datum/pref/keybinds/human/leap/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.switch_leap()
