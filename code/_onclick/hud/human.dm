/datum/hud/proc/human_hud()
	var/mob/living/carbon/human/H = mymob

	add_intents()
	add_move_intent()
	get_screen(/atom/movable/screen/inventory/craft)

	// hiddable inventory
	get_screen(/atom/movable/screen/complex/human)

	add_hands()

	// simple hotkeys
	var/list/types = list(
		/atom/movable/screen/drop,
		/atom/movable/screen/inventory/swap/first,
		/atom/movable/screen/inventory/swap/second,
		/atom/movable/screen/resist,
		/atom/movable/screen/equip,
	)
	init_screens(types)

	// visible inventory, inventory toggle and craft
	types = list(
		/atom/movable/screen/inventory/id,
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

	mymob.pain = new /atom/movable/screen( null )

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
