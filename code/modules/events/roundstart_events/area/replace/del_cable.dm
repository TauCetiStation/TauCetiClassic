/datum/event/feature/area/replace/del_cable
	special_area_types = list(/area/station/maintenance)
	replace_types = list(/obj/structure/cable = null)
	num_replaceable = 1

/datum/event/feature/area/replace/del_cable/setup()
	. = ..()
	num_replaceable = rand(2, 8)
	replace_callback = CALLBACK(src, PROC_REF(remove_wire))

/datum/event/feature/area/replace/del_cable/proc/remove_wire(obj/structure/cable/C)
	var/turf/T = get_turf(C)
	C.deconstruct(FALSE)

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
