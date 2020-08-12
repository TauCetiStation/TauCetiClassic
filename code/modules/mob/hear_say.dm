// At minimum every mob has a hear_say proc.

/mob/proc/hear_say(message, verb = "says", datum/language/language = null, alt_name = "",italics = 0, mob/speaker = null, used_radio, sound/speech_sound, sound_vol)
	if(!client)
		return

	if(stat == UNCONSCIOUS)
		hear_sleep(message)
		return

	//non-verbal languages are garbled if you can't see the speaker. Yes, this includes if they are inside a closet.
	if (language && (language.flags & NONVERBAL))
		if (!speaker || (src.sdisabilities & BLIND || src.blinded) || !(speaker in viewers(src)))
			message = stars(message)

	if(!say_understands(speaker,language))
		var/scrambled_msg = speaker.get_scrambled_message(message, language)
		if(!scrambled_msg)
			return
		message = scrambled_msg

	var/speaker_name = speaker.name
	if(istype(speaker, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = speaker
		speaker_name = H.GetVoice()

	if(ishuman(src)) //zombie logic
		var/mob/living/carbon/human/ME = src
		if(iszombie(ME))
			if(!ishuman(speaker))
				message = stars(message, 40)
			else
				var/mob/living/carbon/human/H = speaker
				if(!iszombie(H))
					message = stars(message, 40)

	if(italics)
		message = "<i>[message]</i>"

	var/track = null
	if(istype(src, /mob/dead/observer))
		if(speaker && !speaker.client && !(client.prefs.chat_toggles & CHAT_GHOSTNPC) && !(speaker in view(src)))
			return
		if(used_radio && (client.prefs.chat_toggles & CHAT_GHOSTRADIO))
			return
		if(speaker_name != speaker.real_name && speaker.real_name)
			speaker_name = "[speaker.real_name] ([speaker_name])"
		track = "<a href='byond://?src=\ref[src];track=\ref[speaker]'>(F)</a>"
		if((client.prefs.chat_toggles & CHAT_GHOSTEARS) && (speaker in view(src)))
			message = "<b>[message]</b>"

	if(sdisabilities & DEAF || ear_deaf)
		if(speaker == src)
			to_chat(src, "<span class='warning'>You cannot hear yourself speak!</span>")
		else
			var/pronoun = null
			switch(speaker.gender)
				if(MALE)
					pronoun = "him"
				if(FEMALE)
					pronoun = "her"
				if(PLURAL)
					pronoun = "them"
				else
					pronoun = "it"
			to_chat(src, "<span class='name'>[speaker_name]</span>[alt_name] talks but you cannot hear [pronoun].")
	else
		if(language)
			to_chat(src, "[track] <span class='game say'><span class='name'>[speaker_name]</span>[alt_name] [language.format_message(message, verb)]</span>")
		else
			to_chat(src, "[track] <span class='game say'><span class='name'>[speaker_name]</span>[alt_name] [verb], <span class='message'><span class='body'>\"[message]\"</span></span></span>")
		if (speech_sound && (get_dist(speaker, src) <= world.view && src.z == speaker.z))
			var/turf/source = speaker? get_turf(speaker) : get_turf(src)
			playsound_local(source, speech_sound, VOL_EFFECTS_MASTER, sound_vol)

/mob/proc/hear_radio(message, verb="says", datum/language/language=null, part_a, part_b, part_c, mob/speaker = null, hard_to_hear = 0, vname ="")

	if(!client)
		return

	if(stat == UNCONSCIOUS)
		hear_sleep(message)
		return

	var/track = null

	//non-verbal languages are garbled if you can't see the speaker. Yes, this includes if they are inside a closet.
	if(language)
		if(language.flags & NONVERBAL && (!speaker || (sdisabilities & BLIND || blinded) || !(speaker in view(src))))
			message = stars(message)
		else if(language.flags & SIGNLANG)
			return

	if(!say_understands(speaker,language))
		if(isanimal(speaker))
			var/mob/living/simple_animal/S = speaker
			message = pick(S.speak)
		else if(isIAN(speaker))
			var/mob/living/carbon/ian/IAN = speaker
			message = pick(IAN.speak)
		else
			if(language)
				message = language.scramble(message)
			else
				message = stars(message)

	if(hard_to_hear)
		message = stars(message)

	var/speaker_name = speaker ? speaker.name : ""

	if(vname)
		speaker_name = vname

	if(istype(speaker, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = speaker
		if(H.voice)
			speaker_name = H.voice

	if(ishuman(src)) //zombie logic
		var/mob/living/carbon/human/ME = src
		if(iszombie(ME))
			if(!ishuman(speaker))
				message = stars(message, 40)
			else
				var/mob/living/carbon/human/H = speaker
				if(!iszombie(H))
					message = stars(message, 40)

	if(hard_to_hear)
		speaker_name = "unknown"

	var/changed_voice

	if(istype(src, /mob/living/silicon/ai) && !hard_to_hear)
		var/jobname // the mob's "job"
		var/mob/living/carbon/human/impersonating //The crewmember being impersonated, if any.

		if (ishuman(speaker))
			var/mob/living/carbon/human/H = speaker

			if((H.wear_id && istype(H.wear_id,/obj/item/weapon/card/id/syndicate)) && (H.wear_mask && istype(H.wear_mask,/obj/item/clothing/mask/gas/voice)))

				changed_voice = 1
				var/mob/living/carbon/human/I = locate(speaker_name)

				if(I)
					impersonating = I
					jobname = impersonating.get_assignment()
				else
					jobname = "Unknown"
			else
				jobname = H.get_assignment()

		else if (iscarbon(speaker)) // Nonhuman carbon mob
			jobname = "No id"
		else if (isAI(speaker))
			jobname = "AI"
		else if (isrobot(speaker))
			jobname = "Cyborg"
		else if (istype(speaker, /mob/living/silicon/pai))
			jobname = "Personal AI"
		else
			jobname = "Unknown"

		if(speaker.mouse_opacity && (speaker.alpha > 50))
			if(changed_voice)
				if(impersonating)
					track = "<a href='byond://?src=\ref[src];trackname=[html_encode(speaker_name)];track=\ref[impersonating]'>[speaker_name] ([jobname])</a>"
				else
					track = "[speaker_name] ([jobname])"
			else
				track = "<a href='byond://?src=\ref[src];trackname=[html_encode(speaker_name)];track=\ref[speaker]'>[speaker_name] ([jobname])</a>"

	if(istype(src, /mob/dead/observer))
		if(speaker_name != speaker.real_name && !isAI(speaker)) //Announce computer and various stuff that broadcasts doesn't use it's real name but AI's can't pretend to be other mobs.
			speaker_name = "[speaker.real_name] ([speaker_name])"
		if(isAI(speaker))
			var/mob/living/silicon/ai/S = speaker
			speaker = S.eyeobj
		track = "<a href='byond://?src=\ref[src];track=\ref[speaker]'>(F)</a> [speaker_name]"

	var/formatted
	if(language)
		formatted = language.format_message_radio(message, verb)
	else
		formatted = "[verb], <span class=\"body\">\"[message]\"</span>"

	if(sdisabilities & DEAF || ear_deaf)
		if(prob(20))
			to_chat(src, "<span class='warning'>You feel your headset vibrate but can hear nothing from it!</span>")
	else if(track)
		to_chat(src, "[part_a][track][part_b][formatted][part_c]")
	else
		to_chat(src, "[part_a][speaker_name][part_b][formatted][part_c]")

/mob/proc/hear_signlang(message, verb = "gestures", datum/language/language, mob/speaker = null)
	var/speaker_name = speaker.name
	if(!client)
		return

	if(say_understands(speaker, language))
		message = "<span class='game say'><span class='name'>[speaker_name]</span> [language.format_message(message, verb)]</span>"
	else
		message = "<span class='game say'><span class='name'>[speaker_name]</span> [verb].</span>"

	if(src.status_flags & PASSEMOTES)
		for(var/obj/item/weapon/holder/H in src.contents)
			H.show_message(message, SHOWMSG_VISUAL)
	show_message(message, SHOWMSG_VISUAL)

/mob/proc/hear_sleep(message, datum/language/language)
	var/heard = ""
	if (language && ((language.flags & NONVERBAL) || (language.flags & SIGNLANG)))
		return

	if (sdisabilities & DEAF || ear_deaf)
		return

	if(prob(15))
		var/list/punctuation = list(",", "!", ".", ";", "?")
		var/list/messages = splittext(message, " ")
		var/R = rand(1, messages.len)
		var/heardword = messages[R]
		if(heardword[1] in punctuation)
			heardword = copytext(heardword,2)
		if(copytext(heardword,-1) in punctuation)
			heardword = copytext(heardword,1,-1)
		heard = "<span class = 'game_say'>...You hear something about...[heardword]</span>"

	else
		heard = "<span class = 'game_say'>...<i>You almost hear someone talking</i>...</span>"

	to_chat(src, heard)
