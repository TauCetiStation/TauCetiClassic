// This class is used for rites that require conesnt of a mob buckled to altar.
/datum/religion_rites/standing/consent
	var/consent_msg = ""
	can_talismaned = FALSE

/datum/religion_rites/standing/consent/New()
	AddComponent(/datum/component/rite/consent, consent_msg)


/*
 * Synthconversion
 * Replace your friendly robotechnicians with this little rite!
 */
/datum/religion_rites/standing/consent/synthconversion
	name = "Синтетическое Возвышение"
	desc = "Превращает <i>homosapiens</i> в (превосходящую) Машину."
	ritual_length = (50 SECONDS)
	ritual_invocations = list("Согласно внутреннему устройству твоему...",
						"...Мы взываем к тебе, перед лицом напасти...",
						"...чтобы завершить нас, искоренить нежелаемое...")
	invoke_msg = "...Восстань, наш чемпион! Стань тем, чего жаждет твоя душа, живи в мире в своем истинном обличье!!"
	favor_cost = 700

	consent_msg = "Are you ready to sacrifice your body to turn into a cyborg?"

	needed_aspects = list(
		ASPECT_TECH = 1,
	)

/datum/religion_rites/standing/consent/synthconversion/can_start(mob/user, obj/AOG)
	if(!..())
		return FALSE

	var/mob/living/simple_animal/shade/god/god = locate() in get_turf(AOG)
	if(!istype(god))
		if(!ishuman(AOG.buckled_mob))
			to_chat(user, "<span class='warning'>Только тела гуманоидов могут быть приняты.</span>")
			return FALSE

		if(AOG.buckled_mob.get_species() == HOMUNCULUS)
			to_chat(user, "<span class='warning'>Тело гомункула слишком слабо.</span>")
			return FALSE

		if(jobban_isbanned(AOG.buckled_mob, "Cyborg") || role_available_in_minutes(AOG.buckled_mob, ROLE_GHOSTLY))
			to_chat(user, "<span class='warning'>Тело [AOG.buckled_mob] слишком слабо!</span>")
			return FALSE
	else
		if(jobban_isbanned(god, "Cyborg") || role_available_in_minutes(god, ROLE_GHOSTLY))
			to_chat(user, "<span class='warning'>[god] слишком слаб!</span>")
			return FALSE

	return TRUE

/datum/religion_rites/standing/consent/synthconversion/invoke_effect(mob/user, obj/AOG)
	..()

	if(convert_god(AOG))
		return TRUE

	var/mob/living/carbon/human/human2borg = AOG.buckled_mob
	if(!istype(human2borg))
		return FALSE
	hgibs(get_turf(AOG), human2borg.dna, human2borg.species.flesh_color, human2borg.species.blood_datum)
	human2borg.visible_message("<span class='notice'>[human2borg] has been converted by the rite of [pick(religion.deity_names)]!</span>")
	var/mob/living/silicon/robot/R = human2borg.Robotize(religion.bible_info.borg_name, religion.bible_info.laws_type, FALSE, religion)
	religion.add_member(R, HOLY_ROLE_PRIEST)
	return TRUE

/datum/religion_rites/standing/consent/synthconversion/proc/convert_god(obj/AOG)
	var/mob/living/simple_animal/shade/god/god = locate() in get_turf(AOG)
	if(!istype(god))
		return FALSE
	god.visible_message("<span class='notice'>[god] has been converted by the rite of [pick(religion.deity_names)]!</span>")
	religion.remove_deity(god)
	var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(AOG), "Son of Heaven", religion.bible_info.laws_type, FALSE, religion)
	god.mind.transfer_to(O)
	O.job = "Cyborg"
	O.mind.skills.add_available_skillset(/datum/skillset/cyborg)
	O.mind.skills.maximize_active_skills()
	qdel(god)
	religion.add_deity(O, HOLY_ROLE_PRIEST)
	return TRUE

/*
 * Sacrifice
 * Sacrifice a willing being to get a lot of points. Non-sentient beings who can not consent give points, but a lesser amount.
 */
/datum/religion_rites/standing/consent/sacrifice
	name = "Добровольное Жертвоприношение"
	desc = "Превращает энергию живого в favor."
	ritual_length = (25 SECONDS)
	ritual_invocations = list("Отче наш, сущий на небесах......",
								"...Да святится име Твое...",
								"...Да наступит царствие Твое...",
								"...Да будет воля Твоя на земле, как на небе;...",
								"...Хлеб наш насущный дай нам на сей день, и прости нам долги наши...",
								"...как и мы прощаем должникам нашим...",
								"...и не введи нас во искушение, но избави нас от лукавого...")
	invoke_msg = "...Ибо Твое есть Царство и сила и слава во веки, Аминь!!!"
	favor_cost = 0

	consent_msg = "Are you ready to sacrifice your body to give strength to a deity?"

	needed_aspects = list(
		ASPECT_DEATH = 1,
	)

/datum/religion_rites/standing/consent/sacrifice/invoke_effect(mob/living/user, obj/AOG)
	..()

	var/mob/living/L = AOG.buckled_mob
	if(!istype(L))
		return FALSE

	var/sacrifice_favor = 0
	if(isanimal(L))
		sacrifice_favor += 100
	else if(ismonkey(L))
		sacrifice_favor += 150
	else if(ishuman(L) && L.mind && L.ckey)
		sacrifice_favor += 350
	else
		sacrifice_favor += 200

	if(L.stat == DEAD)
		sacrifice_favor *= 0.5
	if(!L.ckey)
		sacrifice_favor  *= 0.5

	religion.adjust_favor(sacrifice_favor * divine_power)

	L.gib()
	user.visible_message("<span class='notice'>[user] has finished the rite of [name]!</span>")
	return TRUE

/*
 * Clownconversion
 * Adds clumsy mutation to mob and changes their clothes
 */
/datum/religion_rites/standing/consent/clownconversion
	name = "Клоунконверсия"
	desc = "Превращает маленького человека в Клоуна." // this is ref to Russian writers
	ritual_length = (25 SECONDS)
	ritual_invocations = list("Земля от нашей Матери заполучила бананы...",
						"...Уши от нашей Матери заполучили клаксоны...",
						"...Стопы от нашей Матери заполучили длинную обувь...")
	invoke_msg = "...И от Матери нашей, да заполучишь ты силу ГУДКА!!"
	favor_cost = 500

	consent_msg = "Do you feel the honk, growing, from within your body?"

	needed_aspects = list(
		ASPECT_WACKY = 1,
		ASPECT_CHAOS = 1,
	)

/datum/religion_rites/standing/consent/clownconversion/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Только люди могут пройти через этот ритуал.</span>")
		return FALSE

	if(jobban_isbanned(AOG.buckled_mob, "Clown"))
		to_chat(user, "<span class='warning'>[pick(religion.deity_names)] don't accept this person!</span>")
		return FALSE

	if(!AOG.buckled_mob.mind)
		to_chat(user, "<span class='warning'>Тело [AOG.buckled_mob] слишком слабо!</span>")
		return FALSE

	if(AOG.buckled_mob.mind.holy_role >= HOLY_ROLE_PRIEST)
		to_chat(user, "<span class='warning'>[AOG.buckled_mob]уже святой!</span>")
		return FALSE

	return TRUE

/datum/religion_rites/standing/consent/clownconversion/invoke_effect(mob/living/user, obj/AOG)
	..()

	var/mob/living/carbon/human/H = AOG.buckled_mob
	if(!istype(H))
		return FALSE

	H.remove_from_mob(H.wear_mask)
	H.remove_from_mob(H.w_uniform)
	H.remove_from_mob(H.head)
	H.remove_from_mob(H.wear_suit)
	H.remove_from_mob(H.back)
	H.remove_from_mob(H.shoes)

	H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/clown(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(H), SLOT_IN_BACKPACK)

	religion.add_member(H, HOLY_ROLE_PRIEST)
	ADD_TRAIT(H, TRAIT_CLUMSY, GENETIC_MUTATION_TRAIT)
	H.mind.assigned_role = "Clown"
	return TRUE

/*
 * Divine invitation
 * Undresses and baptizes a person
 */
/datum/religion_rites/standing/consent/invite
	name = "Божественное Приглашение"
	desc = "Заставляет человека поверить в Бога."
	ritual_length = (20 SECONDS)
	ritual_invocations = list("Всевышний, возьми под Свой покров семью мою...",
						"...Всели в сердца супруга моего и чад наших мир, любовь и непрекословие всему доброму...",
						"...Не допусти никого из семьи моей до разлуки и тяжкого расставания...",
						"...До преждевременной и внезапной смерти без покаяния....",
						"...А дом наш и всех нас, живущих в нем, сохрани от огненного запаления, воровского нападения...",
						"...всякого злого обстояния, страха и дьявольского навождения...",
						"...Да и мы, вместе и раздельно, явно и сокровенно будем прославлять имя Твое Святое....",)
	invoke_msg = "...всегда, ныне и присно, и во веки веков. Аминь!!!"
	favor_cost = 250

	consent_msg = "Do you believe in God?"

/datum/religion_rites/standing/consent/invite/can_start(mob/living/user, obj/AOG)
	if(!..())
		return FALSE

	if(!ishuman(AOG.buckled_mob))
		to_chat(user, "<span class='warning'>Только люди могут пройти через этот ритуал.</span>")
		return FALSE

	if(!AOG.buckled_mob.mind)
		to_chat(user, "<span class='warning'>Тело [AOG.buckled_mob] слишком слабо!</span>")
		return FALSE

	if(AOG.buckled_mob.my_religion)
		to_chat(user, "<span class='warning'>[AOG.buckled_mob] уже святой!</span>")
		return FALSE

	return TRUE

/datum/religion_rites/standing/consent/invite/invoke_effect(mob/living/user, obj/AOG)
	..()

	var/mob/living/carbon/human/H = AOG.buckled_mob
	if(!istype(H))
		return FALSE

	H.remove_from_mob(H.wear_mask)
	H.remove_from_mob(H.w_uniform)
	H.remove_from_mob(H.head)
	H.remove_from_mob(H.wear_suit)
	H.remove_from_mob(H.back)
	H.remove_from_mob(H.shoes)

	to_chat(H, "<span class='piety'>Теперь вы верите в [pick(religion.deity_names)]</span>")

	religion.add_member(H, HOLY_ROLE_PRIEST)
	return TRUE
