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


/datum/quality/non_comprende
	desc = "Ты не знаешь никаких языков кроме общего."
	requirement = "Нет."

/datum/quality/non_comprende/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/datum/language/language as anything in H.languages)
		H.remove_language(language.name)


/datum/quality/patriot
	desc = "Ты знаешь только один язык. И всегда будешь говорить только на нём."
	requirement = "Нет."

/datum/quality/patriot/add_effect(mob/living/carbon/human/H, latespawn)
	if(length(H.languages) == 0)
		return

	H.forced_language = pick(H.languages)

	for(var/datum/language/language as anything in H.languages)
		if(language == H.forced_language)
			continue
		H.remove_language(language.name)


/datum/quality/shkiondioniovioion
	desc = "Тё знёёшь тёлькё ёдён ёзёк. Ё всёгдё бёдёшь гёвёрёть тёлькё нё нём."
	requirement = "Нёт."

/datum/quality/shkiondioniovioion/add_effect(mob/living/carbon/human/H, latespawn)
	H.add_language(LANGUAGE_SHKIONDIONIOVIOION)
	H.forced_language = LANGUAGE_SHKIONDIONIOVIOION

	for(var/datum/language/language as anything in H.languages)
		if(language == H.forced_language)
			continue
		H.remove_language(language.name)


/datum/quality/clumsy
	desc = "Ты - неуклюжий, криворукий дурачок. Лучше не трогать всякие опасные штуки!"
	requirement = "Все, кроме Клоуна."

/datum/quality/clumsy/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return H.mind.assigned_role != "Clown"

/datum/quality/clumsy/add_effect(mob/living/carbon/human/H, latespawn)
	H.mutations.Add(CLUMSY)


var/global/list/allergen_reagents_list
/datum/quality/allergies
	desc = "Ты - аллергик, с рождения такой. Вот только беда... А на что аллергия то?"
	requirement = "Не синтет."

	var/allergies_amount = 3

/datum/quality/allergies/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return !H.species.flags[IS_SYNTHETIC]

/datum/quality/allergies/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/i in 1 to allergies_amount)
		var/reagent = pick(global.allergen_reagents_list)
		H.allergies[reagent] = ALLERGY_UNDISCOVERED
