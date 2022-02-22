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

/datum/quality/nigger
	desc = "Перед вылетом на станцию тебя облили чёрной краской."
	requirement = "Быть белым."

/datum/quality/nigger/satisfies_availability(client/C)
	if(!..())
		return FALSE
	// min: -185, max: 34
	if(C.prefs.s_tone > -85)
		return TRUE
	return FALSE

/datum/quality/nigger/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	if(!..())
		return FALSE
	if(H.s_tone > -85)
		return TRUE
	return FALSE

/datum/quality/nigger/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/obj/O in H.get_all_slots())
		O.color = "#4D220E"

	H.hair_painted = TRUE
	H.s_tone = -185
	H.r_skin = 0
	H.g_skin = 0
	H.b_skin = 0
	H.r_hair = 0
	H.g_hair = 0
	H.b_hair = 0
	H.r_facial = 0
	H.g_facial = 0
	H.b_facial = 0

	H.apply_recolor()
	H.update_body()
	H.regenerate_icons()
