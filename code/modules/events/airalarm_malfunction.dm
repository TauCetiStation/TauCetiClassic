/datum/event/air_alarm_malfunction/start()
	var/obj/machinery/alarm/airalarm = acquire_random_airalarm()
	airalarm.remote_control = FALSE
	airalarm.aidisabled = TRUE
	if(prob(50))
		airalarm.breach_detection = FALSE
	if(prob(30))
		airalarm.pressure_dangerlevel *= 2
		airalarm.oxygen_dangerlevel *= 2
		airalarm.co2_dangerlevel *= 2
		airalarm.phoron_dangerlevel *= 2
		airalarm.temperature_dangerlevel *= 2
		airalarm.other_dangerlevel *= 2
	else if(prob(50))
		airalarm.pressure_dangerlevel = 0
		airalarm.oxygen_dangerlevel = 0
		airalarm.co2_dangerlevel = 0
		airalarm.phoron_dangerlevel = 0
		airalarm.temperature_dangerlevel = 0
		airalarm.other_dangerlevel = 0
	if(prob(1))
		for(var/device_id in airalarm.alarm_area.air_scrub_names)
			airalarm.send_signal(device_id, list("power"= 1, "panic_siphon"= 1))
		for(var/device_id in airalarm.alarm_area.air_vent_names)
			airalarm.send_signal(device_id, list("power"= 0))
	if(prob(1))
		for(var/device_id in airalarm.alarm_area.air_vent_names)
			airalarm.send_signal(device_id, list("power"= 1, "checks"= "default", "set_external_pressure"= ONE_ATMOSPHERE * 10) )

var/global/list/air_alarms = list()
/datum/event/air_alarm_malfunction/proc/acquire_random_airalarm()
	var/list/acquire_airalarms = list()
	for(var/obj/machinery/alarm/airalarm as anything in global.air_alarms)
		if(airalarm.emagged)
			continue
		var/turf/T = get_turf(airalarm)
		if(!T || !(T.z in SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_MINING))))
			continue
		acquire_airalarms += airalarm
	return pick(acquire_airalarms)
