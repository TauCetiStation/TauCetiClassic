/datum/emote/robot/deathgasp
	key = "deathgasp"

	message_1p = "You shudder violently for a moment, then become motionless, your eyes slowly darkening..."
	message_3p = "shudders violently for a moment, then becomes motionless, it's eyes slowly darkening..."

	message_impaired_reception = "You hear a shuddering."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat_or_not_intentional, CONSCIOUS),
	)



/datum/emote/robot/bow
	key = "bow"

	message_1p = "You bow."
	message_3p = "bows."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)
