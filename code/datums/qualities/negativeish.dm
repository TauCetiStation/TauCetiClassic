// Put positive or negative-aligned quirks here. For further explanation and more reading material visit __DEFINES/qualities.dm and qualities/quality.dm
/datum/quality/negativeish
	pools = list(
		QUALITY_POOL_NEGATIVEISH
	)

/datum/quality/negativeish/mute
	name = "Mute"
	desc = "Так вышло, что языка у тебя больше нет."
	requirement = "Нет."

/datum/quality/negativeish/mute/add_effect(mob/living/carbon/human/H, latespawn)
	H.add_quirk(QUIRK_MUTE)


// It's 80% negative and 20% positive.
/datum/quality/negativeish/mutant
	name = "Mutant"
	desc = "Тебе не повезло облучиться по пути на работу."
	requirement = "Нет."

/datum/quality/negativeish/mutant/add_effect(mob/living/carbon/human/H, latespawn)
	if(prob(80))
		randmutb(H)
	else
		randmutg(H)
	domutcheck(H, null)


/datum/quality/negativeish/frail
	name = "Frail"
	desc = "Жизнь раба корпорации довела тебя до серьезной болезни. Здоровье существенно снижено."
	requirement = "Нет."

/datum/quality/negativeish/frail/add_effect(mob/living/carbon/human/H, latespawn)
	H.health = 50
	H.maxHealth = 50

/datum/quality/negativeish/soulless
	name = "Soulless"
	desc = "У тебя нет души."
	requirement = "Нет."


/datum/quality/negativeish/soulless/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_NO_SOUL, QUALITY_TRAIT)

	H.r_hair = rand(145, 178)
	H.g_hair = rand(48, 99)
	H.b_hair = rand(43, 54)


	H.r_facial = H.r_hair
	H.g_facial = H.g_hair
	H.b_facial = H.b_hair
	H.regenerate_icons()


/datum/quality/negativeish/dirty
	name = "Dirty"
	desc = "Перед самой посадкой на монорельс Велосити ховер-такси обдало тебя с ног до головы дурнопахнущей грязью. Времени на чистку не было и пришлось ехать на станцию в таком непотребном виде "
	requirement = "Нет."

/datum/quality/negativeish/dirty/add_effect(mob/living/carbon/human/H, latespawn)
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


/datum/quality/negativeish/non_comprende
	name = "Non Comprende"
	desc = "Ты не знаешь никаких языков, кроме общего."
	requirement = "Нет."

/datum/quality/negativeish/non_comprende/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/datum/language/language as anything in H.languages)
		H.remove_language(language.name)


/datum/quality/negativeish/patriot
	name = "Patriot"
	desc = "Ты знаешь только один язык. И всегда будешь говорить только на нём."
	requirement = "Нет."

/datum/quality/negativeish/patriot/add_effect(mob/living/carbon/human/H, latespawn)
	if(length(H.languages) == 0)
		return

	H.forced_language = pick(H.languages)

	for(var/datum/language/language as anything in H.languages)
		if(language.name == H.forced_language)
			continue
		H.remove_language(language.name)


/datum/quality/negativeish/shkiondioniovioion
	name = "Shkёndёnёvёёёn"
	desc = "Тё знёёшь тёлькё ёдён ёзёк. Ё всёгдё бёдёшь гёвёрёть тёлькё нё нём."
	requirement = "Нёт."

/datum/quality/negativeish/shkiondioniovioion/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>Тебе известны новые языки. Нажми 'IC > Check Known Languages' чтобы узнать какие.</span>")

	H.add_language(LANGUAGE_SHKIONDIONIOVIOION)
	H.forced_language = LANGUAGE_SHKIONDIONIOVIOION

	for(var/datum/language/language as anything in H.languages)
		if(language.name == H.forced_language)
			continue
		H.remove_language(language.name)


/datum/quality/negativeish/salackyi
	name = "Салацькый"
	desc = "Ну що хлопче, готовий?"
	requirement = "Все, кроме СБ и глав."

/datum/quality/negativeish/salackyi/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return !(H.mind.assigned_role in global.command_positions) && !(H.mind.assigned_role in global.security_positions)

/datum/quality/negativeish/salackyi/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>Тебе известны новые языки. Нажми 'IC > Check Known Languages' чтобы узнать какие.</span>")

	H.add_language(LANGUAGE_SALACKYI)
	H.common_language = LANGUAGE_SALACKYI


/datum/quality/negativeish/clumsy
	name = "Clumsy"
	desc = "Ты - неуклюжий, криворукий дурачок. Лучше не трогать всякие опасные штуки!"
	requirement = "Нет."

/datum/quality/negativeish/clumsy/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return H.mind.assigned_role != "Clown"

/datum/quality/clumsy/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_CLUMSY, QUALITY_TRAIT)

var/global/list/allergen_reagents_list
/datum/quality/negativeish/allergies
	name = "Allergies"
	desc = "Ты - аллергик, с рождения такой. Вот только беда... А на что аллергия то?"
	requirement = "Нет."

	var/allergies_amount = 3

/datum/quality/negativeish/allergies/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return !H.species.flags[IS_SYNTHETIC]

/datum/quality/negativeish/allergies/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/i in 1 to allergies_amount)
		var/reagent = pick(global.allergen_reagents_list)
		LAZYSET(H.allergies, reagent, ALLERGY_UNDISCOVERED)

/datum/quality/negativeish/trypanophobia
	name = "Trypanophobia"
	desc = "Ты с самого детства боишься уколов."
	requirement = "Нет."

/datum/quality/negativeish/trypanophobia/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return !H.species.flags[IS_SYNTHETIC] && !H.species.flags[IS_PLANT]

/datum/quality/negativeish/trypanophobia/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_SYRINGE_FEAR, QUALITY_TRAIT)


/datum/quality/negativeish/wet_hands
	name = "Wet Hands"
	desc = "Твои верхние конечности можно сравнить с губкой, которая впитывает в себя жидкости. Помни, с мокрыми руками опасно работать за компьютером."
	requirement = "Нет."

/datum/quality/negativeish/wet_hands/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_WET_HANDS, QUALITY_TRAIT)


/datum/quality/negativeish/greasy_fingers
	name = "Greasy Fingers"
	desc = "Твои пальцы часто покрываются природным жиром. Ты их хоть пробовал мыть?"
	requirement = "Нет."

/datum/quality/negativeish/greasy_fingers/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return !H.species.flags[IS_SYNTHETIC]

/datum/quality/negativeish/greasy_fingers/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_GREASY_FINGERS, QUALITY_TRAIT)


/datum/quality/negativeish/husked
	name = "Husked"
	desc = "Этим утром тебя обожгло маршевыми двигателями шаттла. Ожоги вылечили, но опаленную кожу восстановить пока не удалось..."
	requirement = "Нет."

/datum/quality/negativeish/husked/satisfies_requirements(mob/living/carbon/human/H, latespawn)
	return !H.species.flags[IS_SYNTHETIC]

/datum/quality/negativeish/husked/add_effect(mob/living/carbon/human/H, latespawn)
	H.ChangeToHusk()

/datum/quality/negativeish/delicate
	name = "Quality Food Enjoyer"
	desc = "Ты всегда кушал только самую лучшую еду шеф-поваров и не собираешься останавливаться."
	requirement = "Нет."

/datum/quality/negativeish/delicate/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_PICKY_EATER, QUALITY_TRAIT)

/datum/quality/negativeish/greatappetite
	name = "Great Appetite"
	desc = "У тебя большой аппетит, что всегда приводило тебя к неприятностям."
	requirement = "Нет."

/datum/quality/negativeish/greatappetite/add_effect(mob/living/carbon/human/H, latespawn)
	H.metabolism_factor.AddModifier("Appetite", multiple = 2)

/datum/quality/negativeish/proudandwalking
	name = "Proud and Walking"
	desc = "Рождённый ходить ползать не может. Ты слишком горд, чтобы собирать животом пыль с полов станции."
	requirement = "Нет."

/datum/quality/negativeish/proudandwalking/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_NO_CRAWL, QUALITY_TRAIT)

/datum/quality/negativeish/awkward
	name = "Awkward"
	desc = "Ты слон в посудной лавке, ходячая авария, постоянно ударяешься о что-нибудь."
	requirement = "Нет."

/datum/quality/negativeish/awkward/add_effect(mob/living/carbon/human/H, latespawn)
	H.AddElement(/datum/element/awkward)

/datum/quality/negativeish/dumb
	name = "Dumb"
	desc = "Ты несколько раз упал головой на тулбокс и отупел."
	requirement = "Нет."

/datum/quality/negativeish/dumb/add_effect(mob/living/carbon/human/H, latespawn)
	if(latespawn)
		//60 for nasty airlock-bumping, make a light effect for latespawning humans
		addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, adjustBrainLoss), 50), 3 MINUTE)
		return
	H.adjustBrainLoss(60)
