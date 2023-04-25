/mob/camera
	name = "camera mob"
	density = FALSE
	status_flags = GODMODE  // You can't damage it.
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	see_in_dark = 7
	invisibility = 101 // No one can see us

/mob/camera/update_canmove()
	return

/mob/camera/CanPass(atom/movable/mover, turf/target)
	return TRUE

/mob/camera/Process_Spacemove(movement_dir = 0)
	return TRUE
