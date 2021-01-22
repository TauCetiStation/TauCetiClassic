/datum/event/anomaly/anomaly_grav
	startWhen = 3
	announceWhen = 20
	endWhen = 120
	announcement = new /datum/announcement/centcomm/anomaly/gravity

/datum/event/anomaly/anomaly_grav/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/grav(T)
