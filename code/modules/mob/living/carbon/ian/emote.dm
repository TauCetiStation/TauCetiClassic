/mob/living/carbon/ian
	default_emotes = list(
		/datum/emote/help,
		/datum/emote/pray,
		/datum/emote/blink,
		/datum/emote/whimper,
		/datum/emote/moan,
		/datum/emote/roar,
		/datum/emote/gasp,
		/datum/emote/choke,
		/datum/emote/cough,
		/datum/emote/drool,
		/datum/emote/eyebrow,
		/datum/emote/nod,
		/datum/emote/shake,
		/datum/emote/twitch,
		/datum/emote/collapse,
		/datum/emote/faint,
		/datum/emote/deathgasp,
	)

/mob/living/carbon/ian/emote(act, message_type = SHOWMSG_VISUAL, message = "", auto = TRUE)
	if(src.stat == DEAD && (act != "deathgasp"))
		return

	switch(act)
		if("scratch")
			if(!restrained())
				message = "<B>[src]</B> чешется."
				m_type = SHOWMSG_VISUAL
		if("tail")
			message = "<B>[src]</B> машет хвостом."
			m_type = SHOWMSG_VISUAL
		if("paw")
			if(!restrained())
				message = "<B>[src]</B> машет лапой."
				m_type = SHOWMSG_VISUAL
		if("sit")
			message = "<B>[src]</B> садится."
			m_type = SHOWMSG_VISUAL
		if("sway")
			message = "<B>[src]</B> качается."
			m_type = SHOWMSG_VISUAL
		if("sulk")
			message = "<B>[src]</B> печально дуется."
			m_type = SHOWMSG_VISUAL
		if("dance")
			if(!restrained())
				message = "<B>[src]</B> [pick("пляшет", "гоняется за хвостом")]."
				m_type = SHOWMSG_VISUAL
		if("roll")
			if(!restrained())
				message = "<B>[src]</B> катается по полу."
				m_type = SHOWMSG_VISUAL
		if("gnarl")
			message = "<B>[src]</B> злится и оскаливает зубы."
			m_type = SHOWMSG_AUDIO
		if("jump")
			message = "<B>[src]</B> прыгает!"
			m_type = SHOWMSG_VISUAL
