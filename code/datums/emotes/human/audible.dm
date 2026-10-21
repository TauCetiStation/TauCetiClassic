/datum/emote/human/laugh
	key = "laugh"

	message_1p = "Вы смеётесь."
	message_3p = "смеётся."

	message_impaired_production = "беззвучно смеётся."

	message_miming = "сотрясается в беззвучном хохоте."
	message_muzzled = "глухо посмеивается."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	required_stat = CONSCIOUS

/datum/emote/human/laugh/get_impaired_msg(mob/user)
	return "открывает и закрывает рот, улыбаясь."

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

	message_impaired_production = "слегка улыбается и беззвучно хихикает."

	message_miming = "беззучно хихикает."
	message_muzzled = "сдавленно хихикает."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS

/datum/emote/human/giggle/get_impaired_msg(mob/user)
	return "слегка приоткрывает и закрывает рот, улыбаясь."

/datum/emote/human/grunt
	key = "grunt"

	message_1p = "Вы сдавленно вскрикиваете."
	message_3p = "сдавленно вскрикивает."

	message_impaired_production = "корчится и слегка вздыхает."

	message_miming = "картинно морщится в гримасе боли!"
	message_muzzled = "глухо мычит!"

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-pain"

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_PAIN)

/datum/emote/human/grunt/get_impaired_msg(mob/user)
	return "стискивает зубы."

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

	message_impaired_production = "корчится и слегка вздыхает."

	message_miming = "театрально корчится, изображая мучительную боль!"
	message_muzzled = "издаёт слабый звук."

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-pain"

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_PAIN)

/datum/emote/human/groan/get_impaired_msg(mob/user)
	return "приоткрывает рот."

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

	message_impaired_production = "искажает лицо в мучительной гримасе!"

	message_miming = "запрокидывает голову в оглушительном, но беззвучном вопле!"
	message_muzzled = "издаёт громкое мычание!"

	message_type = SHOWMSG_AUDIO

	cloud = "cloud-scream"

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_PAIN)

/datum/emote/human/scream/get_impaired_msg(mob/user)
	return "открывает рот, словно рыба, глотающая воздух!"

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

	message_impaired_production = "сильно содрогается!"

	message_miming = "содрогается в беззвучном кашле."
	message_muzzled = "глухо кашляет."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)

/datum/emote/human/cough/get_impaired_msg(mob/user)
	return "подается вперед, открывая и закрывая рот!"

/datum/emote/human/cough/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_MBCOUGH, SOUNDIN_FBCOUGH)


/datum/emote/human/hiccup
	key = "hiccup"

	message_1p = "Вы икаете."
	message_3p = "икает."

	message_impaired_production = "издаёт слабый звук."

	message_miming = "подпрыгивает на месте, разыгрывая приступ икоты."
	message_muzzled = "издаёт сдавленный звук."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/voice/hiccup.ogg'

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)

/datum/emote/human/hiccup/get_impaired_msg(mob/user)
	return "неожиданно содрогается, открывая рот."


/datum/emote/human/choke
	key = "choke"

	message_1p = "Вы задыхаетесь."
	message_3p = "задыхается."

	message_impaired_production = "издаёт сдавленный звук."

	message_miming = "театрально хватается за горло, изображая удушье."
	message_muzzled = "издаёт сдавленный звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)
	required_bodyparts = list(BP_HEAD)

	cloud = "cloud-gasp"

/datum/emote/human/choke/get_impaired_msg(mob/user)
	return "отчаянно хватается за горло!"

/datum/emote/human/snore
	key = "snore"

	message_1p = "Вы храпите."
	message_3p = "храпит."

	message_impaired_production = "издаёт звук."

	message_miming = "надувает и сдувает щеки в немом храпе."
	message_muzzled = "сопит."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_NO_BREATHE)

/datum/emote/human/snore/get_impaired_msg(mob/user)
	return "широко открывает рот, чтобы сделать вдох."


// TO-DO: make so intentional sniffing reveals how a reagent solution held in hand smells?
/datum/emote/human/sniff
	key = "sniff"

	message_1p = "Вы шмыгаете носом."
	message_3p = "шмыгает носом."

	message_impaired_production = "шмыгает носом."
	message_impaired_reception = "шмыгает носом."

	message_miming = "комично морщит нос, беззвучно шмыгая."
	message_muzzled = "шмыгает носом."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS


/datum/emote/human/sneeze
	key = "sneeze"

	message_1p = "Вы чихаете."
	message_3p = "чихает."

	message_impaired_production = "издаёт странный звук."
	message_impaired_reception = "чихает."

	message_miming = "застывает на мгновение и разражается немым чихом."
	message_muzzled = "глухо чихает."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)

/datum/emote/human/sneeze/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_SNEEZE_MALE, SOUNDIN_SNEEZE_FEMALE)


/datum/emote/human/gasp
	key = "gasp"

	message_1p = "Вы судорожно вдыхаете!"
	message_3p = "судорожно вдыхает!"

	message_impaired_production = "жадно ловит ртом воздух!"
	message_impaired_reception = "жадно ловит ртом воздух!"

	message_miming = "беззвучно ловит ртом воздух!"
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

	message_1p = "Вы вздыхаете."
	message_3p = "вздыхает."

	message_impaired_production = "издаёт сдавленный звук."

	message_miming = "вздымает и опускает грудь, разыгрывая глубокий вздох."
	message_muzzled = "издаёт сдавленный звук."

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_EMOTIONLESS)

/datum/emote/human/sigh/get_impaired_msg(mob/user)
	return "открывает рот."

/datum/emote/human/sigh/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_SIGH_MALE, SOUNDIN_SIGH_FEMALE)

/datum/emote/human/mumble
	key = "mumble"

	message_1p = "Вы бормочете."
	message_3p = "бормочет."

	message_impaired_production = "издаёт сдавленный звук."

	message_miming = "шевелит губами, изображая невнятное бормотание."
	message_muzzled = "раздражённо морщится!"

	message_type = SHOWMSG_AUDIO

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(TRAIT_EMOTIONLESS)

/datum/emote/human/mumble/get_impaired_msg(mob/user)
	return "открывает и закрывает рот."

/datum/emote/human/hmm_think
	key = "hmm"

	message_1p = "Вы задумчиво хмыкаете..."
	message_3p = "задумчиво хмыкает..."

	message_impaired_production = "задумчиво мычит..."

	message_miming = "застывает в позе мыслителя, изображая глубокие философские раздумья..."
	message_muzzled = "глухо и задумчиво мычит..."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	required_stat = CONSCIOUS

/datum/emote/human/hmm_think/get_impaired_msg(mob/user)
	return "задумчиво почёсывает подбородок..."

/datum/emote/human/hmm_think/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_HMM_THINK_MALE, SOUNDIN_HMM_THINK_FEMALE)

/datum/emote/human/hmm_question
	key = "hmm?"

	message_1p = "Вы вопросительно хмыкаете и приподнимаете бровь..?"
	message_3p = "вопросительно хмыкает..?"

	message_impaired_production = "вопросительно мычит..?"

	message_miming = "вопросительно приподнимает бровь..?"
	message_muzzled = "глухо и вопросительно мычит..?"

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	required_stat = CONSCIOUS

/datum/emote/human/hmm_question/get_impaired_msg(mob/user)
	return "вопросительно приподнимает бровь..?"

/datum/emote/human/hmm_question/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_HMM_QUESTION_MALE, SOUNDIN_HMM_QUESTION_FEMALE)

/datum/emote/human/hmm_excited
	key = "hmm!"

	message_1p = "Вы воодушевлённо хмыкаете!"
	message_3p = "воодушевлённо хмыкает."

	message_impaired_production = "воодушевлённо мычит!"

	message_miming = "вскидывает брови, разыгрывая радостное озарение!"
	message_muzzled = "глухо и оживлённо мычит!"

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	required_stat = CONSCIOUS

/datum/emote/human/hmm_excited/get_impaired_msg(mob/user)
	return "оживлённо поднимает брови!"

/datum/emote/human/hmm_excited/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_HMM_EXCLAIM_MALE, SOUNDIN_HMM_EXCLAIM_FEMALE)

/datum/emote/human/woo
	key = "woo"

	message_1p = "Вы восторженно ликуете!"
	message_3p = "восторженно ликует!"

	message_impaired_production = "восторженно ликует!"
	message_impaired_reception = "восторженно ликует!"

	message_miming = "восторженно жестикулирует!"
	message_muzzled = "выглядит возбуждённо."

	message_type = SHOWMSG_AUDIO

	age_variations = TRUE

	required_stat = CONSCIOUS

/datum/emote/human/woo/get_sound(mob/living/carbon/human/user, intentional)
	return get_sound_by_voice(user, SOUNDIN_WOO_MALE, SOUNDIN_WOO_FEMALE)

/datum/emote/human/spit
	key = "spit"

	message_1p = "Вы смачно плюёте."
	message_3p = "смачно плюёт."

	message_impaired_production = "смачно плюёт."
	message_impaired_reception = "смачно плюёт."

	message_miming = "беззвучно набирает невидимую слюну и сплёвывает."
	message_muzzled = "пытается набрать слюну."

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
