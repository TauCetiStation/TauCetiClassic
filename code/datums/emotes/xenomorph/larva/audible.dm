/datum/emote/larva/whimper
	key = "whimper"

	message_1p = "You whimper."
	message_3p = "whimpers sadly."

	message_muzzled = "shakes violently and makes a very weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/larva/roar
	key = "roar"

	message_1p = "You roar."
	message_3p = "roars like a little predator."

	message_muzzled = "shakes violently and makes a very weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/larva/hiss
	key = "hiss"

	message_1p = "You hiss."
	message_3p = "hisses softly."

	message_muzzled = "shakes violently and makes a very weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/larva/growl
	key = "growl"

	message_1p = "You growl."
	message_3p = "growls softly."

	message_muzzled = "shakes violently and makes a very weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)
