/datum/event/anomaly
	var/area/impact_area    //The area the event will hit
	var/obj/effect/anomaly/newAnomaly
	announceWhen = 1
	var/obj/effect/anomaly/anomaly_type

/datum/event/anomaly/announce()
	if(announcement)
		announcement.play(impact_area)

/datum/event/anomaly/setup()
	impact_area = SSevents.findEventArea()
	if(!impact_area)
		CRASH("No valid areas for anomaly found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test || !turf_test.len)
		CRASH("Anomaly : No valid turfs found for [impact_area] - [impact_area.type]")

/datum/event/anomaly/start()
	var/list/turfs = get_area_turfs(impact_area)
	if(!turfs || !turfs.len)
		return
	var/turf/T = pick(turfs)
	newAnomaly = new anomaly_type(T)
	if (newAnomaly)
		notify_ghosts("[newAnomaly] in [get_area(newAnomaly)]!", source=newAnomaly, action=NOTIFY_ORBIT, header="[newAnomaly]")

/datum/event/anomaly/tick()
	if(QDELETED(newAnomaly))
		kill()
		return
	newAnomaly.anomalyEffect()

/datum/event/anomaly/end()
	if(!QDELETED(newAnomaly))//If it hasn't been neutralized, it's time to blow up.
		qdel(newAnomaly)
