/datum/emote/xenomorph/whimper
	key = "whimper"

	message_1p = "Вы скулите."
	message_3p = "жалобно скулит."

	message_muzzled = "сильно трясётся, издавая громкий звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/voice/xenomorph/whimper.ogg'

	required_stat = CONSCIOUS

/datum/emote/xenomorph/whimper/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(10)


/datum/emote/xenomorph/roar
	key = "roar"

	message_1p = "Вы ревёте."
	message_3p = "победоносно ревёт."

	message_muzzled = "сильно трясётся, издавая громкий звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS

/datum/emote/xenomorph/roar/get_sound(mob/user, intentional)
	return pick(SOUNDIN_XENOMORPH_ROAR)

/datum/emote/xenomorph/roar/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(-10)


/datum/emote/xenomorph/hiss
	key = "hiss"

	message_1p = "Вы шипите."
	message_3p = "хищно шипит."

	message_muzzled = "сильно трясётся, издавая громкий звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS

/datum/emote/xenomorph/hiss/get_sound(mob/user, intentional)
	return pick(SOUNDIN_XENOMORPH_HISS)

/datum/emote/xenomorph/hiss/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(-10)


/datum/emote/xenomorph/growl
	key = "growl"

	message_1p = "Вы угрожающе рычите."
	message_3p = "угрожающе рычит."

	message_muzzled = "сильно трясётся, издавая громкий звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS

/datum/emote/xenomorph/growl/get_sound(mob/user, intentional)
	return pick(SOUNDIN_XENOMORPH_GROWL)

/datum/emote/xenomorph/growl/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(-10)
