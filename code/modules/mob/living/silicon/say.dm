/mob/living/silicon/say_quote(text)
	var/ending = copytext(text, -1)

	if (ending == "?")
		return "queries"
	else if (ending == "!")
		return "declares"

	return "states"

#define IS_AI 1
#define IS_ROBOT 2
#define IS_PAI 3

/mob/living/silicon/say_understands(other,datum/language/speaking = null)
	//These only pertain to common. Languages are handled by mob/say_understands()
	if (!speaking)
		if (iscarbon(other) && !isIAN(other))
			return 1
		if (issilicon(other))
			return 1
		if (isbrain(other))
			return 1
	return ..()

/mob/living/silicon/say(var/message)

	/*if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (src.client.handle_spam_prevention(message,MUTE_IC))
			return*/

	message = sanitize(message)

	if(!message)
		return

	if (stat == DEAD)
		return say_dead(message)

	if(message[1] == "*")
		return emote(copytext(message,2))

	var/bot_type = 0			//Let's not do a fuck ton of type checks, thanks.
	if(istype(src, /mob/living/silicon/ai))
		bot_type = IS_AI
	else if(istype(src, /mob/living/silicon/robot))
		bot_type = IS_ROBOT
	else if(istype(src, /mob/living/silicon/pai))
		bot_type = IS_PAI

	var/mob/living/silicon/ai/AI = src		//and let's not declare vars over and over and over for these guys.
	var/mob/living/silicon/robot/R = src
	var/mob/living/silicon/pai/P = src


	//Must be concious to speak
	if (stat)
		return

	var/verb = say_quote(message)

	//parse radio key and consume it
	var/message_mode = parse_message_mode(message, "general")
	if (message_mode)
		if (message_mode == "general")
			message = trim(copytext(message,2))
		else
			message = trim(copytext(message,2 + length(message[2])))

	if(message_mode && bot_type == IS_ROBOT && message_mode != "binary" && !R.is_component_functioning("radio"))
		to_chat(src, "<span class='warning'>Your radio isn't functional at this time.</span>")
		return
	if(bot_type == IS_ROBOT && message_mode != "binary")
		var/datum/robot_component/radio/RA = R.get_component("radio")
		if (!R.cell_use_power(RA.active_usage))
			to_chat(usr, "<span class='warning'>Not enough power to transmit message.</span>")
			return

	//parse language key and consume it
	var/datum/language/speaking = parse_language(message)
	if (speaking)
		verb = speaking.speech_verb
		message = trim(copytext(message,2+length_char(speaking.key)))

	var/area/A = get_area(src)

	switch(message_mode)
		if("department")
			switch(bot_type)
				if(IS_AI)
					return AI.holopad_talk(message, verb, speaking)
				if(IS_ROBOT)
					log_say("[key_name(src)] : \[[A.name][message_mode?"/[message_mode]":""]\]: [message]")
					R.radio.talk_into(src,message,message_mode,verb,speaking)
				if(IS_PAI)
					log_say("[key_name(src)] : \[[A.name][message_mode?"/[message_mode]":""]\]]: [message]")
					P.radio.talk_into(src,message,message_mode,verb,speaking)
			return 1

		if("binary")
			switch(bot_type)
				if(IS_ROBOT)
					if(!R.is_component_functioning("comms"))
						to_chat(src, "<span class='warning'>Your binary communications component isn't functional.</span>")
						return
					var/datum/robot_component/binary_communication/B = R.get_component("comms")
					if(!R.cell_use_power(B.active_usage))
						to_chat(src, "<span class='warning'>Not enough power to transmit message.</span>")
						return
				if(IS_PAI)
					to_chat(src, "You do not appear to have that function")
					return

			robot_talk(message)
			return 1
		if("general")
			switch(bot_type)
				if(IS_AI)
					if (AI.aiRadio.disabledAi)
						to_chat(src, "<span class='warning'>System Error - Transceiver Disabled</span>")
						return
					else
						log_say("[key_name(src)] : \[[A.name][message_mode?"/[message_mode]":""]\]]: [message]")
						AI.aiRadio.talk_into(src,message,null,verb,speaking)
				if(IS_ROBOT)
					log_say("[key_name(src)] : \[[A.name][message_mode?"/[message_mode]":""]\]]: [message]")
					R.radio.talk_into(src,message,null,verb,speaking)
				if(IS_PAI)
					log_say("[key_name(src)] : \[[A.name][message_mode?"/[message_mode]":""]\]]: [message]")
					P.radio.talk_into(src,message,null,verb,speaking)
			return 1

		else
			if(message_mode && (message_mode in radiochannels))
				switch(bot_type)
					if(IS_AI)
						if (AI.aiRadio.disabledAi)
							to_chat(src, "<span class='warning'>System Error - Transceiver Disabled</span>")
							return
						else
							log_say("[key_name(src)] : \[[A.name][message_mode?"/[message_mode]":""]\]]: [message]")
							AI.aiRadio.talk_into(src,message,message_mode,verb,speaking)
					if(IS_ROBOT)
						log_say("[key_name(src)] : \[[A.name][message_mode?"/[message_mode]":""]\]]: [message]")
						R.radio.talk_into(src,message,message_mode,verb,speaking)
					if(IS_PAI)
						log_say("[key_name(src)] : \[[A.name][message_mode?"/[message_mode]":""]\]]: [message]")
						P.radio.talk_into(src,message,message_mode,verb,speaking)
				return 1

	return ..(html_decode(message),speaking,verb)

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(message, verb, datum/language/speaking)

	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if (!message)
		return

	var/obj/machinery/hologram/holopad/T = src.holo
	if(T && T.hologram && T.master == src)//If there is a hologram and its master is the user.

		//Human-like, sorta, heard by those who understand humans.
		var/rendered_a
		//Speach distorted, heard by those who do not understand AIs.
		var/message_stars = stars(message)
		var/rendered_b

		if(speaking)
			rendered_a = "<span class='game say'><span class='name'>[name]</span> [speaking.format_message(message, verb)]</span>"
			rendered_b = "<span class='game say'><span class='name'>[voice_name]</span> [speaking.format_message(message_stars, verb)]</span>"
			to_chat(src, "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> [speaking.format_message(message, verb)]</span></i>")//The AI can "hear" its own message.
		else
			rendered_a = "<span class='game say'><span class='name'>[name]</span> [verb], <span class='message'>\"[message]\"</span></span>"
			rendered_b = "<span class='game say'><span class='name'>[voice_name]</span> [verb], <span class='message'>\"[message_stars]\"</span></span>"
			to_chat(src, "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> [verb], <span class='message'><span class='body'>\"[message]\"</span></span></span></i>")//The AI can "hear" its own message.

		for(var/mob/M in hearers(T.loc))//The location is the object, default distance.
			if(M.say_understands(src))//If they understand AI speak. Humans and the like will be able to.
				M.show_message(rendered_a, SHOWMSG_AUDIO)
			else//If they do not.
				M.show_message(rendered_b, SHOWMSG_AUDIO)
		/*Radios "filter out" this conversation channel so we don't need to account for them.
		This is another way of saying that we won't bother dealing with them.*/
	else
		to_chat(src, "No holopad connected.")
		return
	return 1

/mob/living/proc/robot_talk(message)

	message = trim(message)

	if (!message)
		return

	var/area/A = get_area(src)
	log_say("[key_name(src)] : \[[A.name]/binary\]: [message]")

	var/verb = say_quote(message)


	var/rendered = "<i><span class='binarysay'>Robotic Talk, <span class='name'>[name]</span> <span class='message'>[verb], \"[message]\"</span></span></i>"

	for (var/mob/living/S in alive_mob_list)
		if(S.robot_talk_understand && (S.robot_talk_understand == robot_talk_understand)) // This SHOULD catch everything caught by the one below, but I'm not going to change it.
			if(istype(S , /mob/living/silicon/ai))
				var/renderedAI = "<i><span class='binarysay'>Robotic Talk, <a href='byond://?src=\ref[S];track2=\ref[S];track=\ref[src];trackname=[html_encode(src.name)]'><span class='name'>[name]</span></a> <span class='message'>[verb], \"[message]\"</span></span></i>"
				S.show_message(renderedAI, SHOWMSG_AUDIO)
			else if(istype(S, /mob/living/carbon/brain))
				S.show_message(rendered, SHOWMSG_AUDIO)
			else
				var/mob/living/silicon/robot/borg = S
				//if(istype(borg) && borg.is_component_functioning("comms"))
				//	var/datum/robot_component/RC = borg.get_component("comms")
				//	if(!borg.use_power(RC.active_usage))
				if(!istype(borg) || !borg.is_component_functioning("comms"))
					continue // No power.
				S.show_message(rendered, SHOWMSG_AUDIO)


		else if (S.binarycheck())
			if(istype(S , /mob/living/silicon/ai))
				var/renderedAI = "<i><span class='binarysay'>Robotic Talk, <a href='byond://?src=\ref[S];track2=\ref[S];track=\ref[src];trackname=[html_encode(src.name)]'><span class='name'>[name]</span></a> <span class='message'>[verb], \"[message]\"</span></span></i>"
				S.show_message(renderedAI, SHOWMSG_AUDIO)
			else
				S.show_message(rendered, SHOWMSG_AUDIO)

	var/list/listening = hearers(1, src)
	listening -= src

	var/list/heard = list()
	for (var/mob/M in listening)
		if(!istype(M, /mob/living/silicon) && !M.robot_talk_understand)
			heard += M
	if (length(heard))
		var/message_beep
		verb = "beeps"
		message_beep = "beep beep beep"

		rendered = "<i><span class='binarysay'><span class='name'>[voice_name]</span> <span class='message'>[verb], \"[message_beep]\"</span></span></i>"

		for (var/mob/M in heard)
			M.show_message(rendered, SHOWMSG_AUDIO)

	rendered = "<i><span class='binarysay'>Robotic Talk, <span class='name'>[name]</span> <span class='message'>[verb], \"[message]\"</span></span></i>"

	to_chat(observer_list, rendered)

#undef IS_AI
#undef IS_ROBOT
#undef IS_PAI
