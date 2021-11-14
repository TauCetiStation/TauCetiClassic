/mob/living/carbon/xenomorph/facehugger/Life()
	set invisibility = INVISIBILITY_NONE

	if (notransform)
		return

	for(var/obj/item/weapon/fh_grab/G in src)
		G.process()

	..()

/mob/living/carbon/xenomorph/facehugger/proc/handle_random_events()
	return
