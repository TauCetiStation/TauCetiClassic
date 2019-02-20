/mob/living/silicon/ai/proc/ai_statuschange()
	set category = "AI Commands"
	set name = "AI status"

	if(usr.stat == DEAD)
		to_chat(usr, "You cannot change your emotional status because you are dead!")
		return
	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Friend Computer", "Beer mug", "Dwarf", "Fishtank", "Plump Helmet")
	if(src.ckey == "serithi")
		ai_emotions.Add("Tribunal","Tribunal Malfunctioning")
	var/emote = input("Please, select a status!", "AI Status", null, null) in ai_emotions
	for (var/obj/machinery/ai_status_display/AISD in ai_status_display_list) //change status
		spawn( 0 )
		AISD.emotion = emote
	for (var/obj/machinery/status_display/SD in status_display_list) //if Friend Computer, change ALL displays
		if(emote=="Friend Computer")
			spawn(0)
			SD.friendc = 1
		else
			spawn(0)
			SD.friendc = 0
	return
