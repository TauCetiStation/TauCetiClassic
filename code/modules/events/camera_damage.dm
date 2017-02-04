/datum/event/camera_damage/start()
	var/obj/machinery/camera/C = acquire_random_camera()
	if(!C)
		return

	var/severity_range = rand(0,15)

	for(var/obj/machinery/camera/cam in range(severity_range,C))
		if(is_valid_camera(cam))
			cam.toggle_cam(TRUE)
			if(prob(5))
				cam.triggerCameraAlarm()

/datum/event/camera_damage/proc/acquire_random_camera(remaining_attempts = 5)
	if(!cameranet.cameras.len)
		return
	if(!remaining_attempts)
		return

	var/obj/machinery/camera/C = pick(cameranet.cameras)
	if(is_valid_camera(C))
		return C
	return acquire_random_camera(remaining_attempts--)

/datum/event/camera_damage/proc/is_valid_camera(obj/machinery/camera/C)
	// Only return a functional camera, not installed in a silicon, and that exists somewhere players have access
	var/turf/T = get_turf(C)
	return T && C.can_use() && !istype(C.loc, /mob/living/silicon) && (T.z in config.player_levels)
