/datum/objective/make_money
	var/required_money

/datum/objective/make_money/New()
	explanation_text = "Заработать [required_money] кредитов. В конце смены они должны находиться на вашем счёте."

/datum/objective/make_money/check_completion()
	if(owner)
		var/datum/money_account/MA = get_account(owner.get_key_memory(MEM_ACCOUNT_NUMBER))
		if(MA.money >= required_money)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/make_money/faction/check_completion()
	if(faction)
		var/total_money = 0
		for(var/datum/role/R in faction.members)
			var/datum/money_account/MA = get_account(R.antag.get_key_memory(MEM_ACCOUNT_NUMBER))
			total_money += MA.money
		if(total_money >= required_money)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/make_money/faction/traders
	required_money = 20000


/datum/objective/trader_purchase
	var/list/items = list()
	var/static/possible_items[] = list(
		"эмиттер" = /obj/machinery/power/emitter,
		"инкубатор вирусов" = /obj/machinery/disease2/incubator,
		"хим диспенсер" = /obj/machinery/chem_dispenser,
		"микроволновку" = /obj/machinery/kitchen_machine/microwave,
		"бипски" = /obj/machinery/bot/secbot/beepsky,
		"биогенератор" = /obj/machinery/biogenerator,
		"экстрактор семян" = /obj/machinery/seed_extractor,
		"бухломат" = /obj/machinery/vending/boozeomat,
		"переносной флэшер" = /obj/machinery/flasher/portable,
		"шкаф главы службы безопасности" = /obj/structure/closet/secure_closet/hos,
		"канистру азота" = /obj/machinery/portable_atmospherics/canister/nitrogen,
		"факс" = /obj/machinery/faxmachine,
		"ядерную боеголовку" = /obj/machinery/nuclearbomb,
		"раздатчик атмосферных труб" = /obj/machinery/pipedispenser,
		"питомца главврача Дасти" = /mob/living/simple_animal/cat/dusty,
		"плазменный дробовик" = /obj/item/weapon/gun/plasma/p104sass,
		"ручной телепортер" = /obj/item/weapon/hand_tele,
		"тыквяк" = /obj/item/weapon/reagent_containers/food/snacks/grown/gourd,
		"имплант защиты разума" = /obj/item/weapon/implantcase/mindshield,
		"смирительную рубашку" = /obj/item/clothing/suit/straight_jacket,
		"капитанское жёлтое мыло" = /obj/item/weapon/reagent_containers/food/snacks/soap/deluxe,
		"мулбота" = /obj/machinery/bot/mulebot,
		"новогоднюю ёлку" = /obj/item/device/flashlight/lamp/fir,
		"двухстволку бармена" = /obj/item/weapon/gun/projectile/revolver/doublebarrel,
		"джукбокс" = /obj/machinery/media/jukebox/bar,
		"полностью собранное ядро ИИ" = /obj/structure/AIcore/deactivated,
		"алтарь священника" = /obj/structure/altar_of_gods)

/datum/objective/trader_purchase/New()
	var/indx = rand(1, possible_items.len)
	var/offset = rand(1, possible_items.len - 1)
	var/new_indx = (indx + offset) % possible_items.len
	items += possible_items[indx]
	items += possible_items[new_indx == 0 ? possible_items.len : new_indx]
	explanation_text = "Достать и притащить на наш шаттл [items[1]] и [items[2]]."

/datum/objective/trader_purchase/check_completion()
	var/list/areas = list(/area/shuttle/trader/space, /area/shuttle/trader/station)
	var/list/checks = list(FALSE, FALSE)
	for(var/type in areas)
		for(var/obj/O in get_area_by_type(type))
			if(istype(O, possible_items[items[1]]))
				checks[1] = TRUE
			else if(istype(O, possible_items[items[2]]))
				checks[2] = TRUE
	if(checks[1] && checks[2])
		return OBJECTIVE_WIN
	else if(checks[1] || checks[2])
		return OBJECTIVE_HALFWIN
	return OBJECTIVE_LOSS


/datum/objective/traders_escape
	explanation_text = "Живыми улететь на своём шаттле со станции."

/datum/objective/traders_escape/check_completion()
	var/counter = 0
	if(faction)
		var/list/mems = faction.members
		for(var/datum/role/R in mems)
			var/mob/M = R.antag.current
			if(!M || ((M.stat == DEAD) && !M.fake_death) || isbrain(M) || issilicon(M)) // alive?
				continue
			if(istype(get_area(M), /area/shuttle/trader/space)) // in space on shuttle?
				counter++
		if(counter == mems.len) 	// ALL TRADERS ESCAPE ALIVE
			return OBJECTIVE_WIN
		else if(counter) 			// AT LEAST ONE TRADER ESCAPE ALIVE
			return OBJECTIVE_HALFWIN
		else
			return OBJECTIVE_LOSS
	return OBJECTIVE_LOSS
