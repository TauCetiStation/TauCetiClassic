/datum/event/feature/area/replace/airlock
	replace_types = list(/obj/machinery/door/airlock = null)

/datum/event/feature/area/replace/airlock/setup()
	. = ..()
	replace_callback = CALLBACK(src, PROC_REF(make_rupture))

/datum/event/feature/area/replace/airlock/proc/make_rupture(obj/machinery/door/airlock/A)
	A.door_rupture()
