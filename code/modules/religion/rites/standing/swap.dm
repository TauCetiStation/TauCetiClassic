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
	ritual_invocations = list("Lord, hope and support...",
							  "...Thy Everlasting Throne, your backwater...",
							  "...walked through the sky...",
							  "...carried bags of money...",
							  "...bags opened...",
							  "...money fell...",
							  "...I, your slave, walked along the bottom...",
							  "...raised money...",
							  "...carried it home...",
							  "...lit candles...",
							  "...gave it to mine...",
							  "...Candles, burn...",
							  "...money, come to the house...",)
	invoke_msg = "...Till the end of time!"
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
	ritual_invocations = list("The moon was born...",
							  "...the force was born...",
							  "...She endowed these things with her power...",
							  "... As the moon and the earth never part...",
							  "...So this item will be better forever...",)
	invoke_msg = "...I call on all things!"
	favor_cost = 200

	needed_aspects = list(
		ASPECT_SCIENCE = 1,
	)

/datum/religion_rites/standing/swap/upgrade/New()
	swap_list = stock_parts_increase_list
