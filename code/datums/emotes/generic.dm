/datum/emote/help
	key = "help"

/datum/emote/help/get_emote_message_1p(mob/living/carbon/human/user)
	var/msg = "Available emotes, you can do them by saying \"*emote\"(\"*laugh\"):<br>"
	var/first = TRUE

	for(var/emo_key in user.current_emotes)
		var/datum/emote/E = user.current_emotes[emo_key]
		var/emote_sound = E.get_sound(user, TRUE)

		var/key_mod = emote_sound ? "<span class='bold'>" : ""
		var/key_mod_end = emote_sound ? "</span>" : ""
		if(!first)
			msg += ", "
		first = FALSE
		msg += "[key_mod][E.key][key_mod_end]"

	msg += "."
	return msg
