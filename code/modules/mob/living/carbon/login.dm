/mob/living/carbon/Login()
	..()
	if(ischangeling(src))
		var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
		for(var/mob/living/parasite/essence/E in C.essences)
			if(E.phantom && E.phantom.showed)
				client.images += E.phantom.overlay
