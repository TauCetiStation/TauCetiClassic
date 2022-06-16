/datum/emote/list
	key = "list"

/datum/emote/list/get_emote_message_1p(mob/living/carbon/human/user)
	var/msg = "Available emotes, you can do them by saying \"*emote\"(\"*laugh\"):<br>"
	var/first = TRUE

	for(var/emo_key in user.current_emotes)
		var/datum/emote/E = user.current_emotes[emo_key]

		var/key_mod = ""
		var/key_mod_end = ""

		if(E.get_sound(user, TRUE))
			key_mod += "<span class='bold'>"
			key_mod_end += "</span>"

		if(E.cloud)
			key_mod += "<span class='italics'>"
			key_mod_end += "</span>"

		if(!E.check_cooldown(user.next_emote_use, FALSE))
			key_mod += "<span class='warning'>"
			key_mod_end += "</span>"

		if(!first)
			msg += ", "
		first = FALSE
		msg += "[key_mod][E.key][key_mod_end]"

	msg += "."
	return msg
