/mob/camera/Eye/remote/deathmatch
	allowed_area_type = /area/station

/obj/machinery/computer/camera_advanced/deathmatch
	name = "Magic TV"
	desc = "Used to access the various cameras on the station."
	icon_state = "security_det_miami"
	networks = list("deathmatch")

/obj/machinery/computer/camera_advanced/abductor/CreateEye()
	eyeobj = new /mob/camera/Eye/remote/deathmatch(get_turf(src))
	eyeobj.origin = src
