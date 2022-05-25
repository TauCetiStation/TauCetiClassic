/mob/living/carbon/brain/add_to_hud(datum/hud/hud)
	return

/mob/camera/blob/add_to_hud(datum/hud/hud)
	hud.add_pwr_display(/atom/movable/screen/blob_power)
	hud.add_healths(/atom/movable/screen/blob_health)

/mob/living/parasite/essence/add_to_hud(datum/hud/hud)
	hud.add_essence_voice()
	hud.add_phantom()
	hud.add_internals()
	hud.add_healths()
	hud.add_health_doll()
	hud.init_screen(/atom/movable/screen/essence/ling_abilities)

	if(is_changeling)
		hud.init_screen(/atom/movable/screen/essence/return_to_body)
