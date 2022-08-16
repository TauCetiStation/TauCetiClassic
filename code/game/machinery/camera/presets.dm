// PRESETS

/obj/machinery/camera/emp_proof/atom_init()
	. = ..()
	upgradeEmpProof()

/obj/machinery/camera/xray
	icon_state = "xraycam" // Thanks to Krutchen for the icons.

/obj/machinery/camera/xray/atom_init()
	. = ..()
	upgradeXRay()

/obj/machinery/camera/motion
	name = "motion-sensitive security camera"

/obj/machinery/camera/motion/atom_init()
	. = ..()
	upgradeMotion()

/obj/machinery/camera/all/atom_init()
	. = ..()
	upgradeEmpProof()
	upgradeXRay()
	upgradeMotion()

// AUTONAME

/obj/machinery/camera/autoname
	var/number = 0 //camera number in area
//This camera type automatically sets it's name to whatever the area that it's in is called.
/obj/machinery/camera/autoname/atom_init()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/camera/autoname/atom_init_late()
	number = 1
	var/area/A = get_area(src)
	if(A)
		for(var/obj/machinery/camera/autoname/C in cameranet.cameras)
			if(C == src)
				continue
			var/area/CA = get_area(C)
			if(CA.type == A.type)
				if(C.number)
					number = max(number, C.number+1)
		c_tag = "[A.name] #[number]"
