/mob/living/carbon/brain/emote(act, m_type = SHOWMSG_VISUAL, message = null, auto)
	if(!(container && istype(container, /obj/item/device/mmi)))//No MMI, no emotes
		return

	if (findtext(act, "-", 1))
		var/t1 = findtext(act, "-", 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act, 1, -1)

	if(src.stat == DEAD)
		return
	switch(act)
		if ("me")
			if(silent)
				return
			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='warning'>You cannot send IC messages (muted).</span>")
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)

		if ("custom")
			return custom_emote(m_type, message)
		if ("alarm")
			to_chat(src, "You sound an alarm.")
			message = "<B>[src]</B> sounds an alarm."
			m_type = SHOWMSG_AUDIO
		if ("alert")
			to_chat(src, "You let out a distressed noise.")
			message = "<B>[src]</B> lets out a distressed noise."
			m_type = SHOWMSG_AUDIO
		if ("notice")
			to_chat(src, "You play a loud tone.")
			message = "<B>[src]</B> plays a loud tone."
			m_type = SHOWMSG_AUDIO
		if ("flash")
			message = "The lights on <B>[src]</B> flash quickly."
			m_type = SHOWMSG_VISUAL
		if ("blink")
			message = "<B>[src]</B> blinks."
			m_type = SHOWMSG_VISUAL
		if ("whistle")
			to_chat(src, "You whistle.")
			message = "<B>[src]</B> whistles."
			m_type = SHOWMSG_AUDIO
		if ("beep")
			to_chat(src, "You beep.")
			message = "<B>[src]</B> beeps."
			m_type = SHOWMSG_AUDIO
		if ("boop")
			to_chat(src, "You boop.")
			message = "<B>[src]</B> boops."
			m_type = SHOWMSG_AUDIO
		if ("pray")
			m_type = SHOWMSG_VISUAL
			message = "<b>[src]</b> prays."
			INVOKE_ASYNC(src, /mob.proc/pray_animation)
		if ("help")
			to_chat(src, "alarm,alert,notice,flash,blink,whistle,beep,boop")
		else
			to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")

	if (message)
		log_emote("[key_name(src)] : [message]")

		for(var/mob/M in observer_list)
			if (!M.client)
				continue //skip leavers
			if((M.client.prefs.chat_ghostsight != CHAT_GHOSTSIGHT_NEARBYMOBS) && !(M in viewers(src, null)))
				to_chat(M, "<a href='byond://?src=\ref[src];track=\ref[src]'>(F)</a> [message]") // ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here

		if (m_type & SHOWMSG_VISUAL)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if (m_type & SHOWMSG_AUDIO)
			for (var/mob/O in hearers(src.loc, null))
				O.show_message(message, m_type)
