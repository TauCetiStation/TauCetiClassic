/mob/living/carbon/xenomorph/larva/Life()
	set invisibility = 0

	if (notransform)
		return

	for(var/obj/item/weapon/larva_bite/G in src)
		G.process()
	if(istype(src.loc, /obj/item/alien_embryo))
		SetSleeping(5 SECONDS)

	..()

	if(stat != DEAD && !IS_IN_STASIS(src)) // not dead and not in stasis
		if(amount_grown < max_grown)
			amount_grown++

/mob/living/carbon/xenomorph/larva/proc/handle_random_events()
	return

/mob/living/carbon/xenomorph/larva/handle_hud_icons_health()
	if (healths)
		if (stat != DEAD)
			switch(health)
				if(25 to INFINITY)
					healths.icon_state = "health0"
				if(20 to 25)
					healths.icon_state = "health1"
				if(15 to 20)
					healths.icon_state = "health2"
				if(10 to 15)
					healths.icon_state = "health3"
				if(5 to 10)
					healths.icon_state = "health4"
				if(0 to 5)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"
