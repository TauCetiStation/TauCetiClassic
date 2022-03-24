/mob/living/carbon/brain
	default_emotes = list(
	)


/mob/living/carbon/brain/emote(act, message_type = SHOWMSG_VISUAL, message = "", auto = TRUE)
	// No MMI, no emotes
	if(!container || !isMMI(container))
		to_chat(src, "<span class='notice'>You can not emote in such state.</span>")
		return

	return ..()

	switch(act)
		if ("alarm")
			to_chat(src, "You sound an alarm.")
			message = "<B>[src]</B> sounds an alarm."
			m_type = SHOWMSG_AUDIO
		if ("alert")
			to_chat(src, "You let out a distressed noise.")
			message = "<B>[src]</B> lets out a distressed noise."
			m_type = SHOWMSG_AUDIO
		if ("notice")
			to_chat(src, "You play a loud tone.")
			message = "<B>[src]</B> plays a loud tone."
			m_type = SHOWMSG_AUDIO
		if ("flash")
			message = "The lights on <B>[src]</B> flash quickly."
			m_type = SHOWMSG_VISUAL
		if ("blink")
			message = "<B>[src]</B> blinks."
			m_type = SHOWMSG_VISUAL
		if ("whistle")
			to_chat(src, "You whistle.")
			message = "<B>[src]</B> whistles."
			m_type = SHOWMSG_AUDIO
