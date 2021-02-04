/datum/event/anomaly/anomaly_flux
	startWhen = 3
	announceWhen = 20
	endWhen = 80
	announcement = new /datum/announcement/centcomm/anomaly/flux
	anomaly_type = /obj/effect/anomaly/flux

/datum/event/anomaly/anomaly_flux/end()
	if(!QDELETED(newAnomaly))//If it hasn't been neutralized, it's time to blow up.
		explosion(get_turf(newAnomaly), 3, 5, 5)
		qdel(newAnomaly)
