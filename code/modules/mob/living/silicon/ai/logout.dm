/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/machinery/ai_status_display/O in world) //change status
		O.mode = 0
	for(var/obj/machinery/status_display/O in world)	//disable "Friend computer" status
		if(O.friendc)
			O.friendc = 0
	if(!isturf(loc))
		if (client)
			client.eye = loc
			client.perspective = EYE_PERSPECTIVE
	src.view_core()
	return
