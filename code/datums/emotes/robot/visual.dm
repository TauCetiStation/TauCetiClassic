/datum/emote/robot/deathgasp
	key = "deathgasp"

	message_1p = "You shudder violently for a moment, then become motionless, your eyes slowly darkening..."

	message_impaired_reception = "You hear a shuddering."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat_or_not_intentional, CONSCIOUS),
	)

/datum/emote/robot/deathgasp/get_emote_message_3p(mob/living/silicon/robot/user)
	return "<b>[user]</b> shudders violently for a moment, then becomes motionless, it's eyes slowly darkening..."


/datum/emote/robot/bow
	key = "bow"

	message_1p = "You bow."
	message_3p = "bows."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)
