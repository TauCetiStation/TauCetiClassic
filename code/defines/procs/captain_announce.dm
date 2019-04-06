/proc/captain_announce(message, title = "Priority Announcement", announcer = "", type = "")
	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			to_chat(world, "<h1 class='alert'>[title]</h1>")
			to_chat(world, "<span class='alert'>[message]</span>")
			if(announcer)
				to_chat(world, "<span class='alert'> -[announcer]</span>")
			to_chat(world, "<br>")
			var/announce_sound = 'sound/AI/announce.ogg'
			switch(type)
				if("escalled")
					announce_sound = 'sound/AI/escalled.ogg'
				if("esrecalled")
					announce_sound = 'sound/AI/esrecalled.ogg'
				if("esdocked")
					announce_sound = 'sound/AI/esdocked.ogg'
				if("esleft")
					announce_sound = 'sound/AI/esleft.ogg'
				if("cscalled")
					announce_sound = 'sound/AI/cscalled.ogg'
				if("csrecalled")
					announce_sound = 'sound/AI/csrecalled.ogg'
				if("csdocked")
					announce_sound = 'sound/AI/csdocked.ogg'
				if("csleft")
					announce_sound = 'sound/AI/csleft.ogg'
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
			M.playsound_local(null, announce_sound, 60, environment = -1, echo = null, channel = 802, wait = 1)
