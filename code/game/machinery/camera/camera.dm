/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "camera"
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 10
	layer = 5
	anchored = TRUE
	max_integrity = 25	//1 shot from any gun is normal
	var/status = TRUE	//simple var for non-standart cameras
	var/camera_base = "camera" //used for icon_state overriding in update_icon()
	var/list/network = list("SS13")
	var/c_tag = null
	var/c_tag_order = 999
	var/explosive_immune = FALSE
	var/hidden = FALSE	//Hidden cameras will be unreachable for AI
	var/obj/item/device/camera_bug/bug = null
	var/obj/item/weapon/camera_assembly/assembly = null
	var/datum/wires/camera/wires = null
	//OTHER
	var/view_range = 7
	var/short_range = 2
	var/light_disabled = 0
	var/alarm_on = FALSE
	var/show_paper_cooldown = 0
	var/list/camera_upgrades = list()
	var/list/camera_failings = list()

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
	cancelCameraAlarm()
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
	icon_state = "[camera_base]"
	if(!can_use())
		icon_state = "[camera_base]1"
	if(stat & EMPED)
		icon_state = "[camera_base]emp"
	if(stat & BROKEN || isGlassPainted() || isHandBlockedView())
		icon_state = "[camera_base]x"

/obj/machinery/camera/examine(mob/user)
	. = ..()
	if(isGlassPainted())
		to_chat(user, "<span class='warning'>The lens of [src] is obscured by paint.</span>")
	if(isHandBlockedView())
		to_chat(user, "<span class='warning'>The lens of [src] is obscured by somebodie's hand!</span>")

/obj/machinery/camera/emp_act(severity)
	if(isEmpProof() || (stat & (BROKEN|EMPED)))
		return
	if(prob(100 / severity))
		de_energize_cam()
		addtimer(CALLBACK(src, .proc/energize_cam, network), 300)
		return ..()

/obj/machinery/camera/ex_act(severity)
	if(isExplosiveImmune())
		return
	return ..()

/obj/machinery/camera/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(1)

/obj/machinery/camera/bullet_act(obj/item/projectile/P, def_zone)
	take_damage(P.damage)

/obj/machinery/camera/proc/setViewRange(num = 7)
	view_range = num
	cameranet.updateVisibility(src, 0)

/obj/machinery/camera/attack_paw(mob/living/carbon/xenomorph/humanoid/user)
	if(!istype(user) || !can_use())
		return
	user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)
	visible_message("<span class='warning'>\The [user] slashes at [src]!</span>")
	playsound(src, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
	broke_cam()

/obj/machinery/camera/attack_hand(mob/user)
	if(!ishuman(user) || (user.a_intent != INTENT_HELP) || isHandBlockedView())
		return ..()
	hand_block(user)
	update_icon()
	if(!do_after(user, INFINITY, TRUE, src, FALSE, FALSE))
		hand_block_off(user)
		try_enable_cam()

/obj/machinery/camera/attackby(W, mob/living/user)
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
			deconstruct(TRUE, FALSE)
	//upgrades
	else if(istype(W, /obj/item/device/analyzer) && panel_open) //XRay
		if(!isXRay())
			upgradeXRay(user)
			qdel(W)
		else
			to_chat(user, "<span class='notice'>[src] already have that upgrade.</span>")

	else if(istype(W, /obj/item/stack/sheet/mineral/phoron) && panel_open)
		var/obj/item/stack/sheet/mineral/phoron/P = W
		if(!isEmpProof())
			upgradeEmpProof(user)
			P.use(1)
		else
			to_chat(user, "<span class='notice'>[src] already have that upgrade.</span>")
	else if(istype(W, /obj/item/device/assembly/prox_sensor) && panel_open)
		if(!isMotion())
			upgradeMotion(user)
			qdel(W)
		else
			to_chat(user, "<span class='notice'>[src] already have that upgrade.</span>")
	else if(istype(W, /obj/item/stack/sheet/plasteel) && panel_open)
		var/obj/item/stack/sheet/plasteel/P = W
		if(!isExplosiveImmune())
			upgradeExplosiveImmune(user)
			P.use(1)
		else
			to_chat(user, "<span class='notice'>[src] already have that upgrade.</span>")
	//repair broken stat
	else if(istype(W, /obj/item/stack/sheet/glass) && panel_open)
		var/obj/item/stack/sheet/glass/G = W
		fix_broking_cam(user)
		try_enable_cam()
		to_chat(user, "<span class='notice'>You fixed [src] lens.</span>")
		W.use(1)
	//repair damage
	else if(istype(W, /obj/item/stack/sheet/metal) && panel_open)
		var/obj/item/stack/sheet/metal/M = W
		if(repair_damage(10))
			to_chat(user, "<span class='notice'>[src] looks stronger than before.</span>")
			M.use(1)
		else
			to_chat(user, "<span class='notice'>[src] has enough margin of safety.</span>")
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
			bug.bugged_cameras -= c_tag
			bug = null
		else
			to_chat(user, "<span class='notice'>Camera bugged.</span>")
			bug = W
			bug.bugged_cameras[c_tag] = src

	else if(istype(W, /obj/item/weapon/gun))
		bombastic_shot(W, user)
	else
		..()
		//delete this if fulldestruct system already have damage from all items to machinery
		if(isitem(W) && user.a_intent == INTENT_HARM)
			var/obj/item/I = W
			var/damage = I.force
			if(damage && damage < 15)
				if(!do_after(user, 50, target = src))
					return
			take_damage(damage)

// maybe in future it can triggering AI or human on the computer
/obj/machinery/camera/proc/bombastic_shot(obj/item/weapon/gun, mob/living/user)
	user.visible_message("<span class='warning'>[user] looks at the [src] and raise weapon!</span>",
	"<span class='notice'>You look at the [src] and raise your weapon.</span>")
	user.SetNextMove(CLICK_CD_MELEE)
	if(do_after(user, 20, target = src))	//can_move = TRUE when it have rework
		user.visible_message("<span class='warning'>[user] shoots in the [src]!</span>",
		"<span class='notice'>You fire into the [src] lens.</span>")
		gun.afterattack(src, user)

/obj/machinery/camera/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(stat & BROKEN)
		switch(damage_type)
			if(BRUTE, BURN)
				return damage_amount
		return
	. = ..()

/obj/machinery/camera/atom_break(damage_flag)
	if(!status)
		return
	return ..()

/obj/machinery/camera/deconstruct(disassembled = TRUE, sparks = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()
	if(disassembled)
		drop_assembly(1)
	else
		drop_assembly()
		new /obj/item/stack/cable_coil(loc, 2)
	if(sparks)
		var/datum/effect/effect/system/spark_spread/spark_system = new()
		spark_system.set_up(5, 0, loc)
		spark_system.start()
		playsound(src, pick(SOUNDIN_SPARKS), VOL_EFFECTS_MASTER)
	return ..()

/obj/machinery/camera/proc/drop_assembly(state = 0)
	if(assembly)
		assembly.state = state
		assembly.anchored = !!state
		assembly.forceMove(loc)
		assembly.update_icon()
		assembly = null

/obj/machinery/camera/proc/toggle_cam(show_message, mob/living/user = null)
	status = !status

/obj/machinery/camera/proc/try_enable_cam()
	if(stat & BROKEN|EMPED)
		return FALSE
	cameranet.addCamera(src)
	cancelCameraAlarm()
	update_icon()
	return TRUE

/obj/machinery/camera/proc/broke_cam()
	if(stat & BROKEN)
		return
	stat |= BROKEN
	disable_cam()

/obj/machinery/camera/proc/fix_broking_cam(mob/user = null)
	if(stat & BROKEN)
		stat &= ~BROKEN
	if(isGlassPainted())
		remove_painted_lens(user)
	try_enable_cam()
	update_icon()

/obj/machinery/camera/proc/de_energize_cam()
	if(stat & EMPED)
		return
	stat |= EMPED
	triggerCameraAlarm()
	disable_cam()

/obj/machinery/camera/proc/disable_cam()
	set_light(0)
	cameranet.removeCamera(src)
	disconnect_viewers()
	update_icon()

/obj/machinery/camera/proc/energize_cam()
	if(stat & EMPED)
		stat &= ~EMPED
	try_enable_cam()

/obj/machinery/camera/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, alarm = TRUE)
	. = ..()
	if(alarm)
		triggerCameraAlarm()
		addtimer(CALLBACK(src, .proc/try_cancel_alarm), 100)

/obj/machinery/camera/proc/disconnect_viewers()
	for(var/mob/O in player_list)
		if(O.client && O.client.eye == src)
			O.unset_machine()
			O.reset_view(null)
			to_chat(O, "The screen bursts into static.")

/obj/machinery/camera/proc/try_cancel_alarm()
	if(stat & (BROKEN|EMPED))
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

/obj/machinery/camera/proc/can_use(check_paint = TRUE)
	if(stat & (BROKEN|EMPED))
		return FALSE
	if(!status)
		return FALSE
	if(isGlassPainted() && check_paint || isHandBlockedView())
		if(isXRay())
			return TRUE
		return FALSE
	return TRUE

/obj/machinery/camera/proc/fix_me_all()	//malfunction module
	if(stat & EMPED)
		stat &= ~EMPED
	if(stat & BROKEN)
		stat &= ~BROKEN
	if(isGlassPainted())
		remove_painted_lens()
	if(isHandBlockedView())
		hand_block_off()
	try_enable_cam()

//failings checks
/obj/machinery/camera/proc/isGlassPainted()
	for(var/failin in camera_failings)
		if(failin == "paint")
			return TRUE
	return FALSE

/obj/machinery/camera/proc/isHandBlockedView()
	for(var/failin in camera_failings)
		if(failin == "human palm")
			return TRUE
	return FALSE

//upgrade checks
/obj/machinery/camera/proc/isEmpProof()
	for(var/upgrade_module in camera_upgrades)
		if(upgrade_module == "phoron")
			return TRUE
	return FALSE

/obj/machinery/camera/proc/isXRay()
	for(var/upgrade_module in camera_upgrades)
		if(upgrade_module == "analyzer")
			return TRUE
	return FALSE

/obj/machinery/camera/proc/isMotion()
	for(var/upgrade_module in camera_upgrades)
		if(upgrade_module == "sensor")
			return TRUE
	return FALSE

/obj/machinery/camera/proc/isExplosiveImmune()
	for(var/upgrade_module in camera_upgrades)
		if(upgrade_module == "plasteel")
			return TRUE
	return FALSE

//upgrading procs
/obj/machinery/camera/proc/upgradeEmpProof(mob/user = null)
	if(user)
		to_chat(user, "<span class='notice'>[src] upgraded!</span>")
	camera_upgrades += "phoron"
	update_icon()

/obj/machinery/camera/proc/upgradeXRay(mob/user = null)
	if(user)
		to_chat(user, "<span class='notice'>[src] upgraded!</span>")
	camera_upgrades += "analyzer"
	camera_base = "xraycam"
	update_icon()
// If you are upgrading Motion, and it isn't in the camera's New(), add it to the machines list.
/obj/machinery/camera/proc/upgradeMotion(mob/user = null)
	if(user)
		to_chat(user, "<span class='notice'>[src] upgraded!</span>")
	camera_upgrades += "sensor"
	update_icon()

/obj/machinery/camera/proc/upgradeExplosiveImmune(mob/user = null)
	if(user)
		to_chat(user, "<span class='notice'>[src] upgraded!</span>")
	camera_upgrades += "plasteel"
	modify_max_integrity(max_integrity * 3)
	repair_damage(max_integrity - get_integrity())
	update_icon()
//camera failings
/obj/machinery/camera/proc/paint_lens(mob/user = null)
	if(user)
		to_chat(user, "<span class='notice'>[src] spoiled!</span>")
	camera_failings += "paint"
	if(!isXRay())
		disable_cam()

/obj/machinery/camera/proc/remove_painted_lens(mob/user = null)
	if(user)
		to_chat(user, "<span class='notice'>Paint removed from [src]!</span>")
	if(isGlassPainted())
		for(var/failin in camera_failings)
			if(failin == "paint")
				camera_failings -= failin

/obj/machinery/camera/proc/hand_block(mob/user = null)
	if(user)
		to_chat(user, "<span class='notice'>You blocked the view of the [src]!!</span>")
	camera_failings += "human palm"
	if(!isXRay())
		disconnect_viewers()

/obj/machinery/camera/proc/hand_block_off(mob/user = null)
	if(user)
		to_chat(user, "<span class='notice'>You stop blocking the view of the [src]!</span>")
	if(isHandBlockedView())
		for(var/failin in camera_failings)
			if(failin == "human palm")
				camera_failings -= failin

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
