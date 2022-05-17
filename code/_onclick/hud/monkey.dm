/datum/hud/proc/monkey_hud()
	add_intents(ui_style)
	add_move_intent(ui_style)
	add_hands(ui_style)

	// hotkeys
	var/types = list(
		/atom/movable/screen/drop,
		/atom/movable/screen/inventory/swap/first,
		/atom/movable/screen/inventory/swap/second,
	)
	init_screens(types, ui_style, list_to = hotkeybuttons)

	// inventory
	types = list(
		/atom/movable/screen/inventory/mask/monkey,
		/atom/movable/screen/inventory/back,
	)
	init_screens(types, ui_style, list_to = adding)

	add_throw_icon(ui_style)
	add_internals(ui_style)
	add_healths(ui_style)
	add_pullin(ui_style)
	add_changeling()
	add_zone_sel(ui_style)
	add_gun_setting()
