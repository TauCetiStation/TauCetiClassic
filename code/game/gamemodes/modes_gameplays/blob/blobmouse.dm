/mob/living/simple_animal/mouse/blob

// copypaste from mob/camera/blob/say
// TODO: we should make a hivechat datum at some point for hivechatters
/mob/living/simple_animal/mouse/blob/say(message)
	if (!message)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return

	message = sanitize(message)

	log_say("[key_name(src)] : [message]")

	if (!message)
		return

	//var/message_a = say_quote(message)
	message = "<span class='say_quote'>says,</span> \"<span class='body'>[message]</span>\""
	message = "<font color=\"#EE4000\"><i><span class='game say'>Blob Telepathy, <span class='name'>[name]</span> <span class='message'>[message]</span></span></i></font>"

	for (var/mob/M in mob_list)
		if(isovermind(M) || isobserver(M) || istype(M, /mob/living/simple_animal/mouse/blob))
			to_chat(M, message)


