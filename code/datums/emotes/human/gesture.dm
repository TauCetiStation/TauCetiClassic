/datum/emote/raisehand
	key = "raisehand"

	message_1p = "You raise a hand."
	message_3p = "raises a hand."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
	)


/datum/emote/rock
	key = "rock"

	message_1p = "You play rock."
	message_3p = "plays rock."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
	)

/datum/emote/rock/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.play_rock_paper_scissors_animation(emote_key)


/datum/emote/paper
	key = "paper"

	message_1p = "You play paper."
	message_3p = "plays paper."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
	)

/datum/emote/paper/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.play_rock_paper_scissors_animation(emote_key)


/datum/emote/scissors
	key = "scissors"

	message_1p = "You play scissors."
	message_3p = "plays scissors."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
	)

/datum/emote/scissors/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.play_rock_paper_scissors_animation(emote_key)
