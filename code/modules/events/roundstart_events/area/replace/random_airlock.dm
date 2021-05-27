/datum/event/roundstart/area/replace/airlock
	replace_types = list(/obj/machinery/door/airlock = null)
	num_replaceable = 2

/datum/event/roundstart/area/replace/airlock/setup()
	. = ..()
	replace_callback = CALLBACK(src, .proc/make_rupture)

/datum/event/roundstart/area/replace/airlock/proc/make_rupture(obj/machinery/door/airlock/A)
	A.door_rupture()
