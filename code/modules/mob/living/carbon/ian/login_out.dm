/mob/living/carbon/ian/Login()
	..()

	if(!(is_alien_whitelisted(src, "ian") || (client.supporter && !is_alien_whitelisted_banned(src, "ian"))))
		return

	update_hud()

	universal_understand = TRUE
	unlock_mouth = TRUE

/mob/living/carbon/ian/Logout()
	..()
	universal_understand = FALSE
	unlock_mouth = FALSE
