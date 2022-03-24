/datum/emote/pray
	key = "pray"

	message_1p = "You pray."
	message_3p = "prays."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)
