
var/global/normal_ooc_colour = "#002eb8"
var/global/bridge_ooc_colour = "#7b804f"

/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='red'>Speech is currently admin-disabled.</span>")
		return

	if(!mob || !msg)
		return

	if(!msg)	return

	if(!(prefs.chat_toggles & CHAT_OOC))
		to_chat(src, "<span class='red'>You have OOC muted.</span>")
		return

	if(prefs.muted & MUTE_OOC)
		to_chat(src, "<span class='red'>You cannot use OOC (muted).</span>")
		return

	if(!holder)
		if(!dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='red'>OOC for dead mobs has been turned off.</span>")
			return
		if(!ooc_allowed && !istype(mob, /mob/dead/new_player))
			to_chat(src, "<span class='red'>OOC is globally muted.[config.ooc_round_only ? " Try again after round end." : ""]</span>")
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<b>Advertising other servers is not allowed.</b>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	var/display_colour = normal_ooc_colour
	var/display_name = key

	if(holder && !holder.fakekey)
		display_colour = "#704f80"
		if(holder.rights & R_DEBUG && !(holder.rights & R_ADMIN))
			display_colour = "#1b521f"	//dark green
		else if(holder.rights & R_ADMIN)
			if(config.allow_admin_ooccolor)
				display_colour = src.prefs.aooccolor
			else
				display_colour = "#b82e00"	//orange

	send2ooc(msg, display_name, display_colour, src)

	world.send2bridge(
		type = list(BRIDGE_OOC),
		attachment_msg = "OOC: **[(holder && holder.fakekey)? holder.fakekey : display_name ]**: [msg]",
		attachment_color = (supporter && prefs.ooccolor) ? prefs.ooccolor : display_colour,
	)

/proc/send2ooc(msg, name, colour, client/sender)
	msg = sanitize(msg)

	if(!msg)
		return

	if(sender)
		log_ooc("[key_name(sender)] : [msg]")
	else
		log_ooc("[name]: [msg]")

	for(var/client/C in clients)
		// Lobby people can only say in OOC to other lobby people.
		if(!ooc_allowed && !istype(C.mob, /mob/dead/new_player) && !C.holder)
			continue
		var/display_name = name

		if(sender)
			if(sender.supporter && sender.prefs.ooccolor)
				display_name = "<span style='color: [sender.prefs.ooccolor]'>[display_name]</span>"

			if(sender.holder && sender.holder.fakekey)
				if(C.holder)
					display_name = "[sender.holder.fakekey]/([sender.key])"
				else
					display_name = sender.holder.fakekey

		if(C.prefs.chat_toggles & CHAT_OOC)
			var/chat_suffix = "[C.holder && istype(sender, /mob/dead/new_player) && !ooc_allowed ? " (LOBBY)" : ""]"
			to_chat(C, "<font color='[colour]'><span class='ooc'><span class='prefix'>OOC[chat_suffix]:</span> <EM>[display_name]:</EM> <span class='message emojify linkify'>[msg]</span></span></font>")

/client/proc/set_global_ooc(newColor as color)
	set name = "Set Global OOC Colour"
	set desc = "Set to yellow for eye burning goodness."
	set category = "OOC"
	if(!holder)
		return
	normal_ooc_colour = newColor

/client/verb/set_name_ooc()
	set name = "Set Name OOC Colour"
	set category = "OOC"

	if(!supporter)
		to_chat(usr, "<span class='warning'>This is only for [config.donate_info_url ? "<a href='[config.donate_info_url]'>supporters</a>" : "supporters"][config.allow_byond_membership ? " <a href='http://www.byond.com/membership'>and Byond Members</a>" : ""].</span>")
		return

	var/new_ooccolor = input(src, "Please select your OOC colour.", "OOC colour") as color|null
	if(new_ooccolor)
		prefs.ooccolor = normalize_color(new_ooccolor)
		prefs.save_preferences()

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

	if(!(prefs.chat_toggles & CHAT_LOOC))
		to_chat(src, "<span class='red'>You have LOOC muted.</span>")
		return

	if(!holder)
		if(!looc_allowed)
			to_chat(src, "<span class='red'>LOOC is globally muted</span>")
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='red'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='red'>You cannot use OOC (muted).</span>")
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
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
	else if(prefs.chat_toggles & CHAT_CKEY)
		display_name += " ([key])"

	log_ooc("(LOCAL) [key_name(mob)] : [msg]")

	var/list/heard = get_mobs_in_view(7, src.mob)
	for(var/mob/M in heard)

		if(!M.client)
			continue
		var/client/C = M.client
		if (C in admins)
			continue //they are handled after that

		if(C.prefs.chat_toggles & CHAT_LOOC)
			if(is_fake_key && C.holder)
				display_name = "[holder.fakekey]/([key])"
			to_chat(C, "<font color='#6699CC'><span class='ooc'><span class='prefix'>LOOC:</span> <EM>[display_name]:</EM> <span class='message emojify linkify'>[msg]</span></span></font>")

	for(var/client/C in admins)
		if(C.prefs.chat_toggles & CHAT_LOOC)
			var/prefix = "(R)LOOC"
			if (C.mob in heard)
				prefix = "LOOC"
			to_chat(C, "<font color='#6699CC'><span class='ooc'><span class='prefix'>[prefix]:</span> <EM>[mob.name]/([key]):</EM> <span class='message emojify linkify'>[msg]</span></span></font>")

/client/verb/fix_chat()
	set name = "Fix chat"
	set category = "OOC"
	if (!chatOutput || !istype(chatOutput))
		var/action = alert(src, "Invalid Chat Output data found!\nRecreate data?", "Wot?", "Recreate Chat Output data", "Cancel")
		if (action != "Recreate Chat Output data")
			return
		chatOutput = new /datum/chatOutput(src)
		chatOutput.start()
		action = alert(src, "Goon chat reloading, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
		if (action == "Fixed")
			log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by re-creating the chatOutput datum")
		else
			chatOutput.load()
			action = alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
			if (action == "Yes")
				log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by re-creating the chatOutput datum and forcing a load()")
			else
				action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
				if (action == "Switch to old chat")
					winset(src, "output", "is-visible=true;is-disabled=false")
					winset(src, "browseroutput", "is-visible=false")
				log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window after recreating the chatOutput and forcing a load()")

	else if (chatOutput.loaded)
		var/action = alert(src, "ChatOutput seems to be loaded\nDo you want me to force a reload, wiping the chat log or just refresh the chat window because it broke/went away?", "Hmmm", "Force Reload", "Refresh", "Cancel")
		switch (action)
			if ("Force Reload")
				chatOutput.loaded = FALSE
				chatOutput.start() //this is likely to fail since it asks , but we should try it anyways so we know.
				action = alert(src, "Goon chat reloading, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
				if (action == "Fixed")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a start()")
				else
					chatOutput.load()
					action = alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
					if (action == "Yes")
						log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a load()")
					else
						action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
						if (action == "Switch to old chat")
							winset(src, "output", "is-visible=true;is-disabled=false")
							winset(src, "browseroutput", "is-visible=false")
						log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window forcing a start() and forcing a load()")

			if ("Refresh")
				chatOutput.showChat()
				action = alert(src, "Goon chat refreshing, wait a bit and tell me if it's fixed", "", "Fixed", "Nope, force a reload")
				if (action == "Fixed")
					log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a show()")
				else
					chatOutput.loaded = FALSE
					chatOutput.load()
					action = alert(src, "How about now? (give it a moment)", "", "Yes", "No")
					if (action == "Yes")
						log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by forcing a load()")
					else
						action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
						if (action == "Switch to old chat")
							winset(src, "output", "is-visible=true;is-disabled=false")
							winset(src, "browseroutput", "is-visible=false")
						log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window forcing a show() and forcing a load()")
		return

	else
		chatOutput.start()
		var/action = alert(src, "Manually loading Chat, wait a bit and tell me if it's fixed", "", "Fixed", "Nope")
		if (action == "Fixed")
			log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by manually calling start()")
		else
			chatOutput.load()
			alert(src, "How about now? (give it a moment (it may also try to load twice))", "", "Yes", "No")
			if (action == "Yes")
				log_game("GOONCHAT: [key_name(src)] Had to fix their goonchat by manually calling start() and forcing a load()")
			else
				action = alert(src, "Welp, I'm all out of ideas. Try closing byond and reconnecting.\nWe could also disable fancy chat and re-enable oldchat", "", "Thanks anyways", "Switch to old chat")
				if (action == "Switch to old chat")
					winset(src, "output", list2params(list("on-show" = "", "is-disabled" = "false", "is-visible" = "true")))
					winset(src, "browseroutput", "is-disabled=true;is-visible=false")
				log_game("GOONCHAT: [key_name(src)] Failed to fix their goonchat window after manually calling start() and forcing a load()")
