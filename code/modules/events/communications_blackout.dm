/datum/event/communications_blackout
	announcement = new /datum/announcement/centcomm/comms_blackout

/datum/event/communications_blackout/announce()
	announcement.randomize_message()

	for(var/mob/living/silicon/ai/A in player_list)	//AIs are always aware of communication blackouts.
		to_chat(A, "<br>")
		to_chat(A, "<span class='warning'><b>[announcement.message]</b></span>")
		to_chat(A, "<br>")

	if(prob(30))	//most of the time, we don't want an announcement, so as to allow AIs to fake blackouts.
		announcement.play()


/datum/event/communications_blackout/start()
	for(var/obj/machinery/telecomms/T in telecomms_list)
		T.emplode(1)
