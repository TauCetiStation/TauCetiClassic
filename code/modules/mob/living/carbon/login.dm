/mob/living/carbon/Login()
	..()
	if(mind && mind.changeling)
		for(var/mob/living/parasite/essence/E in mind.changeling.essences)
			if(E.phantom && E.phantom.showed)
				client.images += E.phantom.overlay