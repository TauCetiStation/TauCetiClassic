/mob/living/carbon/xenomorph/facehugger/Life()
	set invisibility = 0

	if (notransform)
		return

	for(var/obj/item/weapon/fh_grab/G in src)
		G.process()

	..()

/mob/living/carbon/xenomorph/facehugger/proc/handle_random_events()
	return

/mob/living/carbon/xenomorph/facehugger/handle_hud_icons_health()
	if (!healths)
		return
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
