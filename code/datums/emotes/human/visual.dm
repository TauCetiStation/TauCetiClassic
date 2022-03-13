/datum/emote/blink
	key = "blink"

	message_1p = "You blink."
	message_3p = "blinks."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)
