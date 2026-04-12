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

	required_stat = CONSCIOUS


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

	required_stat = CONSCIOUS


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

	required_stat = CONSCIOUS


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

	required_stat = CONSCIOUS

/datum/emote/robot/law/can_emote(mob/user, intentional)
	var/mob/living/silicon/robot/R = user
	if(!istype(R.module, /obj/item/weapon/robot_module/security))
		if(intentional)
			to_chat(R, "<span class='notice'>You do not have the required module for this emote.</span>")
		return FALSE

	return ..()


/datum/emote/robot/confirm
	key = "confirm"

	message_1p = "You emits affirmative blip."
	message_3p = "emits an affirmative blip."

	message_impaired_production = "makes a noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/synth_yes.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/deny
	key = "deny"

	message_1p = "You emits negative blip."
	message_3p = "emits a negative blip."

	message_impaired_production = "makes a noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/synth_no.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/scary
	key = "scary"

	message_1p = "You emits disconcerting tone."
	message_3p = "emits a disconcerting tone."

	message_impaired_production = "makes a noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/synth_alert.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/woop
	key = "woop"

	message_1p = "You chirp happily."
	message_3p = "chirps happily."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/dwoop.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/boop
	key = "boop"

	message_1p = "You boop."
	message_3p = "boops."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/roboboop.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/robochirp
	key = "chirp"

	message_1p = "You chirp."
	message_3p = "chirps."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/robochirp.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/calling
	key = "call"

	message_1p = "You're dialing."
	message_3p = "dialling."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/longwhistle_robot.ogg'

	required_stat = CONSCIOUS
