/datum/emote/help
	key = "help"

/datum/emote/help/get_emote_message_1p(mob/living/carbon/human/user)
	var/msg = "Available emotes, you can do them by saying \"*emote\"(\"*laugh\"):\n"
	var/first = TRUE

	for(var/emo_key in user.current_emotes)
		var/datum/emote/E = user.current_emotes[emo_key]
		if(!E.can_emote(user, intentional=TRUE))
			continue
		var/key_mod = E.sound ? "<span class='bold'>" : ""
		var/key_mod_end = E.sound ? "</span>" : ""
		if(!first)
			msg += ", "
		else
			first = FALSE
		msg += "[key_mod][E.key][key_mod_end]"

	msg += "."
	return msg


/datum/emote/me
	key = "me"

/datum/emote/me/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	INVOKE_ASYNC(user, /mob.proc/custom_emote, SHOWMSG_VISUAL)
