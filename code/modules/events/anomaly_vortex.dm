/datum/event/anomaly/anomaly_vortex
	startWhen = 10
	announceWhen = 3
	endWhen = 95
	announcement = new /datum/announcement/centcomm/anomaly/vortex

/datum/event/anomaly/anomaly_vortex/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/bhole(T)
