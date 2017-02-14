/proc/loadTemplateDepartaments()
	loadEngineering()

/proc/loadEngineering()
	if(!engine_templates.len)
		return

	var/datum/map_template/engine/engine = engine_templates[pick(engine_templates)]
	var/turf/spawn_point
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "Engine spawn")
			spawn_point = get_turf(L)
			break
	if(!spawn_point)
		CRASH("CAN'T FIND SPAWN POINT FOR ENGINE")

	engine.load(spawn_point, FALSE)
