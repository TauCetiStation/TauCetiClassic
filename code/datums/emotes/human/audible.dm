/datum/emote/human/laugh
	key = "laugh"

	message_1p = "You laugh."
	message_3p = "laughs."

	message_impaired_production = "laughs silently."

	message_miming = "acts out a laugh."
	message_muzzled = "giggles sligthly."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)

/datum/emote/human/laugh/get_impaired_msg(mob/user)
	return "opens and closes [P_THEIR(user)] mouth, smiling."

/datum/emote/human/laugh/get_sound(mob/living/carbon/human/user, intentional)
	var/static/list/laugh_by_gender_species = list(
		"[SKRELL][FEMALE]" = SOUNDIN_LAUGH_SKRELL_FEMALE,
		"[SKRELL][MALE]" = SOUNDIN_LAUGH_SKRELL_MALE,
	)

	var/hash = "[user.get_species()][user.gender]"

	if(laugh_by_gender_species[hash])
		return laugh_by_gender_species[hash]

	return get_sound_by_voice(user, SOUNDIN_LAUGH_MALE, SOUNDIN_LAUGH_FEMALE)


/datum/emote/human/giggle
	key = "giggle"

	message_1p = "You giggle."
	message_3p = "giggles."

	message_impaired_production = "smiles slightly and giggles silently."

	message_miming = "appears to giggle."
	message_muzzled = "giggles slightly."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/human/giggle/get_impaired_msg(mob/user)
	return "opens and closes [P_THEIR(user)] mouth slightly, smiling."

/datum/emote/human/grunt
	key = "grunt"

	message_1p = "You grunt."
	message_3p = "grunts."

	message_impaired_production = "writhes and sighs slightly."

	message_miming = "appears to grunt!"
	message_muzzled = "grunts silently!"

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-pain"

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_PAIN),
	)

/datum/emote/human/grunt/get_impaired_msg(mob/user)
	return "clenches [P_THEIR(user)] teeth."

/datum/emote/human/grunt/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_MALE_LIGHT_PAIN, SOUNDIN_FEMALE_LIGHT_PAIN)

/datum/emote/human/grunt/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(10)


/datum/emote/human/groan
	key = "groan"

	message_1p = "You groan."
	message_3p = "groans."

	message_impaired_production = "writhes and sighs slightly."

	message_miming = "appears to be in pain!"
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-pain"

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_PAIN),
	)

/datum/emote/human/groan/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user)] mouth slightly."

/datum/emote/human/groan/get_sound(mob/living/carbon/human/user, intentional)
	var/female_groans = SOUNDIN_FEMALE_PASSIVE_PAIN
	var/male_groans = SOUNDIN_MALE_PASSIVE_PAIN
	if(user.get_species() != SKRELL && HAS_TRAIT(src, TRAIT_LOW_PAIN_THRESHOLD) && prob(66))
		female_groans = SOUNDIN_FEMALE_WHINER_PAIN
		male_groans = SOUNDIN_MALE_WHINER_PAIN

	return get_sound_by_voice(user, male_groans, female_groans)

/datum/emote/human/groan/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(10)


/datum/emote/human/scream
	key = "scream"

	message_1p = "You scream!"
	message_3p = "screams!"

	message_impaired_production = "twists their face into an agonised expression!"

	message_miming = "acts out a scream!"
	message_muzzled = "makes a loud noise!"

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-scream"

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_PAIN),
	)

/datum/emote/human/scream/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user)] mouth like a fish gasping for air!"

/datum/emote/human/scream/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_MALE_HEAVY_PAIN, SOUNDIN_FEMALE_HEAVY_PAIN)

/datum/emote/human/scream/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(10)


/datum/emote/human/cough
	key = "cough"

	message_1p = "You cough."
	message_3p = "coughs."

	message_impaired_production = "spasms violently!"

	message_miming = "acts out a cough."
	message_muzzled = "appears to cough."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)

/datum/emote/human/cough/get_impaired_msg(mob/user)
	return "moves [P_THEIR(user)] face forward as [P_THEY(user)] open and close [P_THEIR(user)] mouth!"

/datum/emote/human/cough/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_MBCOUGH, SOUNDIN_FBCOUGH)


/datum/emote/human/hiccup
	key = "hiccup"

	message_1p = "You hiccup."
	message_3p = "hiccups."

	message_impaired_production = "makes a weak noise."

	message_miming = "hiccups."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/voice/hiccup.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)

/datum/emote/human/hiccup/get_impaired_msg(mob/user)
	return "spasms suddenly while opening [P_THEIR(user)] mouth."

/datum/emote/human/choke
	key = "choke"

	message_1p = "You choke."
	message_3p = "chokes."

	message_impaired_production = "makes a weak noise."

	message_miming = "chokes."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)

	cloud = "cloud-gasp"

/datum/emote/human/choke/get_impaired_msg(mob/user)
	return "clutches [P_THEIR(user)] throat desperately!"

/datum/emote/human/snore
	key = "snore"

	message_1p = "You snore."
	message_3p = "snores."

	message_impaired_production = "makes a noise."

	message_miming = "snores."
	message_muzzled = "makes a noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)

/datum/emote/human/snore/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user)] mouth wide to take a breath."

// TO-DO: make so intentional sniffing reveals how a reagent solution held in hand smells?
/datum/emote/human/sniff
	key = "sniff"

	message_1p = "You sniff."
	message_3p = "sniffs."

	message_impaired_production = "sniffs."
	message_impaired_reception = "sniffs."

	message_miming = "whimpers."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)


/datum/emote/human/sneeze
	key = "sneeze"

	message_1p = "You sneeze."
	message_3p = "sneezes."

	message_impaired_production = "makes a strange noise."
	message_impaired_reception = "sneezes."

	message_miming = "sneezes."
	message_muzzled = "makes a strange noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
	)

/datum/emote/human/sneeze/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_SNEEZE_MALE, SOUNDIN_SNEEZE_FEMALE)


/datum/emote/human/gasp
	key = "gasp"

	message_1p = "You gasp!"
	message_3p = "gasps!"

	message_impaired_production = "sucks in air violently!"
	message_impaired_reception = "sucks in air violently!"

	message_miming = "appears to be gasping!"
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_present_bodypart, BP_HEAD),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_BREATHE),
	)

	cloud = "cloud-gasp"

/datum/emote/human/gasp/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_GASP_MALE, SOUNDIN_GASP_FEMALE)


/datum/emote/human/sigh
	key = "sigh"

	message_1p = "You sigh."
	message_3p = "sighs."

	message_impaired_production = "makes a weak noise."

	message_miming = "sighs."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_EMOTION),
	)

/datum/emote/human/sigh/get_impaired_msg(mob/user)
	return "opens [P_THEIR(user)] mouth."

/datum/emote/human/sigh/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_SIGH_MALE, SOUNDIN_SIGH_FEMALE)

/datum/emote/human/mumble
	key = "mumble"

	message_1p = "You mumble."
	message_3p = "mumbles."

	message_impaired_production = "makes a weak noise."

	message_miming = "sighs."
	message_muzzled = "makes an annoyed face!"

	message_type = SHOWMSG_AUDIO

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_intentional_or_species_no_flag, NO_EMOTION),
	)

/datum/emote/human/mumble/get_impaired_msg(mob/user)
	return "opens and closes [P_THEIR(user)] mouth."

/datum/emote/human/hmm_think
	key = "hmm"

	message_1p = "You mumble thoughtfully."
	message_3p = "mumbles thoughtfully..."

	message_impaired_production = "mumbles thougtfully..."

	message_miming = "acts out a philosophical thinking..."
	message_muzzled = "mumble silently and thoughtfully..."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)

/datum/emote/human/hmm_think/get_impaired_msg(mob/user)
	return "scratches [P_THEIR(user)] chin thougtfully..."

/datum/emote/human/hmm_think/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_HMM_THINK_MALE, SOUNDIN_HMM_THINK_FEMALE)

/datum/emote/human/hmm_question
	key = "hmm?"

	message_1p = "You mumble and curle your eyebrows questioningly..?"
	message_3p = "mumbles questioningly..?"

	message_impaired_production = "mumbles questioningly..?"

	message_miming = "curls their eyebrows questioningly..?"
	message_muzzled = "mumbles silently and questioningly..?"

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)

/datum/emote/human/hmm_question/get_impaired_msg(mob/user)
	return "curls [P_THEIR(user)] eyebrows questioningly..?"

/datum/emote/human/hmm_question/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_HMM_QUESTION_MALE, SOUNDIN_HMM_QUESTION_FEMALE)

/datum/emote/human/hmm_excited
	key = "hmm!"

	message_1p = "You mumble excitedly!"
	message_3p = "mumbles excitedly."

	message_impaired_production = "mumbles excitedly!"

	message_miming = "curls their eyebrows excitedly!"
	message_muzzled = "mumbles silently and excitedly!"

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)

/datum/emote/human/hmm_excited/get_impaired_msg(mob/user)
	return "curls [P_THEIR(user)] eyebrows excitedly!"

/datum/emote/human/hmm_excited/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_HMM_EXCLAIM_MALE, SOUNDIN_HMM_EXCLAIM_FEMALE)

/datum/emote/human/woo
	key = "woo"

	message_1p = "You woo excitedly!"
	message_3p = "woos excitedly!"

	message_impaired_production = "woos excitedly!"
	message_impaired_reception = "woos excitedly!"

	message_miming = "acts out gestures, excitedly!"
	message_muzzled = "looks excited."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)

/datum/emote/human/woo/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_WOO_MALE, SOUNDIN_WOO_FEMALE)

/datum/emote/human/spit
	key = "spit"

	message_1p = "You spit tactlessly."
	message_3p = "spits tactlessly."

	message_impaired_production = "spits tactlessly."
	message_impaired_reception = "spits tactlessly."

	message_miming = "silently gathers invisible spittle and spits it out."
	message_muzzled = "tries to gather some spittle."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS)
	)

	// Mouth getting a bit dry
	cooldown = 3 SECONDS

/datum/emote/human/spit/get_sound(mob/user, emote_key, intentional)
	return pick('sound/voice/spit_1.ogg','sound/voice/spit_2.ogg')

/datum/emote/human/spit/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	// We don't really have a hydration system, so this is the limit.
	user.nutrition -= 10

	var/obj/item/cover

	if(user.wear_mask && (user.wear_mask.flags & MASKCOVERSMOUTH))
		cover = user.wear_mask
	else if(user.head && (user.head.flags & MASKCOVERSMOUTH))
		cover = user.head

	if(cover)
		cover.make_wet()
		return

	var/turf/T = get_step(user, user.dir)

	if(!T)
		return

	var/made_wet = FALSE

	for(var/mob/living/carbon/C in T)
		if(!C.shoes)
			continue
		C.shoes.make_wet()
		made_wet = TRUE

	if(prob(50) && !made_wet)
		user.shoes?.make_wet()
