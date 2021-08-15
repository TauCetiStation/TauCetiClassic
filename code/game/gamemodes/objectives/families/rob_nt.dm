/datum/objective/gang/rob_nt
	explanation_text = "У нас тут у поставщика дури возникли некоторые проблемы. Чтобы ему помочь нужны бабки. Попытайтесь где-то найти хотя бы 2000 кредитов наличкой."

/datum/objective/gang/rob_nt/check_completion()
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
	if(all_money < 2000)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
