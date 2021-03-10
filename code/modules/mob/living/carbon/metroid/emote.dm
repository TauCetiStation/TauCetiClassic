/mob/living/carbon/slime/emote(act, m_type = SHOWMSG_VISUAL, message = null, auto)


	if (findtext(act, "-", 1))
		var/t1 = findtext(act, "-", 1)
		//param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,-1)

	var/regenerate_icons

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
		if("bounce")
			message = "<B>The [src.name]</B> bounces in place."
			m_type = SHOWMSG_VISUAL

		if("jiggle")
			message = "<B>The [src.name]</B> jiggles!"
			m_type = SHOWMSG_VISUAL

		if("light")
			message = "<B>The [src.name]</B> lights up for a bit, then stops."
			m_type = SHOWMSG_VISUAL

		if("moan")
			message = "<B>The [src.name]</B> moans."
			m_type = SHOWMSG_AUDIO

		if("shiver")
			message = "<B>The [src.name]</B> shivers."
			m_type = SHOWMSG_AUDIO

		if("sway")
			message = "<B>The [src.name]</B> sways around dizzily."
			m_type = SHOWMSG_VISUAL

		if("twitch")
			message = "<B>The [src.name]</B> twitches."
			m_type = SHOWMSG_VISUAL

		if("vibrate")
			message = "<B>The [src.name]</B> vibrates!"
			m_type = SHOWMSG_VISUAL

		if ("pray")
			m_type = SHOWMSG_VISUAL
			message = "<b>[src]</b> prays."
			INVOKE_ASYNC(src, /mob.proc/pray_animation)

		if("noface") //mfw I have no face
			mood = null
			regenerate_icons = 1

		if("smile")
			mood = "mischevous"
			regenerate_icons = 1

		if(":3")
			mood = ":33"
			regenerate_icons = 1

		if("pout")
			mood = "pout"
			regenerate_icons = 1

		if("frown")
			mood = "sad"
			regenerate_icons = 1

		if("scowl")
			mood = "angry"
			regenerate_icons = 1

		if ("help") //This is an exception
			to_chat(src, "Help for slime emotes. You can use these emotes with say \"*emote\":\n\nbounce, jiggle, light, moan, shiver, sway, twitch, vibrate. \n\nYou may also change your face with: \n\nsmile, :3, pout, frown, scowl, noface")
		else
			to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
	if ((message && src.stat == CONSCIOUS))
		if (m_type & SHOWMSG_VISUAL)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(703)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(746)

	if (regenerate_icons)
		regenerate_icons()

	return
