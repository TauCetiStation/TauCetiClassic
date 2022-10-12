/mob/living/carbon/xenomorph/facehugger/Life()
	set invisibility = 0

	if (notransform)
		return

	for(var/obj/item/weapon/fh_grab/G in src)
		G.process()

	if(!(locate(/obj/structure/alien/weeds) in get_turf(src)))
		move_delay_add = min(move_delay_add + 3, 5)

	..()

/mob/living/carbon/xenomorph/facehugger/proc/handle_random_events()
	return
