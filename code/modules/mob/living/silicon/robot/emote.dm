/mob/living/silicon/robot/emote(act, m_type = SHOWMSG_VISUAL, message = null, auto)
	var/param = null
	if (findtext(act, "-", 1))
		var/t1 = findtext(act, "-", 1)
		param = copytext(act, t1 + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,-1)

	switch(act)
		if ("me")
			if (src.client)
				if(client.prefs.muted & MUTE_IC)
					to_chat(src, "You cannot send IC messages (muted).")
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			else
				return custom_emote(m_type, message)

		if ("custom")
			return custom_emote(m_type, message)

		if ("salute")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					message = "<B>[src]</B> salutes to [param]."
				else
					message = "<B>[src]</b> salutes."
			m_type = SHOWMSG_VISUAL

		if ("bow")
			if (!src.buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null
				if (param)
					message = "<B>[src]</B> bows to [param]."
				else
					message = "<B>[src]</B> bows."
			m_type = SHOWMSG_VISUAL

		if ("clap")
			if (!src.restrained())
				message = "<B>[src]</B> claps."
				m_type = SHOWMSG_AUDIO

		if ("twitch")
			message = "<B>[src]</B> [pick("twitches violently", "twitches")]."
			m_type = SHOWMSG_VISUAL

		if ("nod")
			message = "<B>[src]</B> nods."
			m_type = SHOWMSG_VISUAL

		if ("deathgasp")
			message = "<B>[src]</B> shudders violently for a moment, then becomes motionless, its eyes slowly darkening."
			m_type = SHOWMSG_VISUAL

		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> glares at [param]."
			else
				message = "<B>[src]</B> glares."

		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> stares at [param]."
			else
				message = "<B>[src]</B> stares."

		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break

			if (!M)
				param = null

			if (param)
				message = "<B>[src]</B> looks at [param]."
			else
				message = "<B>[src]</B> looks."
			m_type = SHOWMSG_VISUAL

		if("beep")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> beeps at [param]."
			else
				message = "<B>[src]</B> beeps."
			playsound(src, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			m_type = SHOWMSG_VISUAL

		if("ping")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> pings at [param]."
			else
				message = "<B>[src]</B> pings."
			playsound(src, 'sound/machines/ping.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			m_type = SHOWMSG_VISUAL

		if("buzz")
			var/M = null
			if(param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if(!M)
				param = null

			if (param)
				message = "<B>[src]</B> buzzes at [param]."
			else
				message = "<B>[src]</B> buzzes."
			playsound(src, 'sound/machines/buzz-sigh.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			m_type = SHOWMSG_VISUAL

		if("law")
			if (istype(module,/obj/item/weapon/robot_module/security))
				message = "<B>[src]</B> shows its legal authorization barcode."

				playsound(src, 'sound/voice/beepsky/iamthelaw.ogg', VOL_EFFECTS_MASTER, null, FALSE)
				m_type = SHOWMSG_AUDIO
			else
				to_chat(src, "You are not THE LAW, pal.")

		if("halt")
			if (istype(module,/obj/item/weapon/robot_module/security))
				message = "<B>[src]</B>'s speakers skreech, \"Halt! Security!\"."

				playsound(src, 'sound/voice/halt.ogg', VOL_EFFECTS_MASTER, null, FALSE)
				m_type = SHOWMSG_AUDIO
			else
				to_chat(src, "You are not security.")

		if ("pray")
			m_type = SHOWMSG_VISUAL
			message = "<b>[src]</b> prays."
			INVOKE_ASYNC(src, /mob.proc/pray_animation)

		if ("help")
			to_chat(src, "salute, bow-(none)/mob, clap, flap, aflap, twitch, twitch_s, nod, deathgasp, glare-(none)/mob, stare-(none)/mob, look, beep, ping, \nbuzz, law, halt")
		else
			to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")

	if ((message && src.stat == CONSCIOUS))
		if (m_type & SHOWMSG_VISUAL)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
	return
