// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby. TG-stuff
/obj/item/device/multitool/ai_detect
	icon_state = "multitool"
	var/track_delay = 0

/obj/item/device/multitool/ai_detect/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/device/multitool/ai_detect/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/device/multitool/ai_detect/process()

	if(track_delay > world.time)
		return

	var/found_eye = 0
	var/turf/our_turf = get_turf(src)

	if(cameranet.chunkGenerated(our_turf.x, our_turf.y, our_turf.z))

		var/datum/camerachunk/chunk = cameranet.getCameraChunk(our_turf.x, our_turf.y, our_turf.z)

		if(chunk)
			if(chunk.seenby.len)
				for(var/mob/camera/Eye/ai/A in chunk.seenby)
					var/turf/eye_turf = get_turf(A)
					if(get_dist(our_turf, eye_turf) < 8)
						found_eye = 1
						break

	if(found_eye)
		icon_state = "[initial(icon_state)]_red"
	else
		icon_state = initial(icon_state)

	track_delay = world.time + 10 // 1 second
	return
