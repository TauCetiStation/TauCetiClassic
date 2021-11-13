/datum/objective/gang/save_money

/datum/objective/gang/save_money/check_completion()
	var/all_money = 0
	for(var/R in faction.members)
		var/datum/role/gangster/G = R
		if(!G.antag || !G.antag.current)
			continue
		var/mob/M = G.antag.current
		if(!considered_alive(M.mind))
			continue // dead people cant really do the objective lol
		var/list/items_to_check = M.get_all_contents_type(/obj/item/weapon/spacecash)
		for(var/SC in items_to_check)
			var/obj/item/weapon/spacecash/cash = SC
			all_money += cash.worth
	if(all_money < 8000)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/datum/objective/gang/save_money/variant_one
	explanation_text = "У нас тут у поставщика дури возникли некоторые проблемы. Чтобы ему помочь нужны бабки. Найдите 8000 кредитов наличкой."
	conflicting_types = list(
		/datum/objective/gang/save_money/variant_two,
		/datum/objective/gang/save_money/variant_three,
	)

/datum/objective/gang/save_money/variant_two
	explanation_text = "Товарищ, деньги в нашем банке заканчиваются. Сотрясите с этой станции 8000 кредитов и привезите наличкой."
	conflicting_types = list(
		/datum/objective/gang/save_money/variant_one,
		/datum/objective/gang/save_money/variant_three,
	)

/datum/objective/gang/save_money/variant_three
	explanation_text = "Друг, эта станция нам задолжала приличных бабок. Мы намерены вернуть свой долг и отправили вас. Получите 8000 кредитов любым доступным способом и перевезите эти деньги в банкнотах к нам."
	conflicting_types = list(
		/datum/objective/gang/save_money/variant_one,
		/datum/objective/gang/save_money/variant_two,
	)
