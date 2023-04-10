/mob/Logout()
	global.player_list -= src
	global.keyloop_list -= src
	set_typing_indicator(FALSE)
	nanomanager.user_logout(src) // this is used to clean up (remove) this user's Nano UIs
	SStgui.on_logout(src)
	log_access("Logout: [key_name(src)]")
	if(admin_datums[src.ckey])
		if(!(src.ckey in stealth_keys))
			if (SSticker && SSticker.current_state == GAME_STATE_PLAYING) //Only report this stuff if we are currently playing.
				message_admins("Admin logout: [key_name(src)]")

	if(key)
		logout_reason = logout_reason || LOGOUT_USER

	SEND_SIGNAL(src, COMSIG_LOGOUT, logout_reason)

	..()

	QDEL_NULL(hud_used)		//remove the hud objects

	return 1
