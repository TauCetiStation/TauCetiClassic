//toggles
/client/verb/toggle_ghost_ears()
	set name = "Show/Hide GhostEars"
	set category = "Preferences"
	set desc = ".Toggle Between seeing all mob speech, and only speech of nearby mobs."
	prefs.chat_toggles ^= CHAT_GHOSTEARS
	to_chat(src, "As a ghost, you will now [(prefs.chat_toggles & CHAT_GHOSTEARS) ? "see all speech in the world" : "only see speech from nearby mobs"].")
	prefs.save_preferences()
	feedback_add_details("admin_verb","TGE") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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

/client/verb/toggle_ignored_role()
	set name = "Toggle Ignore Roles"
	set category = "Preferences"
	set desc = "Toggles ignore questions"

	var/role = input(usr, "Ignored Qustions for Roles in current Round:") as null|anything in prefs.ignore_question
	if(!role)
		return
	prefs.ignore_question -= role
	to_chat(src, "You will receive requests for \"[role]\" again")
	feedback_add_details("admin_verb","TBeSpecialIgnore") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/change_ui()
	set name = "Change UI"
	set category = "Preferences"
	set desc = "Configure your user interface."

	if(!ishuman(usr))
		to_chat(usr, "This only for human")
		return

	var/UI_style_new = input(usr, "Select a style, we recommend White for customization") as null|anything in sortList(global.available_ui_styles)
	if(!UI_style_new)
		return

	var/UI_alpha_new = input(usr, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num
	if(!UI_alpha_new || !(UI_alpha_new <= 255 && UI_alpha_new >= 50))
		return

	var/UI_color_new = input(usr, "Choose your UI color, dark colors are not recommended!") as color|null
	if(!UI_color_new)
		return

	var/datum/hud/hud = usr.hud_used

	//update UI
	var/list/screens = hud.main + hud.adding + hud.hotkeybuttons

	for(var/atom/movable/screen/complex/complex as anything in hud.complex)
		screens += complex.screens

	var/ui_style = ui_style2icon(UI_style_new)
	var/list/icon_states = icon_states(ui_style) // so it wont break hud with dmi that has no specific icon_state.

	hud.ui_style = ui_style
	hud.ui_color = UI_color_new
	hud.ui_alpha = UI_alpha_new

	for(var/atom/movable/screen/screen as anything in screens)
		if(screen.alpha && (screen.icon_state in icon_states))
			screen.update_by_hud(hud)

	if(tgui_alert(usr, "Like it? Save changes?",, list("Yes", "No")) == "Yes")
		prefs.UI_style = UI_style_new
		prefs.UI_style_alpha = UI_alpha_new
		prefs.UI_style_color = UI_color_new
		prefs.save_preferences()
		to_chat(usr, "UI was saved")
		return

	hud.ui_style = ui_style2icon(prefs.UI_style)
	hud.ui_color = prefs.UI_style_color
	hud.ui_alpha = prefs.UI_style_alpha

	for(var/atom/movable/screen/screen as anything in screens)
		if(screen.alpha && (screen.icon_state in icon_states))
			screen.update_by_hud(hud)

/client/verb/toggle_lobby_animation()
	set name = "Toggle Lobby Animation"
	set category = "Preferences"
	set desc = "Toggles lobby animations."
	prefs.lobbyanimation = !prefs.lobbyanimation
	prefs.save_preferences()
	if(isnewplayer(mob))
		var/mob/dead/new_player/M = mob
		M.show_titlescreen()
	if(prefs.lobbyanimation)
		to_chat(src, "You have enabled lobby animation.")
	else
		to_chat(src, "You have disabled lobby animation.")

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

/client/verb/set_ckey_show()
	set name = "Show/Hide Ckey"
	set desc = "Toggle between showing your Ckey in LOOC and dead chat."
	set category = "Preferences"
	prefs.chat_toggles ^= CHAT_CKEY
	prefs.save_preferences()
	to_chat(src, "You will [(prefs.chat_toggles & CHAT_CKEY) ? "now" : "no longer"] show your ckey in LOOC and deadchat.")
	feedback_add_details("admin_verb","SC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_ambient_occlusion()
	set name = "Toggle Ambient Occlusion"
	set category = "Preferences"
	set desc = "Toggle ambient occlusion."

	prefs.ambientocclusion = !prefs.ambientocclusion
	to_chat(src, "Ambient Occlusion: [prefs.ambientocclusion ? "Enabled" : "Disabled"].")
	prefs.save_preferences()
	if(length(screen))
		var/atom/movable/screen/plane_master/game_world/PM = locate() in screen
		PM.apply_effects(mob)
	feedback_add_details("admin_verb","TAC")

/client/verb/set_glow_level()
	set name = "Lighting: Glow Level"
	set category = "Preferences"

	var/new_setting = input(src, "Set glow level of light sources:") as null|anything in list("Disable", "Low", "Medium (Default)", "High")
	if(!new_setting)
		return

	switch(new_setting)
		if("Disable")
			prefs.glowlevel = GLOW_DISABLE
		if("Low")
			prefs.glowlevel = GLOW_LOW
		if("Medium (Default)")
			prefs.glowlevel = GLOW_MED
		if("High")
			prefs.glowlevel = GLOW_HIGH

	to_chat(src, "Glow level: [new_setting].")
	prefs.save_preferences()
	if(length(screen))
		var/atom/movable/screen/plane_master/lamps_selfglow/PM = locate() in screen
		PM.apply_effects(mob)
	feedback_add_details("admin_verb","LGL")

/client/verb/toggle_lamp_exposure()
	set name = "Lighting: Lamp Exposure"
	set category = "Preferences"

	prefs.lampsexposure = !prefs.lampsexposure
	to_chat(src, "Lamp exposure: [prefs.lampsexposure ? "Enabled" : "Disabled"].")
	prefs.save_preferences()
	if(length(screen))
		var/atom/movable/screen/plane_master/exposure/EXP = locate() in screen
		EXP.apply_effects(mob)
	feedback_add_details("admin_verb","LEXP")

/client/verb/toggle_lamps_glare()
	set name = "Lighting: Lamp Glare"
	set category = "Preferences"

	prefs.lampsglare = !prefs.lampsglare
	to_chat(src, "Glare: [prefs.lampsglare ? "Enabled" : "Disabled"].")
	prefs.save_preferences()
	if(length(screen))
		var/atom/movable/screen/plane_master/lamps_glare/PM = locate() in screen
		PM.apply_effects(mob)
	feedback_add_details("admin_verb","GLR")

/client/verb/eye_blur_effect()
	set name = "Blur effect"
	set category = "Preferences"

	prefs.eye_blur_effect = !prefs.eye_blur_effect
	to_chat(src, "Blur effect: [prefs.eye_blur_effect ? "Enabled" : "Old design"].")
	prefs.save_preferences()
	var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/rendering_plate/game_world) in screen
	if(mob.eye_blurry)
		PM.remove_filter("eye_blur_angular")
		PM.remove_filter("eye_blur_gauss")
		mob.clear_fullscreen("blurry")
	feedback_add_details("admin_verb","EBE")

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

/client/verb/toggle_ghost_sight()
	set name = "Change Ghost Sight Options"
	set category = "Preferences"
	set desc = "Toggle between seeing all mob emotes, all manual-only emotes and only emotes of nearby mobs."

	var/new_setting = input(src, "Ghost Sight Options:") as null|anything in list("Absolutely all emotes", "All manual-only", "Only emotes of nearby mobs")
	if(!new_setting)
		return

	switch(new_setting)
		if("Absolutely all emotes")
			to_chat(src, "As a ghost, you will now see absolutely all emotes in the world.")
			prefs.chat_ghostsight = CHAT_GHOSTSIGHT_ALL
		if("All manual-only")
			to_chat(src, "As a ghost, you will now see all manual-only(me, *emote, etc) emotes in the world.")
			prefs.chat_ghostsight = CHAT_GHOSTSIGHT_ALLMANUAL
		if("Only emotes of nearby mobs")
			to_chat(src, "As a ghost, you will now see only see emotes from nearby mobs")
			prefs.chat_ghostsight = CHAT_GHOSTSIGHT_NEARBYMOBS

	prefs.save_preferences()
	feedback_add_details("admin_verb","CGSO") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/verb/toggle_fancy_tgui()
	set name = "Toggle Fancy TGUI"
	set category = "Preferences"
	set desc = "Toggle Fancy TGUI"

	prefs.tgui_fancy = !prefs.tgui_fancy
	prefs.save_preferences()
	feedback_add_details("admin_verb", "TFTGUI")

/client/verb/toggle_tooltip()
	set name = "Tooltip: Show/Hide"
	set category = "Preferences"
	set desc = "Toggle Name of Items"

	prefs.tooltip = !prefs.tooltip

	if(prefs.tooltip)
		tooltip.set_state(TRUE)
	else
		tooltip.set_state(FALSE)

	prefs.save_preferences()
	to_chat(src, "Name of items [prefs.tooltip ? "enabled" : "disabled"].")
	feedback_add_details("admin_verb", "TTIP")

/client/verb/change_font_tooltip()
	set name = "Tooltip: Change Font"
	set category = "Preferences"
	set desc = "Toggle Font of Names of Items"

	var/list/fonts = list("System", "Fixedsys", "Small Fonts", "Times New Roman", "Serif", "Verdana", "Custom Font")

	var/font = input(usr, "Font of Names of Items:", "Font", prefs.tooltip_font) as null|anything in fonts | prefs.tooltip_font

	if(font == "Custom Font")
		font = sanitize(input("Enter the font that you have on your computer:", "Font") as null|text)

	if(!font)
		return

	prefs.tooltip_font = font

	prefs.save_preferences()
	feedback_add_details("admin_verb", "FTIP")

/client/verb/change_size_tooltip()
	set name = "Tooltip: Change Size"
	set category = "Preferences"
	set desc = "Change Size of Names of Items"

	prefs.tooltip_size = input(usr, "Введите размер Названий Предметов") as num

	tooltip.font_size = prefs.tooltip_size
	prefs.save_preferences()
	feedback_add_details("admin_verb", "LTIP")

/client/verb/toggle_outline()
	set name = "Toggle Outline"
	set category = "Preferences"
	set desc = "Toggle Outline"

	prefs.outline_enabled = !prefs.outline_enabled
	prefs.save_preferences()
	to_chat(src, "Outline is [prefs.outline_enabled ? "enabled" : "disabled"].")
	feedback_add_details("admin_verb", "TO")

/client/verb/change_outline_color()
	set name = "Change Outline Color"
	set category = "Preferences"
	set desc = "Change Outline Color"

	var/pickedOutlineColor = input(usr, "Choose your outline color.", "General Preference", prefs.outline_color) as color|null
	if(!pickedOutlineColor)
		return
	prefs.outline_color = pickedOutlineColor
	prefs.save_preferences()
	to_chat(src, "Outline color changed.")
	feedback_add_details("admin_verb", "COC")

/client/verb/toggle_eorg()
	set name = "Toggle End of Round Deathmatch"
	set category = "Preferences"
	set desc = "At the end of the round you will be teleported to thunderdome to freely bash your fellow colleagues."

	prefs.eorg_enabled = !prefs.eorg_enabled
	prefs.save_preferences()
	to_chat(src, "You [prefs.eorg_enabled ? "will be" : "won't be"] teleported to Thunderdome at round end.")
	feedback_add_details("admin_verb", "ED")

/client/verb/toggle_runechat()
	set name = "Toggle Runechat (Above-Head-Speech)"
	set category = "Preferences"
	prefs.show_runechat = !prefs.show_runechat

	to_chat(src, "Runechat is [prefs.show_runechat ? "enabled" : "disabled"].")
	feedback_add_details("admin_verb", "TRC")

/client/verb/toggle_hotkeys_mode()
	set name = "Toggle Hotkeys Mode"
	set category = "Preferences"

	prefs.toggle_hotkeys_mode()
	if(prefs.hotkeys)
		to_chat(src, "Режим хоткеев переключен: при клике в окно игры фокус будет переключен на окно игры")
	else
		to_chat(src, "Режим хоткеев переключен: при клике в окно игры фокус останется на чате.")
	feedback_add_details("admin_verb", "thm")

/client/verb/edit_emote_panel()
	set name = "Edit Emote Panel"
	set category = "Preferences"

	if(!emote_panel_editor)
		emote_panel_editor = new /datum/emote_panel_editor(src)
	emote_panel_editor.tgui_interact(usr)

