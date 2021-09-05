/proc/send_pda_message(mob/living/user, sender, obj/item/device/pda/recepient, text, obj/machinery/message_server/useMS = null, system = FALSE)
	var/obj/item/device/pda/senderPDA = null
	if (istype(sender, /obj/item/device/pda))
		senderPDA = sender

	// check if messaging server is stable
	if (!useMS)
		if(message_servers)
			for (var/obj/machinery/message_server/MS in message_servers)
				if(MS.active)
					useMS = MS
					break
	
	var/atom/signal_user = isnull(user) ? recepient : isnull(senderPDA) ? useMS : senderPDA
	if (!signal_user)
		return
	var/datum/signal/signal = signal_user.telecomms_process()

	// check if telecomms I/O route 1459 is stable
	var/useTC = 0
	if (signal)
		if (signal.data["done"])
			useTC = 1
			var/turf/pos = get_turf(recepient)
			if (pos.z in signal.data["level"])
				useTC = 2
				//Let's make this barely readable
				if (signal.data["compression"] > 0)
					text = Gibberish(text, signal.data["compression"] + 50)

	if (useMS && useTC) // only send the message if it's stable
		if (useTC != 2) // Does our recipient have a broadcaster on their level?
			if (user)
				to_chat(user, "ERROR: Cannot reach recipient.")
			return
		if (senderPDA)
			senderPDA.tnote.Add(list(list("sent" = 1, "owner" = "[recepient.owner]", "job" = "[recepient.ownjob]", "message" = "[text]", "target" = "\ref[recepient]")))
			recepient.tnote.Add(list(list("sent" = 0, "owner" = "[senderPDA.owner]", "job" = "[senderPDA.ownjob]", "message" = "[text]", "target" = "\ref[senderPDA]")))
			useMS.save_pda_message("[recepient.owner] ([recepient.ownjob])","[senderPDA.owner]","[text]")
		else
			useMS.save_pda_message("[recepient.owner] ([recepient.ownjob]","[sender]","[text]")
		for (var/mob/M in player_list)
			if (M.stat == DEAD && M.client && (M.client.prefs.chat_toggles & CHAT_GHOSTEARS)) // sender.client is so that ghosts don't have to listen to mice
				if (isnewplayer(M))
					continue
				if (senderPDA)
					to_chat(M, "<span class='game say'>PDA Message - <span class='name'>[senderPDA.owner]</span> -> <span class='name'>[recepient.owner]</span>: <span class='message emojify linkify'>[text]</span></span>")
				else
					to_chat(M, "<span class='game say'>Fake PDA Message - <span class='name'>[sender]</span> -> <span class='name'>[recepient.owner]</span>: <span class='message emojify linkify'>[text]</span></span>")

		if (senderPDA)
			if (!senderPDA.conversations.Find("\ref[recepient]"))
				senderPDA.conversations.Add("\ref[recepient]")
			if (!recepient.conversations.Find("\ref[senderPDA]"))
				recepient.conversations.Add("\ref[senderPDA]")

		if (prob(15) && !system) //Give the AI a chance of intercepting the message
			var/who = senderPDA ? senderPDA.owner : sender
			if (prob(50))
				who = recepient.owner
			for (var/mob/living/silicon/ai/ai in ai_list)
				// Allows other AIs to intercept the message but the AI won't intercept their own message.
				if (ai.pda != recepient && ai.pda != senderPDA)
					to_chat(ai, "<i>Intercepted message from <b>[who]</b>: <span class='emojify linkify'>[text]</span></i>")

		if (user && senderPDA)
			nanomanager.update_user_uis(user, senderPDA) // Update the sending user's PDA UI so that they can see the new message

		if (!recepient.message_silent)
			playsound(recepient, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
			recepient.audible_message("[bicon(recepient)] *[recepient.ttone]*", hearing_distance = 3)

		//Search for holder of the PDA.
		var/mob/living/L = null
		if (recepient.loc && isliving(recepient.loc))
			L = recepient.loc
			text = highlight_traitor_codewords(text, L.mind)
		//Maybe they are a pAI!
		else
			L = get(recepient, /mob/living/silicon)


		if (L)
			if (senderPDA)
				to_chat(L, "[bicon(recepient)] <b>Message from [senderPDA.owner] ([senderPDA.ownjob]), </b>\"<span class='message emojify linkify'>[text]</span>\" (<a href='byond://?src=\ref[recepient];choice=Message;notap=[istype(senderPDA.loc, /mob/living/silicon)];skiprefresh=1;target=\ref[sender]'>Reply</a>)")
			else
				to_chat(L, "[bicon(recepient)] <b>Message from [sender], </b>\"<span class='message emojify linkify'>[text]</span>\"")
			nanomanager.update_user_uis(L, recepient) // Update the receiving user's PDA UI so that they can see the new message

		if (user && senderPDA)
			nanomanager.update_user_uis(user, recepient) // Update the sending user's PDA UI so that they can see the new message

		if (senderPDA)
			log_pda("[user] (PDA: [senderPDA.name]) sent \"[text]\" to [recepient.name]")
		else
			log_pda("[user] (PDA: [sender]) sent \"[text]\" to [recepient.name]")
		recepient.cut_overlays()
		recepient.add_overlay(image('icons/obj/pda.dmi', "pda-r"))
		recepient.newmessage = 1
	else
		if (user && !system)
			to_chat(user, "<span class='notice'>ERROR: Messaging server is not responding.</span>")
