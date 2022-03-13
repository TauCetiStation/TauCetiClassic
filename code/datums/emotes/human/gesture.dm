/datum/emote/raisehand
	key = "raisehand"

	message_1p = "You raise a hand."
	message_3p = "raises a hand."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
	)
