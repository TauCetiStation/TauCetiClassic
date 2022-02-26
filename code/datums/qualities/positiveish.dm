// Put positive or positive-aligned quirks here.

/datum/quality/loadsamoney
	desc = "У тебя целая КУЧА денег! Как бы их потратить?"
	requirement = "Нет."

	var/list/money_types = list(
		/obj/item/weapon/spacecash/c1000,
		/obj/item/weapon/spacecash/c500,
		/obj/item/weapon/spacecash/c200,
		/obj/item/weapon/spacecash/c100,
	)

/datum/quality/loadsamoney/proc/load_money(mob/living/carbon/human/H, obj/item/weapon/storage/S)
	var/money_type = pick(money_types)
	var/obj/item/weapon/spacecash/SC = new money_type
	while(S.can_be_inserted(SC))
		SC.add_fingerprint(H)
		S.handle_item_insertion(SC, TRUE)
		money_type = pick(money_types)
		SC = new money_type

/datum/quality/loadsamoney/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>Ты весь набит деньгами! СКОРЕЕ, К БАНКОМАТУ!</span>")

	var/list/storages = list()
	for(var/A in H.get_contents())
		if(istype(A, /obj/item/weapon/storage))
			load_money(H, A)
			storages += A
		else if(istype(A, /obj/item/clothing/suit/storage))
			var/obj/item/clothing/suit/storage/S = A
			if(S.pockets)
				load_money(H, S.pockets)

	var/spacecash_l_type = pick(money_types)
	var/spacecash_r_type = pick(money_types)

	H.equip_to_slot_or_del(new spacecash_l_type(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new spacecash_r_type(H), SLOT_R_STORE)


/datum/quality/wonder_doctor
	desc = "В качестве эксперимента, тебе выдали таблетку с новейшим препаратом, чем-то напоминающим тот самый Философский Камень."
	requirement = "Доктор, Парамедик, СМО."

	jobs_required = list(
		"Medical Doctor",
		"Paramedic",
		"Chief Medical Officer",
	)

/datum/quality/wonder_doctor/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>В твоем кармане лежит фиолетовая таблетка, которая способна излечить любые раны... как жаль, что в ней лишь одна единица вещества.</span>")
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/pill/adminordrazine(H), SLOT_L_STORE)


/datum/quality/prepared
	desc = "Ты задумал пролезть в какой-то отсек. Пришлось найти изоляционные перчатки."
	requirement = "Нет."

/datum/quality/prepared/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/clothing/gloves/yellow(H), SLOT_L_STORE)


/datum/quality/disguise
	desc = "С ЦК тебе прислали прикольную посылочку с лучшим в мире камуфляжем."
	requirement = "Клоун."

	jobs_required = list("Clown")

/datum/quality/disguise/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>Карта в твоих руках способна менять свой внешний вид и имя владельца, а одежда в коробке заменит целый гардероб.</span>")
	H.equip_or_collect(new /obj/item/weapon/storage/box/syndie_kit/chameleon(H), SLOT_L_HAND)
	H.equip_or_collect(new /obj/item/weapon/card/id/syndicate(H), SLOT_R_HAND)


/datum/quality/heavy_equipment
	desc = "По программе усиления СБ тебе была выдана экипировка получше."
	requirement = "Офицер СБ."

	jobs_required = list("Security Officer")

/datum/quality/heavy_equipment/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/clothing/suit/armor/vest/fullbody(H), SLOT_WEAR_SUIT)
	H.equip_or_collect(new /obj/item/clothing/gloves/combat(H), SLOT_GLOVES)
	H.equip_or_collect(new /obj/item/weapon/gun/projectile/automatic/l13(H), SLOT_S_STORE)
	H.equip_or_collect(new /obj/item/ammo_box/magazine/l13_38(H), SLOT_R_HAND)


/datum/quality/big_iron
	desc = "Эта станция слишком мала для тебя и преступности."
	requirement = "Детектив."

	jobs_required = list("Detective")

/datum/quality/big_iron/add_effect(mob/living/carbon/human/H, latespawn)
	if(prob(50))
		H.equip_or_collect(new /obj/item/clothing/suit/serifcoat(H), SLOT_WEAR_SUIT)
	else
		H.equip_or_collect(new /obj/item/clothing/suit/poncho(H), SLOT_WEAR_SUIT)
	H.equip_or_collect(new /obj/item/clothing/under/fluff/cowboy/brown(H), SLOT_W_UNIFORM)
	H.equip_or_collect(new /obj/item/clothing/head/western/cowboy(H), SLOT_HEAD)
	H.equip_or_collect(new /obj/item/clothing/shoes/western(H), SLOT_SHOES)
	H.equip_or_collect(new /obj/item/weapon/gun/projectile/revolver/peacemaker(H), SLOT_L_HAND)
	H.equip_or_collect(new /obj/item/ammo_box/c45rubber(H), SLOT_L_STORE)
	H.equip_or_collect(new /obj/item/ammo_box/c45rubber(H), SLOT_R_STORE)


/datum/quality/all_affairs
	desc = "У тебя полный доступ. Да начнётся расследование."
	requirement = "Агент Внутренних Дел."

	jobs_required = list("Internal Affairs Agent")

/datum/quality/all_affairs/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>На твоей карточке полный доступ, но необязательно показывать его перед персоналом - вдруг кто-то захочет отнять?</span>")
	var/obj/item/weapon/card/id/id = H.get_idcard()
	id.access = get_all_accesses()


/datum/quality/cultural_heritage
	desc = "Всё племя скинулось на то, чтобы заиметь тебе в космос крутой космический костюм. Лучше оправдать их надежды!"
	requirement = "Унатх."

	species_required = list(UNATHI)

/datum/quality/cultural_heritage/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/clothing/suit/space/unathi/breacher(H), SLOT_WEAR_SUIT)
	H.equip_or_collect(new /obj/item/clothing/head/helmet/space/unathi/breacher(H), SLOT_HEAD)


/datum/quality/sunglasses
	desc = "Крутые очки, чувак."
	requirement = "Нет."

/datum/quality/sunglasses/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), SLOT_GLASSES)


/datum/quality/hygiene
	desc = "Гигиена - это важно. Ты принёс из дома мыльце."
	requirement = "Нет."

/datum/quality/hygiene/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/snacks/soap(H), SLOT_R_STORE)


/datum/quality/vaccinated
	desc = "Привившись всеми известными человечеству вакцинами, ты стал полностью невосприимчив для любого вируса."
	requirement = "Нет."

/datum/quality/vaccinated/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/antigen in ANTIGENS)
		H.antibodies |= text2num(antigen)

	ADD_TRAIT(H, TRAIT_VACCINATED, QUALITY_TRAIT)


/datum/quality/happiness
	desc = "Ты очень-очень счастлив! Жизнь прекрасна и люди на станции прекрасны!!!"
	requirement = "Нет."

/datum/quality/happiness/add_effect(mob/living/carbon/human/H, latespawn)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "roundstart_happiness", /datum/mood_event/happiness)


/datum/quality/polyglot
	desc = "Ты знаешь все языки."
	requirement = "Нет."

/datum/quality/polyglot/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/language in all_languages)
		var/datum/language/L = all_languages[language]
		if(H.get_species() in L.allowed_speak)
			H.add_language(language)


/datum/quality/freakish_linguist
	desc = "Ты знаешь все языки. Абсолютно все. Но какой ценой?"
	requirement = "Мим."

	jobs_required = list(
		"Mime"
	)

/datum/quality/freakish_linguist/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/language in all_languages)
		H.add_language(language)


/datum/quality/traveler
	desc = "Ты много где побывал, и понимаешь большинство существующих языков."
	requirement = "Нет."

/datum/quality/traveler/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/language in all_languages)
		var/datum/language/L = all_languages[language]

		if(L.flags & RESTRICTED)
			continue
		H.add_language(language, LANGUAGE_CAN_UNDERSTAND)


/datum/quality/mutated_throat
	desc = "Мутация в строении твоего речевого аппарата позволяет издавать удивительные звуки..."
	requirement = "Нет."

/datum/quality/mutated_throat/add_effect(mob/living/carbon/human/H, latespawn)
	var/possibilities = list()
	for(var/language in all_languages)
		var/datum/language/L = all_languages[language]
		if(L.flags & RESTRICTED)
			continue
		if(H.can_speak(L))
			continue
		possibilities += L.name

	if(length(possibilities) == 0)
		return

	H.add_language(pick(possibilities))


/datum/quality/endangered_plants
	desc = "Бабушка передала тебе со своего гидропонического огорода семена редких растений."
	requirement = "Ботаник."

	jobs_required = list("Botanist")

/datum/quality/endangered_plants/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/weapon/storage/box/rare_seeds(H), SLOT_L_HAND)


/datum/quality/reliquary
	desc = "Тебе выпала великая честь - нести осколок душ. Возможно, заплатив частью своей."
	requirement = "Капеллан."

	jobs_required = list("Chaplain")

/datum/quality/reliquary/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/device/soulstone(H), SLOT_R_STORE)

/datum/quality/crusader
	desc = "Dominus concessit vos arma! DEUS VULT!"
	requirement = "Капеллан."

	jobs_required = list("Chaplain")

/datum/quality/crusader/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/clothing/head/helmet/crusader(H), SLOT_HEAD)
	H.equip_or_collect(new /obj/item/clothing/suit/armor/crusader(H), SLOT_WEAR_SUIT)
