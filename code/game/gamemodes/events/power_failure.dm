var/power_fail_event = 0
/proc/power_failure(announce = 1)
	if(power_fail_event)
		return
	power_fail_event = 1

	if(announce)
		command_alert("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure")
		player_list << sound('sound/AI/poweroff.ogg')
		if(prob(25))
			addtimer(GLOBAL_PROC, "play_ambience", 600)

	var/list/skipped_areas = list(/area/turret_protected/ai, /area/tcommsat/computer, /area/tcommsat/chamber)

	for(var/obj/machinery/power/smes/S in machines)
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas ||S.z != ZLEVEL_STATION)
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

	for(var/obj/machinery/power/apc/C in machines)
		if(C.cell && C.z == ZLEVEL_STATION)
			C.cell.charge = 0

/proc/play_ambience()
	player_list << sound('sound/ambience/hullcreak.ogg')

/proc/power_restore(announce = 1, badminery = 0)
	power_fail_event = 0
	var/list/skipped_areas = list(/area/turret_protected/ai, /area/tcommsat/computer, /area/tcommsat/chamber)

	if(announce)
		command_alert("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal")
		player_list << sound('sound/AI/poweron.ogg')
	if(badminery)
		for(var/obj/machinery/power/apc/C in machines)
			if(C.cell && C.z == ZLEVEL_STATION)
				C.cell.charge = C.cell.maxcharge
	for(var/obj/machinery/power/smes/S in machines)
		var/area/current_area = get_area(S)
		if(current_area.type in skipped_areas || S.z != ZLEVEL_STATION)
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
		command_alert("All SMESs on [station_name()] have been recharged. We apologize for the inconvenience.", "Power Systems Nominal")
		player_list << sound('sound/AI/poweron.ogg')
	for(var/obj/machinery/power/smes/S in machines)
		if(S.z != ZLEVEL_STATION)
			continue
		S.RefreshParts()
		S.charge = S.capacity
		S.output = S.max_output
		S.online = 1
		S.update_icon()
		S.power_change()
