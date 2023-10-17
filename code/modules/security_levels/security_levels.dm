/var/security_level = 0
/var/delta_timer_id = 0

/proc/set_security_level(level)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("delta")
			level = SEC_LEVEL_DELTA

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != security_level)
		var/datum/announcement/station/code/code_announce
		switch(level)
			if(SEC_LEVEL_GREEN)
				security_level = SEC_LEVEL_GREEN
				code_announce = new /datum/announcement/station/code/downtogreen

				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(is_station_level(FA.z) || is_mining_level(FA.z))
						FA.cut_overlays()
						FA.add_overlay(image('icons/obj/monitors.dmi', "overlay_green"))
				deltimer(delta_timer_id)
				delta_timer_id = 0

			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					code_announce = new /datum/announcement/station/code/uptoblue
				else
					code_announce = new /datum/announcement/station/code/downtoblue
				security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(is_station_level(FA.z) || is_mining_level(FA.z))
						FA.cut_overlays()
						FA.add_overlay(image('icons/obj/monitors.dmi', "overlay_blue"))
				deltimer(delta_timer_id)
				delta_timer_id = 0

			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					code_announce = new /datum/announcement/station/code/uptored
				else
					code_announce = new /datum/announcement/station/code/downtored
				security_level = SEC_LEVEL_RED

				var/obj/machinery/computer/communications/CC = locate() in communications_list
				if(CC)
					CC.post_status("alert", "redalert")

				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(is_station_level(FA.z) || is_mining_level(FA.z))
						FA.cut_overlays()
						FA.add_overlay(image('icons/obj/monitors.dmi', "overlay_red"))
				deltimer(delta_timer_id)
				delta_timer_id = 0

			if(SEC_LEVEL_DELTA)
				security_level = SEC_LEVEL_DELTA
				code_announce = new /datum/announcement/station/code/delta
				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(is_station_level(FA.z) || is_mining_level(FA.z))
						FA.cut_overlays()
						FA.add_overlay(image('icons/obj/monitors.dmi', "overlay_delta"))
				if(!delta_timer_id)
					delta_alarm()
		SSsmartlight.check_nightshift() // Night shift mode turns off if security level is raised to red or above
		code_announce.play()
	else
		return

var/global/list/loud_alarm_areas = typecacheof(typesof(/area/station))
var/global/list/quiet_alarm_areas = typecacheof(typesof(/area/station/maintenance) + typesof(/area/station/storage))

/proc/delta_alarm()
    delta_timer_id = addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(delta_alarm), FALSE), 8 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
    for(var/mob/M in player_list)
        if (is_station_level(M.z))
            var/area/A = get_area(M)
            if (is_type_in_typecache(A, quiet_alarm_areas))
                M.playsound_local(get_turf(M), 'sound/machines/alarm_delta.ogg', VOL_EFFECTS_MASTER, 20, FALSE)
            else if (is_type_in_typecache(A, loud_alarm_areas))
                M.playsound_local(get_turf(M), 'sound/machines/alarm_delta.ogg', VOL_EFFECTS_MASTER, null, FALSE)
    return

/proc/get_security_level()
	switch(security_level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(seclevel)
	switch( lowertext(seclevel) )
		if("green")
			return SEC_LEVEL_GREEN
		if("blue")
			return SEC_LEVEL_BLUE
		if("red")
			return SEC_LEVEL_RED
		if("delta")
			return SEC_LEVEL_DELTA
