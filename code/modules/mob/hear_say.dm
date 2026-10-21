// Processes the message and outputs whatever the mob should actually hear
/mob/proc/process_speech(message, verb = "says", datum/language/language = null, alt_name = "",italics = 0, mob/speaker = null, used_radio, sound/speech_sound, sound_vol)
	//non-verbal languages are garbled if you can't see the speaker. Yes, this includes if they are inside a closet.
	if (language && (language.flags & NONVERBAL))
		if (!speaker || (src.sdisabilities & BLIND || src.blinded) || !(speaker in viewers(src)))
			message = stars(message)

	if(!say_understands(speaker,language))
		var/scrambled_msg = speaker.get_scrambled_message(message, language)
		if(!scrambled_msg)
			return null

		message = scrambled_msg

	var/speaker_name = speaker.name
	if(ishuman(speaker))
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

	if(!(sdisabilities & DEAF || ear_deaf) && client?.prefs.show_runechat)
		var/list/span_list = list()
		if(copytext_char(message, -2) == "!!")
			span_list.Add("yell")
		if(italics)
			span_list.Add("italics")
		if(used_radio)
			span_list.Add("speaker")
		show_runechat_message(speaker, language, capitalize(message), span_list)

	if(italics)
		message = "<i>[message]</i>"

	var/track = null
	if(isobserver(src))
		if(speaker && !speaker.client && !(client.prefs.chat_toggles & CHAT_GHOSTNPC) && !(speaker in view(src)))
			return null
		if(used_radio && (client.prefs.chat_toggles & CHAT_GHOSTRADIO))
			return null

		if(speaker_name != speaker.real_name && speaker.real_name)
			speaker_name = "[speaker.real_name] ([speaker_name])"
		track = "[FOLLOW_LINK(src, speaker)] "
		if((client.prefs.chat_toggles & CHAT_GHOSTEARS) && (speaker in view(src)))
			message = "<b>[message]</b>"

	if((sdisabilities & DEAF || ear_deaf) && !((REMOTE_TALK in mutations)))
		if(speaker == src)
			message = "<span class='warning'>You cannot hear yourself speak!</span>"
		else
			message = "<span class='name'>[speaker_name]</span>[alt_name] talks but you cannot hear [P_THEM(speaker)]."
	else
		if(isliving(src))
			message = highlight_traitor_codewords(message, src.mind)
		if(language && !(REMOTE_TALK in mutations))
			message = "[track]<span class='game say'><span class='name'>[speaker_name]</span>[alt_name] [language.format_message(message, verb)]</span>"
		else
			message = "[track]<span class='game say'><span class='name'>[speaker_name]</span>[alt_name] [verb], <span class='message'><span class='body'>\"[message]\"</span></span></span>"

	return message

// At minimum every mob has a hear_say proc.
/mob/proc/hear_say(message, verb = "says", datum/language/language = null, alt_name = "",italics = 0, mob/speaker = null, used_radio, sound/speech_sound, sound_vol)
	var/not_processed_message = message
	if(!client)
		if(!remote_hearers)
			return FALSE
		message = process_speech(message, verb, language, alt_name, italics, speaker, used_radio, speech_sound, sound_vol)
		if(message)
			telepathy_eavesdrop(speaker, message, "has heard", language, not_processed_message)

		return FALSE

	if(stat == UNCONSCIOUS)
		hear_sleep(message)
		return FALSE

	message = process_speech(message, verb, language, alt_name, italics, speaker, used_radio, speech_sound, sound_vol)
	if(!message)
		return FALSE

	if(length(remote_hearers))
		telepathy_eavesdrop(speaker, message, "has heard", language)
	to_chat(src, message)

	if(ishuman(speaker))
		var/mob/living/carbon/human/H = speaker

		if(H != src && H.mind?.assigned_role == "Mime" && length(H.languages))
			H.emote("gasp")
			H.adjustOxyLoss(20)
			H.Stun(3)
			H.Weaken(3)

			H.loc.shake_act(2)

			to_chat(H, "<span class='bold userdanger'>As punishment for breaking the vow, you will forget all your languages!</span>")

			for(var/datum/language/L as anything in H.languages)
				H.remove_language(L.name)

	if(!(sdisabilities & DEAF) && !ear_deaf)
		var/turf/source = speaker? get_turf(speaker) : get_turf(src)
		if((HAS_TRAIT(speaker, TRAIT_MELODIUS_VOICE) || speech_sound) && (get_dist(speaker, src) <= world.view && src.z == speaker.z))
			if(HAS_TRAIT(speaker, TRAIT_MELODIUS_VOICE) && ishuman(speaker))
				var/mob/living/carbon/human/H = speaker
				var/sounds = clamp(round(length_char(not_processed_message)/3), 1, 5)
				play_instrumental_voice(H, sounds, source)

			else
				playsound_local(source, speech_sound, VOL_EFFECTS_MASTER, sound_vol)

	. = TRUE

	if(speaker == src)
		return

	if(stat != CONSCIOUS)
		return

	if(!client)
		return

	if(!ishuman(speaker))
		return

	var/mob/living/carbon/human/H = speaker
	H.handle_socialization(src)

/mob/proc/play_instrumental_voice(mob/living/carbon/human/H, repeats = 1, turf/source)
	if(!repeats)
		return
	var/instrumental_sound = H.get_instrumental_voice()
	playsound_local(source, instrumental_sound, VOL_EFFECTS_MASTER, 80)
	addtimer(CALLBACK(src, PROC_REF(play_instrumental_voice), H, repeats - 1), 0.3 SECONDS)

/mob/living/carbon/human/proc/get_instrumental_voice()
	var/static/list/sound_by_gender_species = list(
		"[TAJARAN][FEMALE]" = global.SOUNDIN_TAJARAN_FEMALE_VOICES,
		"[TAJARAN][MALE]" = global.SOUNDIN_TAJARAN_MALE_VOICES,
		"[SKRELL][FEMALE]" = global.SOUNDIN_SKRELL_FEMALE_VOICES,
		"[SKRELL][MALE]" = global.SOUNDIN_SKRELL_MALE_VOICES,
		"[UNATHI][FEMALE]" = global.SOUNDIN_UNATHI_FEMALE_VOICES,
		"[UNATHI][MALE]" = global.SOUNDIN_UNATHI_MALE_VOICES,
		"[DIONA][NEUTER]" = global.SOUNDIN_DIONA_VOICES,
	)

	var/hash = "[get_species()][gender]"

	if(sound_by_gender_species[hash])
		return pick(sound_by_gender_species[hash])
	if(istype(species, /datum/species/machine))
		return get_sound_by_voice(src, global.SOUNDIN_IPC_MALE_VOICES, global.SOUNDIN_IPC_FEMALE_VOICES)
	return get_sound_by_voice(src, global.SOUNDIN_HUMAN_MALE_VOICES, global.SOUNDIN_HUMAN_FEMALE_VOICES)

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
			if(!S.speak.len)
				return
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

	if(ishuman(speaker))
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

	if(isAI(src) && !hard_to_hear)
		var/jobname // the mob's "job"
		var/mob/living/carbon/human/impersonating //The crewmember being impersonated, if any.

		if (ishuman(speaker))
			var/mob/living/carbon/human/H = speaker

			if((H.wear_id && istype(H.wear_id,/obj/item/weapon/card/id/syndicate)) && (H.wear_mask && istype(H.wear_mask,/obj/item/clothing/mask/breath/gas/voice)))

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
		else if (isAI(speaker) || isautosay(speaker))
			jobname = "AI"
		else if (isrobot(speaker))
			jobname = "Cyborg"
		else if (ispAI(speaker))
			jobname = "Personal AI"
		else
			jobname = "Unknown"

		if(isautosay(speaker))
			var/turf/T = get_turf(speaker)
			if(T)
				track = "<a href='byond://?src=\ref[src];x=[T.x];y=[T.y];z=[T.z]'>[speaker_name] ([jobname])</a>"
		else
			if(speaker.mouse_opacity && (speaker.alpha > 50))
				if(changed_voice)
					if(impersonating)
						track = "<a href='byond://?src=\ref[src];trackname=[html_encode(speaker_name)];track=\ref[impersonating]'>[speaker_name] ([jobname])</a>"
					else
						track = "[speaker_name] ([jobname])"
				else
					track = "<a href='byond://?src=\ref[src];trackname=[html_encode(speaker_name)];track=\ref[speaker]'>[speaker_name] ([jobname])</a>"

	if(isobserver(src))
		if(isautosay(speaker))
			speaker_name = speaker.real_name
		else
			if(speaker_name != speaker.real_name && !isAI(speaker)) //Announce computer and various stuff that broadcasts doesn't use it's real name but AI's can't pretend to be other mobs.
				speaker_name = "[speaker.real_name] ([speaker_name])"
			if(isAI(speaker))
				var/mob/living/silicon/ai/S = speaker
				speaker = S.eyeobj

		var/track_button
		var/turf/T = get_turf(speaker)
		if(T)
			track_button = FOLLOW_OR_TURF_LINK(src, speaker, T)
		else
			track_button = FOLLOW_LINK(src, speaker)
		track = "[track_button] [speaker_name]"

	if(isliving(src))
		message = highlight_traitor_codewords(message, src.mind)
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

	if(speaker != src)
		telepathy_eavesdrop(speaker, "[speaker_name] [formatted]", "has heard", language, "[speaker_name] [formatted]")

/mob/proc/hear_signlang(message, verb = "gestures", datum/language/language, mob/speaker = null)
	var/speaker_name = speaker.name
	var/runechat_message
	if(!client)
		return

	if(say_understands(speaker, language))
		runechat_message = "[verb], \"[capitalize(message)]\""
		message = "<span class='game say'><span class='name'>[speaker_name]</span> [language.format_message(message, verb)]</span>"
	else
		runechat_message = "[verb]."
		message = "<span class='game say'><span class='name'>[speaker_name]</span> [verb].</span>"

	if(src.status_flags & PASSEMOTES)
		for(var/obj/item/weapon/holder/H in src.contents)
			H.show_message(message, SHOWMSG_VISUAL)
	show_runechat_message(speaker, null, runechat_message, null, SHOWMSG_VISUAL)
	show_message(message, SHOWMSG_VISUAL)

	telepathy_eavesdrop(speaker, message, "has seen", language, runechat_message)

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
		heard = "<span class='notice italic'>... [heardword] ...</span>"
	else
		return

	to_chat(src, heard)

	telepathy_eavesdrop(src, message, pick("has seen", "has heard"), null, message)
