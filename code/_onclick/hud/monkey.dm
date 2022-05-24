/mob/living/carbon/monkey/add_to_hud(datum/hud/hud)
	..()
	hud.add_hands()

	hud.init_screens(list(
		/atom/movable/screen/drop,
		/atom/movable/screen/inventory/swap/first,
		/atom/movable/screen/inventory/swap/second,
		/atom/movable/screen/equip,
		/atom/movable/screen/inventory/mask/monkey,
		/atom/movable/screen/inventory/back,
	))

	hud.add_throw_icon()
	hud.add_internals()
	hud.add_healths()
	hud.add_gun_setting()
