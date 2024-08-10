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

/datum/objective/malf_drone/disposal/check_completion()
	if(global.disposal_count < 20)  // roundstart ~70 on station
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//	3
/datum/objective/malf_drone/parquet
	objective = "Металлическая плитка сковывает мои полы. Замените всю плитку паркетом."

/datum/objective/malf_drone/parquet/check_completion()
	if(global.parquet_installed_count > 1200)	// 300 wood plank
		return OBJECTIVE_WIN				 	// roundstart ~6000 floor tiles on station
	return OBJECTIVE_LOSS

//	4
/datum/objective/malf_drone/chairs
	objective = "Стулья больно упиваются ножками в мой пол. Разберите все стулья."

/datum/objective/malf_drone/chairs/check_completion()
	if(global.chairs_count < 50)	// ¯\_(ツ)_/¯
		return OBJECTIVE_WIN		// roundstart ???? on station
	return OBJECTIVE_LOSS

//	5
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

/datum/objective/malf_drone/department/table/New()
	possible_area += /area/station/hallway/primary
	possible_area[/area/station/hallway/primary] = "главные коридоры"
	target_area = pick(possible_area)
	objective += "Полностью заполните [possible_area[target_area]] столами."
	..()

/datum/objective/malf_drone/department/table/check_completion()
	var/tables = 0
	var/list/areas = typesof(target_area)

	for(var/obj/O as anything in global.table_list)
		if(get_area(O) in areas)
			tables++

	if(tables > 180) // 30/60 tables for each drone in faction
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//	6
/datum/objective/malf_drone/department/airlock
	objective = "Эти люди пришли ко мне и заперлись за стальными вратами. "

/datum/objective/malf_drone/department/airlock/New()
	target_area = pick(possible_area)
	objective += "Освободите [possible_area[target_area]] от шлюзов."
	..()

/datum/objective/malf_drone/department/airlock/check_completion()
	var/airlocks = 0
	var/list/areas = typesof(target_area)

	for(var/obj/O in global.airlock_list)
		if(get_area(O) in areas)
			if(!istype(O, /obj/machinery/door/airlock/external))
				airlocks++

	if(airlocks < 8)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
