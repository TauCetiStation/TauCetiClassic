/datum/emote/shiver
	key = "shiver"

	message_1p = "You shiver."
	message_3p = "shivers."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/collapse
	key = "collapse"

	message_1p = "You collapse!"
	message_3p = "collapses!"

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/collapse/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.Paralyse(2)


/datum/emote/pray
	key = "pray"

	message_1p = "You pray."
	message_3p = "prays."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/pray/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	INVOKE_ASYNC(user, /mob.proc/pray_animation)


/datum/emote/bow
	key = "bow"

	message_1p = "You bow."
	message_3p = "bows."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)


/datum/emote/yawn
	key = "yawn"

	message_1p = "You yawn."
	message_3p = "yawns.."

	message_impaired_reception = "You hear someone yawn."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)


/datum/emote/blink
	key = "blink"

	message_1p = "You blink."
	message_3p = "blinks."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/wink
	key = "wink"

	message_1p = "You wink."
	message_3p = "winks."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)


/datum/emote/grin
	key = "grin"

	message_1p = "You grin."
	message_3p = "grins."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/drool
	key = "drool"

	message_1p = "You drool."
	message_3p = "drools."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/smile
	key = "smile"

	message_1p = "You smile."
	message_3p = "smiles."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/frown
	key = "frown"

	message_1p = "You frown."
	message_3p = "frowns."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/eyebrow
	key = "eyebrow"

	message_1p = "You raise an eyebrow."
	message_3p = "raises an eyebrow."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/shrug
	key = "shrug"

	message_1p = "You shrug."
	message_3p = "shrugs."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)



/datum/emote/nod
	key = "nod"

	message_1p = "You nod."
	message_3p = "nods."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)


/datum/emote/clap
	key = "clap"

	message_1p = "You clap."
	message_3p = "claps."

	message_impaired_reception = "You hear someone clapping."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
	)


/datum/emote/wave
	key = "wave"

	message_1p = "You wave your hand."
	message_3p = "waves."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)


/datum/emote/salute
	key = "salute"

	message_1p = "You salute."
	message_3p = "salutes."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)


/datum/emote/twitch
	key = "twitch"

	message_1p = "You twitch."
	message_3p = "twitches."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/deathgasp
	key = "deathgasp"

	message_1p = "You seize up and fall limp, your eyes dead and lifeless..."

	message_impaired_reception = "You hear a thud."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat_or_not_intentional, CONSCIOUS),
	)

/datum/emote/deathgasp/get_emote_message_3p(mob/living/carbon/human/user)
	return "<b>[user]</b> seizes up and falls limp, [P_THEIR(user)] eyes dead and lifeless..."
