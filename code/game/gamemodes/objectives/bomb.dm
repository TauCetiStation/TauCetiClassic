/datum/objective/bomb
	explanation_text = "Взорвите бомбу в одном из следующих отсеков: Каюта капитана, арсенал, склад токсинов отдела исследований, EVA, телекоммуникации или атмосферный."
	required_equipment = /obj/item/device/radio/beacon/syndicate_bomb/objective
	var/already_completed = FALSE

/datum/objective/bomb/check_completion()
	if(!already_completed)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/obj/item/device/radio/beacon/syndicate_bomb/objective
	bomb_type = /obj/machinery/syndicatebomb/objective

/obj/machinery/syndicatebomb/objective
	for_objective = TRUE
	min_timer = 120
	timer = 120
