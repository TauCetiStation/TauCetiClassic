/mob/proc/say()
	return

/mob/verb/whisper()
	set name = "Whisper"
	set category = "IC"
	return

/mob/verb/say_verb(message as text)
	set name = "Say"
	set category = "IC"
	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	if(client && SSlag_switch.measures[SLOWMODE_IC_CHAT] && !HAS_TRAIT(src, TRAIT_BYPASS_MEASURES))
		if(!COOLDOWN_FINISHED(client, say_slowmode))
			to_chat(src, to_chat("<span class='warning'>Message not sent due to slowmode. Please wait [SSlag_switch.slowmode_cooldown/10] seconds between messages.\n\"[message]\"</span>"))
			return
		COOLDOWN_START(client, say_slowmode, SSlag_switch.slowmode_cooldown)

	usr.say(message)

/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	if(!message)
		return

	if(client && SSlag_switch.measures[SLOWMODE_IC_CHAT] && !HAS_TRAIT(src, TRAIT_BYPASS_MEASURES))
		if(!COOLDOWN_FINISHED(client, say_slowmode))
			to_chat(src, to_chat("<span class='warning'>Message not sent due to slowmode. Please wait [SSlag_switch.slowmode_cooldown/10] seconds between messages.\n\"[message]\"</span>"))
			return
		COOLDOWN_START(client, say_slowmode, SSlag_switch.slowmode_cooldown)


	message = sanitize(message)
	message = uncapitalize(message)
	message = add_period(message)

	if(me_verb_allowed)
		usr.me_emote(message, message_type=usr.emote_type, intentional=TRUE)
	else
		to_chat(usr, "You are unable to emote.")
		return

/mob/proc/say_dead(message)
	var/name = src.real_name
	var/alt_name = ""

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='red'> Speech is currently admin-disabled.</span>")
		return

	if(!src.client.holder)
		if(!dsay_allowed)
			to_chat(src, "<span class='red'> Deadchat is globally muted.</span>")
			return

	if(client)
		if (!(client.prefs.chat_toggles & CHAT_DEAD)) // User preference check
			to_chat(src, "<span class='red'> You have deadchat muted.</span>")
			return

		if(client.prefs.muted & MUTE_DEADCHAT) // Admin/autospam mute check
			to_chat(src, "<span class='alert'>You cannot talk in deadchat (muted).</span>")
			return

		if (client.handle_spam_prevention(message, MUTE_DEADCHAT)) // Autospam
			return

	if(mind && mind.name)
		name = "[mind.name]"
	else
		name = real_name
	if(name != real_name)
		alt_name = " (died as [real_name])"
	if(client.prefs.chat_toggles & CHAT_CKEY)
		name += " ([key])"

	var/rendered = "<span class='game deadsay linkify emojify'><span class='prefix'>DEAD:</span> <span class='name'>[name]</span>[alt_name] [pick("complains","moans","whines","laments","blubbers")], <span class='message'>\"[message]\"</span></span>"

	for(var/mob/M in player_list)
		var/tracker = "[FOLLOW_LINK(M, src)] "
		if(isnewplayer(M))
			continue
		if(M.client && M.stat == DEAD && (M.client.prefs.chat_toggles & CHAT_DEAD))
			if(M.fake_death) //Our changeling with fake_death status must not hear dead chat!!
				continue
			to_chat(M, tracker + rendered)
			continue

		if(M.client && M.client.holder && (M.client.prefs.chat_toggles & CHAT_DEAD) ) // Show the message to admins with deadchat toggled on
			to_chat(M, tracker + rendered)//Admins can hear deadchat, if they choose to, no matter if they're blind/deaf or not.


	return

/mob/proc/say_understands(mob/other,datum/language/speaking = null)

	if (src.stat == DEAD)		//Dead
		return 1

	//Universal speak makes everything understandable, for obvious reasons.
	else if(src.universal_speak || src.universal_understand)
		return 1

	//Languages are handled after.
	if (!speaking)
		if(!other)
			return 1
		if(other.universal_speak)
			return 1
		if(isAI(src) && ispAI(other))
			return 1
		if(istype(other, src.type) || istype(src, other.type))
			return 1
		return 0

	return can_understand(speaking)

/*
   ***Deprecated***
   let this be handled at the hear_say or hear_radio proc
   This is left in for robot speaking when humans gain binary channel access until I get around to rewriting
   robot_talk() proc.
   There is no language handling build into it however there is at the /mob level so we accept the call
   for it but just ignore it.
*/

/mob/proc/say_quote(message, datum/language/speaking = null)
	var/say_verb = "says"
	var/ending = copytext(message, -1)
	if(ending=="!")
		say_verb=pick("exclaims","shouts","yells")
	else if(ending=="?")
		say_verb="asks"

	return say_verb

/mob/proc/get_ear()
	// returns an atom representing a location on the map from which this
	// mob can hear things

	// should be overloaded for all mobs whose "ear" is separate from their "mob"

	return get_turf(src)

/proc/say_test(text)
	var/ending = copytext_char(text, -1)
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"

//parses the message mode code (e.g. :h, :w) from text, such as that supplied to say.
//returns the message mode string or null for no message mode.
//standard mode is the mode returned for the special ';' radio code.
/mob/proc/parse_message_mode(message, standard_mode="headset")
	if(length(message) >= 1 && message[1] == ";")
		return standard_mode

	if(length(message) >= 2)
		var/channel_prefix = copytext(message, 1, 2 + length(message[2]))
		return department_radio_keys[channel_prefix]

	return null

//parses the language code (e.g. :j) from text, such as that supplied to say.
//returns the language object only if the code corresponds to a language that src can speak, otherwise null.
/mob/proc/parse_language_code(message)
	if(length_char(message) >= 2)
		var/language_prefix = lowertext(copytext(message, 1, 2 + length(message[2])))
		var/datum/language/L = language_keys[language_prefix]
		if (can_speak(L))
			return L

	return null

/mob/proc/add_approximation(sound, approximation, case_sensitive=FALSE)
	if(case_sensitive)
		LAZYSET(sensitive_sound_approximations, sound, approximation)
		return

	LAZYSET(sound_approximations, sound, approximation)

/mob/proc/remove_approximation(sound, case_sensitive=FALSE)
	if(case_sensitive)
		LAZYREMOVE(sensitive_sound_approximations, sound)
		return

	LAZYREMOVE(sound_approximations, sound)

/mob/proc/approximate_sounds(txt, datum/language/speaking)
	if(speaking && (speaking.flags & SIGNLANG))
		return txt

	. = txt
	. = replace_characters(., sound_approximations)
	. = replaceEx_characters(., sensitive_sound_approximations)

/mob/proc/accent_sounds(txt, datum/language/speaking)
	return txt

/mob/proc/init_languages()
	return
