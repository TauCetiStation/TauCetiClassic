/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"

/mob/living/captive_brain/say(message)

	if (client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
		if (client.handle_spam_prevention(message,MUTE_IC))
			return

	message = sanitize(message)

	log_say("[key_name(src)] : [message]")

	if(istype(loc, /mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = loc
		to_chat(src, "You whisper silently, \"[message]\"")
		to_chat(B.host, "The captive mind of [src] whispers, \"[message]\"")

		for (var/mob/M in player_list)
			if (isnewplayer(M))
				continue
			if(M.stat == DEAD &&  M.client.prefs.chat_toggles & CHAT_GHOSTEARS)
				to_chat(M, "[FOLLOW_LINK(M, src)] The captive mind of [src] whispers, \"[message]\"")

/mob/living/captive_brain/emote(act, m_type = SHOWMSG_VISUAL, message, auto)
	return

/mob/living/captive_brain/resist()
	var/mob/living/simple_animal/borer/B = src.loc

	to_chat(src, "<span class='danger'>You begin doggedly resisting the parasite's control (this will take approximately sixty seconds).</span>")
	to_chat(B.host, "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>")

	spawn(rand(350,450)+B.host.brainloss)

		if(!B || !B.controlling)
			return

		B.host.adjustBrainLoss(rand(5,10))
		to_chat(src, "<span class='danger'>With an immense exertion of will, you regain control of your body!</span>")
		to_chat(B.host, "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>")
		B.controlling = 0

		B.ckey = B.host.ckey
		B.host.ckey = src.ckey

		src.ckey = null
		src.name = "host brain"
		src.real_name = "host brain"
