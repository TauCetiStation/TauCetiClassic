/datum/objective/gang/waste_nuke
	explanation_text = "К нам поступила информация из достоверного источника, что на этой станции хранится ядерная боеголовка. Я не знаю зачем и почему, но это ставит под сомнения в адекватности представителей НТ. Выкиньте эту бомбу куда-то в космос или спрячьте где-то глубоко в астероиде."
	conflicting_types = list(
		/datum/objective/gang/steal_nuke,
	)

/datum/objective/gang/waste_nuke/check_completion()
	var/list/correct_areas = list(
		/area/asteroid/mine/abandoned,
		/area/asteroid/mine/explored,
		/area/asteroid/mine/unexplored,
		/area/asteroid/mine/dwarf,
	)
	for (var/obj/machinery/nuclearbomb/NUKE in poi_list)
		var/area/A = get_area(NUKE)
		if(is_station_level(NUKE.z))
			return OBJECTIVE_LOSS
		if(istype(A, /area/space) || is_type_in_list(A, correct_areas))
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/gang/steal_nuke
	explanation_text = "Секретные агенты НТ дают вам задачу похитить со станции ядерную бомбу для дальнейшей переработки на ядерный мусор. Ну, ээ, это мне так сказали, но дают они такие деньжища, что можно купить еще 3 таких бомбы. Так вот, вытащите эту бомбу из хранилища и доставьте на ЦК. Мои агенты передадут эту находку не моим агентам, а я вам деньги."
	conflicting_types = list(
		/datum/objective/gang/waste_nuke,
	)


/datum/objective/gang/steal_nuke/check_completion()
	for (var/obj/machinery/nuclearbomb/NUKE in poi_list)
		if(is_type_in_list(get_area(NUKE), centcom_shuttle_areas))
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
