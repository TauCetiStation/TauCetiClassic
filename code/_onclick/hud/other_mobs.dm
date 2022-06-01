/mob/living/carbon/brain/add_to_hud(datum/hud/hud)
	return

/mob/camera/blob/add_to_hud(datum/hud/hud)
	hud.init_screens(list(
		/atom/movable/screen/blob_power,
	))
	hud.add_healths(/atom/movable/screen/health/blob)

/mob/living/parasite/essence/add_to_hud(datum/hud/hud)
	hud.init_screens(list(
		/atom/movable/screen/essence/voice,
		/atom/movable/screen/essence/phantom,
		
		/atom/movable/screen/essence/ling_abilities,
	))
	hud.add_internals()
	hud.add_healths()
	hud.add_health_doll()

	if(is_changeling)
		hud.init_screen(/atom/movable/screen/essence/return_to_body)
