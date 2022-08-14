/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 10
	layer = 5

	var/health = 20
	var/list/network = list("SS13")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = 1
	anchored = TRUE
	var/explosive_immune = FALSE
	var/obj/item/device/camera_bug/bug = null
	var/obj/item/weapon/camera_assembly/assembly = null
	var/hidden = 0	//Hidden cameras will be unreachable for AI

	var/datum/wires/camera/wires = null

	//OTHER
	var/view_range = 7
	var/short_range = 2

	var/light_disabled = 0
	var/alarm_on = FALSE
	var/painted = FALSE // Barber's paint can obstruct camera's view.

	var/show_paper_cooldown = 0

/obj/machinery/camera/atom_init(mapload, obj/item/weapon/camera_assembly/CA)
	. = ..()
	cameranet.cameras += src //Camera must be added to global list of all cameras no matter what...
	var/list/open_networks = difflist(network,RESTRICTED_CAMERA_NETWORKS) //...but if all of camera's networks are restricted, it only works for specific camera consoles.
	if(open_networks.len) //If there is at least one open network, chunk is available for AI usage.
		cameranet.addCamera(src)
	wires = new(src)
	if(!CA)
		CA = new
	CA.forceMove(src)
	assembly = CA
	assembly.state = 4

	/* // Use this to look for cameras that have the same c_tag.
	for(var/obj/machinery/camera/C in cameranet.cameras)
		var/list/tempnetwork = C.network&src.network
		if(C != src && C.c_tag == src.c_tag && tempnetwork.len)
			world.log << "[src.c_tag] [COORD(src)] conflicts with [C.c_tag] [COORD(C)]"
	*/
	if(!network || network.len < 1)
		if(loc)
			error("[name] in [get_area(src)] [COORD(src)] has errored. [network ? "Empty network list" : "Null network list"]")
		else
			error("[name] in [get_area(src)]has errored. [network ? "Empty network list" : "Null network list"]")
		ASSERT(network)
		ASSERT(network.len > 0)

/obj/machinery/camera/Destroy()
	disconnect_viewers()
	QDEL_NULL(wires)
	QDEL_NULL(assembly)
	if(bug)
		bug.bugged_cameras -= c_tag
		if(bug.current == src)
			bug.current = null
		bug = null
	cameranet.cameras -= src
	invalidateCameraCache()
	var/list/open_networks = difflist(network, RESTRICTED_CAMERA_NETWORKS)
	if(open_networks.len)
		cameranet.removeCamera(src)
	return ..()

/obj/machinery/camera/update_icon()
	if(stat & (NOPOWER))
		icon_state = "[initial(icon_state)]1"
	if(stat & EMPED)
		icon_state = "[initial(icon_state)]emp"
	if(stat & (BROKEN))
		icon_state = "[initial(icon_state)]x"
	else
		icon_state = "[initial(icon_state)]"

/obj/machinery/camera/examine(mob/user)
	..()
	if(painted)
		to_chat(user, "<span class='warning'>This camera appears to be painted.</span>")

/obj/machinery/camera/emp_act(severity)
	if(isEmpProof() && (stat & (BROKEN|NOPOWER)))
		return
	if(prob(100/severity))
		addtimer(CALLBACK(src, .proc/energize_cam, network), 900)
		network = list()
		stat |= EMPED
		triggerCameraAlarm()
		return ..()

/obj/machinery/camera/ex_act(severity)
	if(explosive_immune)
		return
	switch(severity)
		if(EXPLODE_HEAVY)
			take_damage(60)
		if(EXPLODE_LIGHT)
			take_damage(30)

/obj/machinery/camera/blob_act()
	take_damage(10, alarm = TRUE)

/obj/machinery/camera/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(1, alarm = TRUE)

/obj/machinery/camera/proc/setViewRange(num = 7)
	view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/attack_paw(mob/living/carbon/xenomorph/humanoid/user)
	if(!istype(user))
		return
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
	playsound(src, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
	broke_cam()

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
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)

	else if(is_wire_tool(W) && panel_open)
		wires.interact(user)

	else if(iswelder(W) && wires.is_deconstructable())
		if(weld(W, user))
			deconstruction(sparks = FALSE)

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
	else if(istype(W, /obj/item/weapon/paper))
		user.SetNextMove(CLICK_CD_INTERACT)
		if(show_paper_cooldown > world.time)
			return
		show_paper_cooldown = world.time + 5 SECONDS
		var/obj/item/weapon/paper/P = W
		if(P.crumpled)
			to_chat(usr, "Paper too crumpled for anything.")
			return
		if(tgui_alert(user, "Would you like to hold up \the [P] to the camera?", "Let AI see your text!", list("Yes!", "No!")) != "Yes!")
			return
		to_chat(user, "You hold \the [P] up to the camera...")
		for(var/mob/living/silicon/ai/O as anything in ai_list)
			if(!O.client || O.stat == DEAD)
				continue
			to_chat(O, "<b><a href='byond://?src=\ref[O];track2=\ref[O];track=\ref[user];trackname=[user.name]'>[user.name]</a></b> holds \the [P] up to one of your cameras...")
			P.show_content(O)

		for(var/obj/machinery/computer/security/S in computer_list) // show the paper to all people watching this camera. except ghosts, fuck ghosts
			if(S.active_camera != src)
				continue
			for(var/M in S.concurrent_users)
				var/mob/living/L = locate(M) // M is a \ref. weird
				to_chat(L, "You can see [user] holding \the [P] to the camera you're watching...")
				P.show_content(L)

	else if (istype(W, /obj/item/device/camera_bug))
		if(!can_use())
			to_chat(user, "<span class='notice'>Camera non-functional</span>")
			return
		if(bug)
			to_chat(user, "<span class='notice'>Camera bug removed.</span>")
			bug.bugged_cameras -= src.c_tag
			bug = null
		else
			to_chat(user, "<span class='notice'>Camera bugged.</span>")
			bug = W
			bug.bugged_cameras[c_tag] = src
	else
		..()
		if(istype(W, /obj/item))
			take_damage(W.damage, alarm = TRUE)


/obj/machinery/camera/proc/enable_cam()
	if(stat & BROKEN)
		stat &= ~BROKEN
	if(stat & NOPOWER)
		stat &= ~NOPOWER
	cameranet.addCamera(src)
	update_icon()

/obj/machinery/camera/proc/broke_cam()
	if(stat & BROKEN)
		return
	stat |= BROKEN
	set_light(0)
	cameranet.removeCamera(src)
	disconnect_viewers()
	update_icon()

/obj/machinery/camera/proc/de_energize_cam()
	if(stat & NOPOWER)
		return
	stat |= NOPOWER
	set_light(0)
	cameranet.removeCamera(src)
	disconnect_viewers()
	update_icon()

/obj/machinery/camera/proc/energize_cam(list/previous_network)
	if(stat & EMPED)
		stat &= ~EMPED
	if(stat & NOPOWER)
		stat &= ~NOPOWER
	network = previous_network
	cancelCameraAlarm()
	enable_cam()

/obj/machinery/camera/proc/is_item_in_blacklist(obj/item/I)
	var/list/black_list = list(/obj/item/weapon/holo)
	for(var/black_list_weapon in black_list)
		if(istype(I, black_list_weapon))
			return TRUE
	return FALSE

/obj/machinery/camera/proc/take_damage(amount, alarm = FALSE)
	if(alarm)
		triggerCameraAlarm()
		addtimer(CALLBACK(src, .proc/try_cancel_alarm), 100)
	if(amount <= 0)
		return
	if(is_item_in_blacklist())
		return
	health -= amount
	check_health()

/obj/machinery/camera/proc/check_health()
	if(health <= 0)
		if(alarm_on)
			cancelCameraAlarm()
		deconstruction()

/obj/machinery/camera/deconstruction(state = 0, sparks = TRUE)
	if(assembly)
		assembly.state = state
		assembly.anchored = !!state
		assembly.forceMove(loc)
		assembly.update_icon()
		assembly = null
	new /obj/item/stack/cable_coil/cut/red(loc)
	if(sparks)
		var/datum/effect/effect/system/spark_spread/spark_system = new()
		spark_system.set_up(5, 0, loc)
		spark_system.start()
	playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	qdel(src)

/obj/machinery/camera/proc/disconnect_viewers()
	for(var/mob/O in player_list)
		if(O.client && O.client.eye == src)
			O.unset_machine()
			O.reset_view(null)
			to_chat(O, "The screen bursts into static.")

/obj/machinery/camera/proc/try_cancel_alarm()
	if(stat & (NOPOWER|BROKEN|EMPED))
		return
	cancelCameraAlarm()

/obj/machinery/camera/proc/triggerCameraAlarm()
	alarm_on = TRUE
	for(var/mob/living/silicon/S as anything in silicon_list)
		S.triggerAlarm("Camera", get_area(src), list(src), src)


/obj/machinery/camera/proc/cancelCameraAlarm()
	alarm_on = FALSE
	for(var/mob/living/silicon/S as anything in silicon_list)
		S.cancelAlarm("Camera", get_area(src), src)

/obj/machinery/camera/proc/can_use()
	if(stat & (NOPOWER|BROKEN|EMPED))
		return FALSE
	return TRUE

/obj/machinery/camera/proc/can_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	if(isXRay())
		see = range(view_range, pos)
	else
		see = hear(view_range, pos)
	return see

/obj/machinery/camera/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/simulated/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					set_dir(SOUTH)
				if(SOUTH)
					set_dir(NORTH)
				if(WEST)
					set_dir(EAST)
				if(EAST)
					set_dir(WEST)
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
	return null

/proc/near_range_camera(mob/M)

	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C

	return null

/obj/machinery/camera/proc/weld(obj/item/weapon/weldingtool/WT, mob/user)
	if(!WT.isOn())
		return FALSE
	if(user.is_busy(src))
		return
	// Do after stuff here
	to_chat(user, "<span class='notice'>You start to weld the [src]..</span>")
	WT.eyecheck(user)
	if(WT.use_tool(src, user, 100, volume = 50))
		return TRUE
	return FALSE

/obj/machinery/camera/proc/add_network(network_name)
	add_networks(list(network_name))

/obj/machinery/camera/proc/remove_network(network_name)
	remove_networks(list(network_name))

/obj/machinery/camera/proc/add_networks(list/networks)
	var/network_added = FALSE
	for(var/network_name in networks)
		if(!(network_name in network))
			network += network_name
			network_added = TRUE

	if(network_added)
		invalidateCameraCache()

/obj/machinery/camera/proc/remove_networks(list/networks)
	var/network_removed = FALSE
	for(var/network_name in networks)
		if(network_name in network)
			network -= network_name
			network_removed = TRUE

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
	cam["isonstation"] = is_station_level(z)
	return cam
