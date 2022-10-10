// PRESETS

// EMP

/obj/machinery/camera/emp_proof/atom_init()
	. = ..()
	var/obj/item/stack/sheet/mineral/phoron/newitem = new(src)
	upgradeEmpProof(newitem)

// X-RAY

/obj/machinery/camera/xray
	icon_state = "xraycam" // Thanks to Krutchen for the icons.

/obj/machinery/camera/xray/atom_init()
	. = ..()
	var/obj/item/device/analyzer/newitem = new(src)
	upgradeXRay(newitem)

//EXPL-IMMUNE

/obj/machinery/camera/ex_immune/
	name = "reinforced security camera"

/obj/machinery/camera/ex_immune/atom_init()
	. = ..()
	upgradeExplosiveImmune()

// MOTION
/obj/machinery/camera/motion
	name = "motion-sensitive security camera"

/obj/machinery/camera/motion/atom_init()
	. = ..()
	var/obj/item/device/assembly/prox_sensor/newitem = new(src)
	upgradeMotion(newitem)

// ALL UPGRADES

/obj/machinery/camera/all/atom_init()
	. = ..()
	var/obj/item/device/assembly/prox_sensor/newsensor = new(src)
	var/obj/item/device/analyzer/newanalyzer = new(src)
	var/obj/item/stack/sheet/mineral/phoron/newphoron = new(src)
	upgradeEmpProof(newphoron)
	upgradeXRay(newanalyzer)
	upgradeMotion(newsensor)
	upgradeExplosiveImmune()

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
