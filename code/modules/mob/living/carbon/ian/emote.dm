/mob/living/carbon/ian/emote(act, m_type = SHOWMSG_AUDIO, message = null, auto)
	if(findtext(act, "s", -1) && !findtext(act, "_", -2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act, 1, -1)

	if(src.stat == DEAD && (act != "deathgasp"))
		return

	switch(act)
		if("me")
			if(silent)
				return
			if(client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='red'>You cannot send IC messages (muted).</span>")
					return
				if(client.handle_spam_prevention(message,MUTE_IC))
					return
			if(stat || !message)
				return
			return custom_emote(m_type, message)

		if ("blink")
			message = "<B>[src]</B> [pick("blinks", "blinks rapidly")]."
			m_type = SHOWMSG_VISUAL
		if("custom")
			return custom_emote(m_type, message)
		if("scratch")
			if(!restrained())
				message = "<B>[src]</B> scratches."
				m_type = SHOWMSG_VISUAL
		if("whimper")
			message = "<B>[src]</B> whimpers."
			m_type = SHOWMSG_AUDIO
		if("roar")
			message = "<B>[src]</B> roars."
			m_type = SHOWMSG_AUDIO
		if("tail")
			message = "<B>[src]</B> waves his tail."
			m_type = SHOWMSG_VISUAL
		if("gasp")
			message = "<B>[src]</B> gasps."
			m_type = SHOWMSG_AUDIO
		if("shiver")
			message = "<B>[src]</B> shivers."
			m_type = SHOWMSG_AUDIO
		if("drool")
			message = "<B>[src]</B> drools."
			m_type = SHOWMSG_VISUAL
		if ("eyebrow")
			message = "<B>[src]</B> raises an eyebrow."
			m_type = SHOWMSG_VISUAL
		if("paw")
			if(!restrained())
				message = "<B>[src]</B> flails his paw."
				m_type = SHOWMSG_VISUAL
		if("choke")
			message = "<B>[src]</B> chokes."
			m_type = SHOWMSG_AUDIO
		if("moan")
			message = "<B>[src]</B> moans!"
			m_type = SHOWMSG_AUDIO
		if("nod")
			message = "<B>[src]</B> nods."
			m_type = SHOWMSG_VISUAL
		if("sit")
			message = "<B>[src]</B> sits down."
			m_type = SHOWMSG_VISUAL
		if("sway")
			message = "<B>[src]</B> sways around dizzily."
			m_type = SHOWMSG_VISUAL
		if("sulk")
			message = "<B>[src]</B> sulks down sadly."
			m_type = SHOWMSG_VISUAL
		if("twitch")
			message = "<B>[src]</B> [pick("twitches violently", "twitches")]."
			m_type = SHOWMSG_VISUAL
		if ("faint")
			message = "<B>[src]</B> faints."
			if(IsSleeping())
				return
			SetSleeping(20 SECONDS)
			m_type = SHOWMSG_VISUAL
		if("dance")
			if(!restrained())
				message = pick("<B>[src]</B> dances around.","chases its tail")
				m_type = SHOWMSG_VISUAL
		if("roll")
			if(!restrained())
				message = "<B>[src]</B> rolls."
				m_type = SHOWMSG_VISUAL
		if("shake")
			message = "<B>[src]</B> shakes head."
			m_type = SHOWMSG_VISUAL
		if("gnarl")
			message = "<B>[src]</B> gnarls and shows his teeth.."
			m_type = SHOWMSG_AUDIO
		if("jump")
			message = "<B>[src]</B> jumps!"
			m_type = SHOWMSG_VISUAL
		if("collapse")
			Paralyse(2)
			message = "<B>[src]</B> collapses!"
			m_type = SHOWMSG_AUDIO
		if("deathgasp")
			message = "<B>[src]</B> seizes up and falls limp, \his eyes dead and lifeless..."
			m_type = SHOWMSG_VISUAL
		if("cough")
			message = "<B>[src]</B> coughs!"
			m_type = SHOWMSG_AUDIO
		if ("pray")
			m_type = SHOWMSG_VISUAL
			message = "<b>[src]</b> prays."
			INVOKE_ASYNC(src, /mob.proc/pray_animation)
		if("help")
			to_chat(src, "blink, blink_r, choke, collapse, cough, eyebrow, faint, dance, deathgasp, drool, gasp, shiver, gnarl, jump, point, paw, moan, nod,\nroar, roll, scratch, shake, sit, sulk, sway, tail, twitch, twitch_s, whimper")
		else
			to_chat(src, "Invalid Emote: [act]")

	if(message)
		if(client)
			log_emote("[key_name(src)] : [message]")

		for(var/mob/M in observer_list)
			if(!M.client)
				continue //skip leavers
			if((M.client.prefs.chat_ghostsight != CHAT_GHOSTSIGHT_NEARBYMOBS) && !(M in viewers(src, null)))
				to_chat(M, "<a href='byond://?src=\ref[src];track=\ref[src]'>(F)</a> [message]") // ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here

		if (m_type & SHOWMSG_VISUAL)
			for (var/mob/O in get_mobs_in_view(world.view,src))
				O.show_message(message, m_type)
		else if (m_type & SHOWMSG_AUDIO)
			for (var/mob/O in (hearers(src.loc, null) | get_mobs_in_view(world.view,src)))
				O.show_message(message, m_type)
