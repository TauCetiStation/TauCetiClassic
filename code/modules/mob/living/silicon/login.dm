/mob/living/silicon/Login()
	..()
	if(mind && SSticker && SSticker.mode)
		SSticker.mode.remove_cultist(mind)
		SSticker.mode.remove_revolutionary(mind, TRUE)
		SSticker.mode.remove_gangster(mind, TRUE)
	for(var/obj/effect/rune/R in cult_runes)
		client.images += R.blood_overlay
