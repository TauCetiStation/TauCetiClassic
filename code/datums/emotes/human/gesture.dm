/datum/emote/human/raisehand
	key = "raisehand"

	message_1p = "Вы поднимаете руку."
	message_3p = "поднимает руку."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	require_usable_hand = TRUE


/datum/emote/human/rock
	key = "rock"

	message_1p = "Вы показываете рукой камень."
	message_3p = "показывает рукой камень."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	require_usable_hand = TRUE

/datum/emote/human/rock/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.play_rock_paper_scissors_animation(emote_key)


/datum/emote/human/paper
	key = "paper"

	message_1p = "Вы показываете рукой бумагу."
	message_3p = "показывает рукой бумагу."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	require_usable_hand = TRUE

/datum/emote/human/paper/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.play_rock_paper_scissors_animation(emote_key)


/datum/emote/human/scissors
	key = "scissors"

	message_1p = "Вы показываете рукой ножницы."
	message_3p = "показывает рукой ножницы."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	require_usable_hand = TRUE

/datum/emote/human/scissors/do_emote(mob/living/carbon/human/user, emote_key, intentional)
	. = ..()
	user.play_rock_paper_scissors_animation(emote_key)

/datum/emote/human/surrender
	key = "surr"

	message_1p = "Вы сдаётесь!"
	message_3p = "сдаётся!"
	cloud = "cloud-white_flag"
	cooldown = 15 SECONDS
	cloud_duration = 20 SECONDS

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	blocklist_traits = list(ELEMENT_TRAIT_ZOMBIE)

/datum/emote/human/surrender/do_emote(mob/living/carbon/human/user)
	. = ..()
	user.AdjustWeakened(10)

/datum/emote/human/clap
	key = "clap"

	message_1p = "Вы хлопаете."
	message_3p = "хлопает."

	message_impaired_reception = "Вы слышите как кто-то хлопает."

	message_type = SHOWMSG_VISUAL

	sound = list('sound/misc/clap_1.ogg', 'sound/misc/clap_2.ogg', 'sound/misc/clap_3.ogg', 'sound/misc/clap_4.ogg')
	soundless_for_mute = FALSE

	required_stat = CONSCIOUS
	require_usable_hand = TRUE

/datum/emote/human/clap/get_sound(mob/living/carbon/human/user, intentional)
 	return pick(sound)


/datum/emote/human/wave
	key = "wave"

	message_1p = "Вы машете рукой."
	message_3p = "машет рукой."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	require_usable_hand = TRUE
	blocklist_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/human/salute
	key = "salute"

	message_1p = "Вы салютуете."
	message_3p = "салютует."

	message_type = SHOWMSG_VISUAL

	sound = 'sound/misc/salute.ogg'
	soundless_for_mute = FALSE

	required_stat = CONSCIOUS
	require_usable_hand = TRUE
	blocklist_traits = list(ELEMENT_TRAIT_ZOMBIE)
