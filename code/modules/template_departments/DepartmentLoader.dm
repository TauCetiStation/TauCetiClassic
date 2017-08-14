/proc/load_template_departments()
	load_engineering()

/proc/load_engineering()
	CHECK_DEPT_LIST_EXIST(TEMPLATE_DEPT_ENGINEERING)

	var/datum/map_template/department/engine/engine = GET_RANDOM_VALUE_FROM_TEMPLATE_DEPT_LIST(TEMPLATE_DEPT_ENGINEERING)
	var/turf/spawn_point
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "Engine spawn")
			spawn_point = get_turf(L)
			break
	if(!spawn_point)
		CRASH("CAN'T FIND SPAWN POINT FOR ENGINE")

	engine.load(spawn_point, FALSE)
