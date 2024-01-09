/datum/emote/pray
	key = "pray"

	message_1p = "You pray."
	message_3p = "prays."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/pray/do_emote(mob/user, emote_key, intentional)
	. = ..()
	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, pray_animation))


/datum/emote/blink
	key = "blink"

	message_1p = "You blink."
	message_3p = "blinks."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/shiver
	key = "shiver"

	message_1p = "You shiver."
	message_3p = "shivers."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/drool
	key = "drool"

	message_1p = "You drool."
	message_3p = "drools."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/eyebrow
	key = "eyebrow"

	message_1p = "You raise an eyebrow."
	message_3p = "raises an eyebrow."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/nod
	key = "nod"

	message_1p = "You nod."
	message_3p = "nods."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)


/datum/emote/shake
	key = "shake"

	message_1p = "You shake your head."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_not_species, ZOMBIE),
	)

/datum/emote/shake/get_emote_message_3p(mob/user)
	return "shakes [P_THEIR(user)] head."


/datum/emote/twitch
	key = "twitch"

	message_1p = "You twitch."
	message_3p = "twitches."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/collapse
	key = "collapse"

	message_1p = "You collapse!"
	message_3p = "collapses!"

	message_type = SHOWMSG_VISUAL

	cooldown = 4 SECONDS

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/collapse/do_emote(mob/user, emote_key, intentional)
	. = ..()
	user.Paralyse(2)


/datum/emote/faint
	key = "faint"

	message_1p = "You faint!"
	message_3p = "faints!"

	message_type = SHOWMSG_VISUAL

	cooldown = 20 SECONDS

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/faint/do_emote(mob/user, emote_key, intentional)
	. = ..()
	if(isliving(user))
		var/mob/living/L = user
		L.SetSleeping(20 SECONDS)


/datum/emote/deathgasp
	key = "deathgasp"

	message_1p = "You seize up and fall limp, your eyes dead and lifeless..."

	message_impaired_reception = "You hear a thud."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat_or_not_intentional, CONSCIOUS),
	)

/datum/emote/deathgasp/get_emote_message_3p(mob/user)
	return "seizes up and falls limp, [P_THEIR(user)] eyes dead and lifeless..."
