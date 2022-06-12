// All mobs should have custom emote, really. TODO: Put all emotions into one proc. Copy paste is bad, it is everywere in different emote procs
/mob/proc/custom_emote(m_type = SHOWMSG_VISUAL, message = null)
	if(stat || !me_verb_allowed && usr == src)
		to_chat(usr, "You are unable to emote.")
		return

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	if(m_type == SHOWMSG_AUDIO && muzzled)
		return

	if(!message)
		message = sanitize(input(src,"Choose an emote to display.") as text|null)

	if(message)
		message = "<span class='emote'><B>[src]</B> [message]</span>"
	else
		return

	log_emote("[key_name(src)] : [message]")

	if(findtext(message," snores.") == 0) // Hearing gasp and such every five seconds is not good emotes were not global for a reason.
		for(var/mob/M in player_list)
			if(isnewplayer(M))
				continue
			if((M.stat == DEAD) && (M.client.prefs.chat_ghostsight in list(CHAT_GHOSTSIGHT_ALL, CHAT_GHOSTSIGHT_ALLMANUAL)) && !(M in viewers(src, null)))
				to_chat(M, message)

	var/list/to_check
	var/list/feel_emote
	// Type 1 (Visual) emotes are sent to anyone in view of the item
	if(m_type & SHOWMSG_VISUAL)
		feel_emote = view(1, src)
		to_check = viewers(src, null)
	// Type 2 (Audible) emotes are sent to anyone in hear range
	// of the *LOCATION* -- this is important for pAIs to be heard
	else if(m_type & SHOWMSG_AUDIO)
		to_check = hearers(get_turf(src), null)

	for(var/mob/O in to_check)
		if(O.status_flags & PASSEMOTES)
			for(var/obj/item/weapon/holder/thing in O.contents)
				thing.show_message(message, m_type)
		if(m_type & SHOWMSG_VISUAL && (O in feel_emote))
			O.show_message(message, SHOWMSG_FEEL)
			continue
		O.show_message(message, m_type)

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
		if(isnewplayer(M))
			continue

		if(M.client && M.client.holder && (M.client.holder.rights & R_ADMIN) && (M.client.prefs.chat_toggles & CHAT_DEAD)) // Show the emote to admins
			to_chat(M, message)

		else if(M.stat == DEAD && (M.client.prefs.chat_toggles & CHAT_DEAD)) // Show the emote to regular ghosts with deadchat toggled on
			to_chat(M, message)

/mob/proc/can_me_emote(message_type, intentional)
	if(stat)
		if(intentional)
			to_chat(src, "You are unable to emote.")
		return FALSE

	if(!me_verb_allowed && intentional)
		to_chat(src, "You are unable to emote.")
		return FALSE

	var/can_audio_emote = !istype(wear_mask, /obj/item/clothing/mask/muzzle) && !HAS_TRAIT(src, TRAIT_MUTE)
	if(message_type == SHOWMSG_AUDIO && !can_audio_emote)
		if(intentional)
			to_chat(src, "You are unable to make such noises.")
		return FALSE

	return TRUE

// A simpler emote. Just the message, and it's type. If you want anything more complex - make a datumized emote.
/mob/proc/me_emote(message, message_type = SHOWMSG_VISUAL, intentional=FALSE)
	if(!can_me_emote(message_type, intentional))
		return

	log_emote("[key_name(src)] : [message]")

	var/msg = "<b>[src]</b> <i>[message]</i>"
	if(message_type & SHOWMSG_VISUAL)
		visible_message(msg, ignored_mobs = observer_list)
	else
		audible_message(msg, ignored_mobs = observer_list)

	for(var/mob/M as anything in observer_list)
		if(!M.client)
			continue

		switch(M.client.prefs.chat_ghostsight)
			if(CHAT_GHOSTSIGHT_ALL)
				// ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here
				to_chat(M, "[FOLLOW_LINK(M, src)] [msg]")
			if(CHAT_GHOSTSIGHT_ALLMANUAL)
				if(intentional)
					to_chat(M, "[FOLLOW_LINK(M, src)] [msg]")
