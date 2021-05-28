/datum/event/anomaly/cult_portal
	var/max_constructs
	announcement = new /datum/announcement/centcomm/anomaly/bluespace
	anomaly_type = /obj/effect/anomaly/bluespace/cult_portal

/datum/event/anomaly/cult_portal/setup()
	..()
	startWhen = rand(50, 150)
	announceWhen = startWhen + 5
	endWhen = startWhen + 300
	max_constructs = rand(2, 3)

/datum/event/anomaly/cult_portal/start()
	var/list/turfs = get_area_turfs(impact_area)
	if(!turfs)
		return

	var/turf/T = pick(turfs)
	var/obj/effect/anomaly/bluespace/cult_portal/C = new(T, TRUE)
	newAnomaly = C
	C.spawns = max_constructs
	C.send_request_to_ghost()

/datum/event/anomaly/cult_portal/end()
	if(newAnomaly)
		var/obj/effect/anomaly/bluespace/cult_portal/C = newAnomaly
		C.disable()

/datum/event/anomaly/cult_portal/massive

/datum/event/anomaly/cult_portal/massive/setup()
	startWhen = 5
	announceWhen = 5
	endWhen = 300
	announcement = new /datum/announcement/centcomm/anomaly/massive_portals

/datum/event/anomaly/cult_portal/massive/start()
	if(!newAnomaly)
		newAnomaly = list()

	INVOKE_ASYNC(src, .proc/spawn_portals)

/datum/event/anomaly/cult_portal/massive/proc/spawn_portals()
	for(var/i in 1 to 50)
		impact_area = findEventArea()
		var/list/turfs = get_area_turfs(impact_area)
		if(!turfs)
			continue
		var/turf/T = pick(turfs)
		newAnomaly += new anomaly_type(T)
		sleep(3 SECONDS)

/datum/event/anomaly/cult_portal/massive/tick()
	return

/datum/event/anomaly/cult_portal/massive/end()
	for(var/anom in newAnomaly)
		var/obj/effect/anomaly/bluespace/cult_portal/C = anom
		for(var/datum/beam/B in C.beams)
			B.origin.icon_state = "pylon"
			B.End()
