/mob/living/carbon/xenomorph/larva/Life()
	set invisibility = 0
	var/larva_in_embryo = FALSE //the larva in the embryo should not grow

	if (notransform)
		return

	for(var/obj/item/weapon/larva_bite/G in src)
		G.process()
	if(istype(loc, /obj/item/alien_embryo))
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

		if(growth_rate == 1)
			throw_alert("alien_queen", /atom/movable/screen/alert/alien_queen)
		else
			clear_alert("alien_queen")

		var/diff = max_grown - amount_grown
		if(diff < growth_rate)
			growth_rate = diff	//so as not to go beyond the maximum growth

		if(amount_grown < max_grown)
			amount_grown += growth_rate

/mob/living/carbon/xenomorph/larva/proc/handle_random_events()
	return
