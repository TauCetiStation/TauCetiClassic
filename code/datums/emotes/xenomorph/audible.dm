/datum/emote/xenomorph/whimper
	key = "whimper"

	message_1p = "You whimper."
	message_3p = "sadly whines."

	message_muzzled = "shakes violently and makes a loud noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/voice/xenomorph/whimper.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/xenomorph/whimper/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(10)

/datum/emote/xenomorph/roar
	key = "roar"

	message_1p = "You roar."
	message_3p = "triumphantly roars."

	message_muzzled = "shakes violently and makes a loud noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/xenomorph/roar/get_sound(mob/user, intentional)
	return pick(SOUNDIN_XENOMORPH_ROAR)

/datum/emote/xenomorph/roar/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(-10)

/datum/emote/xenomorph/hiss
	key = "hiss"

	message_1p = "You hiss."
	message_3p = "predatory hiss."

	message_muzzled = "shakes violently and makes a loud noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/xenomorph/hiss/get_sound(mob/user, intentional)
	return pick(SOUNDIN_XENOMORPH_HISS)

/datum/emote/xenomorph/hiss/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(-10)

/datum/emote/xenomorph/growl
	key = "growl"

	message_1p = "You growl."
	message_3p = "menacingly growls."

	message_muzzled = "shakes violently and makes a loud noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/xenomorph/growl/get_sound(mob/user, intentional)
	return pick(SOUNDIN_XENOMORPH_GROWL)

/datum/emote/xenomorph/growl/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(-10)
