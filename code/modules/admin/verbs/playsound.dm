var/global/list/sounds_cache = list()

/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))	return

	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = 777)
	uploaded_sound.priority = 250

	sounds_cache += S

	switch(alert("Do you ready?\nSong: [S]",,"Play", "Play forced(don't overuse)", "Cancel"))
		if("Play")
			log_admin("[key_name(src)] played sound [S]")
			message_admins("[key_name_admin(src)] played sound [S]")
			for(var/mob/M in player_list)
				if(M.client.prefs.toggles & SOUND_MIDI)
					M << uploaded_sound
		if("Play forced(don't overuse)")
			log_admin("[key_name(src)] played sound [S] FORCED")
			message_admins("[key_name_admin(src)] played sound [S] FORCED")
			for(var/mob/M in player_list)
				M << uploaded_sound

	feedback_add_details("admin_verb","PGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound(S as sound)
	set category = "Fun"
	set name = "Play Local Sound"
	if(!check_rights(R_SOUNDS))	return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]")
	playsound(get_turf_loc(src.mob), S, 50, 0, 0)
	feedback_add_details("admin_verb","PLS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/play_server_sound()
	set category = "Fun"
	set name = "Play Server Sound"
	if(!check_rights(R_SOUNDS))	return

	var/list/sounds = file2list("sound/list.txt");
	sounds += "--CANCEL--"
	sounds += sounds_cache //i don't know, how long stored music on server. Hope, all round

	var/melody = input("Select a sound from the server to play", , "CANCEL") in sounds

	if(melody == "--CANCEL--") return

	play_sound(melody)

/client/proc/stop_server_sound()
	set category = "Fun"
	set name = "Stop Global Sound"
	if(!check_rights(R_SOUNDS))
		return
	var/sound/sound = sound(null, repeat = 0, wait = 0, channel = 777)
	for(var/mob/M in player_list)
		M << sound
	log_admin("[key_name(src)] has stopped the global sound.")
	message_admins("[key_name_admin(src)] has stopped the global sound.")
