/datum/event/grid_check	//NOTE: Times are measured in master controller ticks!
	announceWhen		= 5

/datum/event/grid_check/setup()
	endWhen = rand(30,120)

/datum/event/grid_check/start()
	power_failure(0)

/datum/event/grid_check/announce()
	command_alert("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Automated Grid Check", "poweroff")

/datum/event/grid_check/end()
	if(power_fail_event)
		power_restore()


var/power_fail_event = 0
/proc/power_failure(announce = 1)
	if(power_fail_event)
		return
	power_fail_event = 1

	if(announce)
		command_alert("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure", "poweroff")
		if(prob(25))
			addtimer(CALLBACK(GLOBAL_PROC, .proc/play_ambience), 600)

	var/list/skipped_areas = list(/area/station/aisat/ai_chamber, /area/station/tcommsat/computer, /area/station/tcommsat/chamber)

	for(var/obj/machinery/power/smes/S in smes_list)
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas || !is_station_level(S.z))
			continue
		S.last_charge = S.charge
		S.last_output = S.output
		S.last_online = S.online
		S.charge = 0
		S.output = 0
		S.online = 0
		S.max_input = 0
		S.max_output = 0
		S.update_icon()
		S.power_change()

	for(var/obj/machinery/power/apc/C in apc_list)
		if(C.cell && is_station_level(C.z))
			C.cell.charge = 0

/proc/play_ambience()
	for(var/mob/M in player_list)
		M.playsound_music('sound/ambience/specific/hullcreak.ogg', VOL_AMBIENT, null, null, CHANNEL_AMBIENT_LOOP)

/proc/power_restore(announce = 1, badminery = 0)
	power_fail_event = 0
	var/list/skipped_areas = list(/area/station/aisat/ai_chamber, /area/station/tcommsat/computer, /area/station/tcommsat/chamber)

	if(announce)
		command_alert("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal", "poweron")
	if(badminery)
		for(var/obj/machinery/power/apc/C in apc_list)
			if(C.cell && is_station_level(C.z))
				C.cell.charge = C.cell.maxcharge
	for(var/obj/machinery/power/smes/S in smes_list)
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas || !is_station_level(S.z))
			continue
		S.RefreshParts()
		if(badminery)
			S.charge = S.last_charge
		S.output = S.last_output
		S.online = S.last_online
		S.update_icon()
		S.power_change()

//This one can be called only by admin.
/proc/power_restore_quick(announce = 1)
	if(announce)
		command_alert("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal", "poweron")
	for(var/obj/machinery/power/smes/S in smes_list)
		if(!is_station_level(S.z))
			continue
		S.RefreshParts()
		S.charge = S.capacity
		S.output = S.max_output
		S.online = 1
		S.update_icon()
		S.power_change()
