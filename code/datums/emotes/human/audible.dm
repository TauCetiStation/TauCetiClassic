/datum/emote/laugh
	key = "laugh"

	message_1p = "You laugh."
	message_3p = "laughs."

	message_impaired_production = "laughs silently."
	message_impaired_reception = "You see someone opening and closing their mouth."

	message_miming = "acts out a laugh."
	message_muzzled = "giggles sligthly."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		CALLBACK(GLOBAL_PROC, .proc/is_not_intentional_or_stat, CONSCIOUS),
	)

/datum/emote/laugh/get_sound(mob/living/carbon/human/user, intentional)
	switch(user.get_species())
		if(SKRELL)
			switch(user.gender)
				if(FEMALE)
					return pick(SOUNDIN_LAUGH_SKRELL_FEMALE)
				else
					return pick(SOUNDIN_LAUGH_SKRELL_MALE)
		else
			switch(user.gender)
				if(FEMALE)
					return pick(SOUNDIN_LAUGH_FEMALE)
				else
					return pick(SOUNDIN_LAUGH_MALE)

/datum/emote/laugh/play_sound(mob/living/carbon/human/user, intentional)
	var/voice_frequency = TRANSLATE_RANGE(user.age, user.species.min_age, user.species.max_age, 0.85, 1.05)
	var/sound_frequency = 1.05 - (voice_frequency - 0.85)

	var/S = get_sound(user, intentional)

	playsound(src, S, VOL_EFFECTS_MASTER, null, FALSE, sound_frequency)
