/mob/living/carbon/xenomorph/say(message)

	if(silent)
		return

	message = sanitize(message)

	if(!message)
		return

	if(stat == DEAD)
		return say_dead(message)

	var/datum/language/xeno_language = all_languages["Xenomorph language"]

	if(message[1] == "*")
		return emote(copytext(message, 2))

	if(length(message) >= 2)
		if(parse_message_mode(message) == "alientalk")
			message = copytext(message, 2 + length(message[2]))
			message = trim(message)
			alien_talk(message)
			return

	if(stat == CONSCIOUS)
		playsound(src, pick(SOUNDIN_XENOMORPH_TALK), VOL_EFFECTS_MASTER, 45) // So aliens can hiss while they hiss yo/N
		return ..(message, xeno_language, sanitize = 0)

/mob/living/carbon/xenomorph/facehugger/say(message)

	if(silent)
		return

	message = sanitize(message)

	if(!message)
		return

	if(stat == DEAD)
		return say_dead(message)
	else
		alien_talk(message)

/mob/living/proc/alien_talk(message)
	if(!message)
		return

	message = trim(message)
	log_say("[key_name(src)] : УЛЕЙ: [name] шепчет, [message]")

	var/tag = isxenoqueen(src) ? "hive_queen" : "hive"

	var/rendered = "<span class='[tag]'>УЛЕЙ: <i>[name] шепчет, \"[message]\"</i></span>"
	for(var/key in alien_list)
		for(var/mob/living/carbon/xenomorph/S in alien_list[key])
			if(!S.client)
				continue
			if(S.stat == CONSCIOUS)
				S.show_message(rendered, SHOWMSG_AUDIO)

	for(var/mob/M in observer_list)
		if(!M.client)
			continue
		var/tracker = FOLLOW_LINK(M, src)
		to_chat(M, "[tracker] [rendered]")

	var/list/listening = hearers(1, src)
	listening -= src

	var/list/heard = list()
	for(var/mob/M in listening)
		if(!isxeno(M) && !M.alien_talk_understand)
			heard += M

	if(length(heard))
		rendered = "<span class='name'>[voice_name]</span> <span class='alien'>шепчет, \"хссссс\"</span>"

		for(var/mob/M in heard)
			M.show_message(rendered, SHOWMSG_AUDIO)
