/datum/emote/human/bow
	key = "bow"

	message_1p = "You bow."
	message_3p = "bows."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)


/datum/emote/human/yawn
	key = "yawn"

	message_1p = "You yawn."
	message_3p = "yawns."

	message_impaired_reception = "You hear someone yawn."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)


/datum/emote/human/blink
	key = "blink"

	message_1p = "You blink."
	message_3p = "blinks."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/human/wink
	key = "wink"

	message_1p = "You wink."
	message_3p = "winks."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)


/datum/emote/human/grin
	key = "grin"

	message_1p = "You grin."
	message_3p = "grins."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/human/drool
	key = "drool"

	message_1p = "You drool."
	message_3p = "drools."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/human/smile
	key = "smile"

	message_1p = "You smile."
	message_3p = "smiles."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/human/frown
	key = "frown"

	message_1p = "You frown."
	message_3p = "frowns."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/human/eyebrow
	key = "eyebrow"

	message_1p = "You raise an eyebrow."
	message_3p = "raises an eyebrow."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/human/shrug
	key = "shrug"

	message_1p = "You shrug."
	message_3p = "shrugs."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)


/datum/emote/human/nod
	key = "nod"

	message_1p = "You nod."
	message_3p = "nods."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)


/datum/emote/human/shake
	key = "shake"

	message_1p = "You shake your head."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)

/datum/emote/human/shake/get_emote_message_3p(mob/living/carbon/human/user)
	return "shakes [P_THEIR(user)] head."


/datum/emote/human/twitch
	key = "twitch"

	message_1p = "You twitch."
	message_3p = "twitches."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/human/deathgasp
	key = "deathgasp"

	message_1p = "You seize up and fall limp, your eyes dead and lifeless..."

	message_impaired_reception = "You hear a thud."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat_or_not_intentional, CONSCIOUS),
	)

/datum/emote/human/deathgasp/get_emote_message_3p(mob/living/carbon/human/user)
	return "seizes up and falls limp, [P_THEIR(user)] eyes dead and lifeless..."
