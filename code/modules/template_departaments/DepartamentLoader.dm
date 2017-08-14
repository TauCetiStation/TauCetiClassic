/proc/load_template_departments()
	load_engineering()

/proc/load_engineering()
	if(!map_templates_categorized[TEMPLATE_DEPT][TEMPLATE_DEPT_ENGINE])
		return

	var/engine_key = pick(map_templates_categorized[TEMPLATE_DEPT][TEMPLATE_DEPT_ENGINE])
	var/datum/map_template/department/engine/engine = map_templates_categorized[TEMPLATE_DEPT][TEMPLATE_DEPT_ENGINE][engine_key]
	var/turf/spawn_point
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "Engine spawn")
			spawn_point = get_turf(L)
			break
	if(!spawn_point)
		CRASH("CAN'T FIND SPAWN POINT FOR ENGINE")

	engine.load(spawn_point, FALSE)
