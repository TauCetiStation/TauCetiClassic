var/global/list/sounds_cache = list()

/client/proc/play_global_sound(S as sound)
	set category = "Fun"
	set name = "Play Global Sound"

	if(!check_rights(R_SOUNDS))
		return

	sounds_cache += S

	if(alert("Do you ready?\nSong: [S]\nDon't overuse this (knopka) play (or UNPEDALITY)! This is only for sound effects.",,"Play", "Cancel") == "Cancel")
		return

	log_admin("[key_name(src)] played sound [S].")
	message_admins("[key_name_admin(src)] played sound [S].")

	for(var/mob/M in player_list)
		M.playsound_music(S, VOL_ADMIN, null, TRUE, CHANNEL_ADMIN, 250, SOUND_STREAM)

	feedback_add_details("admin_verb","PGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/play_local_sound(S as sound)
	set category = "Fun"
	set name = "Play Local Sound"

	if(!check_rights(R_SOUNDS))
		return

	log_admin("[key_name(src)] played a local sound [S]")
	message_admins("[key_name_admin(src)] played a local sound [S]")
	playsound(mob, S, VOL_EFFECTS)
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
