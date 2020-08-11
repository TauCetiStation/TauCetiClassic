/mob/Logout()
	nanomanager.user_logout(src) // this is used to clean up (remove) this user's Nano UIs
	player_list -= src
	log_access("Logout: [key_name(src)]")
	if(admin_datums[src.ckey])
		if(!(src.ckey in stealth_keys))
			if (SSticker && SSticker.current_state == GAME_STATE_PLAYING) //Only report this stuff if we are currently playing.
				message_admins("Admin logout: [key_name(src)]")
	..()

	return 1
