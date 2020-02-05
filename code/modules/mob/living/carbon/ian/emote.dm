/mob/living/carbon/ian/emote(act, m_type = SHOWMSG_AUDIO, message = null)
	var/param = null
	if(findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act, "s", -1) && !findtext(act, "_", -2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act, 1, length(act))

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
			message = "<B>[src]</B> blinks."
			m_type = SHOWMSG_VISUAL

		if ("blink_r")
			message = "<B>[src]</B> blinks rapidly."
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
			message = "<B>[src]</B> twitches violently."
			m_type = SHOWMSG_VISUAL
		if ("twitch_s")
			message = "<B>[src]</B> twitches."
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
		if ("point")
			if (!restrained())
				var/atom/target = null
				if (param)
					for (var/atom/A as mob|obj|turf in oview())
						if (param == A.name)
							target = A
							break
				if (!target)
					message = "<span class='notice'><b>[src]</b> points.</span>"
				else
					pointed(target)
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
			if((M.client.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				to_chat(M, message)

		if (m_type & SHOWMSG_VISUAL)
			for (var/mob/O in get_mobs_in_view(world.view,src))
				O.show_message(message, m_type)
		else if (m_type & SHOWMSG_AUDIO)
			for (var/mob/O in (hearers(src.loc, null) | get_mobs_in_view(world.view,src)))
				O.show_message(message, m_type)
