/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/machinery/ai_status_display/O in ai_status_display_list) //change status
		O.mode = 0
	for(var/obj/machinery/status_display/O in status_display_list)	//disable "Friend computer" status
		if(O.friendc)
			O.friendc = 0
	if(!isturf(loc))
		if (client)
			client.eye = loc
			client.perspective = EYE_PERSPECTIVE
	src.view_core()
	wipe_timer_id = addtimer(CALLBACK(src, .proc/wipe_core), 6000, TIMER_STOPPABLE)
	return
