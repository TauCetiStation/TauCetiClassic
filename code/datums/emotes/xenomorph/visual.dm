/datum/emote/xenomorph/deathgasp
	key = "deathgasp"

	message_1p = "Pretending to be dead is not a good idea. I must fight for my Queen!"
	message_3p = "lets out a waning guttural screech, green blood bubbling from its maw..."

	message_impaired_reception = "You hear a thud."

	message_type = SHOWMSG_VISUAL

	sound = 'sound/voice/xenomorph/death_1.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat_or_not_intentional, CONSCIOUS),
	)

