/mob/living/silicon/ai/Login()	//ThisIsDumb(TM) TODO: tidy this up ¬_¬ ~Carn
	..()
	if(wipe_timer_id)
		deltimer(wipe_timer_id)
		wipe_timer_id = 0
	var/datum/element/digitalcamo/ele = SSdcs.GetElement(list(/datum/element/digitalcamo))
	for(var/i in ele.attached_mobs)
		client.images += ele.attached_mobs[i]
	regenerate_icons()

	if(stat != DEAD)
		for(var/obj/machinery/ai_status_display/O in ai_status_display_list) //change status
			O.mode = 1
			O.emotion = "Neutral"
	view_core()
