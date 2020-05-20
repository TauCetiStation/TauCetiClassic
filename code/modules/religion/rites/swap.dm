/datum/religion_rites/swap
	// item = item for which we are changing
	var/list/swap_list

/datum/religion_rites/swap/proc/generate_swap_list()
	return

/*
 * Devaluation
 * In the radius from the altar, changes the denomination of banknotes one higher
 */
/datum/religion_rites/swap/devaluation
	name = "Devaluation"
	desc = "Changes the denomination of banknotes one higher."
	ritual_length = (1 MINUTES)
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

/datum/religion_rites/swap/devaluation/generate_swap_list()
	var/list/money_type_by_cash_am = list()
	var/list/type_cash = subtypesof(/obj/item/weapon/spacecash) - /obj/item/weapon/spacecash/ewallet
	for(var/money_type in type_cash)
		var/obj/item/weapon/spacecash/cash = money_type
		var/cash_am = "[initial(cash.worth)]"
		money_type_by_cash_am[cash_am] = cash

	var/i = 1
	for(var/cash_am in money_type_by_cash_am)
		if(i == money_type_by_cash_am.len - 1)
			break

		var/money_type = money_type_by_cash_am[cash_am]
		var/next_money_type = money_type_by_cash_am[money_type_by_cash_am[i + 1]]
		cash_increase_list[money_type] = next_money_type
		i++

	cash_increase_list[/obj/item/weapon/spacecash] = /obj/item/weapon/spacecash/c1
	cash_increase_list[/obj/item/weapon/spacecash/c1000] = /obj/item/weapon/spacecash

/datum/religion_rites/swap/devaluation/New()
	if(cash_increase_list.len == 0)
		generate_swap_list()

	swap_list = cash_increase_list

/datum/religion_rites/swap/devaluation/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	for(var/obj/item/weapon/spacecash/cash in range(1, AOG.loc))
		if(istype(cash, /obj/item/weapon/spacecash/ewallet))
			continue
		if(swap_list[cash.type])
			var/swapping = swap_list[cash.type]
			new swapping(cash.loc)
			if(prob(20))
				step(swapping, pick(alldirs))
			qdel(cash)
	return TRUE

/datum/religion_rites/swap/devaluation/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	for(var/obj/item/weapon/spacecash/cash in range(1, AOG.loc))
		if(prob(20))
			step(cash, pick(alldirs))
			break
	return TRUE

/*
 * Upgrade
 * In the radius from the altar, changes stock_parts withs rating to stock_parts with rating + 1
 */
/datum/religion_rites/swap/upgrade
	name = "Upgrade"
	desc = "Upgrade scientific things."
	ritual_length = (1 MINUTES)
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

/datum/religion_rites/swap/upgrade/invoke_effect(mob/living/user, obj/structure/altar_of_gods/AOG)
	for(var/obj/item/weapon/stock_parts/S in range(1, AOG.loc))
		if(istype(S, /obj/item/weapon/stock_parts/console_screen))
			continue

		if(swap_list[S.rating][S.type])
			var/swapping = swap_list[S.rating][S.type]
			new swapping(S.loc)
			if(prob(20))
				step(swapping, pick(alldirs))
			qdel(S)

	return TRUE

/datum/religion_rites/swap/upgrade/on_invocation(mob/living/user, obj/structure/altar_of_gods/AOG, stage)
	for(var/obj/item/weapon/stock_parts/S in range(1, AOG.loc))
		if(prob(20))
			step(S, pick(alldirs))
			break
	return TRUE
