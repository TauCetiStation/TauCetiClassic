/datum/event/roundstart/area/replace/del_cable
	special_area_types = list(/area/station/maintenance)
	replace_types = list(/obj/structure/cable = null)
	num_replaceable = 1

/datum/event/roundstart/area/replace/del_cable/setup()
	. = ..()
	num_replaceable = rand(1, 2)
	replace_callback = CALLBACK(src, .proc/remove_wire)

/datum/event/roundstart/area/replace/del_cable/proc/remove_wire(obj/structure/cable/C)
	var/turf/T = get_turf(C)
	C.remove_cable(T)

	var/turf/spawn_turf
	var/mob/living/simple_animal/mouse/M
	for(var/dir in shuffle(alldirs))
		spawn_turf = get_step(T, dir)
		if(spawn_turf.is_mob_placeable())
			M = new(spawn_turf)
			break

	// if it is not possible to spawn the mouse around the wire
	if(!M)
		M = new(T)
	M.death()
