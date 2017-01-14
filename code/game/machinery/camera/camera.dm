/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	use_power = 2
	idle_power_usage = 5
	active_power_usage = 10
	layer = 5

	var/list/network = list("SS13")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1
	anchored = 1
	var/invuln = null
	var/obj/item/device/camera_bug/bug = null
	var/obj/item/weapon/camera_assembly/assembly = null
	var/hidden = 0	//Hidden cameras will be unreachable for AI

	// WIRES
	var/wires = 63 // 0b111111
	var/list/IndexToFlag = list()
	var/list/IndexToWireColor = list()
	var/list/WireColorToIndex = list()
	var/list/WireColorToFlag = list()

	//OTHER

	var/view_range = 7
	var/short_range = 2

	var/light_disabled = 0
	var/alarm_on = 0
	var/busy = 0

/obj/machinery/camera/New()
	..()
	cameranet.cameras += src //Camera must be added to global list of all cameras no matter what...
	var/list/open_networks = difflist(network,RESTRICTED_CAMERA_NETWORKS) //...but if all of camera's networks are restricted, it only works for specific camera consoles.
	if(open_networks.len) //If there is at least one open network, chunk is available for AI usage.
		cameranet.addCamera(src)
	WireColorToFlag = randomCameraWires()
	assembly = new(src)
	assembly.state = 4
	/* // Use this to look for cameras that have the same c_tag.
	for(var/obj/machinery/camera/C in cameranet.cameras)
		var/list/tempnetwork = C.network&src.network
		if(C != src && C.c_tag == src.c_tag && tempnetwork.len)
			world.log << "[src.c_tag] [src.x] [src.y] [src.z] conflicts with [C.c_tag] [C.x] [C.y] [C.z]"
	*/
	if(!src.network || src.network.len < 1)
		if(loc)
			error("[src.name] in [get_area(src)] (x:[src.x] y:[src.y] z:[src.z] has errored. [src.network?"Empty network list":"Null network list"]")
		else
			error("[src.name] in [get_area(src)]has errored. [src.network?"Empty network list":"Null network list"]")
		ASSERT(src.network)
		ASSERT(src.network.len > 0)

/obj/machinery/camera/Destroy()
	disconnect_viewers()
	if(assembly)
		qdel(assembly)
		assembly = null
	if(bug)
		bug.bugged_cameras -= c_tag
		if(bug.current == src)
			bug.current = null
		bug = null
	cameranet.cameras -= src
	var/list/open_networks = difflist(network, RESTRICTED_CAMERA_NETWORKS)
	if(open_networks.len)
		cameranet.removeCamera(src)
	return ..()

/obj/machinery/camera/update_icon()
	if(!status)
		icon_state = "[initial(icon_state)]1"
	else if(stat & EMPED)
		icon_state = "[initial(icon_state)]emp"
	else
		icon_state = "[initial(icon_state)]"

/obj/machinery/camera/emp_act(severity)
	if(!isEmpProof() && status)
		if(prob(100/severity))
			var/list/previous_network = network
			network = list()
			stat |= EMPED
			toggle_cam(TRUE)
			triggerCameraAlarm()
			spawn(900)
				network = previous_network
				stat &= ~EMPED
				cancelCameraAlarm()
				toggle_cam(TRUE)
			..()


/obj/machinery/camera/ex_act(severity)
	if(src.invuln)
		return
	else
		..(severity)
	return

/obj/machinery/camera/blob_act()
	return

/obj/machinery/camera/proc/setViewRange(num = 7)
	src.view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/proc/shock(mob/living/user)
	if(!istype(user))
		return
	user.electrocute_act(10, src)

/obj/machinery/camera/attack_paw(mob/living/carbon/alien/humanoid/user)
	if(!istype(user))
		return
	if(status)
		user.do_attack_animation(src)
		visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
		playsound(src, 'sound/weapons/slash.ogg', 100, 1)
		toggle_cam(FALSE, user)

/obj/machinery/camera/attackby(W, mob/living/user)
	var/msg = "<span class='notice'>You attach [W] into the assembly inner circuits.</span>"
	var/msg2 = "<span class='notice'>The camera already has that upgrade!</span>"

	// DECONSTRUCTION
	if(isscrewdriver(W))
		//user << "<span class='notice'>You start to [panel_open ? "close" : "open"] the camera's panel.</span>"
		//if(toggle_panel(user)) // No delay because no one likes screwdrivers trying to be hip and have a duration cooldown
		panel_open = !panel_open
		user.visible_message("<span class='warning'>[user] screws the camera's panel [panel_open ? "open" : "closed"]!</span>",
		"<span class='notice'>You screw the camera's panel [panel_open ? "open" : "closed"].</span>")
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)

	else if((iswirecutter(W) || ismultitool(W)) && panel_open)
		interact(user)

	else if(iswelder(W) && canDeconstruct())
		if(weld(W, user))
			drop_assembly(1)
			qdel(src)
	else if(istype(W, /obj/item/device/analyzer) && panel_open) //XRay
		if(!isXRay())
			upgradeXRay()
			qdel(W)
			to_chat(user, "[msg]")
		else
			to_chat(user, "[msg2]")

	else if(istype(W, /obj/item/stack/sheet/mineral/phoron) && panel_open)
		if(!isEmpProof())
			upgradeEmpProof()
			to_chat(user, "[msg]")
			qdel(W)
		else
			to_chat(user, "[msg2]")
	else if(istype(W, /obj/item/device/assembly/prox_sensor) && panel_open)
		if(!isMotion())
			upgradeMotion()
			to_chat(user, "[msg]")
			qdel(W)
		else
			to_chat(user, "[msg2]")

	// OTHER
	else if ((istype(W, /obj/item/weapon/paper) && !(W:crumpled==1) || istype(W, /obj/item/device/pda)) && isliving(user))
		var/mob/living/U = user
		var/obj/item/weapon/paper/X = null
		var/obj/item/device/pda/P = null

		var/itemname = ""
		var/info = ""
		if(istype(W, /obj/item/weapon/paper))
			X = W
			itemname = X.name
			info = X.info
		else
			P = W
			itemname = P.name
			info = P.notehtml
		to_chat(U, "You hold \the [itemname] up to the camera ...")
		for(var/mob/living/silicon/ai/O in living_mob_list)
			if(!O.client)
				continue
			if(U.name == "Unknown")
				to_chat(O, "<b>[U]</b> holds \a [itemname] up to one of your cameras ...")
			else
				to_chat(O, "<b><a href='byond://?src=\ref[O];track2=\ref[O];track=\ref[U]'>[U]</a></b> holds \a [itemname] up to one of your cameras ...")
			O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
		for(var/mob/O in player_list)
			if (O.client && O.client.eye == src)
				to_chat(O, "[U] holds \a [itemname] up to one of the cameras ...")
				O << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", itemname, info), text("window=[]", itemname))
	else if (istype(W, /obj/item/device/camera_bug))
		if(!src.can_use())
			to_chat(user, "<span class='notice'>Camera non-functional</span>")
			return
		if(bug)
			to_chat(user, "<span class='notice'>Camera bug removed.</span>")
			src.bug.bugged_cameras -= src.c_tag
			src.bug = null
		else
			to_chat(user, "<span class='notice'>Camera bugged.</span>")
			src.bug = W
			src.bug.bugged_cameras[src.c_tag] = src
	else if(istype(W, /obj/item/weapon/melee/energy))//Putting it here last since it's a special case. I wonder if there is a better way to do these than type casting.
		if(W:force > 3)
			user.do_attack_animation(src)
			disconnect_viewers()
			var/datum/effect/effect/system/spark_spread/spark_system = new()
			spark_system.set_up(5, 0, loc)
			spark_system.start()
			playsound(loc, 'sound/weapons/blade1.ogg', 50, 1)
			playsound(loc, "sparks", 50, 1)
			visible_message("<span class='notice'>The camera has been sliced apart by [user] with [W]!</span>")
			drop_assembly()
			pick(new /obj/item/weapon/cable_coil(loc),
                 new /obj/item/weapon/cable_coil/cut(loc))
			qdel(src)
	else
		..()
	return

/obj/machinery/camera/proc/drop_assembly(state = 0)
	if(assembly)
		assembly.state = state
		assembly.loc = loc
		assembly = null

/obj/machinery/camera/proc/toggle_cam(show_message, mob/living/user = null)
	status = !status

	if(can_use())
		cameranet.addCamera(src)
	else
		set_light(0)
		cameranet.removeCamera(src)

	if(user)
		add_hiddenprint(user)

	if(show_message)
		var/status_message = (status ? "reactivates" : "deactivates")
		if(user)
			visible_message("<span class='danger'>[user] [status_message] [src]!</span>")
		else
			visible_message("<span class='danger'>\The [src] [status_message]!</span>")
		playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)

	update_icon()

	if(!status)
		disconnect_viewers()

/obj/machinery/camera/proc/disconnect_viewers()
	for(var/mob/O in player_list)
		if(O.client && O.client.eye == src)
			O.unset_machine()
			O.reset_view(null)
			to_chat(O, "The screen bursts into static.")

/obj/machinery/camera/proc/triggerCameraAlarm()
	alarm_on = 1
	for(var/mob/living/silicon/S in mob_list)
		S.triggerAlarm("Camera", get_area(src), list(src), src)


/obj/machinery/camera/proc/cancelCameraAlarm()
	alarm_on = 0
	for(var/mob/living/silicon/S in mob_list)
		S.cancelAlarm("Camera", get_area(src), src)

/obj/machinery/camera/proc/can_use()
	if(!status)
		return 0
	if(stat & EMPED)
		return 0
	return 1

/obj/machinery/camera/proc/can_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	if(isXRay())
		see = range(view_range, pos)
	else
		see = hear(view_range, pos)
	return see

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/simulated/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					src.dir = SOUTH
				if(SOUTH)
					src.dir = NORTH
				if(WEST)
					src.dir = EAST
				if(EAST)
					src.dir = WEST
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break
	return null

/proc/near_range_camera(mob/M)

	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
			break

	return null

/obj/machinery/camera/proc/weld(obj/item/weapon/weldingtool/WT, mob/user)

	if(busy)
		return 0
	if(!WT.isOn())
		return 0

	// Do after stuff here
	to_chat(user, "<span class='notice'>You start to weld the [src]..</span>")
	playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
	WT.eyecheck(user)
	busy = 1
	if(do_after(user, 100, target = src))
		busy = 0
		if(!WT.isOn())
			return 0
		return 1
	busy = 0
	return 0

/obj/machinery/camera/proc/add_network(network_name)
	add_networks(list(network_name))

/obj/machinery/camera/proc/remove_network(network_name)
	remove_networks(list(network_name))

/obj/machinery/camera/proc/add_networks(list/networks)
	var/network_added
	network_added = 0
	for(var/network_name in networks)
		if(!(network_name in src.network))
			network += network_name
			network_added = 1

	if(network_added)
		invalidateCameraCache()

/obj/machinery/camera/proc/remove_networks(list/networks)
	var/network_removed
	network_removed = 0
	for(var/network_name in networks)
		if(network_name in src.network)
			network -= network_name
			network_removed = 1

	if(network_removed)
		invalidateCameraCache()

/obj/machinery/camera/proc/replace_networks(list/networks)
	if(networks.len != network.len)
		network = networks
		invalidateCameraCache()
		return

	for(var/new_network in networks)
		if(!(new_network in network))
			network = networks
			invalidateCameraCache()
			return

/obj/machinery/camera/proc/clear_all_networks()
	if(network.len)
		network.Cut()
		invalidateCameraCache()

/obj/machinery/camera/proc/nano_structure()
	var/cam[0]
	cam["name"] = sanitize(c_tag)
	cam["deact"] = !can_use()
	cam["camera"] = "\ref[src]"
	cam["x"] = x
	cam["y"] = y
	cam["z"] = z
	return cam
