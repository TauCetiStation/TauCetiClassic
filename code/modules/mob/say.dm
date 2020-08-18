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

	usr.say(message)

/mob/verb/me_verb(message as text)
	set name = "Me"
	set category = "IC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	message = sanitize(message)

	if(me_verb_allowed)
		usr.emote("me", usr.emote_type, message, FALSE)
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

	if(client && !(client.prefs.chat_toggles & CHAT_DEAD))
		to_chat(usr, "<span class='red'> You have deadchat muted.</span>")
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
		if(isnewplayer(M))
			continue
		if(M.client && M.stat == DEAD && (M.client.prefs.chat_toggles & CHAT_DEAD))
			if(M.fake_death) //Our changeling with fake_death status must not hear dead chat!!
				continue
			to_chat(M, rendered)
			continue

		if(M.client && M.client.holder && (M.client.prefs.chat_toggles & CHAT_DEAD) ) // Show the message to admins with deadchat toggled on
			to_chat(M, rendered)//Admins can hear deadchat, if they choose to, no matter if they're blind/deaf or not.


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
		if(src.alien_talk_understand && other.alien_talk_understand)
			return 1
		return 0

	//Language check.
	for(var/datum/language/L in languages)
		if(speaking.name == L.name)
			return 1

	return 0

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

/mob/proc/emote(act, type, message, auto)
	if(act == "me")
		return custom_emote(type, message)

/mob/proc/get_ear()
	// returns an atom representing a location on the map from which this
	// mob can hear things

	// should be overloaded for all mobs whose "ear" is separate from their "mob"

	return get_turf(src)

/proc/say_test(text)
	var/ending = copytext(text, -1)
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
/mob/proc/parse_language(message)
	if(length_char(message) >= 2)
		var/language_prefix = lowertext(copytext(message, 1, 2 + length(message[2])))
		var/datum/language/L = language_keys[language_prefix]
		if (can_speak(L))
			return L

	return null
