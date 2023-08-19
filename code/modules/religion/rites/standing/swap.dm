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
	ritual_invocations = list("Всевышний, надейся и поддерживай...",
							  "...Твой вечный трон, твоя заводь...",
							  "...шел по небу...",
							  "...неся мешки с деньгами...",
							  "...мешки открылись...",
							  "...деньги упали...",
							  "...Я, твой раб, шел по дну...",
							  "...собранные деньги...",
							  "...отнес домой...",
							  "...зажжег свечи...",
							  "...отдал их моим...", 	//help
							  "...Свечам, горите...",   //help2 etc
							  "...деньги, приходите ко мне...",)
	invoke_msg = "...До скончания времен!"
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
							  "... Она наделила эти вещи своей силой...",
							  "... Как луна и земля никогда не расстаются...",
							  "... Так этот предмет всегда будет лучше...",)
	invoke_msg = "...Я взываю ко всему сущему!"
	favor_cost = 200

	needed_aspects = list(
		ASPECT_SCIENCE = 1,
	)

/datum/religion_rites/standing/swap/upgrade/New()
	swap_list = stock_parts_increase_list
