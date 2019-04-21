/proc/command_alert(text, title = "", sound = "")
	var/command
	command += "<h1 class='alert'>[command_name()] Update</h1>"
	if (title && length(title) > 0)
		command += "<br><h2 class='alert'>[title]</h2>"
	command += "<br><span class='alert'>[text]</span><br>"
	command += "<br>"
	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			to_chat(M, command)
			var/announce_sound = 'sound/AI/commandreport.ogg'
			switch(sound)
				if("radpassed")
					announce_sound = 'sound/AI/radpassed.ogg'
				if("radiation")
					announce_sound = pick('sound/AI/radiation1.ogg', 'sound/AI/radiation2.ogg', 'sound/AI/radiation3.ogg')
				if("noert")
					announce_sound = 'sound/AI/noert.ogg'
				if("yesert")
					announce_sound = 'sound/AI/yesert.ogg'
				if("meteors")
					announce_sound = pick('sound/AI/meteors1.ogg', 'sound/AI/meteors2.ogg')
				if("meteorcleared")
					announce_sound = 'sound/AI/meteorcleared.ogg'
				if("gravanom")
					announce_sound = 'sound/AI/gravanomalies.ogg'
				if("fluxanom")
					announce_sound = 'sound/AI/flux.ogg'
				if("vortexanom")
					announce_sound = 'sound/AI/vortex.ogg'
				if("bluspaceanom")
					announce_sound = 'sound/AI/blusp_anomalies.ogg'
				if("pyroanom")
					announce_sound = 'sound/AI/pyr_anomalies.ogg'
				if("wormholes")
					announce_sound = 'sound/AI/wormholes.ogg'
				if("outbreak7")
					announce_sound = 'sound/AI/outbreak7.ogg'
				if("outbreak5")
					announce_sound = pick('sound/AI/outbreak5_1.ogg', 'sound/AI/outbreak5_2.ogg')
				if("lifesigns")
					announce_sound = pick('sound/AI/lifesigns1.ogg', 'sound/AI/lifesigns2.ogg', 'sound/AI/lifesigns3.ogg')
				if("greytide")
					announce_sound = 'sound/AI/greytide.ogg'
				if("rampbrand")
					announce_sound = 'sound/AI/rampant_brand_int.ogg'
				if("carps")
					announce_sound = 'sound/AI/carps.ogg'
				if("estorm")
					announce_sound = 'sound/AI/e-storm.ogg'
				if("istorm")
					announce_sound = 'sound/AI/i-storm.ogg'
				if("poweroff")
					announce_sound = pick('sound/AI/poweroff1.ogg', 'sound/AI/poweroff2.ogg')
				if("poweron")
					announce_sound = 'sound/AI/poweron.ogg'
				if("gravoff")
					announce_sound = 'sound/AI/gravityoff.ogg'
				if("gravon")
					announce_sound = 'sound/AI/gravityon.ogg'
				if("artillery")
					announce_sound = 'sound/AI/artillery.ogg'
				if("icaruslost")
					announce_sound = 'sound/AI/icarus.ogg'
				if("fungi")
					announce_sound = 'sound/AI/fungi.ogg'
			M.playsound_local(null, announce_sound, 70, channel = CHANNEL_ANNOUNCE, wait = 1, is_global = 1)
