/mob/living/silicon/ai/say(message)
	if(parent && istype(parent) && parent.stat != DEAD)
		return parent.say(message)
		//If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
	return ..(message)
