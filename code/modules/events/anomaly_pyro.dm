/datum/event/anomaly/anomaly_pyro
	startWhen = 10
	announceWhen = 3
	endWhen = 110

/datum/event/anomaly/anomaly_pyro/announce()
	command_alert("Pyroclastic anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert", sound = "pyroanom")

/datum/event/anomaly/anomaly_pyro/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/pyro(T)

/datum/event/anomaly/anomaly_pyro/tick()
	if(!newAnomaly)
		kill()
		return
	if(IS_MULTIPLE(activeFor, 5))
		newAnomaly.anomalyEffect()

/datum/event/anomaly/anomaly_pyro/end()
	if(newAnomaly)//Kill the anomaly if it still exists at the end.
		var/turf/simulated/T = get_turf(newAnomaly)
		if(istype(T))
			T.assume_gas("phoron", 200)
			T.hotspot_expose(1000, CELL_VOLUME)

		var/mob/living/carbon/slime/S
		if(prob(50))
			S = new/mob/living/carbon/slime/red(T)
		else
			S = new/mob/living/carbon/slime/orange(T)
		S.rabid = 1

		qdel(newAnomaly)
