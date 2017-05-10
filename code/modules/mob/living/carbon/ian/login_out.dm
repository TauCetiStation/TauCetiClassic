/mob/living/carbon/human/ian/Login()
	..()

	if(!is_alien_whitelisted(src, "ian"))
		return

	update_hud()

	universal_understand = TRUE
	unlock_mouth = TRUE

/mob/living/carbon/human/ian/Logout()
	..()
	universal_understand = FALSE
	unlock_mouth = FALSE
