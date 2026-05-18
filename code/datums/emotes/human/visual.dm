/datum/emote/human/bow
	key = "bow"

	message_1p = "Вы кланяетесь."
	message_3p = "кланяется."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	blocklist_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/human/yawn
	key = "yawn"

	message_1p = "Вы зеваете."
	message_3p = "зевает."

	message_impaired_reception = "Вы слышите, как кто-то зевает."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/human/blink
	key = "blink"

	message_1p = "Вы моргаете."
	message_3p = "моргает."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/wink
	key = "wink"

	message_1p = "Вы подмигиваете."
	message_3p = "подмигивает."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)
	blocklist_unintentional_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/human/grin
	key = "grin"

	message_1p = "Вы ухмыляетесь."
	message_3p = "ухмыляется."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/drool
	key = "drool"

	message_1p = "Вы пускаете слюни."
	message_3p = "пускает слюни."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/smile
	key = "smile"

	message_1p = "Вы улыбаетесь."
	message_3p = "улыбается."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/frown
	key = "frown"

	message_1p = "Вы хмуритесь."
	message_3p = "хмурится."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/eyebrow
	key = "eyebrow"

	message_1p = "Вы приподнимаете бровь."
	message_3p = "поднимает бровь."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)


/datum/emote/human/shrug
	key = "shrug"

	message_1p = "Вы пожимаете плечами."
	message_3p = "пожимает плечами."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	blocklist_unintentional_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/human/nod
	key = "nod"

	message_1p = "Вы киваете."
	message_3p = "кивает."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)
	blocklist_unintentional_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/human/shake
	key = "shake"

	message_1p = "Вы качаете головой."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	required_bodyparts = list(BP_HEAD)
	blocklist_unintentional_traits = list(ELEMENT_TRAIT_ZOMBIE)

/datum/emote/human/shake/get_emote_message_3p(mob/living/carbon/human/user)
	return "качает своей головой."


/datum/emote/human/twitch
	key = "twitch"

	message_1p = "Вы дёргаетесь."
	message_3p = "дёргается."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS


/datum/emote/human/deathgasp
	key = "deathgasp"

	message_1p = "Вы бьётесь в короткой агонии и обмякаете, ваш остекленевший взгляд устремляется в пустоту..."

	message_impaired_reception = "You hear a thud."

	message_type = SHOWMSG_VISUAL

	required_intentional_stat = CONSCIOUS

/datum/emote/human/deathgasp/get_emote_message_3p(mob/living/carbon/human/user)
	return "бьется в короткой агонии и обмякает, остекленевший взгляд устремляется в пустоту..."

/datum/emote/human/flip
	key = "flip"

	message_type = SHOWMSG_VISUAL


	message_1p = "Вы делаете сальто."
	message_3p = "делает сальто."
	required_stat = CONSCIOUS

	required_bodyparts = list(BP_R_LEG, BP_L_LEG)


/datum/emote/human/flip/do_emote(mob/living/carbon/human/user)
	. = ..()
	user.SpinAnimation(5,1)
