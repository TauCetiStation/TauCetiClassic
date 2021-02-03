/datum/event/anomaly/anomaly_grav
	startWhen = 3
	announceWhen = 20
	endWhen = 120
	announcement = new /datum/announcement/centcomm/anomaly/gravity

/datum/event/anomaly/anomaly_grav/start()
	var/list/turfs = get_area_turfs(impact_area)
	if(!turfs.len)
		return
	var/turf/T = pick(turfs)
	if(T)
		newAnomaly = new /obj/effect/anomaly/grav(T)
