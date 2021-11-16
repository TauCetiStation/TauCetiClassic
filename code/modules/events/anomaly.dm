/datum/event/anomaly
	var/area/impact_area    //The area the event will hit
	var/obj/effect/anomaly/newAnomaly
	announceWhen = 1
	var/obj/effect/anomaly/anomaly_type

/datum/event/anomaly/announce()
	if(announcement)
		announcement.play(impact_area)

/datum/event/anomaly/setup()
	impact_area = findEventArea()
	if(!impact_area)
		CRASH("No valid areas for anomaly found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test)
		CRASH("Anomaly : No valid turfs found for [impact_area] - [impact_area.type]")

/datum/event/anomaly/start()
	var/list/turfs = get_area_turfs(impact_area)
	if(!turfs)
		return
	var/turf/T = pick(turfs)
	newAnomaly = new anomaly_type(T)

/datum/event/anomaly/tick(delta_time)
	if(QDELETED(newAnomaly))
		kill()
		return
	newAnomaly.anomalyEffect(delta_time)

/datum/event/anomaly/end()
	if(!QDELETED(newAnomaly))//If it hasn't been neutralized, it's time to blow up.
		qdel(newAnomaly)


/proc/findEventArea()
	var/static/list/allowed_areas
	if(!allowed_areas)
		//Places that shouldn't explode
		var/list/safe_areas = typecacheof(list(
			/area/station/ai_monitored/storage_secure,
			/area/station/aisat/ai_chamber,
			/area/station/bridge/ai_upload,
			/area/station/engineering,
			/area/station/solar,
			/area/station/civilian/holodeck,
			))

		//Subtypes from the above that actually should explode.
		var/list/unsafe_areas =  typecacheof(list(
			/area/station/engineering/break_room,
			/area/station/engineering/chiefs_office,
			))

		allowed_areas = make_associative(subtypesof(/area/station)) - safe_areas + unsafe_areas

	var/list/possible_areas = typecache_filter_list(global.all_areas, allowed_areas)
	if(length(possible_areas))
		return pick(possible_areas)
