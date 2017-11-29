/mob/living/carbon/ian/Login()
	..()

	if(!is_alien_whitelisted(src, "ian") || (config.allow_donators && client.donator))
		return

	update_hud()

	universal_understand = TRUE
	unlock_mouth = TRUE

/mob/living/carbon/ian/Logout()
	..()
	universal_understand = FALSE
	unlock_mouth = FALSE
