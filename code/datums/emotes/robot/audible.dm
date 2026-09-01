/datum/emote/robot/beep
	key = "beep"

	message_1p = "Вы пикаете."
	message_3p = "пикает."

	message_impaired_production = "издаёт слабый звук."
	message_impaired_reception = "мерцает."

	message_miming = "изображает звуки робота."
	message_muzzled = "издаёт слабый звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/twobeep.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/ping
	key = "ping"

	message_1p = "Вы сигналите."
	message_3p = "сигналит."

	message_impaired_production = "издаёт слабый звук."
	message_impaired_reception = "мерцает."

	message_miming = "изображает звуки робота."
	message_muzzled = "издаёт слабый звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/ping.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/buzz
	key = "buzz"

	message_1p = "Вы жужжите."
	message_3p = "жужжит."

	message_impaired_production = "издаёт слабый звук."
	message_impaired_reception = "мерцает."

	message_miming = "изображает звуки робота."
	message_muzzled = "издаёт слабый звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/buzz-sigh.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/law
	key = "law"

	message_1p = "Вы предъявляете штрихкод полномочий службы безопасности.."
	message_3p = "предъявляет штрихкод полномочий службы безопасности.."

	message_impaired_production = "издаёт звук."
	message_impaired_reception = "мерцает."

	message_miming = "изображает звуки робота."
	message_muzzled = "издаёт звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/voice/beepsky/iamthelaw.ogg'

	required_stat = CONSCIOUS

/datum/emote/robot/law/can_emote(mob/user, intentional)
	var/mob/living/silicon/robot/R = user
	if(!istype(R.module, /obj/item/weapon/robot_module/security))
		if(intentional)
			to_chat(R, "<span class='notice'>У вас неподходящий модуль для этого эмоута.</span>")
		return FALSE

	return ..()


/datum/emote/robot/confirm
	key = "confirm"

	message_1p = "Вы утвердительно сигналите."
	message_3p = "утвердительно сигналит."

	message_impaired_production = "издаёт звук."
	message_impaired_reception = "мерцает."

	message_miming = "изображает звуки робота."
	message_muzzled = "издаёт слабый звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/synth_yes.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/deny
	key = "deny"

	message_1p = "Вы отрицательно сигналите."
	message_3p = "отрицательно сигналит."

	message_impaired_production = "издаёт звуки."
	message_impaired_reception = "мерцает."

	message_miming = "изображает звуки робота."
	message_muzzled = "издаёт слабый звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/synth_no.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/scary
	key = "scary"

	message_1p = "Вы пугающе сигналите."
	message_3p = "пугающе сигналит."

	message_impaired_production = "издаёт звуки."
	message_impaired_reception = "мерцает."

	message_miming = "изображает звуки робота."
	message_muzzled = "издаёт слабый звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/synth_alert.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/woop
	key = "woop"

	message_1p = "Вы радостно пиликаете."
	message_3p = "радостно пиликает."

	message_impaired_production = "издаёт слабый звук."
	message_impaired_reception = "мерцает."

	message_miming = "изображает звуки робота."
	message_muzzled = "издаёт слабый звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/dwoop.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/boop
	key = "boop"

	message_1p = "Вы издаёте короткий гудок."
	message_3p = "издаёт короткий гудок."

	message_impaired_production = "издаёт слабый звук."
	message_impaired_reception = "мерцает."

	message_miming = "изображает звуки робота."
	message_muzzled = "издаёт слабый звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/roboboop.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/robochirp
	key = "chirp"

	message_1p = "Вы пиликаете."
	message_3p = "пиликает."

	message_impaired_production = "издаёт слабый звук."
	message_impaired_reception = "мерцает."

	message_miming = "изображает звуки робота."
	message_muzzled = "издаёт слабый звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/robochirp.ogg'

	required_stat = CONSCIOUS


/datum/emote/robot/calling
	key = "call"

	message_1p = "Вы набираете номер."
	message_3p = "набирает номер."

	message_impaired_production = "издаёт звуки."
	message_impaired_reception = "мерцает."

	message_miming = "изображает звуки робота."
	message_muzzled = "издаёт слабый звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/longwhistle_robot.ogg'

	required_stat = CONSCIOUS
