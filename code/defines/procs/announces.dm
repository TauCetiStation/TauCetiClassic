var/list/escape_area_transit = typecacheof(list(/area/shuttle/escape/transit,
                                                /area/shuttle/escape_pod1/transit,
                                                /area/shuttle/escape_pod2/transit,
                                                /area/shuttle/escape_pod3/transit,
                                                /area/shuttle/escape_pod4/transit))

#define IS_ON_ESCAPE_SHUTTLE is_type_in_typecache(get_area(M), escape_area_transit)

/proc/station_announce(message, title, subtitle, announcer, sound)
	var/announce_text
	var/announce_sound

	if(title)
		announce_text += "<h1 class='alert'>[title]</h1><br>"
	if(subtitle)
		announce_text += "<h2 class='alert'>[subtitle]</h2><br>"
	if(message)
		announce_text += "<span class='alert'>[message]</span><br>"
	if(announcer)
		announce_text += "<span class='alert'> -[announcer]</span><br>"

	if(sound)
		announce_sound = get_announce_sound(sound)


	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			if(announce_text)
				to_chat(M, announce_text+"<br>")

			if(announce_sound)
				if((sound == "emer_shut_left" || sound == "crew_shut_left") && IS_ON_ESCAPE_SHUTTLE)
					continue

				M.playsound_local(null, announce_sound, VOL_EFFECTS_VOICE_ANNOUNCEMENT, null, FALSE, channel = CHANNEL_ANNOUNCE, wait = TRUE)

//station announces: communication console, shuttle(?), departaments
/proc/captain_announce(message, title = "Priority Announcement", announcer, sound = "announce", subtitle)
	
	station_announce(message, title, subtitle, announcer, sound)

	add_communication_log(type = "station", title = title ? title : subtitle, author = announcer, content = message)

//messages from centcomm
/proc/command_alert(message, title, sound = "commandreport")

	station_announce(message, "[command_name()] Update", title, null, sound)

	add_communication_log(type = "centcomm", title = title, content = message)
