#define IS_ON_ESCAPE_SHUTTLE is_type_in_typecache(get_area(M), escape_shuttle_area)
/proc/captain_announce(message, title = "Priority Announcement", announcer = "", sound = "")
	var/escape_shuttle_area = list()
	escape_shuttle_area = typecacheof(/area/shuttle/escape/transit)
	escape_shuttle_area += typecacheof(/area/shuttle/escape_pod1/transit)
	escape_shuttle_area += typecacheof(/area/shuttle/escape_pod2/transit)
	escape_shuttle_area += typecacheof(/area/shuttle/escape_pod3/transit)
	escape_shuttle_area += typecacheof(/area/shuttle/escape_pod5/transit)
	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			to_chat(M, "<h1 class='alert'>[title]</h1>")
			to_chat(M, "<span class='alert'>[message]</span>")
			if(announcer)
				to_chat(M, "<span class='alert'> -[announcer]</span>")
			to_chat(M, "<br>")
			var/announce_sound = 'sound/AI/announce.ogg'
			switch(sound)
				if("emer_shut_called")
					announce_sound = 'sound/AI/emergency_s_called.ogg'
				if("emer_shut_recalled")
					announce_sound = 'sound/AI/emergency_s_recalled.ogg'
				if("emer_shut_docked")
					announce_sound = 'sound/AI/emergency_s_docked.ogg'
				if("emer_shut_left")
					if(IS_ON_ESCAPE_SHUTTLE)
						continue
					announce_sound = 'sound/AI/emergency_s_left.ogg'
				if("crew_shut_scalled")
					announce_sound = 'sound/AI/crew_s_called.ogg'
				if("crew_shut_recalled")
					announce_sound = 'sound/AI/crew_s_recalled.ogg'
				if("crew_shut_docked")
					announce_sound = 'sound/AI/crew_s_docked.ogg'
				if("crew_shut_left")
					if(IS_ON_ESCAPE_SHUTTLE)
						continue
					announce_sound = 'sound/AI/crew_s_left.ogg'
				if("malf1")
					announce_sound = 'sound/AI/ai_malf_1.ogg'
				if("malf2")
					announce_sound = 'sound/AI/ai_malf_2.ogg'
				if("malf3")
					announce_sound = 'sound/AI/ai_malf_3.ogg'
				if("malf4")
					announce_sound = 'sound/AI/ai_malf_4.ogg'
				if("aiannounce")
					announce_sound = 'sound/AI/aiannounce.ogg'
				if("nuke")
					announce_sound = 'sound/AI/nuke.ogg'
			M.playsound_local(null, announce_sound, 70, channel = CHANNEL_ANNOUNCE, wait = 1, is_global = 1)
#undef IS_ON_ESCPAE_SHUTTLE
