/mob
	var/list/default_emotes
	var/list/current_emotes

	var/list/next_emote_use
	var/list/next_audio_emote_produce

/mob/proc/emote_dead(message)

	if(client.prefs.muted & MUTE_DEADCHAT)
		to_chat(src, "<span class='warning'>You cannot send deadchat emotes (muted).</span>")
		return

	if(!(client.prefs.chat_toggles & CHAT_DEAD))
		to_chat(src, "<span class='warning'>You have deadchat muted.</span>")
		return

	if(!src.client.holder)
		if(!dsay_allowed)
			to_chat(src, "<span class='warning'>Deadchat is globally muted</span>")
			return


	if(!message)
		message = sanitize(input(src, "Choose an emote to display.") as text|null)

	if(message)
		message = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[src]</span> <span class='message'>[message]</span></span>"
	else
		return


	log_emote("Ghost/[key_name(src)] : [message]")

	for(var/mob/M in player_list)
		var/tracker = "[FOLLOW_LINK(M, src)] "
		if(isnewplayer(M))
			continue

		if(M.client && M.client.holder && (M.client.holder.rights & R_ADMIN) && (M.client.prefs.chat_toggles & CHAT_DEAD)) // Show the emote to admins
			to_chat(M, tracker + message)

		else if(M.stat == DEAD && (M.client.prefs.chat_toggles & CHAT_DEAD)) // Show the emote to regular ghosts with deadchat toggled on
			to_chat(M, tracker + message)

/mob/atom_init()
	. = ..()
	load_default_emotes()

/mob/proc/load_default_emotes()
	for(var/emote in default_emotes)
		var/datum/emote/E = global.all_emotes[emote]
		set_emote(E.key, E)
	default_emotes = null

/mob/proc/get_emote(key)
	return LAZYACCESS(current_emotes, key)

/mob/proc/set_emote(key, datum/emote/emo)
	LAZYSET(current_emotes, key, emo)

/mob/proc/clear_emote(key)
	LAZYREMOVE(current_emotes, key)

/mob/proc/emote(act, intentional = FALSE)
	var/datum/emote/emo = get_emote(act)
	if(!emo)
		return

	if(!emo.can_emote(src, intentional))
		return

	emo.do_emote(src, act, intentional)

// A simpler emote. Just the message, and it's type. If you want anything more complex - make a datumized emote.
/mob/proc/me_emote(message, message_type = SHOWMSG_VISUAL, intentional = FALSE)
	log_emote("[key_name(src)] : [message]")

	var/msg = "<b>[src]</b> <i>[message]</i>"
	if(message_type & SHOWMSG_VISUAL)
		visible_message(msg, ignored_mobs = observer_list, runechat_msg = message)
	else
		audible_message(msg, ignored_mobs = observer_list, runechat_msg = message)

	for(var/mob/M as anything in observer_list)
		if(!M.client)
			continue

		if(M in viewers(get_turf(src), world.view))
			M.show_runechat_message(src, null, message, null, SHOWMSG_VISUAL)

		switch(M.client.prefs.chat_ghostsight)
			if(CHAT_GHOSTSIGHT_ALL)
				// ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here
				to_chat(M, "[FOLLOW_LINK(M, src)] [msg]")
			if(CHAT_GHOSTSIGHT_ALLMANUAL)
				if(intentional)
					to_chat(M, "[FOLLOW_LINK(M, src)] [msg]")
