//toggles
/client/verb/toggle_ghost_ears()
	set name = "Show/Hide GhostEars"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob speech, and only speech of nearby mobs."
	prefs.chat_toggles ^= CHAT_GHOSTEARS
	to_chat(src, "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"].")
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_sight()
	set name = "Show/Hide GhostSight"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob emotes, and only emotes of nearby mobs."
	prefs.chat_toggles ^= CHAT_GHOSTSIGHT
	to_chat(src, "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTSIGHT) ? "see all emotes in the world" : "only see emotes from nearby mobs"].")
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ghost_npc()
	set name = "Show/Hide GhostNPCsSpeech"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all non-player mobs speech, and only speech of nearby non-player mobs."
	prefs.chat_toggles ^= CHAT_GHOSTNPC
	to_chat(src, "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTNPC) ? "see all non-player mobs speech in the world" : "only see speech from nearby non-player mobs"].")
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGN")

/client/verb/toggle_ghost_radio()
	set name = "Enable/Disable GhostRadio"
	set category = "Preferences"
	set desc = ".Toggle between hearing all radio chatter, or only from nearby speakers."
	prefs.chat_toggles ^= CHAT_GHOSTRADIO
	to_chat(src, "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTRADIO) ? "hear all radio chat in the world" : "only hear from nearby speakers"].")
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGR")

/client/proc/toggle_hear_radio()
	set name = "Show/Hide RadioChatter"
	set category = "Preferences"
	set desc = "Toggle seeing radiochatter from radios and speakers."
	if(!holder) return
	prefs.chat_toggles ^= CHAT_RADIO
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.chat_toggles & CHAT_RADIO) ? "now" : "no longer"] see radio chatter from radios or speakers")
	feedback_add_details("admin_verb","THR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleadminhelpsound()
	set name = "Hear/Silence Adminhelps"
	set category = "Preferences"
	set desc = "Toggle hearing a notification when admin PMs are recieved."
	if(!holder)	return
	prefs.toggles ^= SOUND_ADMINHELP
	prefs.save_preferences()
	to_chat(usr, "You will [(prefs.toggles & SOUND_ADMINHELP) ? "now" : "no longer"] hear a sound when adminhelps arrive.")
	feedback_add_details("admin_verb","AHS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/deadchat() // Deadchat toggle is usable by anyone.
	set name = "Show/Hide Deadchat"
	set category = "Preferences"
	set desc ="Toggles seeing deadchat."
	prefs.chat_toggles ^= CHAT_DEAD
	prefs.save_preferences()

	if(src.holder)
		to_chat(src, "You will [(prefs.chat_toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat.")
	else
		to_chat(src, "As a ghost, you will [(prefs.chat_toggles & CHAT_DEAD) ? "now" : "no longer"] see deadchat.")

	feedback_add_details("admin_verb","TDV") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggleprayers()
	set name = "Show/Hide Prayers"
	set category = "Preferences"
	set desc = "Toggles seeing prayers."
	prefs.chat_toggles ^= CHAT_PRAYER
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.chat_toggles & CHAT_PRAYER) ? "now" : "no longer"] see prayerchat.")
	feedback_add_details("admin_verb","TP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggletitlemusic()
	set name = "Hear/Silence LobbyMusic"
	set category = "Preferences"
	set desc = "Toggles hearing the GameLobby music."
	prefs.toggles ^= SOUND_LOBBY
	prefs.save_preferences()
	if(prefs.toggles & SOUND_LOBBY)
		to_chat(src, "You will now hear music in the game lobby.")
		if(isnewplayer(mob))
			playtitlemusic()
	else
		to_chat(src, "You will no longer hear music in the game lobby.")
		if(isnewplayer(mob))
			src << sound(null, repeat = 0, wait = 0, volume = 85, channel = 1) // stop the jamsz
	feedback_add_details("admin_verb","TLobby") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/togglemidis()
	set name = "Hear/Silence Midis"
	set category = "Preferences"
	set desc = "Toggles hearing sounds uploaded by admins."
	prefs.toggles ^= SOUND_MIDI
	prefs.save_preferences()
	if(prefs.toggles & SOUND_MIDI)
		to_chat(src, "You will now hear any sounds uploaded by admins.")
		var/sound/break_sound = sound(null, repeat = 0, wait = 0, channel = CHANNEL_ADMIN)

		break_sound.priority = 250
		src << break_sound	//breaks the client's sound output on channel CHANNEL_ADMIN
	else
		to_chat(src, "You will no longer hear sounds uploaded by admins; any currently playing midis have been disabled.")
	feedback_add_details("admin_verb","TMidi") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/listen_ooc()
	set name = "Show/Hide OOC"
	set category = "Preferences"
	set desc = "Toggles seeing OutOfCharacter chat."
	prefs.chat_toggles ^= CHAT_OOC
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.chat_toggles & CHAT_OOC) ? "now" : "no longer"] see messages on the OOC channel.")
	feedback_add_details("admin_verb","TOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/listen_looc()
	set name = "Show/Hide LOOC"
	set category = "Preferences"
	set desc = "Toggles seeing Local OutOfCharacter chat."
	prefs.chat_toggles ^= CHAT_LOOC
	prefs.save_preferences()

	to_chat(src, "You will [(prefs.chat_toggles & CHAT_LOOC) ? "now" : "no longer"] see messages on the LOOC channel.")
	feedback_add_details("admin_verb","TLOOC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/verb/Toggle_Soundscape() //All new ambience should be added here so it works with this verb until someone better at things comes up with a fix that isn't awful
	set name = "Hear/Silence Ambience"
	set category = "Preferences"
	set desc = "Toggles hearing ambient sound effects."
	prefs.toggles ^= SOUND_AMBIENCE
	prefs.save_preferences()
	if(prefs.toggles & SOUND_AMBIENCE)
		to_chat(src, "You will now hear ambient sounds.")
	else
		to_chat(src, "You will no longer hear ambient sounds.")
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 1)
		src << sound(null, repeat = 0, wait = 0, volume = 0, channel = 2)
	feedback_add_details("admin_verb","TAmbi") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_be_role(role in special_roles)
	set name = "Toggle SpecialRole Candidacy"
	set category = "Preferences"
	set desc = "Toggles which special roles you would like to be a candidate for, during events."
	var/role_type = role
	if(!role_type)	return
	if(role_type in prefs.be_role)
		prefs.be_role -= role_type
	else
		prefs.be_role += role_type
	prefs.save_preferences()
	to_chat(src, "You will [(role_type in prefs.be_role) ? "now" : "no longer"] be considered for [role] events (where possible).")
	feedback_add_details("admin_verb","TBeSpecial") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/change_ui()
	set name = "Change UI"
	set category = "Preferences"
	set desc = "Configure your user interface."

	if(!ishuman(usr))
		to_chat(usr, "This only for human")
		return

	var/UI_style_new = input(usr, "Select a style, we recommend White for customization") in list("White", "Midnight", "Orange", "old")
	if(!UI_style_new) return

	var/UI_style_alpha_new = input(usr, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num
	if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return

	var/UI_style_color_new = input(usr, "Choose your UI color, dark colors are not recommended!") as color|null
	if(!UI_style_color_new) return

	//update UI
	var/list/icons = usr.hud_used.adding + usr.hud_used.other +usr.hud_used.hotkeybuttons
	icons.Add(usr.zone_sel)

	for(var/obj/screen/I in icons)
		if(I.color && I.alpha)
			I.icon = ui_style2icon(UI_style_new)
			I.color = UI_style_color_new
			I.alpha = UI_style_alpha_new



	if(alert("Like it? Save changes?",,"Yes", "No") == "Yes")
		prefs.UI_style = UI_style_new
		prefs.UI_style_alpha = UI_style_alpha_new
		prefs.UI_style_color = UI_style_color_new
		prefs.save_preferences()
		to_chat(usr, "UI was saved")

/client/verb/toggle_anim_attacks()
	set name = "Show/Hide Melee Animations"
	set category = "Preferences"
	set desc = "Toggles seeing melee attack animations."
	prefs.toggles ^= SHOW_ANIMATIONS
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.toggles & SHOW_ANIMATIONS) ? "now" : "no longer"] see melee attack animations.")
	feedback_add_details("admin_verb","MAA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_progress_bar()
	set name = "Show/Hide Progress Bar"
	set category = "Preferences"
	set desc = "Toggles visibility of progress bars."
	prefs.toggles ^= SHOW_PROGBAR
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.toggles & SHOW_PROGBAR) ? "now" : "no longer"] see progress bars.")
	feedback_add_details("admin_verb","PRB") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_media()
	set name = "Hear/Silence Streaming"
	set category = "Preferences"
	set desc = "Toggle hearing streaming media (radios, jukeboxes, etc)."
	prefs.toggles ^= SOUND_STREAMING
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.toggles & SOUND_STREAMING) ? "now" : "no longer"] hear streamed media.")
	if(!media) return
	if(prefs.toggles & SOUND_STREAMING)
		media.update_music()
	else
		media.stop_music()

var/global/list/ghost_orbits = list(GHOST_ORBIT_CIRCLE,GHOST_ORBIT_TRIANGLE,GHOST_ORBIT_SQUARE,GHOST_ORBIT_HEXAGON,GHOST_ORBIT_PENTAGON)

/client/verb/pick_ghost_orbit()
	set name = "Choose Ghost Orbit"
	set category = "Preferences"
	set desc = "Choose your preferred ghostly orbit."

	var/new_orbit = input(src, "Choose your ghostly orbit:") as null|anything in ghost_orbits
	if(new_orbit)
		prefs.ghost_orbit = new_orbit
		prefs.save_preferences()
		if(istype(mob, /mob/dead/observer))
			var/mob/dead/observer/O = mob
			O.ghost_orbit = new_orbit

/client/verb/set_ckey_show()
	set name = "Show/Hide Ckey"
	set desc = "Toggle between showing your Ckey in LOOC and dead chat."
	set category = "Preferences"
	prefs.chat_toggles ^= CHAT_CKEY
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.chat_toggles & CHAT_CKEY) ? "now" : "no longer"] show your ckey in LOOC and deadchat.")
	feedback_add_details("admin_verb","SC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/set_parallax_quality()
	set name = "Set Parallax Quality"
	set category = "Preferences"
	set desc = "Set space parallax quality."

	var/new_setting = input(src, "Parallax quality:") as null|anything in list("Disable", "Low", "Medium", "High", "Insane")
	if(!new_setting)
		return

	switch(new_setting)
		if("Disable")
			prefs.parallax = PARALLAX_DISABLE
		if("Low")
			prefs.parallax = PARALLAX_LOW
		if("Medium")
			prefs.parallax = PARALLAX_MED
		if("High")
			prefs.parallax = PARALLAX_HIGH
		if("Insane")
			prefs.parallax = PARALLAX_INSANE

	to_chat(src, "Parallax (Fancy Space): [new_setting].")
	prefs.save_preferences()
	feedback_add_details("admin_verb","TPX")

	if (mob && mob.hud_used)
		mob.hud_used.update_parallax_pref()
