/mob/proc/add_to_hud(datum/hud/hud)
	return

/mob/living/add_to_hud(datum/hud/hud)
	hud.add_intents()
	hud.add_move_intent()
	hud.add_zone_sel()
	hud.add_pullin()
