/datum/event/anomaly/anomaly_flux
	startWhen = 3
	announceWhen = 20
	endWhen = 80
	announcement = new /datum/announcement/centcomm/anomaly/flux

/datum/event/anomaly/anomaly_flux/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/flux(T)

/datum/event/anomaly/anomaly_flux/end()
	if(!QDELETED(newAnomaly))//If it hasn't been neutralized, it's time to blow up.
		explosion(get_turf(newAnomaly), 3, 5, 5)
		qdel(newAnomaly)
