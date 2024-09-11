/mob/living/carbon/brain/add_to_hud(datum/hud/hud)
	hud.init_screen(/atom/movable/screen/health/living)

/mob/living/parasite/essence/add_to_hud(datum/hud/hud)
	hud.init_screens(list(
		/atom/movable/screen/essence/voice,
		/atom/movable/screen/essence/phantom,
		/atom/movable/screen/health,
		/atom/movable/screen/health_doll,
		/atom/movable/screen/essence/ling_abilities,
	))

	if(is_changeling)
		hud.init_screen(/atom/movable/screen/essence/return_to_body)
