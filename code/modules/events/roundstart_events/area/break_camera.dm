/datum/event/feature/area/break_camera
    percent_areas = 40

/datum/event/feature/area/break_camera/start()
    message_admins("RoundStart Event: [percent_areas]% of cameras have been disabled.")
    for(var/area/target_area in targeted_areas)
        for(var/obj/machinery/camera/C in target_area)
            if(C.status)
                C.status = 0
                C.update_icon()
