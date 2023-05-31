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


/datum/emote/robot/halt
	message_1p = "You skreech with your speakers, \"Halt! Security!\""
	message_3p = "skreeches with it's skeapers, \"Halt! Security!\""

	message_impaired_production = "makes a loud noise."
	message_impaired_reception = "flickers with red."

	message_miming = "makes loud robot noises."
	message_muzzled = "makes a loud noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/voice/halt.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(has_robot_module, /obj/item/weapon/robot_module/security),
	)
