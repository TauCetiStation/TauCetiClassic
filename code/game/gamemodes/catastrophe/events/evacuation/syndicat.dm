/datum/catastrophe_event/syndicat_evacuation
	name = "Syndicat evacuation"

	one_time_event = TRUE

	weight = 100

	event_type = "evacuation"
	steps = 1

	manual_stop = TRUE

/datum/catastrophe_event/syndicat_evacuation/on_step()
	switch(step)
		if(1)
			announce(CYRILLIC_EVENT_SYNDICAT_EVAC_1)

			addtimer(CALLBACK(src, .proc/syndicat_evacuation_real), 5 MINUTES)

/datum/catastrophe_event/syndicat_evacuation/proc/syndicat_evacuation_real()
	announce(CYRILLIC_EVENT_SYNDICAT_EVAC_2)

	var/list/shuttle_turfs = get_area_turfs(locate(/area/shuttle/escape/centcom))
	for(var/turf/simulated/shuttle/wall/W in shuttle_turfs)
		W.color = "#aa0000"
	for(var/turf/simulated/shuttle/floor/F in shuttle_turfs)
		F.color = "#550000"

	var/list/shuttle_atoms = get_area_all_atoms(locate(/area/shuttle/escape/centcom))
	for(var/obj/structure/window/reinforced/shuttle/default/W in shuttle_atoms)
		W.color = "#222222"
	for(var/obj/machinery/door/unpowered/shuttle/D in shuttle_atoms)
		D.color = "#333333"

	if(SSshuttle)
		SSshuttle.always_fake_recall = FALSE
		SSshuttle.fake_recall = 0

		SSshuttle.incall()
	stop()
