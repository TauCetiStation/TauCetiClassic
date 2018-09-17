/mob/living/carbon/human/say(message, ignore_appearance)
	var/verb = "says"
	var/message_range = world.view
	var/italics = 0
	var/alt_name = ""
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='userdange'>You cannot speak in IC (Muted).</span>")
			return

	//Meme stuff
	if((!speech_allowed && usr == src) || miming)
		to_chat(usr, "<span class='userdange'>You can't speak.</span>")
		return

	message =  sanitize(message)

	if(stat == DEAD)
		if(fake_death) //Our changeling with fake_death status must not speak in dead chat!!
			return
		return say_dead(message)

	var/message_mode = parse_message_mode(message, "headset")

	if (istype(wear_mask, /obj/item/clothing/mask/muzzle) && !(message_mode == "changeling" || message_mode == "alientalk"))  //Todo:  Add this to speech_problem_flag checks.
		return

	if(copytext(message,1,2) == "*")
		return emote(copytext(message,2))

	if(!ignore_appearance && name != GetVoice())
		alt_name = "(as [get_id_name("Unknown")])"

	//parse the radio code and consume it
	if (message_mode)
		if (message_mode == "headset")
			message = copytext(message,2)	//it would be really nice if the parse procs could do this for us.
		else
			message = copytext(message,3)

	//parse the language code and consume it or use default racial language if forced.
	var/datum/language/speaking = parse_language(message)
	if (speaking)
		message = copytext(message,2+length(speaking.key))
	else if(species.force_racial_language)
		speaking = all_languages[species.language]
	else
		switch(species.name)
			if(TAJARAN)
				message = replacetext(message, "р", pick(list("ррр" , "рр")))
				message = replacetext(message, "Р", pick(list("Ррр" , "Рр")))
			if(UNATHI)
				message = replacetext(message, "с", pick(list("ссс" , "сс")))
				//И для заглавной... Фигова копипаста. Кто знает решение без второй обработки для заглавной буквы, обязательно переделайте.
				message = replacetext(message, "С", pick(list("Ссс" , "Сс")))
			if(ABDUCTOR)
				var/mob/living/carbon/human/user = usr
				var/sm = sanitize(message)
				for(var/mob/living/carbon/human/H in mob_list)
					if(H.species.name != ABDUCTOR)
						continue
					else
						if(user.team != H.team)
							continue
						else
							to_chat(H, text("<span class='abductor_team[]'><b>[user.real_name]:</b> [sm]</span>", user.team))
							//return - technically you can add more aliens to a team
				for(var/mob/M in dead_mob_list)
					to_chat(M, text("<span class='abductor_team[]'><b>[user.real_name]:</b> [sm]</span>", user.team))
					if(!isobserver(M) && (M.stat != DEAD))
						to_chat(M, "<hr><span class='warning'>Если вы видите это сообщение, значит что-то сломалось. Пожалуйста, свЯжитесь со мной <b>SpaiR</b> на форуме (http://tauceti.ru/forums/index.php?action=profile;u=1929) или попросите кого-нибудь менЯ позвать. Пожалуйста, <u>запомните</u> что произошло в раунде, эта информациЯ очень <b>важна</b>. Чтобы сообщение исчезло попросите админа достать вас из тела и поместить обратно или сами уйдите в обсерверы.</span><hr>")
				log_say("Abductor: [name]/[key] : [sm]")
				return ""

	message = capitalize(trim(message))
	if(iszombie(src))
		message = zombie_talk(message)

	var/ending = copytext(message, length(message))
	if (speaking)
		//If we've gotten this far, keep going!
		verb = speaking.get_spoken_verb(ending)
	else
		if(ending=="!")
			verb=pick("exclaims","shouts","yells")
		if(ending=="?")
			verb="asks"

	if(speech_problem_flag)
		var/list/handle_r = handle_speech_problems(message, message_mode)
		//var/list/handle_r = handle_speech_problems(message)
		message = handle_r[1]
		verb = handle_r[2]
		speech_problem_flag = handle_r[3]

	if(!message || stat)
		return

	var/list/obj/item/used_radios = new

	switch (message_mode)
		if("headset")
			if(l_ear && istype(l_ear,/obj/item/device/radio))
				var/obj/item/device/radio/R = l_ear
				R.talk_into(src,message,null,verb,speaking)
				used_radios += l_ear
			else if(r_ear && istype(r_ear,/obj/item/device/radio))
				var/obj/item/device/radio/R = r_ear
				R.talk_into(src,message,null,verb,speaking)
				used_radios += r_ear

		if("right ear")
			var/obj/item/device/radio/R
			var/has_radio = 0
			if(r_ear && istype(r_ear,/obj/item/device/radio))
				R = r_ear
				has_radio = 1
			if(r_hand && istype(r_hand, /obj/item/device/radio))
				R = r_hand
				has_radio = 1
			if(has_radio)
				R.talk_into(src,message,null,verb,speaking)
				used_radios += R


		if("left ear")
			var/obj/item/device/radio/R
			var/has_radio = 0
			if(l_ear && istype(l_ear,/obj/item/device/radio))
				R = l_ear
				has_radio = 1
			if(l_hand && istype(l_hand,/obj/item/device/radio))
				R = l_hand
				has_radio = 1
			if(has_radio)
				R.talk_into(src,message,null,verb,speaking)
				used_radios += R

		if("intercom")
			for(var/obj/item/device/radio/intercom/I in view(1, null))
				I.talk_into(src, message, verb, speaking)
				used_radios += I
		if("whisper")
			whisper_say(message, speaking, alt_name)
			return
		if("binary")
			if(robot_talk_understand || binarycheck())
				robot_talk(message)
			return
		if("changeling")
			if(mind && mind.changeling)
				var/n_message = message
				log_say("Changeling Mind: [mind.changeling.changelingID]/[mind.name]/[key] : [n_message]")
				for(var/mob/Changeling in mob_list)
					if(Changeling.mind && Changeling.mind.changeling)
						to_chat(Changeling, "<span class='changeling'><b>[mind.changeling.changelingID]:</b> [n_message]</span>")
						for(var/M in Changeling.mind.changeling.essences)
							to_chat(M, "<span class='changeling'><b>[mind.changeling.changelingID]:</b> [n_message]</span>")

					else if(isobserver(Changeling))
						to_chat(Changeling, "<span class='changeling'><b>[mind.changeling.changelingID]:</b> [n_message]</span>")
			return
		if("alientalk")
			if(mind && mind.changeling)
				var/n_message = message
				for(var/M in mind.changeling.essences)
					to_chat(M, "<span class='shadowling'><b>[mind.changeling.changelingID]:</b> [n_message]</span>")

				for(var/mob/M in dead_mob_list)
					if(!M.client || isnewplayer(M))
						continue //skip monkeys, leavers and new players
					if(M.stat == DEAD && (M.client.prefs.chat_toggles & CHAT_GHOSTEARS))
						to_chat(M, "<span class='shadowling'><b>[mind.changeling.changelingID]:</b> [n_message]</span>")

				to_chat(src, "<span class='shadowling'><b>[mind.changeling.changelingID]:</b> [n_message]</span>")
				log_say("Changeling Mind: [mind.changeling.changelingID]/[mind.name]/[key] : [n_message]")
			return
		else
			if(message_mode)
				if(message_mode in (radiochannels | "department"))
					if(l_ear && istype(l_ear,/obj/item/device/radio))
						l_ear.talk_into(src,message, message_mode, verb, speaking)
						used_radios += l_ear
					else if(r_ear && istype(r_ear,/obj/item/device/radio))
						r_ear.talk_into(src,message, message_mode, verb, speaking)
						used_radios += r_ear

	var/sound/speech_sound
	var/sound_vol
	if((species.name == VOX || species.name == VOX_ARMALIS) && prob(20))
		speech_sound = sound('sound/voice/shriek1.ogg')
		sound_vol = 50

	..(message, speaking, verb, alt_name, italics, message_range, used_radios, speech_sound, sound_vol, sanitize = FALSE, message_mode = message_mode)	//ohgod we should really be passing a datum here.

/mob/living/carbon/human/say_understands(mob/other,datum/language/speaking = null)

	if(has_brain_worms()) //Brain worms translate everything. Even mice and alien speak.
		return 1

	//These only pertain to common. Languages are handled by mob/say_understands()
	if (!speaking)
		if (istype(other, /mob/living/carbon/monkey/diona))
			if(other.languages.len >= 2)			//They've sucked down some blood and can speak common now.
				return 1
		if (istype(other, /mob/living/silicon))
			return 1
		if (istype(other, /mob/living/carbon/brain))
			return 1
		if (istype(other, /mob/living/carbon/slime))
			return 1

	//This is already covered by mob/say_understands()
	//if (istype(other, /mob/living/simple_animal))
	//	if((other.universal_speak && !speaking) || src.universal_speak || src.universal_understand)
	//		return 1
	//	return 0

	return ..()

/mob/living/carbon/human/GetVoice()
	if(istype(src.wear_mask, /obj/item/clothing/mask/gas/voice))
		var/obj/item/clothing/mask/gas/voice/V = src.wear_mask
		if(V.vchange)
			return V.voice
		else
			return name
	if(mind && mind.changeling && mind.changeling.mimicing)
		return mind.changeling.mimicing
	if(special_voice)
		return special_voice
	return real_name

/*
   ***Deprecated***
   let this be handled at the hear_say or hear_radio proc
   This is left in for robot speaking when humans gain binary channel access until I get around to rewriting
   robot_talk() proc.
   There is no language handling build into it however there is at the /mob level so we accept the call
   for it but just ignore it.
*/

/mob/living/carbon/human/say_quote(message, datum/language/speaking = null)
	var/verb = "says"
	var/ending = copytext(message, length(message))

	if(speaking)
		verb = speaking.get_spoken_verb(ending)
	else
		if(ending == "!")
			verb=pick("exclaims","shouts","yells")
		else if(ending == "?")
			verb="asks"

	return verb




//mob/living/carbon/human/proc/handle_speech_problems(message)
/mob/living/carbon/human/proc/handle_speech_problems(message, message_mode)
	var/list/returns[3]
	var/verb = "says"
	var/handled = 0
	if(silent)
		if(message_mode != "changeling")
			message = ""
		handled = 1
	if(sdisabilities & MUTE)
		message = ""
		handled = 1
	if(wear_mask)
		if(message_mode != "changeling")
			message = wear_mask.speechModification(message)
		handled = 1

	if((HULK in mutations) && health >= 25 && length(message))
		message = "[uppertext_(message)]!!!"
		verb = pick("yells","roars","hollers")
		handled = 1
	if(slurring)
		message = slur(message)
		verb = pick("stammers","stutters")
		handled = 1
	if (stuttering)
		message = stutter(message)
		verb = pick("stammers","stutters")
		handled = 1

	var/braindam = getBrainLoss()
	if(braindam >= 60)
		handled = 1
		if(prob(braindam/4))
			message = stutter(message)
			verb = pick("stammers", "stutters")
		if(prob(braindam))
			message = uppertext_(message)
			verb = pick("yells like an idiot","says rather loudly")

	returns[1] = message
	returns[2] = verb
	returns[3] = handled

	return returns
