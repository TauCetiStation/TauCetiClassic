/datum/unit_test/areas_apc_uniqueness
	name = "ATMOSPHERE ALARM: check area on alarm"

/datum/unit_test/areas_apc_uniqueness/start_test()
	var/failure = ""
	for(var/obj/machinery/alarm/found_alarm in alarm_list)
		atmos_alarm.first_run()
		if(!alarm_area)
			failure += "\n[failure]\nAlarm with lost area: x = [found_alarm.x] y = [found_alarm.y] z = [found_alarm.z]. #1: [log_info_line(found_alarm)]"

	if(failure)
		fail(failure)
	else
		pass("No alarm`s with lost area have been found.")
	return TRUE
