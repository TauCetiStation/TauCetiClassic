/datum/event/anomaly
	startWhen = 3
	announceWhen = 20
	endWhen = 120
	var/obj/effect/anomaly/newAnomaly

/datum/event/anomaly/setup()
	impact_area = findEventArea()
	if(!impact_area)
		CRASH("No valid areas for anomaly found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		CRASH("Anomaly : No valid turfs found for [impact_area] - [impact_area.type]")

/datum/event/anomaly/announce()
	command_alert("Localized hyper-energetic flux wave detected on long range scanners. Expected location of impact: [impact_area.name].", "Anomaly Alert", sound = "fluxanom")

/datum/event/anomaly/start()
	var/turf/T = pick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/flux(T)

/datum/event/anomaly/tick()
	if(!newAnomaly)
		kill()
		return
	newAnomaly.anomalyEffect()

/datum/event/anomaly/end()
	if(newAnomaly)//If it hasn't been neutralized, it's time to blow up.
		qdel(newAnomaly)
