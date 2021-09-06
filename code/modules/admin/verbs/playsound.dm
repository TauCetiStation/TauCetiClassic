var/global/list/sounds_cache_global = list()
var/global/list/sounds_cache_local = list()

/client/proc/play_global_sound()
	set category = "Fun"
	set name = "Play Global Sound"

	if(!check_rights(R_SOUNDS))
		return



	var/choice = tgui_alert(usr,"Category",, list("Cache", "File", "Cancel"))
	var/sound/S

	switch(choice)
		if("Cache")
			if(!length(sounds_cache_global))
				to_chat(src, "<span class='notice'>Operation aborted. Reason: no cache.</span>")
				return
			S = input("Select a sound from the server to play") as null|anything in sounds_cache_global
		if("File")
			S = input("Select a sound from the local repository") as null|sound
			sounds_cache_global |= S

	if(!isfile(S))
		to_chat(src, "<span class='notice'>Operation aborted. Reason: no input sound.</span>")
		return

	if(tgui_alert(usr, "Do you ready?\nSong: [S]\nDon't overuse this (knopka) play (or UNPEDALITY)! Suits for music and sound effects.",, list("Play", "Cancel")) == "Cancel")
		return

	log_admin("[key_name(src)] played sound [S].")
	message_admins("[key_name_admin(src)] played sound [S].")

	for(var/mob/M in player_list)
		M.playsound_music(S, VOL_ADMIN, null, TRUE, CHANNEL_ADMIN, 250, SOUND_STREAM)

	feedback_add_details("admin_verb","PGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound()
	set category = "Fun"
	set name = "Play Local Sound"

	if(!check_rights(R_SOUNDS))
		return

	var/choice = tgui_alert(usr, "Category",, list("Cache", "File", "Cancel"))
	var/sound/S
	var/set_vary

	switch(choice)
		if("Cache")
			if(!length(sounds_cache_local))
				to_chat(src, "<span class='notice'>Operation aborted. Reason: no cache.</span>")
				return
			var/cache_entry = input("Select a sound from the server to play") as null|anything in sounds_cache_local
			if(cache_entry)
				S = sounds_cache_local[cache_entry]["file"]

				if(isfile(S))
					set_vary = sounds_cache_local[cache_entry]["vary"]

		if("File")
			if(tgui_alert(usr, "For sound effects only, not music.", "Agreement", list("Accept", "Cancel")) == "Cancel")
				return

			S = input("Select a sound from the local repository") as null|sound

			if(isfile(S))
				set_vary = tgui_alert(usr, "Vary?", "Set Vary", list("Yes", "No"))
				if(set_vary == "Yes")
					set_vary = TRUE
				else
					set_vary = FALSE

				sounds_cache_local["[S] (Vary:[set_vary ? "On" : "Off"])"] = list("file" = S, "vary" = set_vary)

	if(!isfile(S))
		to_chat(src, "<span class='notice'>Operation aborted. Reason: no input sound.</span>")
		return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]")
	playsound(mob, S, VOL_EFFECTS_MASTER, null, set_vary)
	feedback_add_details("admin_verb","PLS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/stop_server_sound()
	set category = "Fun"
	set name = "Stop Global Sound"
	if(!check_rights(R_SOUNDS))
		return
	for(var/mob/M in player_list)
		M.playsound_stop(CHANNEL_ADMIN)
	log_admin("[key_name(src)] has stopped the global sound.")
	message_admins("[key_name_admin(src)] has stopped the global sound.")

/client/proc/play_server_sound()
	set category = "Fun"
	set name = "Play Server Sound"
	if(!check_rights(R_SOUNDS))
		return

	var/sound_path = browse_files(root="sound/", max_iterations=10, valid_extensions=list("ogg", "wav", "mp3"))

	if(!sound_path)
		return

	log_admin("[key_name(src)] played server sound [sound_path].")
	message_admins("[key_name_admin(src)] played server sound [sound_path].")

	for(var/mob/M in player_list)
		M.playsound_music(sound_path, VOL_ADMIN, null, TRUE, CHANNEL_ADMIN, 250, 0)
	
	feedback_add_details("admin_verb","PSS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/set_bwoink_sound()
	set category = "Fun"
	set name = "Set Own Bwoink Sound"

	if(!check_rights(R_ADMIN))
		return

	var/choice = tgui_alert(usr, "Category",, list("Cache", "File", "Cancel"))
	var/sound/S

	switch(choice)
		if("Cache")
			if(!length(sounds_cache_global))
				to_chat(src, "<span class='notice'>Operation aborted. Reason: no cache.</span>")
				return
			S = input("Select a sound from the server to play") as null|anything in sounds_cache_global
		if("File")
			S = input("Select a sound from the local repository") as null|sound
			sounds_cache_global |= S

	if(!isfile(S))
		to_chat(src, "<span class='notice'>Operation aborted. Reason: no input sound.</span>")
		return

	bwoink_sound = S
