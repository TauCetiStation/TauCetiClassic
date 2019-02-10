#define BORG_CAMERA_BUFFER 30

//UPDATE TRIGGERS, when the chunk (and the surrounding chunks) should update.

// TURFS

/turf
	var/image/obscured

/turf/proc/visibilityChanged()
	cameranet.updateVisibility(src)

/turf/simulated/Destroy()
	visibilityChanged()
	return ..()

/turf/simulated/atom_init()
	. = ..()
	visibilityChanged()



// STRUCTURES

/obj/structure/Destroy()
	cameranet.updateVisibility(src)
	climbers.Cut()
	return ..()

/obj/structure/atom_init()
	. = ..()
	cameranet.updateVisibility(src)

// EFFECTS

/obj/effect/Destroy()
	cameranet.updateVisibility(src)
	return ..()

/obj/effect/atom_init()
	. = ..()
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

/mob/living/silicon/robot/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
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
