/datum/objective/malf_drone
	explanation_text = ""
	var/objective = ""

/datum/objective/malf_drone/New()
	explanation_text = "Внемли же словам моим, дрон. "
	explanation_text += objective
	..()

//	1
/datum/objective/malf_drone/closets
	objective = "Лязг стальных дверей мне наскучил. Заварите все шкафы на станции."

/datum/objective/malf_drone/closets/check_completion()
	var/welded_closets = 0
	var/all_closets = 0

	for(var/obj/structure/closet/C in global.closet_list)
		if(is_station_level(C.z))
			all_closets++
			if(C.welded)
				welded_closets++

	if(welded_closets > all_closets * 0.7)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//	2
/datum/objective/malf_drone/disposal
	objective = "Вечный шум гремящего в трубах мусора утомляет меня. Разберите все мусорки на станции."
	var/initial_disposal_count = 0

/datum/objective/malf_drone/disposal/New()
	..()
	initial_disposal_count = global.station_disposal_count

/datum/objective/malf_drone/disposal/check_completion()
	if(global.station_disposal_count < initial_disposal_count * 0.2)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//	3
/datum/objective/malf_drone/chairs
	objective = "Стулья больно упиваются ножками в мой пол. Разберите все стулья."
	var/initial_chair_count = 0

/datum/objective/malf_drone/chairs/New()
	..()
	initial_chair_count = global.station_chairs_count

/datum/objective/malf_drone/chairs/check_completion()
	if(global.station_chairs_count < initial_chair_count * 0.2)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//	4
/datum/objective/malf_drone/department
	var/area/station/target_area
	var/list/possible_area = list(
		/area/station/medical = "медблок",
		/area/station/rnd = "научный отдел",
		/area/station/bridge = "мостик",
		/area/station/engineering = "инженерный отдел",
		/area/station/security = "отдел охраны",
		/area/station/cargo = "отдел снабжения")

/datum/objective/malf_drone/department/table
	objective = "Люди слишком громко топают своими ногами, пусть передвигаются ползком. "
	var/initial_table_count = 0

/datum/objective/malf_drone/department/table/New()
	target_area = pick(possible_area)
	objective += "Полностью заполните [possible_area[target_area]] столами."
	initial_table_count = count_tables()
	..()

/datum/objective/malf_drone/department/table/check_completion()
	if(count_tables() > 60 - initial_table_count)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/malf_drone/department/table/proc/count_tables()
	var/tables = 0

	for(var/obj/O as anything in global.table_list)
		if(get_area(O) in typesof(target_area))
			tables++

	return tables

//	5
/datum/objective/malf_drone/department/airlock
	objective = "Эти люди пришли ко мне и заперлись за стальными вратами. "
	var/initial_airlock_count = 0

/datum/objective/malf_drone/department/airlock/New()
	target_area = pick(possible_area)
	objective += "Освободите [possible_area[target_area]] от шлюзов."
	initial_airlock_count = count_airlocks()
	..()

/datum/objective/malf_drone/department/airlock/check_completion()
	if(count_airlocks() < initial_airlock_count * 0.2)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/malf_drone/department/airlock/proc/count_airlocks()
	var/airlocks = 0

	for(var/obj/O in global.airlock_list)
		if(get_area(O) in typesof(target_area))
			if(!istype(O, /obj/machinery/door/airlock/external))
				airlocks++

	return airlocks
