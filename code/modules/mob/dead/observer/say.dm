/mob/dead/observer/say(message)
	message = sanitize(message)

	if (!message)
		return

	log_say("Ghost/[key_name(src)] : [message]")

	. = say_dead(message)


/mob/dead/observer/me_emote(message, message_type = SHOWMSG_VISUAL, intentional=FALSE)
	log_emote("Ghost/[key_name(src)] : [message]")

	if(client)
		if(client.prefs.muted & MUTE_OOC || IS_ON_ADMIN_CD(client, ADMIN_CD_OOC))
			to_chat(src, "<span class='alert'>You cannot emote in deadchat (muted).</span>")
			return

		if(client.handle_spam_prevention(message, ADMIN_CD_OOC))
			return

	return emote_dead(message)
