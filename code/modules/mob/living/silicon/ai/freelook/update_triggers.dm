#define BORG_CAMERA_BUFFER 30

//UPDATE TRIGGERS, when the chunk (and the surrounding chunks) should update.

// TURFS

/turf
	var/image/obscured

/turf/proc/visibilityChanged()
	if(ticker)
		cameranet.updateVisibility(src)

/turf/simulated/Destroy()
	visibilityChanged()
	return ..()

/turf/simulated/New()
	..()
	visibilityChanged()



// STRUCTURES

/obj/structure/Destroy()
	if(ticker)
		cameranet.updateVisibility(src)
	climbers.Cut()
	return ..()

/obj/structure/New()
	..()
	if(ticker)
		cameranet.updateVisibility(src)

// EFFECTS

/obj/effect/Destroy()
	if(ticker)
		cameranet.updateVisibility(src)
	return ..()

/obj/effect/New()
	..()
	if(ticker)
		cameranet.updateVisibility(src)


// DOORS

// Simply updates the visibility of the area when it opens/closes/destroyed.
/obj/machinery/door/update_nearby_tiles(need_rebuild)
	. = ..(need_rebuild)
	// Glass door glass = 1
	// don't check then?
	if(!glass && cameranet)
		cameranet.updateVisibility(src, 0)


// ROBOT MOVEMENT

// Update the portable camera everytime the Robot moves.
// This might be laggy, comment it out if there are problems.
/mob/living/silicon/robot/var/updating = 0

/mob/living/silicon/robot/Move()
	var/oldLoc = src.loc
	. = ..()
	if(.)
		if(src.camera && src.camera.network.len)
			if(!updating)
				updating = 1
				spawn(BORG_CAMERA_BUFFER)
					if(oldLoc != src.loc)
						cameranet.updatePortableCamera(src.camera)
					updating = 0

#undef BORG_CAMERA_BUFFER