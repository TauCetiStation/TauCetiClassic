/mob/living/carbon/xenomorph/larva/emote(act, m_type = SHOWMSG_VISUAL, message = null, auto)
	if(stat == UNCONSCIOUS)
		return
	if (findtext(act, "-", 1))
		var/t1 = findtext(act, "-", 1)
		act = copytext(act, 1, t1)

	if(findtext(act, "s", -1) && !findtext(act, "_", -2))//Removes ending s's unless they are prefixed with a '_'
		if(act != "hiss")
			act = copytext(act, 1, -1)
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)

	switch(act)

//  ========== SOUNDED ==========

		if("hiss")
			message = "<B>The [src.name]</B> hisses softly."
			m_type = SHOWMSG_AUDIO
		if("growl")
			message = "<B>The [src.name]</B> growls softly."
			m_type = SHOWMSG_AUDIO
		if("whimper")
			message = "<B>The [src.name]</B> whimpers sadly."
			m_type = SHOWMSG_AUDIO
		if("roar")
			message = "<B>The [src.name]</B> roars [pick("softly", "like a little predator")]."
			m_type = SHOWMSG_AUDIO

//  ========== BASIC ==========

		if("tail")
			message = "<B>The [src.name]</B> waves its tail[pick(" like a snake", "")]."
			m_type = SHOWMSG_VISUAL
		if("drool")
			message = "<B>The [src.name]</B> drools [pick("like a little predator", "hungry")]."
			m_type = SHOWMSG_VISUAL
		if("nod")
			message = "<B>The [src.name]</B> nods its head."
			m_type = SHOWMSG_VISUAL
		if("sit")
			message = "<B>The [src.name]</B> sits down [pick("and curls up in a ball", "like a little kitten")]."
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
		if("shake")
			message = "<B>The [src.name]</B> shakes its head."
			m_type = SHOWMSG_VISUAL

//  ========== EXTENDED ==========

		if("dance")
			if (!src.restrained())
				message = "<B>The [src.name]</B> dances around [pick("happily", "joyfully")]."
				m_type = SHOWMSG_VISUAL
		if("roll")
			if (!src.restrained())
				message = "<B>The [src.name]</B> rolls [pick("like a snake", "on the floor", "around itslef")]."
				m_type = SHOWMSG_VISUAL
		if("gnarl")
			if(!muzzled)
				message = "<B>The [src.name]</B> gnarls and shows its teeth."
				m_type = SHOWMSG_VISUAL
		if("jump")
			if(!src.restrained())
				message = "<B>The [src.name]</B> jumps around[pick(" happily", " joyfully", "")]."
				m_type = SHOWMSG_VISUAL
		if("scratch")
			if (!src.restrained())
				message = "<B>The [src.name]</B> scratches."
				m_type = SHOWMSG_VISUAL
		if ("pray")
			m_type = SHOWMSG_VISUAL
			message = "<b>[src]</b> prays."
			INVOKE_ASYNC(src, /mob.proc/pray_animation)

//  ========== SPECIAL ==========

		if ("custom")
			var/input = sanitize(input("Choose an emote to display.") as text|null)
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = SHOWMSG_VISUAL
			else if (input2 == "Hearable")
				if (HAS_TRAIT(src, TRAIT_MUTE))
					return
				m_type = SHOWMSG_AUDIO
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			return custom_emote(m_type, message)
		if ("me")
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
		if("help")
			to_chat(src, "<span class ='notice'>SOUNDED IN <B>BOLD</B>:   dance, drool, grin, jump, <B>hiss</B>, nod, <B>roar</B>, roll, custom, \
			                                                              scratch, shake, sit, sway, tail, twitch, <B>whimper</B>, <B>growl</B></span>")
		else
			to_chat(src, "<span class='notice'>This action is not provided: \"[act]\". Write \"*help\" to find out all available emotes. Write \"*custom\" to do your own emote. \
			                                   Otherwise, you can perform your action via the \"F4\" button.</span>")
	if(message)
		if(muzzled && (m_type & SHOWMSG_AUDIO))
			message = "<B>The [src.name]</B>[pick("", " looks around angrily and", " shakes violently and")] makes a[pick("", " very faint", " very weak", " very quiet")] noise."
		if(m_type & SHOWMSG_AUDIO)
			if(last_sound_emote < world.time)
				last_sound_emote = world.time + 4 SECONDS
			else
				to_chat(src, "<span class='warning'>You notice you make too much noises! You can give out your location to the hosts, you don't want to risk it!</span>")
				return
		log_emote("[key_name(src)] : [message]")

		for(var/mob/M in observer_list)
			if(!M.client)
				continue //skip leavers
			if((M.client.prefs.chat_ghostsight != CHAT_GHOSTSIGHT_NEARBYMOBS) && !(M in viewers(src, null)))
				to_chat(M, "<a href='byond://?src=\ref[src];track=\ref[src]'>(F)</a> [message]") // ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here

		if(m_type & SHOWMSG_VISUAL)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if(m_type & SHOWMSG_AUDIO)
			if(!muzzled)
				playsound(src, 'sound/voice/xenomorph/small_roar.ogg', VOL_EFFECTS_MASTER, 60)
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
