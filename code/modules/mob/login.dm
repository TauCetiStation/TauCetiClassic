//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying
/mob/proc/update_Login_details()
	//Multikey checks and logging
	lastKnownIP	= client.address
	computer_id	= client.computer_id
	log_access("Login: [key_name(src)] from [lastKnownIP ? lastKnownIP : "localhost"]-[computer_id] || BYOND v[client.byond_version]")
	if(config.log_access)
		for(var/mob/M in player_list)
			if(M == src)	continue
			if( M.key && (M.key != key) )
				var/matches
				if( (M.lastKnownIP == client.address) )
					matches += "IP ([client.address])"
				if( (M.computer_id == client.computer_id) )
					if(matches)	matches += " and "
					matches += "ID ([client.computer_id])"
					spawn() tgui_alert(usr, "You have logged in already with another key this round, please log out of this one NOW or risk being banned!")
				if(matches)
					if(M.client)
						message_admins("<font color='red'><B>Notice: </B></font><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same [matches] as <A href='?src=\ref[usr];priv_msg=\ref[M]'>[key_name_admin(M)]</A>.</font>", R_LOG)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)].")
					else
						message_admins("<font color='red'><B>Notice: </B></font><font color='blue'><A href='?src=\ref[usr];priv_msg=\ref[src]'>[key_name_admin(src)]</A> has the same [matches] as [key_name_admin(M)] (no longer logged in). </font>", R_LOG)
						log_access("Notice: [key_name(src)] has the same [matches] as [key_name(M)] (no longer logged in).")

/mob/proc/create_mob_hud()
	if(!client || hud_used)
		return FALSE

	hud_used = new hud_type(src)
	SEND_SIGNAL(src, COMSIG_MOB_HUD_CREATED)
	hud_used.show_hud(istype(loc, /obj/mecha) ? HUD_STYLE_REDUCED : HUD_STYLE_STANDARD)
	update_sight()
	return TRUE

/mob/Login()
	player_list |= src
	
	if(client.holder)
		global.keyloop_list |= src
	else if(stat != DEAD || !SSlag_switch?.measures[DISABLE_DEAD_KEYLOOP])
		global.keyloop_list |= src

	update_Login_details()
	world.update_status()

	client.images = null				//remove the images such as AIs being unable to see runes
	client.screen = list()				//remove hud items just in case

	create_mob_hud()

	client.pixel_x = 0
	client.pixel_y = 0
	next_move = 1

	..()

	SEND_SIGNAL(src, COMSIG_LOGIN)
	logout_reason = LOGOUT_UNKNOWN

	if(loc && !isturf(loc))
		client.eye = loc
		client.perspective = EYE_PERSPECTIVE
	else
		client.eye = src
		client.perspective = MOB_PERSPECTIVE

	//Some weird magic to block users who cant see lighting normally
	var/atom/movable/screen/blocker = new /atom/movable/screen()
	blocker.screen_loc = "WEST,SOUTH to EAST,NORTH"
	blocker.icon = 'icons/effects/chaos.dmi'
	blocker.icon_state = "8"
	blocker.blend_mode = BLEND_MULTIPLY
	blocker.color = list(1,1,1,0,1,1,1,0,1,1,1,0,0,0,0,1,0,0,0,1)
	blocker.alpha = 255
	blocker.plane = ABOVE_HUD_PLANE
	blocker.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	// atom_huds
	reload_huds()

	//Reload alternate appearances
	update_all_alt_apperance()

	add_click_catcher()

	client.screen += blocker

	if(isAI(src))
		client.show_popup_menus = 0
	else
		client.show_popup_menus = 1

	if(client.click_intercept)
		client.click_intercept.post_login()
