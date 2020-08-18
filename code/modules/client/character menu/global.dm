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
	if(config.allow_Metadata)
		. +=			"<tr><td><br><b>OOC Notes: </b><a href='?_src_=prefs;preference=metadata;task=input'>[length(metadata)>0?"[copytext_char(metadata, 1, 3)]...":"\[...\]"]</a></td></tr>"
	//if(user.client) TG
	//	if(user.client.holder)
	//		. += "<b>Announce Login:</b> <a href='?_src_=prefs;preference=announce_login'>[(toggles & ANNOUNCE_LOGIN)?"On":"Off"]</a><br>"

	//	if(unlock_content || check_rights_for(user.client, R_ADMIN))
	//		. += "<b>OOC:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ooccolor;task=input'>Change</a><br>"

	//	if(unlock_content)
	//		. += "<b>BYOND Membership Publicity:</b> <a href='?_src_=prefs;preference=publicity'>[(toggles & MEMBER_PUBLIC) ? "Public" : "Hidden"]</a><br>"
	//		. += "<b>Ghost Form:</b> <a href='?_src_=prefs;task=input;preference=ghostform'>[ghost_form]</a><br>"
	//		. += "<B>Ghost Orbit: </B> <a href='?_src_=prefs;task=input;preference=ghostorbit'>[ghost_orbit]</a><br>"
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
	. += 					"<td width='45%'>Parallax theme:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=parallax_theme'><b>[parallax_theme]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Ambient Occlusion:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=ambientocclusion'><b>[ambientocclusion ? "Enabled" : "Disabled"]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Melee Animations:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=see_animations'><b>[(toggles & SHOW_ANIMATIONS) ? "Yes" : "No"]</b></a></td>"
	. += 				"</tr>"
	. += 				"<tr>"
	. += 					"<td width='45%'>Progress Bar:</td>"
	. += 					"<td><a href='?_src_=prefs;preference=see_progbar'><b>[(toggles & SHOW_PROGBAR) ? "Yes" : "No"]</b></a></td>"
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

			//if(href_list["preference"] == "ghostorbit")
			//	if(unlock_content)
			//		var/new_orbit = input(user, "Thanks for supporting BYOND - Choose your ghostly orbit:","Thanks for supporting BYOND", null) as null|anything in ghost_orbits
			//		if(new_orbit)
			//			ghost_orbit = new_orbit

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
			if(!UI_style_alpha_new | !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50)) return
			UI_style_alpha = UI_style_alpha_new

		if("ui")
			var/pickedui = input(user, "Choose your UI style.", "Character Preference", UI_style) as null|anything in sortList(global.available_ui_styles)
			if(pickedui)
				UI_style = pickedui

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
				var/obj/screen/plane_master/game_world/PM = locate(/obj/screen/plane_master/game_world) in parent.screen
				PM.backdrop(parent.mob)

		if("parallax_theme")
			switch(parallax_theme)
				if(PARALLAX_THEME_CLASSIC)
					parallax_theme = PARALLAX_THEME_TG
				if(PARALLAX_THEME_TG)
					parallax_theme = PARALLAX_THEME_CLASSIC

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
