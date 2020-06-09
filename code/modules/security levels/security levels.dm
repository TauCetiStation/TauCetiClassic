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
		switch(level)
			if(SEC_LEVEL_GREEN)
				security_level = SEC_LEVEL_GREEN
				captain_announce(config.alert_desc_green, title = null, subtitle = "Attention! Security level lowered to green", sound = "downtogreen")

				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(is_station_level(FA.z) || is_mining_level(FA.z))
						FA.cut_overlays()
						FA.add_overlay(image('icons/obj/monitors.dmi', "overlay_green"))
				deltimer(delta_timer_id)
				delta_timer_id = 0

			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					captain_announce(config.alert_desc_blue_upto, title = null, subtitle = "Attention! Security level elevated to blue", sound = "blue")
				else
					captain_announce(config.alert_desc_blue_downto, title = null, subtitle = "Attention! Security level lowered to blue", sound = "downtoblue")
				security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(is_station_level(FA.z) || is_mining_level(FA.z))
						FA.cut_overlays()
						FA.add_overlay(image('icons/obj/monitors.dmi', "overlay_blue"))
				deltimer(delta_timer_id)
				delta_timer_id = 0

			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					captain_announce(config.alert_desc_red_upto, title = null, subtitle = "Attention! Code red!", sound = "red")
				else
					captain_announce(config.alert_desc_red_downto, "Attention! Code red!", sound = "downtored")
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
				captain_announce(config.alert_desc_delta, title = null, subtitle = "Attention! Delta security level reached!", sound = "delta")
				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(is_station_level(FA.z) || is_mining_level(FA.z))
						FA.cut_overlays()
						FA.add_overlay(image('icons/obj/monitors.dmi', "overlay_delta"))
				if(!delta_timer_id)
					delta_alarm()
		SSnightshift.check_nightshift() // Night shift mode turns off if security level is raised to red or above
	else
		return

var/list/loud_alarm_areas = typecacheof(typesof(/area/station))
var/list/quiet_alarm_areas = typecacheof(typesof(/area/station/maintenance) + typesof(/area/station/storage))

/proc/delta_alarm()
    delta_timer_id = addtimer(CALLBACK(GLOBAL_PROC, .proc/delta_alarm, FALSE), 8 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
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