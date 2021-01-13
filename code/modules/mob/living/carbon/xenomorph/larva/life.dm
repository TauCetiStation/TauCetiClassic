/mob/living/carbon/xenomorph/larva/Life()
	set invisibility = 0
	var/larva_in_embryo = FALSE //the larva in the embryo should not grow

	if (notransform)
		return

	for(var/obj/item/weapon/larva_bite/G in src)
		G.process()
	if(istype(src.loc, /obj/item/alien_embryo))
		larva_in_embryo = TRUE
		SetSleeping(5 SECONDS)

	..()

	if(stat != DEAD && !IS_IN_STASIS(src) && !larva_in_embryo) // not dead and not in stasis
		var/growth_rate = 1
		for(var/mob/living/carbon/xenomorph/humanoid/queen/Q in oview_or_orange(world.view, src, "view"))
			if(Q)
				if(Q.stat == DEAD || !Q.key)
					continue
				growth_rate = 2	//we grow faster if we look at the queen
				break

		var/diff = max_grown - amount_grown
		if(diff < growth_rate)
			growth_rate = diff	//so as not to go beyond the maximum growth

		if(amount_grown < max_grown)
			amount_grown += growth_rate

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
