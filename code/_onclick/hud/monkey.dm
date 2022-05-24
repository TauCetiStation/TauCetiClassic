/datum/hud/proc/monkey_hud()
	default_hud()
	add_hands()

	var/types = list(
		/atom/movable/screen/drop, // hotkeys
		/atom/movable/screen/inventory/swap/first,
		/atom/movable/screen/inventory/swap/second,
		/atom/movable/screen/equip,
		/atom/movable/screen/inventory/mask/monkey, // inventory
		/atom/movable/screen/inventory/back,
	)
	init_screens(types)

	add_throw_icon()
	add_internals()
	add_healths()
	add_gun_setting()
