/mob/living/carbon/monkey/add_to_hud(datum/hud/hud)
	..(hud, FALSE)

	hud.init_screens(list(
		/atom/movable/screen/inventory/hand/r,
		/atom/movable/screen/inventory/hand/l,
		/atom/movable/screen/drop,
		/atom/movable/screen/swap/first,
		/atom/movable/screen/swap/second,
		/atom/movable/screen/equip,
		/atom/movable/screen/throw,
		/atom/movable/screen/inventory/mask/monkey,
		/atom/movable/screen/inventory/back,
		/atom/movable/screen/complex/gun,
		/atom/movable/screen/internal,
		/atom/movable/screen/health
	))
