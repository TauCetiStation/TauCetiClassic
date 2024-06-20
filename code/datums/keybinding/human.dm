/datum/keybinding/human
	category = CATEGORY_HUMAN
	weight = WEIGHT_MOB

/datum/keybinding/human/can_use(client/user)
	return ishuman(user.mob)

/datum/keybinding/human/quick_equip
	hotkey_keys = list("E")
	name = "quick_equip"
	full_name = "Quick Equip"
	description = "Quickly puts an item in the best slot available"

/datum/keybinding/human/quick_equip/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.quick_equip()
	return TRUE

/datum/keybinding/human/holster
	hotkey_keys = list("H")
	name = "holster"
	full_name = "Holster"
	description = "Draw or holster weapon."

/datum/keybinding/human/holster/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.holster_weapon()

/datum/keybinding/human/emote_panel
	hotkey_keys = list("J")
	name = "emote_panel"
	full_name = "Emote Panel"
	description = "Shows you emote panel."

/datum/keybinding/human/emote_panel/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	H.emote_panel()

/datum/keybinding/human/leap
	hotkey_keys = list("U")
	name = "leap"
	full_name = "Leap Switch"
	description = "Switches leap mode."

/datum/keybinding/human/leap/down(client/user)
	var/mob/living/carbon/human/H = user.mob
	if(!HAS_TRAIT(H, TRAIT_CAN_LEAP))
		to_chat(H, "<span class='notice'>Вы не умеете прыгать!</span>")
		return
	switch(H.leap_mode)
		if(LEAP_MODE_OFF)
			to_chat(H, "<span class='notice'>Вы попытаетесь совершить прыжок.</span>")
			H.leap_mode = LEAP_MODE_ON
		else
			to_chat(H, "<span class='notice'>Вы не будете пытаться совершить прыжок.</span>")
			H.leap_mode = LEAP_MODE_OFF
