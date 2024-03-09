/datum/objective/bomb
	explanation_text = "Взорвите выданную вам бомбу в одном из следующих отсеков: Каюта капитана, арсенал, склад токсинов отдела исследований, EVA, телекоммуникации или атмосферный."
	required_equipment = /obj/item/device/radio/beacon/syndicate_bomb/objective
	global_objective = TRUE
	var/already_completed = FALSE
	var/list/areas_for_objective = list(/area/station/bridge/captain_quarters,
										/area/station/security/armoury,
										/area/station/rnd/storage,
										/area/station/ai_monitored/eva,
										/area/station/tcommsat,
										/area/station/engineering/atmos)

/datum/objective/bomb/check_completion()
	if(!already_completed)
		return OBJECTIVE_LOSS
	return OBJECTIVE_WIN

/obj/item/device/radio/beacon/syndicate_bomb/objective
	bomb_type = /obj/machinery/syndicatebomb/objective

/obj/machinery/syndicatebomb/objective
	min_timer = 120
	timer = 120
