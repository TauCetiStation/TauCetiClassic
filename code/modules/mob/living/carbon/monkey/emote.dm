/mob/living/carbon/monkey/emote(act, m_type = SHOWMSG_VISUAL, message = null, auto)

	var/param = null
	if (findtext(act, "-", 1))
		var/t1 = findtext(act, "-", 1)
		param = copytext(act, t1 + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,-1)

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)

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

		if ("chirp")
			if(istype(src,/mob/living/carbon/monkey/diona))
				message = "<B>The [src.name]</B> chirps!"
				playsound(src, 'sound/misc/nymphchirp.ogg', VOL_EFFECTS_MASTER, null, FALSE)
				m_type = SHOWMSG_AUDIO
		if("sign")
			if (!src.restrained())
				message = text("<B>The monkey</B> signs[].", (text2num(param) ? text(" the number []", text2num(param)) : null))
				m_type = SHOWMSG_VISUAL
		if("scratch")
			if (!src.restrained())
				message = "<B>The [src.name]</B> scratches."
				m_type = SHOWMSG_VISUAL
		if("whimper")
			if (!muzzled)
				message = "<B>The [src.name]</B> whimpers."
				m_type = SHOWMSG_AUDIO
		if("roar")
			if (!muzzled)
				message = "<B>The [src.name]</B> roars."
				m_type = SHOWMSG_AUDIO
		if("tail")
			message = "<B>The [src.name]</B> waves his tail."
			m_type = SHOWMSG_VISUAL
		if("gasp")
			message = "<B>The [src.name]</B> gasps."
			m_type = SHOWMSG_AUDIO
		if("shiver")
			message = "<B>The [src.name]</B> shivers."
			m_type = SHOWMSG_AUDIO
		if("drool")
			message = "<B>The [src.name]</B> drools."
			m_type = SHOWMSG_VISUAL
		if("paw")
			if (!src.restrained())
				message = "<B>The [src.name]</B> flails his paw."
				m_type = SHOWMSG_VISUAL
		if("scretch")
			if (!muzzled)
				message = "<B>The [src.name]</B> scretches."
				m_type = SHOWMSG_AUDIO
		if("choke")
			message = "<B>The [src.name]</B> chokes."
			m_type = SHOWMSG_AUDIO
		if("moan")
			message = "<B>The [src.name]</B> moans!"
			m_type = SHOWMSG_AUDIO
		if("nod")
			message = "<B>The [src.name]</B> nods his head."
			m_type = SHOWMSG_VISUAL
		if("sit")
			message = "<B>The [src.name]</B> sits down."
			m_type = SHOWMSG_VISUAL
		if("sway")
			message = "<B>The [src.name]</B> sways around dizzily."
			m_type = SHOWMSG_VISUAL
		if("sulk")
			message = "<B>The [src.name]</B> sulks down sadly."
			m_type = SHOWMSG_VISUAL
		if("twitch")
			message = "<B>The [src.name]</B> twitches violently."
			m_type = SHOWMSG_VISUAL
		if("dance")
			if (!src.restrained())
				message = "<B>The [src.name]</B> dances around happily."
				m_type = SHOWMSG_VISUAL
		if("roll")
			if (!src.restrained())
				message = "<B>The [src.name]</B> rolls."
				m_type = SHOWMSG_VISUAL
		if("shake")
			message = "<B>The [src.name]</B> shakes his head."
			m_type = SHOWMSG_VISUAL
		if("gnarl")
			if (!muzzled)
				message = "<B>The [src.name]</B> gnarls and shows his teeth.."
				m_type = SHOWMSG_AUDIO
		if("jump")
			message = "<B>The [src.name]</B> jumps!"
			m_type = SHOWMSG_VISUAL
		if("collapse")
			Paralyse(2)
			message = text("<B>[]</B> collapses!", src)
			m_type = SHOWMSG_AUDIO
		if("deathgasp")
			message = "<b>The [src.name]</b> lets out a faint chimper as it collapses and stops moving..."
			m_type = SHOWMSG_VISUAL
		if("cough")
			if(istype(src,/mob/living/carbon/monkey/diona))
				message = "<B>The [src.name]</B> shrinks and twitches slightly"
				m_type = SHOWMSG_VISUAL
			else
				message = "<B>The [src.name]</B> coughs!"
				m_type = SHOWMSG_AUDIO
		if ("pray")
			m_type = SHOWMSG_VISUAL
			message = "<b>[src]</b> prays."
			INVOKE_ASYNC(src, /mob.proc/pray_animation)
		if("help")
			var/text = "choke, "
			if(istype(src,/mob/living/carbon/monkey/diona))
				text += "chirp, "
			text += "collapse, cough, dance, deathgasp, drool, gasp, shiver, gnarl, jump, paw, moan, nod, roar, roll, scratch,\nscretch, shake, sign-#, sit, sulk, sway, tail, twitch, whimper"
			to_chat(src, text)
		else
			to_chat(src, text("Invalid Emote: []", act))
	if ((message && src.stat == CONSCIOUS))
		if(src.client)
			log_emote("[key_name(src)] : [message]")
		if (m_type & SHOWMSG_VISUAL)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(703)
		else
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
				//Foreach goto(746)
	return
