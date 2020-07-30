/datum/event/anomaly
	var/area/impact_area    //The area the event will hit
	var/obj/effect/anomaly/newAnomaly
	announceWhen = 1

/datum/event/anomaly/setup()
	impact_area = findEventArea()
	if(!impact_area)
		CRASH("No valid areas for anomaly found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		CRASH("Anomaly : No valid turfs found for [impact_area] - [impact_area.type]")

/datum/event/anomaly/tick()
	if(!newAnomaly)
		kill()
		return
	newAnomaly.anomalyEffect()

/datum/event/anomaly/end()
	if(newAnomaly)//If it hasn't been neutralized, it's time to blow up.
		qdel(newAnomaly)


/datum/event/anomaly/proc/findEventArea()
	var/static/list/allowed_areas
	var/static/list/world_areas
	if(!allowed_areas)
		//Places that shouldn't explode
		var/list/safe_areas = list(
			/area/station/ai_monitored/storage_secure,
			/area/station/aisat/ai_chamber,
			/area/station/bridge/ai_upload,
			) + typesof(/area/station/engineering) + typesof(/area/station/solar) + typesof(/area/station/civilian/holodeck)

		//Subtypes from the above that actually should explode.
		var/list/unsafe_areas = list(
			/area/station/engineering/break_room,
			/area/station/engineering/chiefs_office
			)

		allowed_areas = subtypesof(/area/station) - safe_areas + unsafe_areas

		world_areas = list()
		for(var/area/A in world)
			world_areas.Add(A.type)

		allowed_areas &= world_areas

	return locate(pick(allowed_areas))
