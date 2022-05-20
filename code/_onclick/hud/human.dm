/datum/hud/proc/human_hud()
	var/mob/living/carbon/human/H = mymob

	add_intents()
	add_move_intent()
	add_hands()

	var/list/types = list(
		/atom/movable/screen/inventory/craft, // craft
		/atom/movable/screen/drop, // simple hotkeys
		/atom/movable/screen/inventory/swap/first,
		/atom/movable/screen/inventory/swap/second,
		/atom/movable/screen/resist,
		/atom/movable/screen/equip,
		/atom/movable/screen/complex/human, // hidden inventory
		/atom/movable/screen/inventory/id,	// visible inventory
		/atom/movable/screen/inventory/back,
		/atom/movable/screen/inventory/pocket1,
		/atom/movable/screen/inventory/pocket2,
		/atom/movable/screen/inventory/suit_storage,
		/atom/movable/screen/inventory/belt,
	)
	init_screens(types)

	add_throw_icon()
	add_internals()
	add_healths()
	add_health_doll()
	add_nutrition_icon()
	add_pullin()

	add_changeling()

	add_zone_sel()

	if(isanycop(H) || isanygangster(H))
		add_wanted_level()

	if(mymob.leap_icon)
		mymob.leap_icon.add_to_hud(src)

	add_gun_setting()


/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 0
	else
		client.screen -= hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 1
