/datum/religion_rites/swap
	// item = item for which we are changing
	var/list/swap_list

/datum/religion_rites/swap/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	. = ..()
	if(!.)
		return FALSE

	for(var/obj/O in range(1, AOG.loc))
		if(swap_list[O.type])
			var/swapping = swap_list[O.type]
			var/obj/new_item = new swapping(O.loc)
			var/holy_outline = filter(type = "outline", size = 1, color = "#FFD700EE")
			new_item.filters += holy_outline
			animate(new_item.filters[new_item.filters.len], color = "#FFD70000", time = 2 SECONDS)
			addtimer(CALLBACK(src, .proc/revert_effects, new_item, user, holy_outline), 2 SECONDS)
			if(prob(20))
				step(swapping, pick(alldirs))
			qdel(O)
	return TRUE

/datum/religion_rites/swap/proc/revert_effects(var/obj/new_item, mob/user, holy_outline)
	new_item.filters -= holy_outline

/datum/religion_rites/swap/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	for(var/obj/O in range(1, AOG.loc))
		if(!swap_list[O.type])
			continue
		if(prob(20))
			step(O, pick(alldirs))
			break

/*
 * Devaluation
 * In the radius from the altar, changes the denomination of banknotes one higher
 */
/datum/religion_rites/swap/devaluation
	name = "Devaluation"
	desc = "Changes the denomination of banknotes one higher."
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

/datum/religion_rites/swap/devaluation/New()
	swap_list = cash_increase_list

/*
 * Upgrade
 * In the radius from the altar, changes stock_parts withs rating to stock_parts with rating + 1
 */
/datum/religion_rites/swap/upgrade
	name = "Upgrade"
	desc = "Upgrade scientific things."
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

/datum/religion_rites/swap/upgrade/New()
	swap_list = stock_parts_increase_list
