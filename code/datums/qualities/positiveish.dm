// Put positive or positive-aligned quirks here. For further explanation and more reading material visit __DEFINES/qualities.dm and qualities/quality.dm
/datum/quality/positiveish
	pools = list(
		QUALITY_POOL_POSITIVEISH
	)

/datum/quality/positiveish/loadsamoney
	name = "Loadsamoney"
	desc = "У тебя целая КУЧА денег! Как бы их потратить?"
	requirement = "Нет."

	var/list/money_types = list(
		/obj/item/weapon/spacecash/c1000,
		/obj/item/weapon/spacecash/c500,
		/obj/item/weapon/spacecash/c200,
		/obj/item/weapon/spacecash/c100,
	)

/datum/quality/positiveish/loadsamoney/proc/load_money(mob/living/carbon/human/H, obj/item/weapon/storage/S)
	var/money_type = pick(money_types)
	var/obj/item/weapon/spacecash/SC = new money_type
	while(S.can_be_inserted(SC))
		SC.add_fingerprint(H)
		S.handle_item_insertion(SC, TRUE)
		money_type = pick(money_types)
		SC = new money_type

/datum/quality/positiveish/loadsamoney/add_effect(mob/living/carbon/human/H, latespawn)
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

	H.equip_or_collect(new spacecash_l_type(H), SLOT_L_STORE)
	H.equip_or_collect(new spacecash_r_type(H), SLOT_R_STORE)


/datum/quality/positiveish/wonder_doctor
	name = "Wonder Doctor"
	desc = "В качестве эксперимента, тебе выдали таблетку с новейшим препаратом, чем-то напоминающим тот самый Философский Камень."
	requirement = "Доктор, Парамедик, СМО."

	jobs_required = list(
		"Medical Doctor",
		"Paramedic",
		"Chief Medical Officer",
	)

/datum/quality/positiveish/wonder_doctor/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>В твоем кармане лежит фиолетовая таблетка, которая способна излечить любые раны... как жаль, что в ней лишь одна единица вещества.</span>")
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/pill/adminordrazine(H), SLOT_L_STORE)


/datum/quality/positiveish/prepared
	name = "Prepared"
	desc = "Ты задумал пролезть в какой-то отсек. Пришлось найти изоляционные перчатки."
	requirement = "Нет."

/datum/quality/positiveish/prepared/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/clothing/gloves/insulated(H), SLOT_L_STORE)


/datum/quality/positiveish/disguise
	name = "Disguise"
	desc = "С ЦК тебе прислали прикольную посылочку с лучшим в мире камуфляжем."
	requirement = "Клоун."

	jobs_required = list("Clown")

/datum/quality/positiveish/disguise/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>Карта в твоих руках способна менять свой внешний вид и имя владельца, а одежда в коробке заменит целый гардероб.</span>")
	H.equip_or_collect(new /obj/item/weapon/storage/box/syndie_kit/chameleon(H), SLOT_L_HAND)
	H.equip_or_collect(new /obj/item/weapon/card/id/syndicate(H), SLOT_R_HAND)


/datum/quality/positiveish/heavy_equipment
	name = "Heavy Equipment"
	desc = "По программе усиления СБ тебе была выдана экипировка получше."
	requirement = "Офицер СБ."

	jobs_required = list("Security Officer")

/datum/quality/positiveish/heavy_equipment/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/clothing/suit/armor/vest/fullbody(H), SLOT_WEAR_SUIT)
	H.equip_or_collect(new /obj/item/clothing/gloves/combat(H), SLOT_GLOVES)
	H.equip_or_collect(new /obj/item/weapon/melee/baton/double(H), SLOT_S_STORE)


/datum/quality/positiveish/big_iron
	name = "Big Iron"
	desc = "Эта станция слишком мала для тебя и преступности."
	requirement = "Детектив."

	jobs_required = list("Detective")

/datum/quality/positiveish/big_iron/add_effect(mob/living/carbon/human/H, latespawn)
	if(prob(50))
		H.equip_to_slot(new /obj/item/clothing/suit/serifcoat(H), SLOT_WEAR_SUIT)
	else
		H.equip_to_slot(new /obj/item/clothing/suit/poncho(H), SLOT_WEAR_SUIT)
	H.equip_to_slot(new /obj/item/clothing/under/cowboy/brown(H), SLOT_W_UNIFORM)
	H.equip_to_slot(new /obj/item/clothing/head/western/cowboy(H), SLOT_HEAD)
	H.equip_to_slot(new /obj/item/clothing/shoes/western(H), SLOT_SHOES)
	H.equip_to_slot(new /obj/item/weapon/gun/projectile/revolver/peacemaker/detective(H), SLOT_L_HAND)
	H.equip_to_slot(new /obj/item/ammo_box/speedloader/c45rubber(H), SLOT_L_STORE)
	H.equip_to_slot(new /obj/item/ammo_box/speedloader/c45rubber(H), SLOT_R_STORE)


/datum/quality/positiveish/all_affairs
	name = "All Affairs"
	desc = "У тебя полный доступ. Да начнётся расследование."
	requirement = "Агент Внутренних Дел."

	jobs_required = list("Internal Affairs Agent")

/datum/quality/positiveish/all_affairs/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>На твоей карточке полный доступ, но необязательно показывать его перед персоналом - вдруг кто-то захочет отнять?</span>")
	var/obj/item/weapon/card/id/id = H.get_idcard()
	id.access = get_all_accesses()


/datum/quality/positiveish/cultural_heritage
	name = "Cultural Heritage"
	desc = "Всё племя скинулось на то, чтобы заиметь тебе в космос крутой космический костюм. Лучше оправдать их надежды!"
	requirement = "Унатх."

	species_required = list(UNATHI)

/datum/quality/positiveish/cultural_heritage/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/clothing/suit/space/unathi/breacher(H), SLOT_WEAR_SUIT)
	H.equip_or_collect(new /obj/item/clothing/head/helmet/space/unathi/breacher(H), SLOT_HEAD)


/datum/quality/positiveish/sunglasses
	name = "Sunglasses"
	desc = "Крутые очки, чувак."
	requirement = "Нет."

/datum/quality/positiveish/sunglasses/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/clothing/glasses/sunglasses(H), SLOT_GLASSES)


/datum/quality/positiveish/hygiene
	name = "Hygiene"
	desc = "Гигиена - это важно. Ты принёс из дома мыльце."
	requirement = "Нет."

/datum/quality/positiveish/hygiene/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/weapon/reagent_containers/food/snacks/soap(H), SLOT_R_STORE)


/datum/quality/positiveish/vaccinated
	name = "Vaccinated"
	desc = "Привившись всеми известными человечеству вакцинами, ты стал полностью невосприимчив для любого вируса."
	requirement = "Нет."

/datum/quality/positiveish/vaccinated/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/antigen in ANTIGENS)
		H.antibodies |= text2num(antigen)

	ADD_TRAIT(H, TRAIT_VACCINATED, QUALITY_TRAIT)


/datum/quality/positiveish/polyglot
	name = "Polyglot"
	desc = "Ты знаешь все языки."
	requirement = "Нет."

/datum/quality/positiveish/polyglot/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>Тебе известны новые языки. Нажми 'IC > Check Known Languages' чтобы узнать какие.</span>")

	for(var/language in all_languages)
		var/datum/language/L = all_languages[language]
		if(H.get_species() in L.allowed_speak)
			H.add_language(language)


/datum/quality/positiveish/freakish_linguist
	name = "Freakish Linguist"
	desc = "Ты знаешь все языки. Абсолютно все. Но какой ценой?"
	requirement = "Мим."

	jobs_required = list(
		"Mime"
	)

/datum/quality/positiveish/freakish_linguist/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/language in all_languages)
		H.add_language(language)


/datum/quality/positiveish/traveler
	name = "Traveler"
	desc = "Ты много где побывал, и понимаешь большинство существующих языков."
	requirement = "Нет."

/datum/quality/positiveish/traveler/add_effect(mob/living/carbon/human/H, latespawn)
	for(var/language in all_languages)
		var/datum/language/L = all_languages[language]

		if(L.flags & RESTRICTED)
			continue
		H.add_language(language, LANGUAGE_CAN_UNDERSTAND)


/datum/quality/positiveish/augmented_voice
	name = "Augmented Voice"
	desc = "Кузнец подковал тебе голосок и теперь ты освоил невозможный для себя язык."
	requirement = "Нет."

/datum/quality/positiveish/augmented_voice/add_effect(mob/living/carbon/human/H, latespawn)
	to_chat(H, "<span class='notice'>Тебе известны новые языки. Нажми 'IC > Check Known Languages' чтобы узнать какие.</span>")

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


/datum/quality/positiveish/endangered_plants
	name = "Endangered Plants"
	desc = "Бабушка передала тебе со своего гидропонического огорода семена редких растений."
	requirement = "Ботаник."

	jobs_required = list("Botanist")

/datum/quality/positiveish/endangered_plants/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/weapon/storage/box/rare_seeds(H), SLOT_L_HAND)


/datum/quality/positiveish/reliquary
	name = "Reliquary"
	desc = "Тебе выпала великая честь - нести осколок душ. Возможно, заплатив частью своей."
	requirement = "Капеллан."

	jobs_required = list("Chaplain")

/datum/quality/positiveish/reliquary/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/device/soulstone(H), SLOT_R_STORE)


/datum/quality/positiveish/crusader
	name = "Crusader"
	desc = "Dominus concessit vos arma! DEUS VULT!"
	requirement = "Капеллан."

	jobs_required = list("Chaplain")

/datum/quality/positiveish/crusader/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/clothing/head/helmet/crusader(H), SLOT_HEAD)
	H.equip_or_collect(new /obj/item/clothing/suit/armor/crusader(H), SLOT_WEAR_SUIT)


/datum/quality/positiveish/eye_reading
	name = "Eye Reading"
	desc = "Ты по их глазам видишь чего они там задумали."
	requirement = "Нет."

/datum/quality/positiveish/eye_reading/proc/see_intent(datum/source, atom/target)
	var/mob/living/carbon/human/seer = source
	if(!ismob(target))
		return
	var/mob/M = target
	if(M?.client?.tooltip)
		var/atom/targets_target = locate(M.client.tooltip.looking_at)
		if(isturf(targets_target.loc))
			to_chat(seer, "<span class='notice'>They are looking at [targets_target].</span>")

	switch(M.a_intent)
		if(INTENT_HELP)
			to_chat(seer, "<span class='notice'>They intend to help out.</span>")
		if(INTENT_PUSH)
			to_chat(seer, "<span class='notice'>They are very pushy.</span>")
		if(INTENT_GRAB)
			to_chat(seer, "<span class='notice'>They will grab whatever.</span>")
		if(INTENT_HARM)
			to_chat(seer, "<span class='warning'>They intend to do harm!</span>")

	var/target_zone = M.get_targetzone()
	if(target_zone)
		to_chat(seer, "<span class='notice'>Their gaze is somewhere at the level of \the [parse_zone(target_zone)].</span>")

/datum/quality/positiveish/eye_reading/add_effect(mob/living/carbon/human/H, latespawn)
	RegisterSignal(H, list(COMSIG_PARENT_POST_EXAMINATE), PROC_REF(see_intent))


/datum/quality/positiveish/deathalarm
	name = "Deathalarm"
	desc = "Вы раскошелились на имплант оповещения о смерти перед тем, как отправиться в опасный сектор станции."
	requirement = "Нет."

/datum/quality/positiveish/deathalarm/add_effect(mob/living/carbon/human/H, latespawn)
	var/obj/item/weapon/implant/death_alarm/DA = new(H)
	DA.stealth_inject(H)


/datum/quality/positiveish/anatomist
	name = "Anatomist"
	desc = "Ты с первого взгляда можешь по походке и телосложению узнать расу гуманоида перед тобой."
	requirement = "Нет."

/datum/quality/positiveish/anatomist/add_effect(mob/living/carbon/human/H, latespawn)
	ADD_TRAIT(H, TRAIT_ANATOMIST, QUALITY_TRAIT)


/datum/quality/positiveish/petiteprotector
	name = "Petite Protector"
	desc = "На станции всё опаснее и опаснее. Руководство выдало тебе новое средство самозащиты."
	requirement = "Безоружные главы, АВД."
	jobs_required = list("Research Director", "Chief Engineer", "Chief Medical Officer", "Internal Affairs Agent")

/datum/quality/positiveish/petiteprotector/add_effect(mob/living/carbon/human/H, latespawn)
	H.equip_or_collect(new /obj/item/weapon/gun/projectile/revolver/doublebarrel/derringer(H), SLOT_R_STORE)


/datum/quality/positiveish/cqc
	name = "CQC"
	desc = "Вы прошли курсы единоборств и теперь знаете на несколько приёмов больше."
	requirement = "Нет."

/datum/quality/positiveish/cqc/add_effect(mob/living/carbon/human/H)
	H.add_moveset(new /datum/combat_moveset/cqc, MOVESET_QUALITY)


/datum/quality/positiveish/investory
	name = "Investor"
	desc = "Вдоволь находившись на околофинансовые семинары, ты решил прикупить парочку пакетов акций."
	requirement = "Нет."

/datum/quality/positiveish/investory/add_effect(mob/living/carbon/human/H, latespawn)
	if(!H.mind)
		return
	var/datum/money_account/MA = get_account(H.mind.get_key_memory(MEM_ACCOUNT_NUMBER))
	if(!MA)
		return
	SSeconomy.issue_founding_stock(MA.account_number, "Cargo", rand(10, 20))
	SSeconomy.issue_founding_stock(MA.account_number, "Medical", rand(10, 20))


/datum/quality/positiveish/healthy_body
	name = "Healthy Body"
	desc = "У тебя здоровое тело, которому позавидует среднестатистический космонавт."
	requirement = "Нет."

/datum/quality/positiveish/healthy_body/add_effect(mob/living/carbon/human/H)
	H.health = 125
	H.maxHealth = 125 //150 would be too much methinks


/datum/quality/positiveish/psc
	name = "Private Security Company"
	desc = "Акции Карго растут в цене, и завхозу пришлось прибегнуть к услугам ЧОП."
	requirement = "Карготех."
	jobs_required = list("Cargo Technician")

/datum/quality/positiveish/psc/add_effect(mob/living/carbon/human/H)
	H.equip_or_collect(new /obj/item/clothing/suit/armor/vest(H), SLOT_WEAR_SUIT)
	if(is_species(H, TAJARAN))
		H.equip_or_collect(new /obj/item/device/flash(H), SLOT_IN_BACKPACK)
	else
		H.equip_or_collect(new /obj/item/weapon/gun/projectile/automatic/pistol/wjpp(H), SLOT_S_STORE)
		H.equip_or_collect(new /obj/item/ammo_box/magazine/wjpp/rubber(H), SLOT_IN_BACKPACK)
		H.equip_or_collect(new /obj/item/ammo_box/magazine/wjpp/rubber(H), SLOT_IN_BACKPACK)
	H.equip_or_collect(new /obj/item/weapon/paper/psc(H), SLOT_IN_BACKPACK)


/datum/quality/positiveish/selfdefense
	name = "Self Defense"
	desc = "Самооборона - это важно. Ты спрятал пушку в одной из мусорок."
	requirement = "Нет."

/datum/quality/positiveish/selfdefense/add_effect(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_HIDDEN_TRASH_GUN, QUALITY_TRAIT)


/datum/quality/positiveish/rollercoaster
	name = "Roller Coaster"
	desc = "Случайная встреча с подопытным в техах научила тебя безболезненно кататься по мусорным трубам."
	requirement = "Нет."

/datum/quality/positiveish/rollercoaster/add_effect(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_NO_DISPOSALS_DAMAGE, QUALITY_TRAIT)

/datum/quality/positiveish/spaceartist
	name = "Space Artist"
	desc = "Как же быть актёром в космосе, но без космического скафандра?"
	requirement = "Клоун, Мим."
	jobs_required = list("Clown", "Mime")

/datum/quality/positiveish/spaceartist/add_effect(mob/living/carbon/human/H)
	if(H.job == "Clown")
		H.equip_to_slot(new /obj/item/clothing/suit/space/clown, SLOT_R_HAND)
		H.equip_to_slot(new /obj/item/clothing/head/helmet/space/clown, SLOT_L_HAND)
	else if(H.job == "Mime")
		H.equip_to_slot(new /obj/item/clothing/suit/space/mime, SLOT_R_HAND)
		H.equip_to_slot(new /obj/item/clothing/head/helmet/space/mime, SLOT_L_HAND)

/datum/quality/positiveish/fastwalker
	name = "Fast Walker"
	desc = "Упражнения спортивной ходьбой по таяранской методике дали свои плоды - ты способен передвигаться быстро, бесшумно и аккуратно, когда не бежишь."
	requirement = "Нет."

/datum/quality/positiveish/fastwalker/add_effect(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_FAST_WALKER, QUALITY_TRAIT)
