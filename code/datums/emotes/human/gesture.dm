/datum/emote/human/raisehand
	key = "raisehand"

	message_1p = "You raise a hand."
	message_3p = "raises a hand."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
	)


/datum/emote/human/rock
	key = "rock"

	message_1p = "You play rock."
	message_3p = "plays rock."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
	)

/datum/emote/human/rock/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.play_rock_paper_scissors_animation(emote_key)


/datum/emote/human/paper
	key = "paper"

	message_1p = "You play paper."
	message_3p = "plays paper."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
	)

/datum/emote/human/paper/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.play_rock_paper_scissors_animation(emote_key)


/datum/emote/human/scissors
	key = "scissors"

	message_1p = "You play scissors."
	message_3p = "plays scissors."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
	)

/datum/emote/human/scissors/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.play_rock_paper_scissors_animation(emote_key)

/datum/emote/human/surrender
	key = "surr"

	message_1p = "You surrender!"
	message_3p = "surrenders!"
	cloud = "cloud-white_flag"
	cooldown = 15 SECONDS
	cloud_duration = 20 SECONDS

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)

/datum/emote/human/surrender/do_emote(mob/living/carbon/human/user)
	. = ..()
	user.AdjustWeakened(10)

/datum/emote/human/clap
	key = "clap"

	message_1p = "You clap."
	message_3p = "claps."

	message_impaired_reception = "You hear someone clapping."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
	)


/datum/emote/human/wave
	key = "wave"

	message_1p = "You wave your hand."
	message_3p = "waves."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)


/datum/emote/human/salute
	key = "salute"

	message_1p = "You salute."
	message_3p = "salutes."

	message_type = SHOWMSG_VISUAL

	sound = 'sound/misc/salute.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)
