/datum/event/air_alarm_malfunction/start()
	var/obj/machinery/alarm/airalarm = acquire_random_airalarm()
	if(prob(50))
		airalarm.enable_siphon_mode()
	else
		airalarm.enable_highpressure_mode()
	for(var/obj/machinery/alarm/allied_alarms in airalarm.alarm_area)
		allied_alarms.remote_control = FALSE
		allied_alarms.aidisabled = TRUE
		allied_alarms.breach_detection = FALSE
		allied_alarms.disable_sensors()

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
