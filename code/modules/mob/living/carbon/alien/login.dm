/mob/living/carbon/alien/Login()
	..()
	AddInfectionImages()
	update_hud()
	if(!isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	return
