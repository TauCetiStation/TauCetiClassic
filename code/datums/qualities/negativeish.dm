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

/datum/quality/dirty
	desc = "Прекрасным ранним утром в дороге на работу ты поскользнулся и упал в глубокую лужу грязи, полностью пропитавшись этой субстанцией. Времени не было и пришлось лететь на станцию в таком виде."
	requirement = "Быть чистым. (Требований нет)"

/datum/quality/dirty/add_effect(mob/living/carbon/human/H, latespawn)
	var/datum/dirt_cover/mud/dirt_config = new
	var/dirt_r = HEX_VAL_RED(dirt_config.color)
	var/dirt_g = HEX_VAL_GREEN(dirt_config.color)
	var/dirt_b = HEX_VAL_BLUE(dirt_config.color)

	for(var/obj/O in H.get_all_slots())
		O.add_dirt_cover(dirt_config)

	var/list/dirt_DNA = list("UNKNOWN DNA" = "X*")
	H.blood_DNA = dirt_DNA
	H.hand_dirt_datum = new /datum/dirt_cover(dirt_config)
	H.feet_blood_DNA = dirt_DNA
	H.feet_dirt_color = new /datum/dirt_cover(dirt_config)

	H.lip_style = "spray_face"
	H.lip_color = dirt_config.color

	H.dyed_r_hair = dirt_r
	H.dyed_g_hair = dirt_g
	H.dyed_b_hair = dirt_b
	H.hair_painted = TRUE

	H.dyed_r_facial = dirt_r
	H.dyed_g_facial = dirt_g
	H.dyed_b_facial = dirt_b
	H.facial_painted = TRUE

	H.apply_recolor()
	H.update_body()
	H.regenerate_icons()

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
		LAZYSET(H.allergies, reagent, ALLERGY_UNDISCOVERED)


/datum/quality/dumb
	desc = "Ты несколько раз упал головой на тулбокс и отупел."
	requirement = "Нет."

/datum/quality/dumb/add_effect(mob/living/carbon/human/H, latespawn)
	H.adjustBrainLoss(rand(30, 99))
