#define CAN_MAKE_A_SOUND !muzzled && (last_sound_emote < world.time)
/mob/living/carbon/alien/humanoid/emote(act, m_type = 1, message = null)

	if(stat == DEAD && (act != "deathgasp"))
		return
	if(stat == UNCONSCIOUS)
		return
	if(findtext(act, "s", -1) && !findtext(act, "_", -2)) // Removes ending s's unless they are prefixed with a '_'
		if(act != "hiss")
			act = copytext(act, 1, length(act))
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)

	switch(act)

//  ========== SOUNDED ==========

		if ("deathgasp")
			message = "<B>[src]</B> lets out a waning guttural screech, green blood bubbling from its maw..."
			m_type = 1
			to_chat(src, "<span class='warning'>Pretending to be dead is not a good idea. I must fight for my Queen!</span>")
			if(CAN_MAKE_A_SOUND)
				playsound(src, 'sound/voice/xenomorph/death_1.ogg', VOL_EFFECTS_MASTER, 50)
				last_sound_emote = world.time + 7 SECONDS
		if("whimper")
			message = "<B>The [src.name]</B> sadly [pick("screeches", "whines")]."
			m_type = 2
			if(CAN_MAKE_A_SOUND)
				playsound(src, 'sound/voice/xenomorph/whimper.ogg', VOL_EFFECTS_MASTER, 25)
		if("roar")
			message = "<B>The [src.name]</B>[pick(" triumphantly", " menacingly", "")] roars."
			m_type = 2
			if(CAN_MAKE_A_SOUND)
				playsound(src, pick(SOUNDIN_XENOMORPH_ROAR), VOL_EFFECTS_MASTER, vary = FALSE)
		if("hiss")
			message = "<B>The [src.name]</B>[pick(" predatory", " dissatisfied", " maliciously", " menacingly", " suspiciously", "")] hisses!"
			m_type = 2
			if(CAN_MAKE_A_SOUND)
				playsound(src, pick(SOUNDIN_XENOMORPH_HISS), VOL_EFFECTS_MASTER, vary = FALSE)
		if("growl")
			message = "<B>The [src.name]</B>[pick(" relaxed", " predatory", " excitedly", " joyfully", " maliciously", " menacingly", " suspiciously", "")] growls."
			m_type = 2
			if(CAN_MAKE_A_SOUND)
				playsound(src, pick(SOUNDIN_XENOMORPH_GROWL), VOL_EFFECTS_MASTER, vary = FALSE)

//  ========== BASIC ==========

		if("scratch")
			message = "<B>The [src.name]</B> [pick("maliciously", "menacingly", "excitedly", "erotically")] scratches the floor with its claws on its feet."
			m_type = 1
		if("tail")
			message = "<B>The [src.name]</B>[pick("", " menacingly", " slyly", " deftly", " erotically")] waves its tail."
			m_type = 1
		if("twitch")
			message = "<B>The [src.name]</B> [pick("unbearably", "mockingly")] twitches."
			m_type = 1
		if("drool")
			message = "<B>The [src.name]</B> drools [pick("like a true predator", "hungry")]."
			m_type = 1
		if("nod")
			message = "<B>The [src.name]</B> [pick("slowly", "predatory")] nods its head."
			m_type = 1
		if("sway")
			message = "<B>The [src.name]</B> sways around [pick("dizzily", "drunkenly", "wearily")]."
			m_type = 1
		if("sulk")
			message = "<B>The [src.name]</B> [pick("sulks down sadly", "sadly lowers its head")]."
			m_type = 1
		if("shake")
			message = "<B>The [src.name]</B> shakes its head [pick("like a true hunter", "and it seems to be grinning at you")]."
			m_type = 1
		if("jump")
			message = "<B>The [src.name]</B>[pick(" happily", " joyfully", "")] jumps!"
			m_type = 1

//  ========== EXTENDED ==========

		if("dance")
			if (!src.restrained())
				message = "<B>The [src.name]</B> [pick("deftly", "quickly", "erotically", "joyfully")] moves its body."
				m_type = 1
		if("roll")
			if (!src.restrained())
				message = "<B>The [src.name]</B> falls on its back and[pick("", " cheerfully", " awkwardly")] rolls on the floor kinda like a kitten. [pick("Really cute.", "Very cute.", "So cute!")]"
				m_type = 1
				if(prob(50)) // xenomorphs are not kittens!
					to_chat(src, "<span class='warning'>You feel shame. [pick("You want to hunt, not waste time", "You're not an obedient girl", "You're not a good girl")].</span>")
		if("sit")
			message = "<B>The [src.name]</B> sits down[pick(" like a good girl", " wearily", " and turns its tail into a ball")]."
			m_type = 1
			if(prob(50)) // xenomorphs are not good girls!
				to_chat(src, "<span class='warning'>You feel shame. [pick("You want to hunt, not waste time", "You're not an obedient girl", "You're not a good girl")].</span>")
		if("grin")
			if (!muzzled)
				message = "<B>The [src.name]</B>[pick(" makes something like a smile and", "")] grinning its white[pick(" and crooked", " and slobbering", "")] teeth."
				m_type = 1

//  ========== SPECIAL ==========

		if ("custom")
			var/input = sanitize(input("Choose an emote to display.") as text|null)
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible", "Hearable")
			if (input2 == "Visible")
				m_type = 1
			else if (input2 == "Hearable")
				if(has_trait(TRAIT_MUTE))
					return
				m_type = 2
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
		if(muzzled && (m_type & 2))
			message = "<B>The [src.name]</B>[pick("", " looks around angrily and", " shakes violently and")] makes a[pick("", " faint", " weak", " quiet")] noise."
		if(m_type & 2)
			if(last_sound_emote < world.time)
				last_sound_emote = world.time + 7 SECONDS
			else
				to_chat(src, "<span class='warning'>You notice you make too much noises! You can give out your location to the hosts, you don't want to risk it!</span>")
				return
		log_emote("[name]/[key] : [message]")

		for(var/mob/M in observer_list)
			if(!M.client)
				continue //skip leavers
			if((M.client.prefs.chat_toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)

		if(m_type & 1)
			for(var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if(m_type & 2)
			for(var/mob/O in hearers(src, null))
				O.show_message(message, m_type)

#undef CAN_MAKE_A_SOUND
