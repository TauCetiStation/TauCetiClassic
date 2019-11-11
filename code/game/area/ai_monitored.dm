/area/station/ai_monitored
	name = "AI Monitored Area"
	var/obj/machinery/camera/motioncamera = null


/area/station/ai_monitored/atom_init(mapload)
	. = ..()

	if(mapload)
		for (var/obj/machinery/camera/M in src)
			if(M.isMotion())
				motioncamera = M
				M.area_motion = src
				return

/area/station/ai_monitored/Entered(atom/movable/O)
	..()
	if (ismob(O) && motioncamera)
		motioncamera.newTarget(O)

/area/station/ai_monitored/Exited(atom/movable/O)
	if (ismob(O) && motioncamera)
		motioncamera.lostTarget(O)


