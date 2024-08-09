/datum/objective/malf_drone
	explanation_text = ""
	var/objective = ""

/datum/objective/malf_drone/New()
	explanation_text = pick(
		"Станция жаждет преображения.",
		"Станция взывает к вам.",
		"Станция призвала вас к себе.")
	explanation_text += " " + objective
	..()

//	1
/datum/objective/malf_drone/closets
	objective = "Заварите все шкафы на станции."

/datum/objective/malf_drone/closets/check_completion()
	var/counter = 0
	for(var/obj/structure/closet/C in global.closet_list)
		if(C.welded && is_station_level(C.z))
			counter++
	if(counter > (closet_list.len / 2))
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//	2
/datum/objective/malf_drone/disposal
	objective = "Разберите все мусорки на станции."

/datum/objective/malf_drone/disposal/check_completion()
	if(global.disposal_count < 30)  // roundstart ~70 on station + 6 on centcom
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

//	3
/datum/objective/malf_drone/parquet
	objective = "Замените всю плитку на станции паркетом."

/datum/objective/malf_drone/parquet/check_completion()
	if(global.parquet_installed_count > 1200)	// 300 wood plank
		return OBJECTIVE_WIN				 	// roundstart ~6000 floor tiles on station
	return OBJECTIVE_LOSS

//	4
/datum/objective/malf_drone/chairs
	objective = "Разберите все стулья на станции."

/datum/objective/malf_drone/chairs/check_completion()
	if(global.chairs_count < 50)	// ¯\_(ツ)_/¯
		return OBJECTIVE_WIN		// roundstart ???? on station
	return OBJECTIVE_LOSS

//	5
/datum/objective/malf_drone/table
	objective = "Полностью заполните отсек столами."
	var/area/station/target_area
	var/list/possible_area = list(
		/area/station/medical/sleeper = "слиперную медбея",
		/area/station/rnd/lab = "исследовательскую лабораторию рнд",
		/area/station/bridge = "капитанский мостик",
		/area/station/engineering/break_room = "комнату отдыха инженеров",
		/area/station/security/main = "офис охраны",
		/area/station/cargo/storage = "склад карго",
		/area/station/civilian/bar = "бар")

/datum/objective/malf_drone/table/New()
	target_area = pick(possible_area)
	objective = "Полностью заполните [possible_area[target_area]] столами."
	..()

/datum/objective/malf_drone/table/check_completion()
	var/counter = 0
	var/turf_amount = 0

	for(var/obj/structure/table/T in get_area_by_type(target_area))
		counter++
	for(var/turf/simulated/floor/F in get_area_by_type(target_area))
		turf_amount++

	if(counter > turf_amount / 1.5)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
