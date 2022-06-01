/mob/proc/add_to_hud(datum/hud/hud)
	return

/mob/living/add_to_hud(datum/hud/hud)
	hud.init_screens(list(
		/atom/movable/screen/complex/act_intent,
		/atom/movable/screen/move_intent,
		/atom/movable/screen/zone_sel,
		/atom/movable/screen/pull,
	))
