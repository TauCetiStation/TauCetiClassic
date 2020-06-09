/datum/event/anomaly
	startWhen = 3
	announceWhen = 20
	endWhen = 120
	var/area/impact_area
	var/obj/effect/anomaly/newAnomaly

/datum/event/anomaly/setup(loop=0)
	var/safety_loop = loop + 1
	if(safety_loop > 50)
		kill()
		end()
	impact_area = findEventArea()
	if(!impact_area)
		setup(safety_loop)
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		setup(safety_loop)

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
