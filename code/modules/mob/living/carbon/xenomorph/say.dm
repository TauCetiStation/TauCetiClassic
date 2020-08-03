/mob/living/carbon/xenomorph/say(message)

	if (silent)
		return

	message = sanitize(message)

	if(!message)
		return

	if(message[1] == "*")
		return emote(copytext(message, 2))

	if (length(message) >= 1)
		if (department_radio_keys[copytext(message, 1, 2 + length(message[2]))] == "alientalk")
			message = copytext(message, 2 + length(message[2]))
			message = trim(message)
			if (stat == DEAD)
				return say_dead(message)
			else
				alien_talk(message)
		else
			if (!stat)
				playsound(src, pick(SOUNDIN_XENOMORPH_TALK), VOL_EFFECTS_MASTER, 45) // So aliens can hiss while they hiss yo/N
			return ..("<span class='alien'>[message]</span>", sanitize = 0)

/mob/living/carbon/xenomorph/facehugger/say(message)

	if (silent)
		return

	message = sanitize(message)

	if (length(message) >= 1)
		if (department_radio_keys[copytext(message, 1, 2 + length(message[2]))] == "alientalk")
			message = copytext(message, 2 + length(message[2]))
			message = trim(message)
			if (stat == DEAD)
				return say_dead(message)
			else
				alien_talk(message)

/mob/living/proc/alien_talk(message)

	log_say("[key_name(src)] : [message]")
	message = trim(message)

	if (!message)
		return

	//var/message_a = sanitize_chat(say_quote(message))
	//на бэй опять рефакторят, нужно обновить эту часть кода. А пока, так
	var/message_a = "<span class='say_quote'>hisses,</span> \"<span class='body'>[message]</span>\""

	var/rendered = "<i><span class='game say'>Hivemind, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"
	for (var/mob/living/S in player_list)
		if(!S.stat)
			if(S.alien_talk_understand)
				if(S.alien_talk_understand == alien_talk_understand)
					S.show_message(rendered, SHOWMSG_AUDIO)
			else if (S.hivecheck())
				S.show_message(rendered, SHOWMSG_AUDIO)

	var/list/listening = hearers(1, src)
	listening -= src
	listening += src

	var/list/heard = list()
	for (var/mob/M in listening)
		if(!isxeno(M) && !M.alien_talk_understand)
			heard += M


	if (length(heard))
		var/message_b

		//message_b = "hsssss"
		//message_b = say_quote(message_b)
		message_b = "<span class='say_quote'>hisses,</span> \"<span class='body'>hsssss</span>\""

		message_b = "<i>[message_b]</i>"
		rendered = "<i><span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span></i>"

		for (var/mob/M in heard)
			M.show_message(rendered, SHOWMSG_AUDIO)

	//message = say_quote(message)
	message = "<span class='say_quote'>hisses,</span> \"<span class='body'>[message]</span>\""

	rendered = "<i><span class='game say'>Hivemind, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"

	for (var/mob/M in player_list)
		if (isnewplayer(M))
			continue
		if (M.stat > 1)
			to_chat(rendered)
