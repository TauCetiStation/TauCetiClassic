/datum/emote/pray
	key = "pray"

	message_1p = "Вы молитесь."
	message_3p = "молится."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS

/datum/emote/pray/do_emote(mob/user, emote_key, intentional)
	. = ..()
	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, pray_animation))


/datum/emote/blink
	key = "blink"

	message_1p = "Вы моргаете."
	message_3p = "моргает."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS


/datum/emote/shiver
	key = "shiver"

	message_1p = "Вы дрожите."
	message_3p = "дрожит."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS


/datum/emote/drool
	key = "drool"

	message_1p = "Вы пускаете слюни."
	message_3p = "пускает слюни."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS


/datum/emote/eyebrow
	key = "eyebrow"

	message_1p = "Вы приподнимаете бровь."
	message_3p = "поднимает бровь."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS


/datum/emote/nod
	key = "nod"

	message_1p = "Вы киваете."
	message_3p = "кивает."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	blocklist_traits = list(ELEMENT_TRAIT_ZOMBIE)


/datum/emote/shake
	key = "shake"

	message_1p = "Вы качаете головой."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS
	blocklist_traits = list(ELEMENT_TRAIT_ZOMBIE)

/datum/emote/shake/get_emote_message_3p(mob/user)
	return "качает головой."


/datum/emote/twitch
	key = "twitch"

	message_1p = "Вы дёргаетесь."
	message_3p = "дёргается."

	message_type = SHOWMSG_VISUAL

	required_stat = CONSCIOUS


/datum/emote/collapse
	key = "collapse"

	message_1p = "Вы падаете в обморок!"
	message_3p = "падает в обморок!"

	message_type = SHOWMSG_VISUAL

	cooldown = 4 SECONDS

	required_stat = CONSCIOUS

/datum/emote/collapse/do_emote(mob/user, emote_key, intentional)
	. = ..()
	user.Paralyse(2)


/datum/emote/faint
	key = "faint"

	message_1p = "Вы теряете сознание!"
	message_3p = "теряет сознание!"

	message_type = SHOWMSG_VISUAL

	cooldown = 20 SECONDS

	required_stat = CONSCIOUS

/datum/emote/faint/do_emote(mob/user, emote_key, intentional)
	. = ..()
	if(isliving(user))
		var/mob/living/L = user
		L.SetSleeping(20 SECONDS)


/datum/emote/deathgasp
	key = "deathgasp"

	message_1p = "Вы бьётесь в короткой агонии и обмякаете, ваш остекленевший взгляд устремляется в пустоту..."

	message_impaired_reception = "Вы слышите глухой удар."

	message_type = SHOWMSG_VISUAL

	required_intentional_stat = CONSCIOUS

/datum/emote/deathgasp/get_emote_message_3p(mob/user)
	return "бьется в короткой агонии и обмякает, остекленевший взгляд устремляется в пустоту..."
