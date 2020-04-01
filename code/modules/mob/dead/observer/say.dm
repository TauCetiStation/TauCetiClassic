/mob/dead/observer/say(var/message)
	message = sanitize(message)

	if (!message)
		return

	log_say("Ghost/[src.key] : [message]")

	if (src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "<span class='alert'>You cannot talk in deadchat (muted).</span>")
			return

		if (src.client.handle_spam_prevention(message,MUTE_DEADCHAT))
			return

	. = src.say_dead(message)


/mob/dead/observer/emote(act, type, message, auto)
	message = sanitize(message)

	if(!message)
		return

	if(act != "me")
		return

	log_emote("Ghost/[key_name(src)] : [message]")

	if(src.client)
		if(src.client.prefs.muted & MUTE_DEADCHAT)
			to_chat(src, "<span class='alert'>You cannot emote in deadchat (muted).</span>")
			return

		if(src.client.handle_spam_prevention(message, MUTE_DEADCHAT))
			return

	. = src.emote_dead(message)
