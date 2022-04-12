/datum/emote/laugh
	key = "laugh"

	message_1p = "You laugh."
	message_3p = "laughs."

	message_impaired_production = "laughs silently."
	message_impaired_reception = "You see someone opening and closing their mouth, smiling."

	message_miming = "acts out a laugh."
	message_muzzled = "giggles sligthly."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)

/datum/emote/laugh/get_sound(mob/living/carbon/human/user, intentional)
	var/static/list/laugh_by_gender_species = list(
		"[SKRELL][FEMALE]" = SOUNDIN_LAUGH_SKRELL_FEMALE,
		"[SKRELL][MALE]" = SOUNDIN_LAUGH_SKRELL_MALE,
	)

	var/g = user.gender == FEMALE ? FEMALE : MALE
	var/hash = "[user.get_species()][g]"

	if(laugh_by_gender_species[hash])
		return laugh_by_gender_species[hash]

	if(g == FEMALE)
		return pick(SOUNDIN_LAUGH_FEMALE)

	return pick(SOUNDIN_LAUGH_MALE)

/datum/emote/laugh/play_sound(mob/living/carbon/human/user, intentional, emote_sound)
	var/voice_frequency = TRANSLATE_RANGE(user.age, user.species.min_age, user.species.max_age, 0.85, 1.05)
	var/sound_frequency = 1.05 - (voice_frequency - 0.85)

	playsound(user, emote_sound, VOL_EFFECTS_MASTER, null, FALSE, sound_frequency)


/datum/emote/giggle
	key = "giggle"

	message_1p = "You giggle."
	message_3p = "giggles."

	message_impaired_production = "smiles slightly and giggles silently."
	message_impaired_reception = "You see someone opening and closing their mouth slightly, smiling."

	message_miming = "appears to giggle."
	message_muzzled = "giggles slightly."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/grunt
	key = "grunt"

	message_1p = "You grunt."
	message_3p = "grunts."

	message_impaired_production = "writhes and sighs slightly."
	message_impaired_reception = "You see someone clench their teeth."

	message_miming = "appears to grunt!"
	message_muzzled = "grunts silently!"

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-pain"

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_PAIN),
	)

/datum/emote/grunt/get_sound(mob/living/carbon/human/user, intentional)
	return pick(user.gender == FEMALE ? SOUNDIN_FEMALE_LIGHT_PAIN : SOUNDIN_MALE_LIGHT_PAIN)

/datum/emote/grunt/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(10)


/datum/emote/groan
	key = "groan"

	message_1p = "You groan."
	message_3p = "groans."

	message_impaired_production = "writhes and sighs slightly."
	message_impaired_reception = "You see someone opening their mouth slightly."

	message_miming = "appears to be in pain!"
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-pain"

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_PAIN),
	)

/datum/emote/groan/get_sound(mob/living/carbon/human/user, intentional)
	if(user.get_species() != SKRELL && HAS_TRAIT(src, TRAIT_LOW_PAIN_THRESHOLD) && prob(66))
		return pick(user.gender == FEMALE ? SOUNDIN_FEMALE_WHINER_PAIN : SOUNDIN_MALE_WHINER_PAIN)

	return pick(user.gender == FEMALE ? SOUNDIN_FEMALE_PASSIVE_PAIN : SOUNDIN_MALE_PASSIVE_PAIN)

/datum/emote/groan/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(10)


/datum/emote/scream
	key = "scream"

	message_1p = "You scream!"
	message_3p = "screams!"

	message_impaired_production = "twists their face into an agonised expression!"
	message_impaired_reception = "You see someone opening their mouth like a fish gasping for air!"

	message_miming = "acts out a scream!"
	message_muzzled = "makes a louad noise!"

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-scream"

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_PAIN),
	)

/datum/emote/scream/get_sound(mob/living/carbon/human/user, intentional)
	return pick(user.gender == FEMALE ? SOUNDIN_FEMALE_HEAVY_PAIN : SOUNDIN_MALE_HEAVY_PAIN)

/datum/emote/scream/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(10)


/datum/emote/cough
	key = "cough"

	message_1p = "You cough."
	message_3p = "coughs."

	message_impaired_production = "spasms violently!"
	message_impaired_reception = "You see someone moving their face forward as they open and close their mouth!"

	message_miming = "acts out a cough."
	message_muzzled = "appears to cough."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)

/datum/emote/cough/get_sound(mob/living/carbon/human/user, intentional)
	return pick(user.gender == FEMALE ? SOUNDIN_FBCOUGH : SOUNDIN_MBCOUGH)


/datum/emote/hiccup
	key = "hiccup"

	message_1p = "You hiccup."
	message_3p = "hiccups."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "You see someone spasm suddenly while opening their mouth."

	message_miming = "hiccups."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/voice/hiccup.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)


/datum/emote/beep
	key = "beep"

	message_1p = "You beep."
	message_3p = "beeps."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "You see someone open their mouth quickly."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/twobeep.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/ping
	key = "ping"

	message_1p = "You ping."
	message_3p = "pings."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "You see someone opening and closing their mouth."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/ping.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/buzz
	key = "buzz"

	message_1p = "You buzz."
	message_3p = "buzzes."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "You see someone clenching their teeth."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/buzz-sigh.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/choke
	key = "choke"

	message_1p = "You choke."
	message_3p = "chokes."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "You see someone clutching their throat desperately!"

	message_miming = "chokes."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)


/datum/emote/snore
	key = "snore"

	message_1p = "You snore."
	message_3p = "snores."

	message_impaired_production = "makes a noise."
	message_impaired_reception = "You see someone opening their mouth wide to take a breath."

	message_miming = "snores."
	message_muzzled = "makes a noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)


/datum/emote/whimper
	key = "whimper"

	message_1p = "You whimper."
	message_3p = "whimpers."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "You see someone making a sad face."

	message_miming = "whimpers."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_EMOTION),
	)


// TO-DO: make so intentional sniffing reveals how a reagent solution held in hand smells?
/datum/emote/sniff
	key = "sniff"

	message_1p = "You sniff."
	message_3p = "sniffs."

	message_impaired_production = "sniffs."
	message_impaired_reception = "You see someone sniffing."

	message_miming = "whimpers."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/sneeze
	key = "sneeze"

	message_1p = "You sneeze."
	message_3p = "sneezes."

	message_impaired_production = "makes a strange noise."
	message_impaired_reception = "You see someone sneezing."

	message_miming = "sneezes."
	message_muzzled = "makes a strange noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)


/datum/emote/gasp
	key = "gasp"

	message_1p = "You gasp!"
	message_3p = "gasps!"

	message_impaired_production = "sucks in air violently!"
	message_impaired_reception = "You see someone sucking in air violently!"

	message_miming = "appears to be gasping!"
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)

	cloud = "cloud-gasp"


/datum/emote/moan
	key = "moan"

	message_1p = "You moan!"
	message_3p = "moans!"

	message_impaired_production = "moans silently."
	message_impaired_reception = "You see someone opening their mouth wide."

	message_miming = "appears to moan!"
	message_muzzled = "moans silently!"

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_EMOTION),
	)


/datum/emote/sigh
	key = "sigh"

	message_1p = "You sigh."
	message_3p = "sighs."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "You see someone opening their mouth."

	message_miming = "sighs."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_EMOTION),
	)


/datum/emote/mumble
	key = "mumble"

	message_1p = "You mumble."
	message_3p = "mumbles."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "You see someone opening and closing their mouth."

	message_miming = "sighs."
	message_muzzled = "makes an annoyed face!"

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_EMOTION),
	)
