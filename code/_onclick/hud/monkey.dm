/datum/hud/proc/monkey_hud()
	add_intents()
	add_move_intent()
	add_hands()

	// hotkeys
	var/types = list(
		/atom/movable/screen/drop,
		/atom/movable/screen/inventory/swap/first,
		/atom/movable/screen/inventory/swap/second,
	)
	init_screens(types)

	// inventory
	types = list(
		/atom/movable/screen/inventory/mask/monkey,
		/atom/movable/screen/inventory/back,
	)
	init_screens(types)

	add_throw_icon()
	add_internals()
	add_healths()
	add_pullin()
	add_changeling()
	add_zone_sel()
	add_gun_setting()
