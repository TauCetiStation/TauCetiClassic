/datum/emote/robot/beep
	key = "beep"

	message_1p = "You beep."
	message_3p = "beeps."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/twobeep.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/robot/ping
	key = "ping"

	message_1p = "You ping."
	message_3p = "pings."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/ping.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/robot/buzz
	key = "buzz"

	message_1p = "You buzz."
	message_3p = "buzzes."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/buzz-sigh.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/robot/law
	key = "law"

	message_1p = "You show your legal authorization barcode."
	message_3p = "shows it's legal authorization barcode."

	message_impaired_production = "makes a noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/voice/beepsky/iamthelaw.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(has_robot_module, /obj/item/weapon/robot_module/security),
	)


/datum/emote/robot/confirm
	key = "confirm"
	emote_message_3p = "emits an affirmative blip."

/datum/emote/robot/deny
	key = "deny"
	emote_message_3p = "emits a negative blip."

/datum/emote/robot/scary
	key = "scary"
	emote_message_3p = "emits a disconcerting tone."

/datum/emote/robot/dwoop
	key = "dwoop"
	emote_message_1p_target = "You chirp happily at TARGET!"
	emote_message_1p = "You chirp happily."
	emote_message_3p_target = "chirps happily at TARGET!"
	emote_message_3p = "chirps happily.

/datum/emote/robot/boop
	key = "roboboop"
	emote_message_1p_target = "You boop at TARGET!"
	emote_message_1p = "You boop."
	emote_message_3p_target = "boops at TARGET!"
	emote_message_3p = "boops."

/datum/emote/robot/robochirp
	key = "robochirp"
	emote_message_1p_target = "You chirp at TARGET!"
	emote_message_1p = "You chirp."
	emote_message_3p_target = "chirps at TARGET!"
	emote_message_3p = "chirps."
