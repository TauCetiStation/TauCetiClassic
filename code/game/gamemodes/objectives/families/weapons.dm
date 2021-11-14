/datum/objective/gang/steal_weapons
	explanation_text = "У нас на базе заканчиваются пушки. Найдите и доставьте где-нибудь как минимум 15 образцов."
	conflicting_types = list(
		/datum/objective/gang/steal_weapons/variant_two,
		/datum/objective/gang/steal_weapons/variant_three,
	)

/datum/objective/gang/exterminate_species/check_completion()
	var/total_amount = 0
	for(var/datum/role/raider in faction.members)
		if(raider?.antag.current && considered_alive(raider.antag) && is_type_in_list(get_area(raider.antag.current), centcom_shuttle_areas))
			for(var/obj/item/weapon/gun/G in as anything raider.antag.current.get_all_contents_type(/obj/item/weapon/gun))
					total_amount++
				if(total_amount >= 15)
					return OBJECTIVE_WIN
	return OBJECTIVE_WIN

/datum/objective/gang/steal_weapons/variant_two
	explanation_text = "Предлагаю вам сделку. Вы должны раздобить 15 абсолютно любых пушек, а по прибытии домой мы вам за это заплатим. Хотя это не сделка, у вас нет выбора. Найдите оружие!"
	conflicting_types = list(
		/datum/objective/gang/steal_weapons,
		/datum/objective/gang/steal_weapons/variant_three,
	)

/datum/objective/gang/steal_weapons/variant_two
	explanation_text = "Вперед легалайз оружия! Оружие всем: детям, женщинам и старикам! В безопасности должны быть не только Вы, здравомыслящие люди, но и более глупые на других планетах и станциях! Поэтому вам дана важная миссия, любым возможным способом доставьте на ЦК 15 моделей любого оружия. Вперед легалайз пушек!"
	conflicting_types = list(
		/datum/objective/gang/steal_weapons,
		/datum/objective/gang/steal_weapons/variant_two,
	)
