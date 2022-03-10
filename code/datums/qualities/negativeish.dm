// Put negative or negative-aligned quirks here.

/datum/quality/mute
	desc = "Так вышло, что языка у тебя больше нет."
	requirement = "Нет."

/datum/quality/mute/add_effect(mob/living/carbon/human/H, latespawn)
	H.add_quirk(QUIRK_MUTE)


// It's 80% negative and 20% positive.
/datum/quality/mutant
	desc = "Тебе не повезло облучиться по пути на работу."
	requirement = "Нет."

/datum/quality/mutant/add_effect(mob/living/carbon/human/H, latespawn)
	if(prob(80))
		randmutb(H)
	else
		randmutg(H)
	domutcheck(H, null)


/datum/quality/frail
	desc = "Жизнь раба корпорации довела тебя до серьезной болезни. Здоровье существенно снижено."
	requirement = "Нет."

/datum/quality/frail/add_effect(mob/living/carbon/human/H, latespawn)
	H.health = 50
	H.maxHealth = 50


/datum/quality/depression
	desc = "Ты в депрессии и чувствуешь себя уныло. Так и живём."
	requirement = "Нет."

/datum/quality/depression/add_effect(mob/living/carbon/human/H, latespawn)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "roundstart_depression", /datum/mood_event/depression)


/datum/quality/true_keeper
	desc = "Ты не должен покидать бриг ЛЮБОЙ ЦЕНОЙ. Он ведь загнётся без твоего надзора!"
	requirement = "Варден."

	jobs_required = list(
		"Warden",
	)

/datum/quality/true_keeper/add_effect(mob/living/carbon/human/H, latespawn)
	RegisterSignal(H, COMSIG_ENTER_AREA, .proc/on_enter)
	RegisterSignal(H, COMSIG_EXIT_AREA, .proc/on_exit)

/datum/quality/true_keeper/proc/on_enter(datum/source, area/A, atom/OldLoc)
	if(istype(A, /area/station/security))
		SEND_SIGNAL(source, COMSIG_CLEAR_MOOD_EVENT, "true_keeper_failure")

/datum/quality/true_keeper/proc/on_exit(datum/source, area/A, atom/NewLoc)
	if(istype(A, /area/station/security))
		SEND_SIGNAL(source, COMSIG_ADD_MOOD_EVENT, "true_keeper_failure", /datum/mood_event/true_keeper_failure)


/datum/quality/rts
	desc = "Ты не должен покидать мостик. Ты ведь мозг станции, а мозг должен быть в самом защищенном месте."
	requirement = "Капитан."

	jobs_required = list(
		"Captain",
	)

/datum/quality/rts/add_effect(mob/living/carbon/human/H, latespawn)
	RegisterSignal(H, COMSIG_ENTER_AREA, .proc/on_enter)
	RegisterSignal(H, COMSIG_EXIT_AREA, .proc/on_exit)

/datum/quality/rts/proc/on_enter(datum/source, area/A, atom/OldLoc)
	if(istype(A, /area/station/bridge))
		SEND_SIGNAL(source, COMSIG_CLEAR_MOOD_EVENT, "rts_failure")

/datum/quality/rts/proc/on_exit(datum/source, area/A, atom/NewLoc)
	if(istype(A, /area/station/bridge))
		SEND_SIGNAL(source, COMSIG_ADD_MOOD_EVENT, "rts_failure", /datum/mood_event/rts_failure)


/datum/quality/kamikaze
	desc = "Каким-то образом Вам вставили имплант самоуничтожения. Реанимировать после смерти Вас будет значительно сложнее..."
	requirement = "Нет."

/datum/quality/kamikaze/add_effect(mob/living/carbon/human/H, latespawn)
	var/obj/item/weapon/implant/dexplosive/DE = new(H)
	DE.imp_in = H
	DE.implanted = TRUE

/datum/quality/obedient
	desc = "За плохое поведение Вам ввели имплант подчинения. Лучше вести себя хорошо."
	requirement = "Не охранник."

/datum/quality/obedient/add_effect(mob/living/carbon/human/H, latespawn)
	var/obj/item/weapon/implant/obedience/O = new(H)
	O.imp_in = H
	O.implanted = TRUE

/datum/quality/soulless
	desc = "У Вас нет души."
	requirement = "Нет."

/datum/quality/soulless/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_NO_SOUL, QUALITY_TRAIT)
