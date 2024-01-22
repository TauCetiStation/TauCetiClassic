#define SOCIALIZATION_NORMAL 0
#define SOCIALIZATION_LONELY 1
#define SOCIALIZATION_VERY_LONELY 2

/mob/living/carbon/human
	var/conversation_timer
	var/social_state = SOCIALIZATION_NORMAL

/mob/living/carbon/human/atom_init()
	. = ..()
	handle_socialization()

/mob/living/carbon/human/Destroy()
	deltimer(conversation_timer)
	return ..()

/mob/living/carbon/human/proc/set_social_state(state)
	switch(state)
		if(SOCIALIZATION_NORMAL)
			social_state = SOCIALIZATION_NORMAL
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "no_socialization")

			deltimer(conversation_timer)
			conversation_timer = addtimer(
				CALLBACK(src, PROC_REF(handle_no_socialization)),
				5 MINUTES,
				TIMER_STOPPABLE
			)

		if(SOCIALIZATION_LONELY)
			social_state = SOCIALIZATION_LONELY
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "no_socialization", /datum/mood_event/lonely)

			deltimer(conversation_timer)
			conversation_timer = addtimer(
				CALLBACK(src, PROC_REF(handle_prolonged_no_socialization)),
				5 MINUTES,
				TIMER_STOPPABLE
			)

		if(SOCIALIZATION_VERY_LONELY)
			social_state = SOCIALIZATION_VERY_LONELY
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "no_socialization", /datum/mood_event/very_lonely)

/mob/living/carbon/human/proc/handle_prolonged_no_socialization()
	if(HAS_TRAIT(src, TRAIT_MUTE))
		return
	set_social_state(SOCIALIZATION_VERY_LONELY)

/mob/living/carbon/human/proc/handle_no_socialization()
	if(HAS_TRAIT(src, TRAIT_MUTE))
		return
	set_social_state(SOCIALIZATION_LONELY)

/mob/living/carbon/human/proc/handle_socialization(mob/hearer)
	if(!species.flags[IS_SOCIAL])
		return
	if(HAS_TRAIT(src, TRAIT_MUTE))
		return

	var/new_social_state = SOCIALIZATION_LONELY
	if(ishuman(hearer))
		new_social_state = SOCIALIZATION_NORMAL
	else if(isnull(hearer))
		new_social_state = SOCIALIZATION_NORMAL

	if(social_state > new_social_state)
		set_social_state(new_social_state)

/mob/living/carbon/human/say(message, ignore_appearance)
	var/verb = "says"
	var/message_range = world.view
	var/italics = 0
	var/alt_name = ""
	var/sound/speech_sound
	var/sound_vol
	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='userdanger'>You cannot speak in IC (Muted).</span>")
			return

	message =  sanitize(message)
	if(!message)
		return

	if(stat == DEAD)
		if(fake_death) //Our changeling with fake_death status must not speak in dead chat!!
			return
		return say_dead(message)

	var/message_mode = parse_message_mode(message, "headset")

	if (istype(wear_mask, /obj/item/clothing/mask/muzzle) && !(message_mode == "changeling" || message_mode == "alientalk" || message_mode == "mafia"))  //Todo:  Add this to speech_problem_flag checks.
		return

	if(message[1] == "*")
		return emote(copytext(message, 2), intentional = TRUE)

	//check if we are miming
	if (miming && !(message_mode == "changeling" || message_mode == "alientalk" || message_mode == "mafia"))
		to_chat(usr, "<span class='userdanger'>You are mute.</span>")
		return

	if(!ignore_appearance && name != GetVoice())
		alt_name = "(as [get_id_name("Unknown")])"

	//parse the radio code and consume it
	if (message_mode)
		if (message_mode == "headset")
			message = copytext(message,2)	//it would be really nice if the parse procs could do this for us.
		else
			message = copytext(message,2 + length(message[2]))
		if(!message)
			return

	//parse the language code and consume it or use default racial language if forced.
	var/list/parsed = parse_language(message)
	message = parsed[1]
	var/datum/language/speaking = parsed[2]

	//check if we're muted and not using gestures
	if (HAS_TRAIT(src, TRAIT_MUTE) && !(message_mode == "changeling" || message_mode == "alientalk" || message_mode == "mafia"))
		if (!(speaking && (speaking.flags & SIGNLANG)))
			to_chat(usr, "<span class='userdanger'>You are mute.</span>")
			return

	if (speaking && (speaking.flags & SIGNLANG))
		var/obj/item/organ/external/LH = get_bodypart(BP_L_ARM)
		var/obj/item/organ/external/RH = get_bodypart(BP_R_ARM)
		if (!(LH && LH.is_usable() && RH && RH.is_usable()))
			to_chat(usr, "<span class='userdanger'>You tried to make a gesture, but your hands are not responding.</span>")
			return

	message = approximate_sounds(message, speaking)
	if(!message)
		return

	message = accent_sounds(message, speaking)

	if(!speaking)
		switch(species.name)
			if(PODMAN)
				message = replacetext(message, "ж", pick(list("ш", "хш")))
				message = replacetext(message, "з", pick(list("с", "хс")))
			if(ABDUCTOR)
				var/mob/living/carbon/human/user = usr
				var/datum/role/abductor/A = user.mind.GetRoleByType(/datum/role/abductor)
				var/sm = sanitize(message)
				for(var/mob/living/carbon/human/H as anything in human_list)
					if(!H.mind || H.species.name != ABDUCTOR)
						continue
					var/datum/role/abductor/human = H.mind.GetRoleByType(/datum/role/abductor)
					if(!(human in A.faction.members))
						continue
					to_chat(H, "<span class='abductor_team[1]'><b>[user.real_name]:</b> [sm]</span>")
					//return - technically you can add more aliens to a team
				for(var/mob/M as anything in observer_list)
					var/link = FOLLOW_LINK(M, user)
					to_chat(M, "[link]<span class='abductor_team[1]'><b>[user.real_name]:</b> [sm]</span>")
				log_say("Abductor: [key_name(src)] : [sm]")
				return ""

	if(get_species() == HOMUNCULUS)
		message = cursed_talk(message)

	message = capitalize(trim(message))
	message = add_period(message)

	if(iszombie(src))
		message = zombie_talk(message)
	var/ending = copytext(message, -1)

	if(speaking)
		//If we've gotten this far, keep going!
		verb = speaking.get_spoken_verb(ending)
	else
		if(ending == "!")
			verb = pick("exclaims","shouts","yells")
		if(ending == "?")
			verb = "asks"

	if(speech_problem_flag)
		var/list/handle_r = handle_speech_problems(message, message_mode, verb)
		//var/list/handle_r = handle_speech_problems(message)
		message = handle_r[1]
		verb = handle_r[2]
		speech_problem_flag = handle_r[3]
		if(handle_r[4]) // speech sound management
			speech_sound = handle_r[4]
			sound_vol = handle_r[5]

	if(!message || (stat != CONSCIOUS && (message_mode != "changeling"))) // little tweak so changeling can call for help while in sleep
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
			if(ischangeling(src))
				if(stat != CONSCIOUS)
					message = stars(message, 20) // sleeping changeling has a little confused mind
				var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
				var/n_message = "<span class='changeling'><b>[C.changelingID]:</b> [message]</span>"
				log_say("Changeling Mind: [C.changelingID]/[mind.name]/[key] : [message]")
				for(var/mob/Changeling as anything in mob_list)
					if(ischangeling(Changeling))
						to_chat(Changeling, n_message)
						var/datum/role/changeling/CC = Changeling.mind.GetRoleByType(/datum/role/changeling)
						for(var/M in CC.essences)
							to_chat(M, n_message)

					else if(isobserver(Changeling))
						to_chat(Changeling, n_message)
			return
		if("alientalk")
			if(ischangeling(src))
				var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
				var/n_message = "<span class='shadowling'><b>[C.changelingID]:</b> [message]</span>"
				for(var/M in C.essences)
					to_chat(M, n_message)
				for(var/datum/orbit/O in orbiters)
					to_chat(O.orbiter, n_message)
				to_chat(src, n_message)
				log_say("Changeling Mind: [C.changelingID]/[mind.name]/[key] : [message]")
			return
		if("mafia")
			if(global.mafia_game)
				var/datum/mafia_controller/MF = global.mafia_game
				var/datum/mafia_role/R = MF.player_role_lookup[src]
				if(R && R.team == "mafia")
					MF.send_message("<span class='shadowling'><b>[R.body.real_name]:</b> [message]</span>", "mafia")
			return
		else
			if(message_mode)
				if(message_mode in (radiochannels | "department"))
					if(l_ear && istype(l_ear,/obj/item/device/radio) && l_ear.talk_into(src,message, message_mode, verb, speaking))
						used_radios += l_ear
					else if(r_ear && istype(r_ear,/obj/item/device/radio) && r_ear.talk_into(src,message, message_mode, verb, speaking))
						used_radios += r_ear

	if((species.name == VOX || species.name == VOX_ARMALIS) && prob(20))
		speech_sound = sound('sound/voice/shriek1.ogg')
		sound_vol = 50

	else if(species.name == ABOMINATION)
		speech_sound = sound('sound/voice/abomination.ogg')
		sound_vol = 50

	..(message, speaking, verb, alt_name, italics, message_range, used_radios, speech_sound, sound_vol, sanitize = FALSE, message_mode = message_mode)	//ohgod we should really be passing a datum here.

/mob/living/carbon/human/say_understands(mob/other,datum/language/speaking = null)

	if(has_brain_worms()) //Brain worms translate everything. Even mice and alien speak.
		return 1

	//These only pertain to common. Languages are handled by mob/say_understands()
	if(!speaking)
		if(istype(other, /mob/living/carbon/monkey/diona))
			if(other.languages.len >= 2)			//They've sucked down some blood and can speak common now.
				return 1
		if(isautosay(other))
			return 1
		if(issilicon(other))
			return 1
		if(isbrain(other))
			return 1
		if(isslime(other))
			return 1
		if(isgod(other))
			var/mob/living/simple_animal/shade/god/G = other
			if(G.my_religion.is_member(src))
				return TRUE

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
	if(ischangeling(src))
		var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
		if(C.mimicing)
			return C.mimicing
	if(special_voice)
		return special_voice
	return real_name

/mob/living/carbon/human/get_alt_name()
	if(name != GetVoice())
		return " (as [get_id_name("Unknown")])"
	return ""

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
	var/ending = copytext(message, -1)

	if(speaking)
		verb = speaking.get_spoken_verb(ending)
	else
		if(ending == "!")
			verb=pick("exclaims","shouts","yells")
		else if(ending == "?")
			verb="asks"

	return verb




//mob/living/carbon/human/proc/handle_speech_problems(message)
/mob/living/carbon/human/proc/handle_speech_problems(message, message_mode, verb)
	var/list/returns[5]
	var/handled = 0
	var/sound/speech_sound = null
	var/sound_vol = 50
	if(silent)
		if(message_mode != "changeling")
			message = ""
		handled = 1
	if(sdisabilities & MUTE)
		message = ""
		handled = 1
	if(gnomed)
		handled = 1
		if((message_mode != "changeling") && prob(40))
			if(prob(80))
				message = pick("A-HA-HA-HA!", "U-HU-HU-HU!", "I'm a GN-NOME!", "I'm a GnOme!", "Don't GnoMe me!", "I'm gnot a gnoblin!", "You've been GNOMED!")
			else
				message =  "[message]... Но я ГНОМ!"

			verb = pick("yells like an idiot", "says rather loudly")
			speech_sound = 'sound/magic/GNOMED.ogg'

	if(wear_mask)
		if(message_mode != "changeling")
			message = wear_mask.speechModification(message)
		handled = 1

	if((HULK in mutations) && health >= 25 && length(message) && !HAS_TRAIT(src, TRAIT_STRONGMIND))
		message = "[uppertext(message)]!!!"
		verb = pick("yells","roars","hollers")
		handled = 1
	if(disabilities & TOURETTES || HAS_TRAIT(src, TRAIT_TOURETTE))
		if(prob(50))
			message = turret_talk(message, get_species())
	if(slurring)
		message = slur(message)
		verb = pick("stammers","stutters")
		handled = 1
	if (stuttering)
		message = stutter(message)
		verb = pick("stammers","stutters")
		handled = 1

	var/braindam = getBrainLoss()
	if(braindam >= 60 && !HAS_TRAIT(src, TRAIT_STRONGMIND))
		handled = 1
		if(prob(braindam/4))
			message = stutter(message)
			verb = pick("stammers", "stutters")
		if(prob(braindam))
			message = uppertext(message)
			verb = pick("yells like an idiot","says rather loudly")

	returns[1] = message
	returns[2] = verb
	returns[3] = handled
	returns[4] = speech_sound
	returns[5] = sound_vol

	return returns

#undef SOCIALIZATION_NORMAL
#undef SOCIALIZATION_LONELY
#undef SOCIALIZATION_VERY_LONELY
