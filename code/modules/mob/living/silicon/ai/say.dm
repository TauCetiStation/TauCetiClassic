/mob/living/silicon/ai/say(message)
	if(parent && istype(parent) && parent.stat != DEAD)
		return parent.say(message)
		//If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
	return ..(message)

/mob/living/silicon/ai/GetVoice()
	if(voice_change)
		return voice
	else
		return name

/mob/living/silicon/ai/say_quote(text)
	var/ending = copytext(text, -1)
	if(voice_change)
		if (ending == "?")
			return "asks"
		else if (ending == "!")
			return "exclaims"
		
		return "says"
	return ..()