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
	DE.stealth_inject(H)


/datum/quality/obedient
	desc = "За плохое поведение Вам ввели имплант подчинения. Лучше вести себя хорошо."
	requirement = "Не охранник."

	var/list/funpolice = list("Security Officer", "Security Cadet", "Warden")

/datum/quality/obedient/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return !(H.mind.assigned_role in funpolice)

/datum/quality/obedient/add_effect(mob/living/carbon/human/H, latespawn)
	var/obj/item/weapon/implant/obedience/O = new(H)
	O.stealth_inject(H)


/datum/quality/soulless
	desc = "У Вас нет души."
	requirement = "Нет."


/datum/quality/soulless/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_NO_SOUL, QUALITY_TRAIT)

	H.r_hair = rand(170, 255)
	H.g_hair = rand(0, 100)
	H.b_hair = rand(50, 100)


	H.r_facial = H.r_hair
	H.g_facial = H.g_hair
	H.b_facial = H.b_hair


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
		if(language.name == H.forced_language)
			continue
		H.remove_language(language.name)


/datum/quality/shkiondioniovioion
	desc = "Тё знёёшь тёлькё ёдён ёзёк. Ё всёгдё бёдёшь гёвёрёть тёлькё нё нём."
	requirement = "Нёт."

/datum/quality/shkiondioniovioion/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>Тебе известны новые языки. Нажми 'IC > Check Known Languages' чтобы узнать какие.</span>")

	H.add_language(LANGUAGE_SHKIONDIONIOVIOION)
	H.forced_language = LANGUAGE_SHKIONDIONIOVIOION

	for(var/datum/language/language as anything in H.languages)
		if(language.name == H.forced_language)
			continue
		H.remove_language(language.name)


/datum/quality/salarian
	desc = "Ну що хлопче, готовий?"
	requirement = "Нема."

/datum/quality/salarian/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>Тебе известны новые языки. Нажми 'IC > Check Known Languages' чтобы узнать какие.</span>")

	H.add_language(LANGUAGE_SALARIAN)
	H.common_language = LANGUAGE_SALARIAN


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

/datum/quality/c4
	desc = "Спокойно, на Вас всего лишь повесили бомбу. \
	<br>- ВЗОРВЁТСЯ ЛИ ОНА? \
	<br>- Да. \
	<br>- КОГДА? \
	<br>- Ну может вообще не взорвётся, ну а может и бахнет минут через 5? 20? 40? Кто его знает?"
	requirement = "Нет."

/datum/quality/c4/add_effect(mob/living/carbon/human/H, latespawn)
	var/obj/item/weapon/plastique/C4 = new(H)
	C4.timer = rand(600, 1800)
	C4.plant_bomb(H)

/datum/quality/trypanophobia
	desc = "Вы с самого детства боитесь уколов."
	requirement = "Не СПУ, не Диона"

/datum/quality/trypanophobia/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return !H.species.flags[IS_SYNTHETIC] && !H.species.flags[IS_PLANT]

/datum/quality/trypanophobia/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_SYRINGE_FEAR, QUALITY_TRAIT)


/datum/quality/wet_hands
	desc = "Ваши верхние конечности можно сравнить с губкой, которая впитывает в себя жидкости. Осторожнее при работе с консолями."
	requirement = "Нет."

/datum/quality/wet_hands/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_WET_HANDS, QUALITY_TRAIT)


/datum/quality/greasy_fingers
	desc = "Ваши пальцы часто покрываются природным жиром."
	requirement = "Не СПУ."

/datum/quality/greasy_fingers/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return !H.species.flags[IS_SYNTHETIC]

/datum/quality/greasy_fingers/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_GREASY_FINGERS, QUALITY_TRAIT)
