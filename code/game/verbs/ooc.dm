
var/global/bridge_ooc_colour = "#7b804f"

/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='red'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	msg = sanitize(msg)

	if(!msg)	return

	if(!prefs.get_pref(/datum/pref/player/chat/ooc))
		to_chat(src, "<span class='red'>You have OOC muted.</span>")
		return

	if(prefs.muted & MUTE_OOC || IS_ON_ADMIN_CD(src, ADMIN_CD_OOC))
		to_chat(src, "<span class='red'>You cannot use OOC (muted).</span>")
		return

	if(!holder)

		if(!dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='red'>OOC for dead mobs has been turned off.</span>")
			return
		if(!ooc_allowed) // can be disabled globally, or autodisabled for round only
			var/user_message = "OOC is globally muted."

			if(config.ooc_round_autotoggle && SSticker.current_state == GAME_STATE_PLAYING) //disabled for round only
				user_message += " Try again after the round ends."

			if(looc_allowed)
				if(istype(mob, /mob/dead/new_player))
					user_message += "<br>While in lobby, you can still use LOOC to chat with others people in lobby."
				else
					user_message += "<br>You can still use LOOC to chat with others people in view."

			to_chat(src, "<span class='red'>[user_message]</span>")
			return

		if(handle_spam_prevention(msg,ADMIN_CD_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<b>Advertising other servers is not allowed.</b>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	var/display_colour = null
	var/ooc_name = key

	if(holder && !holder.fakekey)
		display_colour = OOC_COLOR_EVENTADMIN // we don't use it anymore?
		if(holder.rights & R_DEBUG && !(holder.rights & R_ADMIN))
			display_colour = OOC_COLOR_CODEADMIN
		else if(holder.rights & R_ADMIN)
			display_colour = (config.allow_admin_ooccolor && prefs.get_pref(/datum/pref/player/chat/aooccolor)) || OOC_COLOR_ADMIN

	send2ooc(msg, ooc_name, display_colour, src)

	world.send2bridge(
		type = list(BRIDGE_OOC),
		attachment_msg = "OOC: **[(holder && holder.fakekey)? holder.fakekey : ooc_name ]**: [msg]",
		attachment_color = (supporter && prefs.get_pref(/datum/pref/player/chat/ooccolor)) || display_colour
	)

/proc/send2ooc(msg, name, colour, client/sender, display_name, prefix = "OOC")
	if(sender)
		log_ooc("[key_name(sender)] : [msg]")
	else
		log_ooc("[name]: [msg]")

	var/msg_start = "<span class='ooc'><font[colour ? " color='[colour]'" : ""]><span class='prefix'>[prefix]"
	var/msg_end = "<span class='message emojify linkify'>[msg]</span></font></span>"

	for(var/client/C in clients)
		if(!display_name)
			display_name = name

		if(sender)
			if(sender.supporter && sender.prefs.get_pref(/datum/pref/player/chat/ooccolor))
				display_name = "<span style='color: [sender.prefs.get_pref(/datum/pref/player/chat/ooccolor)]'>[display_name]</span>"

			if(sender.holder && sender.holder.fakekey)
				if(C.holder)
					display_name = "[sender.holder.fakekey]/([sender.key])"
				else
					display_name = sender.holder.fakekey

		if(C.prefs.get_pref(/datum/pref/player/chat/ooc))
			to_chat(C, "[msg_start]:</span> [display_name?"<EM>[display_name]:</EM> ":""][msg_end]")

/client/verb/looc(msg as text)
	set name = "LOOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set desc = "Local OOC, seen only by those in view."
	set category = "OOC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='red'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)	return

	msg = sanitize(msg)
	if(!msg)	return

	if(!prefs.get_pref(/datum/pref/player/chat/looc))
		to_chat(src, "<span class='red'>You have LOOC muted.</span>")
		return

	if(!holder)
		if(!looc_allowed)
			to_chat(src, "<span class='red'>LOOC is globally muted</span>")
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='red'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC || IS_ON_ADMIN_CD(src, ADMIN_CD_OOC))
			to_chat(src, "<span class='red'>You cannot use OOC (muted).</span>")
			return
		if(handle_spam_prevention(msg,ADMIN_CD_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	var/display_name = "[mob.name]"
	var/is_fake_key = FALSE
	if(holder && holder.fakekey)
		display_name = holder.fakekey
		is_fake_key = TRUE
	if(isobserver(mob))
		display_name = "(Ghost) [key]"
	else if(prefs.get_pref(/datum/pref/player/chat/show_ckey))
		display_name += " ([key])"

	log_ooc("(LOCAL) [key_name(mob)] : [msg]")

	var/list/heard
	var/prefix = "LOOC"

	// mobs_in_view doesn't work for lobby mobs and i don't know why, already spend to much time on it
	// so currently admins can't jump to lobby location for lobby looc
	if(isnewplayer(mob))
		heard = new_player_list
		prefix = "(LOBBY)[prefix]"
	else
		heard = get_mobs_in_view(7, src.mob)

	for(var/mob/M in heard)

		if(!M.client)
			continue
		var/client/C = M.client
		if (C in admins)
			continue //they are handled after that

		if(C.prefs.get_pref(/datum/pref/player/chat/looc))
			if(is_fake_key && C.holder)
				display_name = "[holder.fakekey]/([key])"
			to_chat(C, "<span class='looc'><span class='prefix'>[prefix]:</span> <EM>[display_name]:</EM> <span class='message emojify linkify'>[msg]</span></span>")

	for(var/client/C as anything in admins)
		if(C.prefs.get_pref(/datum/pref/player/chat/looc))
			var/track = ""
			if(isobserver(C.mob) && !isnewplayer(mob))
				track = FOLLOW_LINK(C.mob, mob)
			var/remote = ""
			if (!(C.mob in heard))
				remote = "(R)"
			to_chat(C, "[track]<span class='looc'><span class='prefix'>[remote][prefix]:</span> <EM>[mob.name]/([key]):</EM> <span class='message emojify linkify'>[msg]</span></span>")

/client/verb/fix_ui()
	set name = "Fix UI"
	set desc = "Closes all opened NanoUI/TGUI and Reload your TGUI/NanoUI assets if they are not working"
	set category = "OOC"

	if(last_ui_resource_send > world.time)
		to_chat(usr, "<span class='warning'>You requested your TGUI/NanoUI resource files too quickly. This will reload your NanoUI and TGUI/NanoUI resources. If you have any open UIs this may break them. Please try again in [(last_ui_resource_send - world.time)/10] seconds.</span>")
		return
	last_ui_resource_send = world.time + 60 SECONDS

	// Close all NanoUI/TGUI windows
	nanomanager.close_user_uis(usr)
	SStgui.close_user_uis(usr)

	// Clear the user's cache so they get resent.
	// This is not fully clearing their BYOND cache, just their assets sent from the server this round
	sent_assets = list()

	// Resend the resources
	get_asset_datum(/datum/asset/nanoui)
	get_asset_datum(/datum/asset/simple/tgui)

	to_chat(src, "<span class='notice'>UI resource files resent successfully. If you are still having issues, please try manually clearing your BYOND cache.</span>")

/client/verb/show_test_merges()
	set name = "Show Test Merges"
	set desc = "Shows a list of all test merges that are currently active"
	set category = "OOC"

	if(!test_merges)
		to_chat(src, "<div class='test_merges'>No test merges are currently active</div>")
		return

	var/joined_text = "[EMBED_TIP("<b>Test merged PRs</b>", "Данные изменения временно залиты на сервер, для теста перед окончательным принятием изменений или сбора отзывов")]<b>:</b><br>"
	var/is_loading = FALSE
	for(var/pr in test_merges)
		if(test_merges[pr])
			joined_text += "[ENTITY_TAB]<a href='[config.repository_link]/pull/[pr]'>#[pr]</a>: [test_merges[pr]]<br>"
			if(test_merges[pr] == TEST_MERGE_DEFAULT_TEXT)
				is_loading = TRUE

	if(is_loading)
		joined_text += "<br><i>You can use OOC - Show Test Merges a bit later for more information about current test merges.</i>"

	to_chat(src, "<div class='test_merges'>[joined_text]</div>")
