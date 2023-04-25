/datum/preferences/proc/ShowGlobal(mob/user)
	. =  "<table cellspacing='0' width='100%'>"
	. += 	"<tr valign='top'>"
	. += 		"<td width='50%'>"
	. += 			"<table width='100%'>"
	. += 				"<tr><td><b>UI Style:</b> <a href='?_src_=prefs;preference=ui'><b>[UI_style]</b></a></td></tr>"
	. += 				"<tr><td><b>Custom UI</b>(recommended for White UI):<td></tr>"
	. += 				"<tr><td><a href='?_src_=prefs;preference=UIcolor'><b>Change color</b></a> <table border cellspacing='0' style='display:inline;' bgcolor='[UI_style_color]'><tr><td width='20' height='15'></td></tr></table></td></tr>"
	. += 				"<tr><td>Alpha(transparency): <a href='?_src_=prefs;preference=UIalpha'><b>[UI_style_alpha]</b></a></td></tr>"
	. += 				"<tr><td colspan='3'><a href='?_src_=prefs;task=reset'>Reset custom UI</a></td></tr>"
	. +=				"<tr><td>TGUI Window Mode:</b> <a href='?_src_=prefs;preference=tgui_fancy'><b>[tgui_fancy ? "Fancy (default)" : "Compatible (slower)"]</a></td></tr>"
	. += 				"<tr><td>TGUI Window Placement:</b> <a href='?_src_=prefs;preference=tgui_lock'><b>[tgui_lock ? "Primary Monitor" : "Free (default)"]</a></td></tr>"
	. += 				"<tr><td>Outline: <a href='?_src_=prefs;preference=outline_enabled'>[outline_enabled ? "Enabled" : "Disabled"]</a><br>"
	. += 				"<tr><td>Outline Color: <span style='border:1px solid #161616; background-color: [outline_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=outline_color'>Change</a><BR>"
	. += 				"<tr><td>FPS: <a href='?_src_=prefs;preference=change_fps'>[clientfps]</a></td></tr>"
	. +=			"<tr><td><br><b>OOC Notes: </b><a href='?_src_=prefs;preference=metadata;task=input'>[length(metadata)>0?"[copytext_char(metadata, 1, 3)]...":"\[...\]"]</a></td></tr>"
	//if(user.client) TG
	//	if(user.client.holder)
	//		. += "<b>Announce Login:</b> <a href='?_src_=prefs;preference=announce_login'>[(toggles & ANNOUNCE_LOGIN)?"On":"Off"]</a><br>"

	//	if(unlock_content || check_rights_for(user.client, R_ADMIN))
	//		. += "<b>OOC:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ooccolor;task=input'>Change</a><br>"

	//	if(unlock_content)
	//		. += "<b>BYOND Membership Publicity:</b> <a href='?_src_=prefs;preference=publicity'>[(toggles & MEMBER_PUBLIC) ? "Public" : "Hidden"]</a><br>"
	//		. += "<b>Ghost Form:</b> <a href='?_src_=prefs;task=input;preference=ghostform'>[ghost_form]</a><br>"
	. += 			"</table>"
	. += 		"</td>"
	. += 		"<td>"
	. += 			"<table width='100%'>"
	. += 				"<tr><td colspan='2'><b>Preferences:</b></td></tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Ghost ears:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=ghost_ears'><b>[(chat_toggles & CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</b></a></td>"
	. += 				"</tr>"
	. +=				"<tr>"
	. += 					"<td width='45%'>Ghost hear NPCs:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=npc_ghost_ears'><b>[(chat_toggles & CHAT_GHOSTNPC) ? "All Speech" : "Nearest Creatures"]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Ghost sight:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=ghost_sight'><b>[(chat_ghostsight == CHAT_GHOSTSIGHT_ALL) ? "All Emotes" : ((chat_ghostsight == CHAT_GHOSTSIGHT_ALLMANUAL) ? "All manual-only emotes" : "Nearest Creatures")]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Ghost radio:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=ghost_radio'><b>[(chat_toggles & CHAT_GHOSTRADIO) ? "All Chatter" : "Nearest Speakers"]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>OOC:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=see_ooc'><b>[(chat_toggles & CHAT_OOC) ? "Shown" : "Hidden"]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>LOOC:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=see_looc'><b>[(chat_toggles & CHAT_LOOC) ? "Shown" : "Hidden"]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Parallax (Fancy Space)</td>"
	. += 					"<td><b><a href='?_src_=prefs;preference=parallaxdown' oncontextmenu='window.location.href=\"?_src_=prefs;preference=parallaxup\";return false;'>"
	switch (parallax)
		if (PARALLAX_LOW)
			. += "Low"
		if (PARALLAX_MED)
			. += "Medium"
		if (PARALLAX_INSANE)
			. += "Insane"
		if (PARALLAX_DISABLE)
			. += "Disabled"
		else
			. += "High"
	. += 					"</a></b></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Lobby Animation:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=lobbyanimation'><b>[lobbyanimation ? "Enabled" : "Disabled"]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Ambient Occlusion:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=ambientocclusion'><b>[ambientocclusion ? "Enabled" : "Disabled"]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Fit Viewport:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=auto_fit_viewport'><b>[auto_fit_viewport ? "Auto" : "Manual"]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Melee Animations:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=see_animations'><b>[(toggles & SHOW_ANIMATIONS) ? "Yes" : "No"]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Progress Bar:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=see_progbar'><b>[(toggles & SHOW_PROGBAR) ? "Yes" : "No"]</b></a></td>"
	. += 				"</tr>"
	. +=				"<tr>"
	. += 					"<td width='45%'>Name of Items:</td>"
	. +=					"<td><a href='?_src_=prefs;preference=tooltip_show'><b>[tooltip ? "Hide" : "Show"]</b></a></td>"
	. += 				"</tr>"
	. +=				"<tr>"
	. += 					"<td width='45%'>Change Font of Names of Items:</td>"
	. +=					"<td><a href='?_src_=prefs;preference=change_font_tooltip'><b>Change</b></a></td>"
	. += 				"</tr>"
	. +=				"<tr>"
	. += 					"<td width='45%'>Change Names Size:</td>"
	. +=					"<td><a href='?_src_=prefs;preference=change_size_tooltip'><b>[tooltip_size]</b></a></td>"
	. += 				"</tr>"
	. += 			"</table>"
	. += 		"</td>"
	. += 	"</tr>"
	. += "</table>"

/datum/preferences/proc/process_link_glob(mob/user, list/href_list)
	switch(href_list["task"])
		if("input")
			if(href_list["preference"] == "metadata")
				var/new_metadata = sanitize(input(user, "Enter any OOC information you'd like others to see:", "Game Preference", input_default(metadata)) as message|null)
				if(new_metadata)
					metadata = new_metadata

		if("reset")
			UI_style_color = initial(UI_style_color)
			UI_style_alpha = initial(UI_style_alpha)

	switch(href_list["preference"])

		if("UIcolor")
			var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!") as color|null
			if(!UI_style_color_new) return
			UI_style_color = UI_style_color_new

		if("UIalpha")
			var/UI_style_alpha_new = input(user, "Select a new alpha(transparence) parametr for UI, between 50 and 255") as num|null
			if(!UI_style_alpha_new || !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return
			UI_style_alpha = UI_style_alpha_new

		if("ui")
			var/pickedui = input(user, "Choose your UI style.", "Character Preference", UI_style) as null|anything in sortList(global.available_ui_styles)
			if(pickedui)
				UI_style = pickedui

		if("tgui_fancy")
			tgui_fancy = !tgui_fancy

		if("tgui_lock")
			tgui_lock = !tgui_lock

		if("tooltip_show")
			parent?.toggle_tooltip()

		if("change_size_tooltip")
			parent?.change_size_tooltip()

		if("change_font_tooltip")
			parent?.change_font_tooltip()

		if("outline_enabled")
			outline_enabled = !outline_enabled

		if("outline_color")
			var/pickedOutlineColor = input(user, "Choose your outline color.", "General Preference", outline_color) as color|null
			if(pickedOutlineColor)
				outline_color = pickedOutlineColor

		if("change_fps")
			var/desiredfps = input(user, "Choose your desired fps.\n-1 means recommended value (currently:[RECOMMENDED_FPS])\n0 means world fps (currently:[world.fps])", "Character Preference", clientfps)  as null|num
			if (!isnull(desiredfps))
				clientfps = sanitize_integer(desiredfps, -1, 1000, clientfps)
				parent.fps = (clientfps < 0) ? RECOMMENDED_FPS : clientfps

		if("parallaxup")
			parallax = WRAP(parallax + 1, PARALLAX_INSANE, PARALLAX_DISABLE + 1)
			if (parent && parent.mob && parent.mob.hud_used)
				parent.mob.hud_used.update_parallax_pref()

		if("parallaxdown")
			parallax = WRAP(parallax - 1, PARALLAX_INSANE, PARALLAX_DISABLE + 1)
			if (parent && parent.mob && parent.mob.hud_used)
				parent.mob.hud_used.update_parallax_pref()

		if("ambientocclusion")
			ambientocclusion = !ambientocclusion
			if(parent && parent.screen && parent.screen.len)
				var/atom/movable/screen/plane_master/game_world/PM = locate(/atom/movable/screen/plane_master/game_world) in parent.screen
				PM.backdrop(parent.mob)

		if("lobbyanimation")
			lobbyanimation = !lobbyanimation // shouldn't prefs changes be saved somewhere here?
			if(isnewplayer(user))
				var/mob/dead/new_player/M = user
				M.show_titlescreen()

		if("auto_fit_viewport")
			auto_fit_viewport = !auto_fit_viewport
			if(auto_fit_viewport && parent)
				parent.fit_viewport()

		if("ghost_sight")
			switch(chat_ghostsight)
				if(CHAT_GHOSTSIGHT_ALL)
					chat_ghostsight = CHAT_GHOSTSIGHT_ALLMANUAL
				if(CHAT_GHOSTSIGHT_ALLMANUAL)
					chat_ghostsight = CHAT_GHOSTSIGHT_NEARBYMOBS
				if(CHAT_GHOSTSIGHT_NEARBYMOBS)
					chat_ghostsight = CHAT_GHOSTSIGHT_ALL

		if("ghost_ears")
			chat_toggles ^= CHAT_GHOSTEARS

		if("npc_ghost_ears")
			chat_toggles ^= CHAT_GHOSTNPC

		if("ghost_radio")
			chat_toggles ^= CHAT_GHOSTRADIO

		if("see_ooc")
			chat_toggles ^= CHAT_OOC

		if("see_looc")
			chat_toggles ^= CHAT_LOOC

		if("see_animations")
			toggles ^= SHOW_ANIMATIONS

		if("see_progbar")
			toggles ^= SHOW_PROGBAR
