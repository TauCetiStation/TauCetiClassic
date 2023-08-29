/datum/religion_rites/standing/swap
	// item = item for which we are changing
	var/list/swap_list

/datum/religion_rites/standing/swap/invoke_effect(mob/living/user, obj/AOG)
	. = ..()
	if(!.)
		return FALSE

	for(var/obj/O in range(1, get_turf(AOG)))
		if(swap_list[O.type])
			var/swapping = swap_list[O.type]
			new swapping(O.loc)
			if(prob(20))
				step(swapping, pick(alldirs))
			qdel(O)
	return TRUE

/datum/religion_rites/standing/swap/rite_step(mob/living/user, obj/AOG, stage)
	..()
	for(var/obj/O in range(1, get_turf(AOG)))
		if(!swap_list[O.type])
			continue
		if(prob(20))
			step(O, pick(alldirs))
			break

/*
 * Devaluation
 * In the radius from the altar, changes the denomination of banknotes one higher
 */
/datum/religion_rites/standing/swap/devaluation
	name = "Девальвация"
	desc = "Меняет номинал банкнот на один выше."
	ritual_length = (50 SECONDS)
	ritual_invocations = list("Услышь, Всевышний, наш призыв...",
							  "...Сокровищ сказочный прорыв...",
							  "...на нас златым дождем прольется!...",
							  "...И те сердца, что в унисон...",
							  "...со всей Вселенной в ритме бьются...",
							  "...богатств достигнут и высот...",
							  "...и Ангелов душой коснутся...",
							  "...Что приготовили дары...",
							  "...для всех - несметные богатства...",
							  "...всё есть твоё! Иди - бери!...",
							  "...вступай в божественное братство!...", 	//help
							  "...Фортуна! Возроди сознанье!...",   //help2 etc
							  "...чтоб манну получить с небес!...",
							  "...низ равен верху в век познанья!..")
	invoke_msg = "...Для всех достаточно чудес!"
	favor_cost = 150

	needed_aspects = list(
		ASPECT_GREED = 1,
	)

/datum/religion_rites/standing/swap/devaluation/New()
	swap_list = cash_increase_list

/*
 * Upgrade
 * In the radius from the altar, changes stock_parts withs rating to stock_parts with rating + 1
 */
/datum/religion_rites/standing/swap/upgrade
	name = "Улучшение"
	desc = "Улучшает научные штуки."
	ritual_length = (50 SECONDS)
	ritual_invocations = list("Родилась луна...",
							  "...Родилась сила...",
							  "...Она наделила эти вещи своей силой...",
							  "...Как луна и земля никогда не расстаются...",
							  "...так этот предмет всегда будет лучше...",)
	invoke_msg = "...Я взываю ко всему сущему!"
	favor_cost = 200

	needed_aspects = list(
		ASPECT_SCIENCE = 1,
	)

/datum/religion_rites/standing/swap/upgrade/New()
	swap_list = stock_parts_increase_list
