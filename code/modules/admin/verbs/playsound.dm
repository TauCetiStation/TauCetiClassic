var/global/list/sounds_cache = list()

/client/proc/play_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"
	if(!check_rights(R_SOUNDS))	return

	var/sound/uploaded_sound = new()//sound(S, repeat = 0, wait = 1, channel = CHANNEL_ADMIN)
	uploaded_sound.file = S
	uploaded_sound.priority = 250
	uploaded_sound.channel = CHANNEL_ADMIN
	uploaded_sound.wait = 1
	uploaded_sound.status = SOUND_STREAM
	uploaded_sound.volume = 100

	sounds_cache += S

	var/forced = FALSE

	switch(alert("Do you ready?\nSong: [S]\nDon't overuse forced play (or UNPEDALITY)! This is only for sound effects.",,"Play", "Forced", "Cancel"))
		if("Forced")
			forced = TRUE
		if("Cancel")
			return

	log_admin("[key_name(src)] played sound [S] [forced ? "FORCED" : ""]")
	message_admins("[key_name_admin(src)] played sound [S] [forced ? "FORCED" : ""]")

	for(var/mob/M in player_list)
		if(forced || M.client.prefs.toggles & SOUND_MIDI)
			uploaded_sound.volume = M.client.adminSoundVolume
			M.client << uploaded_sound

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

	var/list/sounds = file2list("sound/serversound_list.txt");
	sounds += "--CANCEL--"
	sounds += sounds_cache

	var/melody = input("Select a sound from the server to play", , "CANCEL") in sounds

	if(melody == "--CANCEL--") return

	play_sound(melody)

/client/proc/stop_server_sound()
	set category = "Fun"
	set name = "Stop Global Sound"
	if(!check_rights(R_SOUNDS))
		return
	var/sound/sound = sound(null, repeat = 0, wait = 0, channel = CHANNEL_ADMIN)
	for(var/mob/M in player_list)
		M << sound
	log_admin("[key_name(src)] has stopped the global sound.")
	message_admins("[key_name_admin(src)] has stopped the global sound.")
