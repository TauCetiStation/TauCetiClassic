#define CAN_MAKE_A_SOUND !muzzled && (last_sound_emote < world.time)

/mob/living/carbon/xenomorph/humanoid/emote(act, m_type = SHOWMSG_VISUAL, message = null, auto)
	if(stat == DEAD && (act != "deathgasp"))
		return
	if(stat == UNCONSCIOUS)
		return
	if(findtext(act, "s", -1) && !findtext(act, "_", -2)) // Removes ending s's unless they are prefixed with a '_'
		if(act != "hiss")
			act = copytext(act, 1, -1)
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)

	// These scare the enemies out, causing them to lose 10 combo points.
	if(act == "scream")
		act = pick("roar", "growl", "hiss")

	switch(act)

//  ========== SOUNDED ==========

		if ("deathgasp")
			message = "<B>[src]</B> lets out a waning guttural screech, green blood bubbling from its maw..."
			m_type = SHOWMSG_VISUAL
			to_chat(src, "<span class='warning'>Pretending to be dead is not a good idea. I must fight for my Queen!</span>")
			if(CAN_MAKE_A_SOUND)
				playsound(src, 'sound/voice/xenomorph/death_1.ogg', VOL_EFFECTS_MASTER, 50)
				last_sound_emote = world.time + 7 SECONDS
		if("whimper")
			message = "<B>The [src.name]</B> sadly [pick("screeches", "whines")]."
			m_type = SHOWMSG_AUDIO
			if(CAN_MAKE_A_SOUND)
				playsound(src, 'sound/voice/xenomorph/whimper.ogg', VOL_EFFECTS_MASTER, 25)

			add_combo_value_all(10)
		if("roar")
			message = "<B>The [src.name]</B>[pick(" triumphantly", " menacingly", "")] roars."
			m_type = SHOWMSG_AUDIO
			if(CAN_MAKE_A_SOUND)
				playsound(src, pick(SOUNDIN_XENOMORPH_ROAR), VOL_EFFECTS_MASTER, vary = FALSE)

			add_combo_value_all(-10)
		if("hiss")
			message = "<B>The [src.name]</B>[pick(" predatory", " dissatisfied", " maliciously", " menacingly", " suspiciously", "")] hisses!"
			m_type = SHOWMSG_AUDIO
			if(CAN_MAKE_A_SOUND)
				playsound(src, pick(SOUNDIN_XENOMORPH_HISS), VOL_EFFECTS_MASTER, vary = FALSE)

			add_combo_value_all(-10)
		if("growl")
			message = "<B>The [src.name]</B>[pick(" relaxed", " predatory", " excitedly", " joyfully", " maliciously", " menacingly", " suspiciously", "")] growls."
			m_type = SHOWMSG_AUDIO
			if(CAN_MAKE_A_SOUND)
				playsound(src, pick(SOUNDIN_XENOMORPH_GROWL), VOL_EFFECTS_MASTER, vary = FALSE)

			add_combo_value_all(-10)

//  ========== BASIC ==========

		if("scratch")
			message = "<B>The [src.name]</B> [pick("maliciously", "menacingly", "excitedly", "erotically")] scratches the floor with its claws on its feet."
			m_type = SHOWMSG_VISUAL
		if("tail")
			message = "<B>The [src.name]</B>[pick("", " menacingly", " slyly", " deftly", " erotically")] waves its tail."
			m_type = SHOWMSG_VISUAL
		if("twitch")
			message = "<B>The [src.name]</B> [pick("unbearably", "mockingly")] twitches."
			m_type = SHOWMSG_VISUAL
		if("drool")
			message = "<B>The [src.name]</B> drools [pick("like a true predator", "hungry")]."
			m_type = SHOWMSG_VISUAL
		if("nod")
			message = "<B>The [src.name]</B> [pick("slowly", "predatory")] nods its head."
			m_type = SHOWMSG_VISUAL
		if("sway")
			message = "<B>The [src.name]</B> sways around [pick("dizzily", "drunkenly", "wearily")]."
			m_type = SHOWMSG_VISUAL
		if("sulk")
			message = "<B>The [src.name]</B> [pick("sulks down sadly", "sadly lowers its head")]."
			m_type = SHOWMSG_VISUAL
		if("shake")
			message = "<B>The [src.name]</B> shakes its head [pick("like a true hunter", "and it seems to be grinning at you")]."
			m_type = SHOWMSG_VISUAL
		if("jump")
			message = "<B>The [src.name]</B>[pick(" happily", " joyfully", "")] jumps!"
			m_type = SHOWMSG_VISUAL

		if ("pray")
			m_type = SHOWMSG_VISUAL
			message = "<b>[src]</b> prays."
			INVOKE_ASYNC(src, /mob.proc/pray_animation)

//  ========== EXTENDED ==========

		if("dance")
			if (!src.restrained())
				message = "<B>The [src.name]</B> [pick("deftly", "quickly", "erotically", "joyfully")] moves its body."
				m_type = SHOWMSG_VISUAL
		if("roll")
			if (!src.restrained())
				message = "<B>The [src.name]</B> falls on its back and[pick("", " cheerfully", " awkwardly")] rolls on the floor kinda like a kitten. [pick("Really cute.", "Very cute.", "So cute!")]"
				m_type = SHOWMSG_VISUAL
				if(prob(50)) // xenomorphs are not kittens!
					to_chat(src, "<span class='warning'>You feel shame. [pick("You want to hunt, not waste time", "You're not an obedient girl", "You're not a good girl")].</span>")
		if("sit")
			message = "<B>The [src.name]</B> sits down[pick(" like a good girl", " wearily", " and turns its tail into a ball")]."
			m_type = SHOWMSG_VISUAL
			if(prob(50)) // xenomorphs are not good girls!
				to_chat(src, "<span class='warning'>You feel shame. [pick("You want to hunt, not waste time", "You're not an obedient girl", "You're not a good girl")].</span>")
		if("grin")
			if (!muzzled)
				message = "<B>The [src.name]</B>[pick(" makes something like a smile and", "")] grinning its white[pick(" and crooked", " and slobbering", "")] teeth."
				m_type = SHOWMSG_VISUAL

//  ========== SPECIAL ==========

		if ("custom")
			var/input = sanitize(input("Choose an emote to display.") as text|null)
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible", "Hearable")
			if (input2 == "Visible")
				m_type = SHOWMSG_VISUAL
			else if (input2 == "Hearable")
				if(HAS_TRAIT(src, TRAIT_MUTE))
					return
				m_type = SHOWMSG_AUDIO
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			return custom_emote(m_type, message)
		if ("me")
			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class='danger'>You cannot send IC messages(muted).</span>")
					return
				if (src.client.handle_spam_prevention(message,MUTE_IC))
					return
			if (stat)
				return
			if(!(message))
				return
			return custom_emote(m_type, message)
		if("help")
			to_chat(src, "<span class ='notice'>SOUNDED IN <B>BOLD</B>:   <B>deathgasp</B>, dance, drool, grin, jump, <B>hiss</B>, nod, custom, <B>roar</B>, \
			                                                              roll, scratch, shake, sit, sway, tail, twitch, <B>whimper</B>, <B>growl</B></span>")
		else
			to_chat(src, "<span class='notice'>This action is not provided: \"[act]\". Write \"*help\" to find out all available emotes. Write \"*custom\" to do your own emote. \
			                                   Otherwise, you can perform your action via the \"F4\" button.</span>")


	if(message)
		if(muzzled && (m_type & SHOWMSG_AUDIO))
			message = "<B>The [src.name]</B>[pick("", " looks around angrily and", " shakes violently and")] makes a[pick("", " faint", " weak", " quiet")] noise."
		if(m_type & SHOWMSG_AUDIO)
			if(last_sound_emote < world.time)
				last_sound_emote = world.time + 7 SECONDS
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
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)

#undef CAN_MAKE_A_SOUND
