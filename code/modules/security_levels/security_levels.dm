/var/security_level = SEC_LEVEL_GREEN
/var/delta_timer_id = 0
var/global/list/code_name_eng = list("green", "blue", "red", "delta")
var/global/list/code_name_ru = list("зелёный", "синий", "красный", "дельта")

/proc/open_armory_poddoors()
	for (var/obj/machinery/door/poddoor/D in world)
		if (D.is_armory_door && D.density)
			var/area/A = get_area(D)
			if(A && A.power_environ)
				D.do_open()

/proc/close_armory_poddoors()
	for (var/obj/machinery/door/poddoor/D in world)
		if (D.is_armory_door && !D.density)
			var/area/A = get_area(D)
			if(A && A.power_environ)
				D.do_close()

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

	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != security_level)
		var/datum/announcement/station/code/code_announce
		switch(level)
			if(SEC_LEVEL_GREEN)
				if(security_level == SEC_LEVEL_DELTA)
					SSsmartlight.reset_smartlight()
				security_level = SEC_LEVEL_GREEN
				code_announce = new /datum/announcement/station/code/downtogreen
				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(is_station_level(FA.z) || is_mining_level(FA.z))
						FA.cut_overlays()
						FA.add_overlay(image('icons/obj/monitors.dmi', "overlay_green"))
				deltimer(delta_timer_id)
				delta_timer_id = 0

				close_armory_poddoors()

			if(SEC_LEVEL_BLUE)
				if(security_level < SEC_LEVEL_BLUE)
					code_announce = new /datum/announcement/station/code/uptoblue
				else
					code_announce = new /datum/announcement/station/code/downtoblue
				if(security_level == SEC_LEVEL_DELTA)
					SSsmartlight.reset_smartlight()
				security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(is_station_level(FA.z) || is_mining_level(FA.z))
						FA.cut_overlays()
						FA.add_overlay(image('icons/obj/monitors.dmi', "overlay_blue"))
				deltimer(delta_timer_id)
				delta_timer_id = 0

				close_armory_poddoors()

			if(SEC_LEVEL_RED)
				if(security_level < SEC_LEVEL_RED)
					code_announce = new /datum/announcement/station/code/uptored
				else
					code_announce = new /datum/announcement/station/code/downtored
				if(security_level == SEC_LEVEL_DELTA)
					SSsmartlight.reset_smartlight()
				security_level = SEC_LEVEL_RED

				var/obj/machinery/computer/communications/CC = locate() in communications_list
				if(CC)
					CC.post_status("alert", "redalert")

				for(var/obj/machinery/firealarm/FA in firealarm_list)
					if(is_station_level(FA.z) || is_mining_level(FA.z))
						FA.cut_overlays()
						FA.add_overlay(image('icons/obj/monitors.dmi', "overlay_red"))

				open_armory_poddoors()

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
				SSsmartlight.update_mode(light_modes_by_name["Code Delta"], TRUE)

				open_armory_poddoors()

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
