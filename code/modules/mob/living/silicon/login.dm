/mob/living/silicon/Login()
	..()
	if(mind && ticker && ticker.mode)
		ticker.mode.remove_cultist(mind)
		ticker.mode.remove_revolutionary(mind, TRUE)
		ticker.mode.remove_gangster(mind, TRUE)
	for(var/obj/effect/rune/R in cult_runes)
		client.images += R.blood_overlay
