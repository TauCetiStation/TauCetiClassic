/datum/emote/human/laugh
	key = "laugh"

	message_1p = "Вы смеётесь."
	message_3p = "смеётся."

	message_impaired_production = "тихо посмеивается."

	message_miming = "изображает смех."
	message_muzzled = "издаёт сдавленный смех."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	required_stat = CONSCIOUS

/datum/emote/human/laugh/get_impaired_msg(mob/user)
	return "открывает и закрывает свой рот, улыбаясь."

/datum/emote/human/laugh/get_sound(mob/living/carbon/human/user, intentional)
	var/static/list/laugh_by_gender_species = list(
		"[SKRELL][FEMALE]" = SOUNDIN_LAUGH_SKRELL_FEMALE,
		"[SKRELL][MALE]" = SOUNDIN_LAUGH_SKRELL_MALE,
		"[SERPENTID][NEUTER]" = SOUNDIN_LAUGH_INSECTOID,
		"[MOTH][NEUTER]" = SOUNDIN_LAUGH_INSECTOID,
	)

	var/hash = "[user.get_species()][user.gender]"

	if(laugh_by_gender_species[hash])
		return laugh_by_gender_species[hash]

	return get_sound_by_voice(user, SOUNDIN_LAUGH_MALE, SOUNDIN_LAUGH_FEMALE)


/datum/emote/human/giggle
	key = "giggle"

	message_1p = "Вы хихикаете."
	message_3p = "хихикает."

	message_impaired_production = "слегка улыбается и тихо хихикает."

	message_miming = "изображает хихикание."
	message_muzzled = "издаёт сдавленное хихикание."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS

/datum/emote/human/giggle/get_impaired_msg(mob/user)
	return "открывает и закрывает слегка свой рот, улыбаясь."

/datum/emote/human/grunt
	key = "grunt"

	message_1p = "Вы ворчите."
	message_3p = "ворчит."

	message_impaired_production = "корчится, слегка вздыхая."

	message_miming = "изображает ворчание!"
	message_muzzled = "тихо ворчит!"

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-pain"

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_PAIN)

/datum/emote/human/grunt/get_impaired_msg(mob/user)
	return "стиснул свои зубы."

/datum/emote/human/grunt/get_sound(mob/living/carbon/human/user, intentional)
	var/static/list/grunt_by_gender_species = list(
		"[TAJARAN][FEMALE]" = SOUNDIN_TAJARAN_FEMALE_LIGHT_PAIN,
		"[TAJARAN][MALE]" = SOUNDIN_TAJARAN_MALE_LIGHT_PAIN,
		"[SKRELL][FEMALE]" = SOUNDIN_SKRELL_LIGHT_PAIN,
		"[SKRELL][MALE]" = SOUNDIN_SKRELL_LIGHT_PAIN,
		"[UNATHI][FEMALE]" = SOUNDIN_UNATHI_LIGHT_PAIN,
		"[UNATHI][MALE]" = SOUNDIN_UNATHI_LIGHT_PAIN,
		"[VOX][NEUTER]" = SOUNDIN_VOX_LIGHT_PAIN,
		"[SERPENTID][NEUTER]" = SOUNDIN_GRUNT_INSECTOID,
		"[MOTH][NEUTER]" = SOUNDIN_GRUNT_INSECTOID,
	)

	var/hash = "[user.get_species()][user.gender]"

	if(grunt_by_gender_species[hash])
		return pick(grunt_by_gender_species[hash])
	return get_sound_by_voice(user, SOUNDIN_MALE_LIGHT_PAIN, SOUNDIN_FEMALE_LIGHT_PAIN)

/datum/emote/human/grunt/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(10)


/datum/emote/human/groan
	key = "groan"

	message_1p = "Вы стонете."
	message_3p = "стонет."

	message_impaired_production = "корчится и тихо постанывает."

	message_miming = "изображает боль"
	message_muzzled = "издаёт сдавленный шум"

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-pain"

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_PAIN)

/datum/emote/human/groan/get_impaired_msg(mob/user)
	return "приоткрывает свой рот."

/datum/emote/human/groan/get_sound(mob/living/carbon/human/user, intentional)
	var/static/list/grunt_by_gender_species = list(
		"[UNATHI]" = SOUNDIN_UNATHI_PASSIVE_PAIN,
		"[SKRELL]" = SOUNDIN_SKRELL_PASSIVE_PAIN,
		"[VOX]" = SOUNDIN_VOX_PASSIVE_PAIN,
		"[SERPENTID]" = SOUNDIN_GRUNT_INSECTOID,
		"[MOTH]" = SOUNDIN_GRUNT_INSECTOID,
	)

	var/hash = "[user.get_species()]"

	if(grunt_by_gender_species[hash])
		return pick(grunt_by_gender_species[hash])
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

	message_1p = "Вы кричите!"
	message_3p = "кричит!"

	message_impaired_production = "кривит лицо в муках!"

	message_miming = "изображает крик!"
	message_muzzled = "издаёт громкое мычание!"

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-scream"

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_PAIN)

/datum/emote/human/scream/get_impaired_msg(mob/user)
	return "открывает свой рот как рыбка хватающая ртом воздух!"

/datum/emote/human/scream/get_sound(mob/living/carbon/human/user, intentional)
	var/static/list/scream_by_gender_species = list(
		"[TAJARAN][FEMALE]" = SOUNDIN_TAJARAN_MALE_HEAVY_PAIN,
		"[TAJARAN][MALE]" = SOUNDIN_TAJARAN_MALE_HEAVY_PAIN,
		"[SKRELL][FEMALE]" = SOUNDIN_SKRELL_HEAVY_PAIN,
		"[SKRELL][MALE]" = SOUNDIN_SKRELL_HEAVY_PAIN,
		"[UNATHI][FEMALE]" = SOUNDIN_UNATHI_HEAVY_PAIN,
		"[UNATHI][MALE]" = SOUNDIN_UNATHI_HEAVY_PAIN,
		"[VOX][NEUTER]" = SOUNDIN_VOX_HEAVY_PAIN,
		"[SERPENTID][NEUTER]" = SOUNDIN_SCREAM_INSECTOID,
		"[MOTH][NEUTER]" = SOUNDIN_SCREAM_INSECTOID,
	)
	var/hash = "[user.get_species()][user.gender]"

	if(scream_by_gender_species[hash])
		return pick(scream_by_gender_species[hash])
	return get_sound_by_voice(user, SOUNDIN_MALE_HEAVY_PAIN, SOUNDIN_FEMALE_HEAVY_PAIN)

/datum/emote/human/scream/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.add_combo_value_all(10)


/datum/emote/human/cough
	key = "cough"

	message_1p = "Вы кашляете."
	message_3p = "кашляет."

	message_impaired_production = "сильно дергается!"

	message_miming = "изображает кашель."
	message_muzzled = "пытается покашлять."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)

/datum/emote/human/cough/get_impaired_msg(mob/user)
	return "дергается своим лицом вперед, открывая и закрывая свой рот!"

/datum/emote/human/cough/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_MBCOUGH, SOUNDIN_FBCOUGH)


/datum/emote/human/hiccup
	key = "hiccup"

	message_1p = "Вы икаете."
	message_3p = "икает."

	message_impaired_production = "издаёт слаыбй шум."

	message_miming = "изображает икоту."
	message_muzzled = "издаёт сдавленный звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/voice/hiccup.ogg'

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)

/datum/emote/human/hiccup/get_impaired_msg(mob/user)
	return "неожиданно содрогается, открыв свой рот."


/datum/emote/human/choke
	key = "choke"

	message_1p = "Вы задыхаетесь."
	message_3p = "задыхается."

	message_impaired_production = "издаёт сдавленный звук."

	message_miming = "изображает удушье."
	message_muzzled = "издаёт сдавленный звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)
	required_bodyparts = list(BP_HEAD)

	cloud = "cloud-gasp"

/datum/emote/human/choke/get_impaired_msg(mob/user)
	return "отчаянно хватается за своё горло!"

/datum/emote/human/snore
	key = "snore"

	message_1p = "Вы сопите."
	message_3p = "сопит."

	message_impaired_production = "издаёт звук."

	message_miming = "изображает сопение."
	message_muzzled = "издаёт звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)

/datum/emote/human/snore/get_impaired_msg(mob/user)
	return "открывает свой рот широко, чтобы сделать вдох."


// TO-DO: make so intentional sniffing reveals how a reagent solution held in hand smells?
/datum/emote/human/sniff
	key = "sniff"

	message_1p = "Вы принюхиваетесь."
	message_3p = "принюхивается."

	message_impaired_production = "принюхивается."
	message_impaired_reception = "принюхивается."

	message_miming = "принюхивается."
	message_muzzled = "издаёт сдавленный звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS


/datum/emote/human/sneeze
	key = "sneeze"

	message_1p = "Вы чихнули."
	message_3p = "чихает."

	message_impaired_production = "издаёт странный звук."
	message_impaired_reception = "чихает."

	message_miming = "чихает."
	message_muzzled = "издаёт странный звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)

/datum/emote/human/sneeze/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_SNEEZE_MALE, SOUNDIN_SNEEZE_FEMALE)


/datum/emote/human/gasp
	key = "gasp"

	message_1p = "Вы ловите ртом воздух с трудом!"
	message_3p = "жадно ловит ртом воздух!"

	message_impaired_production = "жадно втягивает воздух!"
	message_impaired_reception = "жадно втягивает воздух!"

	message_miming = "изображает удушье!"
	message_muzzled = "издаёт сдавленный звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)

	cloud = "cloud-gasp"

/datum/emote/human/gasp/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_GASP_MALE, SOUNDIN_GASP_FEMALE)


/datum/emote/human/sigh
	key = "sigh"

	message_1p = "Вы вздохнули."
	message_3p = "вздыхает."

	message_impaired_production = "издаёт сдавленный звук."

	message_miming = "изображает вздох."
	message_muzzled = "издаёт сдавленный звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_EMOTIONLESS)

/datum/emote/human/sigh/get_impaired_msg(mob/user)
	return "открывает свой рот."

/datum/emote/human/sigh/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_SIGH_MALE, SOUNDIN_SIGH_FEMALE)

/datum/emote/human/mumble
	key = "mumble"

	message_1p = "Вы бормочете."
	message_3p = "бормочет."

	message_impaired_production = "издаёт сдавленный звук."

	message_miming = "изображает вздох."
	message_muzzled = "раздражается!"

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_EMOTIONLESS)

/datum/emote/human/mumble/get_impaired_msg(mob/user)
	return "открывает и закрывает [THEIR_RU(user)] рот."

/datum/emote/human/hmm_think
	key = "hmm"

	message_1p = "Вы задумались..."
	message_3p = "о чём-то задумчиво размышляет..."

	message_impaired_production = "о чём-то задумался"

	message_miming = "изображает из себя философа"
	message_muzzled = "невнятно бормочет..."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	required_stat = CONSCIOUS

/datum/emote/human/hmm_think/get_impaired_msg(mob/user)
	return "задумчиво потирает свой подбородок..."

/datum/emote/human/hmm_think/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_HMM_THINK_MALE, SOUNDIN_HMM_THINK_FEMALE)

/datum/emote/human/hmm_question
	key = "hmm?"

	message_1p = "Вы задумались и вопросительно подняли бровь."
	message_3p = "вопросительно бормочет..?"

	message_impaired_production = "вопросительно бормочет..?"

	message_miming = "вопросительно поднимает бровь..?"
	message_muzzled = "тихо и загадочно бормочет..."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	required_stat = CONSCIOUS

/datum/emote/human/hmm_question/get_impaired_msg(mob/user)
	return "вопросительно приподнимает свои брови..?"

/datum/emote/human/hmm_question/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_HMM_QUESTION_MALE, SOUNDIN_HMM_QUESTION_FEMALE)

/datum/emote/human/hmm_excited
	key = "hmm!"

	message_1p = "Вы взволнованно бормочете!"
	message_3p = "взволнованно о чём-то бормочет."

	message_impaired_production = "взволнованно бормочет!"

	message_miming = "с удивлением поднимает бровь!"
	message_muzzled = "издаёт сдавленное, но взволнованное бормотание!"

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	required_stat = CONSCIOUS

/datum/emote/human/hmm_excited/get_impaired_msg(mob/user)
	return "взволнованно приподнимает свои брови!"

/datum/emote/human/hmm_excited/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_HMM_EXCLAIM_MALE, SOUNDIN_HMM_EXCLAIM_FEMALE)

/datum/emote/human/woo
	key = "woo"

	message_1p = "Вы прокричали с восторгом!"
	message_3p = "восторженно кричит!"

	message_impaired_production = "восторженно кричит!"
	message_impaired_reception = "восторженно кричит!"

	message_miming = "изображает восторг!"
	message_muzzled = "выглядит взволнованно..."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	required_stat = CONSCIOUS

/datum/emote/human/woo/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_WOO_MALE, SOUNDIN_WOO_FEMALE)

/datum/emote/human/spit
	key = "spit"

	message_1p = "Вы плюетесь."
	message_3p = "плюется."

	message_impaired_production = "плюется."
	message_impaired_reception = "плюется."

	message_miming = "изображает плевок."
	message_muzzled = "пытается собрать слюну во рту..."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE
	soundless_for_mute = FALSE

	required_stat = CONSCIOUS

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
