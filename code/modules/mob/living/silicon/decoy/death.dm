/mob/living/silicon/decoy/death(gibbed)
	if(stat == DEAD)	return
	stat = DEAD
	icon_state = "ai-crash"
	spawn(10)
		explosion(loc, 3, 6, 12, 14)

	for(var/obj/machinery/ai_status_display/O in ai_status_display_list) //change status
		O.mode = 2
	return ..(gibbed)
