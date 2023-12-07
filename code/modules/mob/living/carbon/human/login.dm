/mob/living/carbon/human/Login()
	..()
	update_hud()
	if(HAS_TRAIT(src, TRAIT_RANDOM_CLIENT_DIR))
		client.dir = pick(2, 4, 8)
	return
