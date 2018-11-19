/obj/item/pod_parts
	parent_type = /obj/item/mecha_parts
	icon = 'icons/goonstation/pods/pod_parts.dmi'

/obj/item/pod_parts/core
	name="Space Pod Core"
	icon_state = "core"
	flags = CONDUCT
	origin_tech = "programming=2;materials=2;biotech=2;engineering=2"

/obj/item/pod_parts/pod_frame
	name = "Space Pod Frame"
	icon_state = ""
	flags = CONDUCT
	density = 0
	anchored = 0
	var/link_to = null
	var/link_angle = 0

/obj/item/pod_parts/pod_frame/proc/find_square()
	/*
	each part, in essence, stores the relative position of another part
	you can find where this part should be by looking at the current direction of the current part and applying the link_angle
	the link_angle is the angle between the part's direction and its following part, which is the current part's link_to
	the code works by going in a loop - each part is capable of starting a loop by checking for the part after it, and that part checking, and so on
	this 4-part loop, starting from any part of the frame, can determine if all the parts are properly in place and aligned
	it also checks that each part is unique, and that all the parts are there for the spacepod itself
	*/
	var/neededparts = list(/obj/item/pod_parts/pod_frame/aft_port, /obj/item/pod_parts/pod_frame/aft_starboard, /obj/item/pod_parts/pod_frame/fore_port, /obj/item/pod_parts/pod_frame/fore_starboard)
	var/turf/T
	var/obj/item/pod_parts/pod_frame/linked
	var/obj/item/pod_parts/pod_frame/pointer
	var/list/connectedparts =  list()
	neededparts -= src
	//log_admin("Starting with [src]")
	linked = src
	for(var/i = 1; i <= 4; i++)
		T = get_turf(get_step(linked, turn(linked.dir, -linked.link_angle))) //get the next place that we want to look at
		if(locate(linked.link_to) in T)
			pointer = locate(linked.link_to) in T
			//log_admin("Looking at [pointer.type]")
		if(istype(pointer, linked.link_to) && pointer.dir == linked.dir && pointer.anchored)
			if(!(pointer in connectedparts))
				connectedparts += pointer
			linked = pointer
			pointer = null
	if(connectedparts.len < 4)
		return 0
	for(var/i = 1; i <=4; i++)
		var/obj/item/pod_parts/pod_frame/F = connectedparts[i]
		if(F.type in neededparts) //if one of the items can be founded in neededparts
			neededparts -= F.type
			log_admin("Found [F.type]")
		else //because neededparts has 4 distinct items, this must be called if theyre not all in place and wrenched
			return 0
	return connectedparts

/obj/item/pod_parts/pod_frame/attackby(var/obj/item/O, mob/user)
	if(istype(O, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = O
		var/list/linkedparts = find_square()
		if(!linkedparts)
			to_chat(user, "<span class='rose'>You cannot assemble a pod frame because you do not have the necessary assembly.</span>")
			return
		var/obj/structure/spacepod_frame/pod = new /obj/structure/spacepod_frame(src.loc)
		pod.dir = src.dir
		to_chat(user, "<span class='notice'>You strut the pod frame together.</span>")
		R.use(10)
		for(var/obj/item/pod_parts/pod_frame/F in linkedparts)
			if(1 == turn(F.dir, -F.link_angle)) //if the part links north during construction, as the bottom left part always does
				//log_admin("Repositioning")
				pod.loc = F.loc
			qdel(F)
		playsound(get_turf(src), 'sound/effects/grillehit.ogg', 50, 1)
	if(istype(O, /obj/item/weapon/wrench))
		to_chat(user, "<span class='notice'>You [!anchored ? "secure \the [src] in place."  : "remove the securing bolts."]</span>")
		anchored = !anchored
		density = anchored
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)

/obj/item/pod_parts/pod_frame/verb/rotate()
	set name = "Rotate Frame"
	set category = "Object"
	set src in oview(1)
	if(anchored)
		to_chat(usr, "\The [src] is securely bolted!")
		return 0
	src.dir = turn(src.dir, -90)
	return 1

/obj/item/pod_parts/pod_frame/attack_hand()
	src.rotate()

/obj/item/pod_parts/pod_frame/fore_port
	name = "fore port pod frame"
	icon_state = "pod_fp"
	desc = "A space pod frame component. This is the fore port component."
	link_to = /obj/item/pod_parts/pod_frame/fore_starboard
	link_angle = 90

/obj/item/pod_parts/pod_frame/fore_starboard
	name = "fore starboard pod frame"
	icon_state = "pod_fs"
	desc = "A space pod frame component. This is the fore starboard component."
	link_to = /obj/item/pod_parts/pod_frame/aft_starboard
	link_angle = 180

/obj/item/pod_parts/pod_frame/aft_port
	name = "aft port pod frame"
	icon_state = "pod_ap"
	desc = "A space pod frame component. This is the aft port component."
	link_to = /obj/item/pod_parts/pod_frame/fore_port
	link_angle = 0

/obj/item/pod_parts/pod_frame/aft_starboard
	name = "aft starboard pod frame"
	icon_state = "pod_as"
	desc = "A space pod frame component. This is the aft starboard component."
	link_to = /obj/item/pod_parts/pod_frame/aft_port
	link_angle = 270

/obj/item/pod_parts/armor
	name = "civilian pod armor"
	icon = 'icons/goonstation/pods/pod_parts.dmi'
	icon_state = "pod_armor_civ"
	desc = "Spacepod armor. This is the civilian version. It looks rather flimsy."

/obj/item/weapon/circuitboard/mecha/pod
	name = "Space Pod Circuitboard"
	icon = 'icons/obj/module.dmi'
	icon_state = "mainboard"
	desc = "A space pod frame component. This is the aft port component."

//Datum parts for fabricator//

/datum/design/c_pod
	name = "Space pod pircuitboard"
	id = "Space pod circuitboard"
	build_type = PODFAB
	req_tech = list("programming" = 5, "engineering" = 3)
	build_path = /obj/item/weapon/circuitboard/mecha/pod
	materials = list(MAT_METAL=1000,MAT_GLASS=5000)
	construction_time = 400
	category = list("Pod Parts")

/datum/design/pod_armor
	name = "Space pod armor"
	id = "Space pod armor"
	build_type = PODFAB
	req_tech = list("materials"=5, "engineering" = 5)
	build_path = /obj/item/pod_parts/armor
	materials = list(MAT_METAL=40000,MAT_DIAMOND=12000,MAT_SILVER=5000,MAT_GOLD = 5000)
	construction_time = 900
	category = list("Pod Parts")

/datum/design/pod_core
	name = "Space pod core"
	id = "Space pod core"
	build_type = PODFAB
	req_tech = list("materials"=5, "engineering" = 5, "powerstorage"=5, "magnets"=5, "bluespace"=3)
	build_path = /obj/item/pod_parts/core
	materials = list(MAT_METAL=50000,MAT_GLASS=15000,MAT_DIAMOND=15000,MAT_SILVER=15000,MAT_GOLD = 15000,MAT_URANIUM=25000)
	construction_time = 900
	category = list("Pod Parts")

/datum/design/pod_frame_fp
	name = "fore port pod frame"
	id = "fore port pod frame"
	build_type = PODFAB
	req_tech = list("materials"=3)
	build_path = /obj/item/pod_parts/pod_frame/fore_port
	materials = list(MAT_METAL=25000)
	construction_time = 300
	category = list("Pod Frames")

/datum/design/pod_frame_fs
	name = "fore starboard pod frame"
	id = "fore starboard pod frame"
	build_type = PODFAB
	req_tech = list("materials"=3)
	build_path = /obj/item/pod_parts/pod_frame/fore_starboard
	materials = list(MAT_METAL=25000)
	construction_time = 300
	category = list("Pod Frames")

/datum/design/pod_frame_ap
	name = "aft port pod frame"
	id = "aft port pod frame"
	build_type = PODFAB
	req_tech = list("materials"=3)
	build_path = /obj/item/pod_parts/pod_frame/aft_port
	materials = list(MAT_METAL=25000)
	construction_time = 300
	category = list("Pod Frames")

/datum/design/pod_frame_as
	name = "aft starboard pod frame"
	id = "aft starboard pod frame"
	build_type = PODFAB
	req_tech = list("materials"=3)
	build_path = /obj/item/pod_parts/pod_frame/aft_starboard
	materials = list(MAT_METAL=25000)
	construction_time = 300
	category = list("Pod Frames")

/datum/design/pod_passenger
	name = "passenger seat"
	id = "passenger seat"
	build_type = PODFAB
	req_tech = list("materials"=3, "engineering"=3)
	build_path = /obj/item/spacepod_equipment/sec_cargo/chair
	materials = list(MAT_METAL=10000)
	construction_time = 100
	category = list("Pod Modules")

/datum/design/pod_keylock
	name = "spacepod tumbler lock"
	id = "spacepod tumbler lock"
	build_type = PODFAB
	req_tech = list("materials"=3, "engineering"=3,"magnets"=4,"powerstorage"=3)
	build_path = /obj/item/spacepod_equipment/lock/keyed
	materials = list(MAT_METAL=10000,MAT_GOLD=6000)
	construction_time = 100
	category = list("Pod Modules")

/datum/design/pod_key
	name = "spacepod key"
	id = "spacepod key"
	build_type = PODFAB
	req_tech = list("materials"=2, "engineering"=2)
	build_path = /obj/item/spacepod_key
	materials = list(MAT_METAL=5000)
	construction_time = 50
	category = list("Pod Modules")