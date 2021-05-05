/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up ¬_¬ ~Carn
	..()
	if(wipe_timer_id)
		deltimer(wipe_timer_id)
		wipe_timer_id = 0
	for(var/mob/living/M in living_list)
		if(M.digitalcamo && M.digitaldisguise)
			client.images += M.digitaldisguise
	regenerate_icons()

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in ai_status_display_list) //change status
			O.mode = 1
			O.emotion = "Neutral"
	src.view_core()
