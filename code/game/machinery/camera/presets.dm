// PRESETS

// EMP

/obj/machinery/camera/emp_proof/atom_init()
	. = ..()
	upgradeEmpProof()

// X-RAY

/obj/machinery/camera/xray
	icon_state = "xraycam" // Thanks to Krutchen for the icons.

/obj/machinery/camera/xray/atom_init()
	. = ..()
	upgradeXRay()

// MOTION
/obj/machinery/camera/motion
	name = "motion-sensitive security camera"

/obj/machinery/camera/motion/atom_init()
	. = ..()
	upgradeMotion()

// ALL UPGRADES

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
	..()
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


// CHECKS

/obj/machinery/camera/proc/isEmpProof()
	var/O = locate(/obj/item/stack/sheet/mineral/phoron) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isXRay()
	var/O = locate(/obj/item/device/analyzer) in assembly.upgrades
	return O

/obj/machinery/camera/proc/isMotion()
	var/O = locate(/obj/item/device/assembly/prox_sensor) in assembly.upgrades
	return O

// UPGRADE PROCS

/obj/machinery/camera/proc/upgradeEmpProof()
	assembly.upgrades.Add(new /obj/item/stack/sheet/mineral/phoron(assembly))

/obj/machinery/camera/proc/upgradeXRay()
	assembly.upgrades.Add(new /obj/item/device/analyzer(assembly))

// If you are upgrading Motion, and it isn't in the camera's New(), add it to the machines list.
/obj/machinery/camera/proc/upgradeMotion()
	assembly.upgrades.Add(new /obj/item/device/assembly/prox_sensor(assembly))
