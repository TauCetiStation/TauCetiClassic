/proc/invalidateCameraCache()
	for(var/obj/machinery/computer/security/s in computer_list)
		s.camera_cache = null
	for(var/datum/alarm/A in datum_alarm_list)
		A.cameras = list()

#define DEFAULT_MAP_SIZE 15

/obj/machinery/computer/security
	name = "security camera monitor"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"
	state_broken_preset = "securityb"
	state_nopower_preset = "security0"
	circuit = /obj/item/weapon/circuitboard/security
	light_color = "#a91515"
	var/obj/machinery/camera/active_camera = null
	var/last_pic = 1.0
	var/list/network = list("SS13")

	/// The turf where the camera was last updated.
	var/turf/last_camera_turf
	var/list/concurrent_users = list()

	// Stuff needed to render the map
	var/map_name
	var/atom/movable/screen/map_view/cam_screen
	/// All the plane masters that need to be applied.
	var/list/cam_plane_masters
	var/atom/movable/screen/background/cam_background

	var/camera_cache = null

/obj/machinery/computer/security/atom_init(mapload, obj/item/weapon/circuitboard/C)
	. = ..()
	// Map name has to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	// I wasted 6 hours on this. :agony:
	map_name = "camera_console_\ref[src]_map"
	// Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_plane_masters = list()
	for(var/plane in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/blackness)
		cam_plane_masters += plane
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE
	var/obj/item/weapon/circuitboard/security/board = circuit
	if(istype(C))
		var/list/circuitboard_network = board.network
		if(circuitboard_network.len > 0)
			network = circuitboard_network
	else
		board.network = network

/obj/machinery/computer/security/Destroy()
	qdel(cam_screen)
	cam_plane_masters.Cut()
	qdel(cam_background)
	return ..()

/obj/machinery/computer/security/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/computer/security/proc/close_other_camera_uis(mob/user, datum/tgui/current_ui)
	for(var/datum/tgui/ui in user.tgui_open_uis)
		if((isnull(current_ui) || current_ui != ui) && ui.interface == "CameraConsole")
			ui.close()

/obj/machinery/computer/security/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	update_active_camera_screen()

	close_other_camera_uis(user, ui)

	if(!ui)
		var/user_ref = "\ref[user]"
		var/is_living = isliving(user)
		// Ghosts shouldn't count towards concurrent users, which produces
		// an audible terminal_on click.
		if(is_living)
			concurrent_users += user_ref
		// Turn on the console
		if(length(concurrent_users) == 1 && is_living)
			playsound(src, 'sound/machines/terminal_on.ogg', VOL_EFFECTS_MASTER, 25, FALSE)
			use_power(active_power_usage)
		// Register map objects
		user.client.register_map_obj(cam_screen)

		for(var/plane in cam_plane_masters)
			var/atom/movable/screen/plane_master/instance = new plane()

			if(instance.blend_mode_override)
				instance.blend_mode = instance.blend_mode_override
			instance.assigned_map = map_name
			instance.del_on_map_removal = FALSE
			instance.screen_loc = "[map_name]:CENTER"

			instance.apply_effects(user, iscamera = TRUE)
			user.client.register_map_obj(instance)

		user.client.register_map_obj(cam_background)
		// Open UI
		ui = new(user, src, "CameraConsole", name)
		ui.open()

/obj/machinery/computer/security/tgui_state(mob/user)
	return global.machinery_state

/obj/machinery/computer/security/tgui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "switch_camera")
		var/c_tag = params["name"]
		var/list/cameras = get_cached_cameras()
		var/obj/machinery/camera/selected_camera = cameras[c_tag]

		switch_to_camera(selected_camera)

		return TRUE

/obj/machinery/computer/security/proc/switch_to_camera(obj/machinery/camera/camera_to_switch)
	active_camera = camera_to_switch
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', VOL_EFFECTS_MASTER, 25, FALSE)

	update_active_camera_screen()

//Camera control: moving.
/obj/machinery/computer/security/proc/jump_on_click(mob/user,A)
	if(user.machine != src)
		return
	var/obj/machinery/camera/jump_to
	if(istype(A,/obj/machinery/camera))
		jump_to = A
	else if(ismob(A))
		if(ishuman(A))
			jump_to = locate() in A:head
		else if(isrobot(A))
			jump_to = A:camera
	else if(isobj(A))
		jump_to = locate() in A
	else if(isturf(A))
		var/best_dist = INFINITY
		for(var/obj/machinery/camera/camera in get_area(A))
			if(!camera.can_use())
				continue
			if(!can_access_camera(camera))
				continue
			var/dist = get_dist(camera,A)
			if(dist < best_dist)
				best_dist = dist
				jump_to = camera
	if(isnull(jump_to))
		return
	if(can_access_camera(jump_to))
		switch_to_camera(jump_to)

/obj/machinery/computer/security/proc/update_active_camera_screen()
	// Show static if can't use the camera
	if(QDELETED(active_camera) || (istype(active_camera) && !active_camera.can_use()))
		show_camera_static()
		return

	var/list/visible_turfs = list()

	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	var/camera_turf = get_turf(active_camera)
	if(last_camera_turf == camera_turf)
		return

	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_camera_turf = camera_turf
	//hear() bypasses luminosity checks
	var/list/visible_things = active_camera.isXRay() ? range(active_camera.view_range, camera_turf) : hear(active_camera.view_range, camera_turf)

	for(var/turf/visible_turf in visible_things)
		visible_turfs += visible_turf

	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/obj/machinery/computer/security/tgui_close(mob/user)
	. = ..()
	var/user_ref = "\ref[user]"
	var/is_living = isliving(user)
	// Living creature or not, we remove you anyway.
	concurrent_users -= user_ref
	// Unregister map objects
	if(user.client)
		user.client.clear_map(map_name)
	// Turn off the console
	if(length(concurrent_users) == 0 && is_living)
		active_camera = null
		last_camera_turf = null
		playsound(src, 'sound/machines/terminal_off.ogg', VOL_EFFECTS_MASTER, 25, FALSE)
		use_power(0)

/obj/machinery/computer/security/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, DEFAULT_MAP_SIZE, DEFAULT_MAP_SIZE)

/obj/machinery/computer/security/proc/can_access_camera(obj/machinery/camera/C)
	var/list/shared_networks = src.network & C.network
	if(shared_networks.len)
		return TRUE
	return FALSE

// Returns the list of cameras accessible from this computer
/obj/machinery/computer/security/proc/get_available_cameras()
	cameranet.process_sort()
	var/list/L = list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		if(!can_access_camera(C))
			continue
		L.Add(C)
	var/list/D = list()
	for(var/obj/machinery/camera/C in L)
		D["[C.c_tag]"] = C
	return D

/obj/machinery/computer/security/proc/get_cached_cameras()
	if (isnull(camera_cache))
		camera_cache = get_available_cameras()

	return camera_cache

/obj/machinery/computer/security/tgui_data(mob/user)
	var/list/data = list()
	data["activeCamera"] = null
	if(!QDELETED(active_camera))
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			status = active_camera.status,
		)
	return data

/obj/machinery/computer/security/tgui_static_data(mob/user)
	var/list/data = list()
	data["mapRef"] = map_name
	var/list/cameras = get_cached_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		if(!QDELETED(C))
			data["cameras"] += list(list(
				name = C.c_tag,
			))

	return data

/obj/machinery/computer/security/attack_ghost(mob/user) // this should not ever be opened to ghots, there is simply no point (even for admin) and also this thing eats up ALOT of resources.
	return

/obj/machinery/computer/security/attack_hand(mob/user)
	if (!network)
		world.log << "A computer lacks a network at [COORD(src)]."
		return
	if (!istype(network, /list))
		world.log << "The computer at [COORD(src)] has a network that is not a list!"
		return

	..()

//Camera control: mouse.
/atom/DblClick()
	..()
	if(istype(usr.machine,/obj/machinery/computer/security))
		var/obj/machinery/computer/security/console = usr.machine
		console.jump_on_click(usr,src)

/obj/machinery/computer/security/telescreen
	name = "Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'icons/obj/objects.dmi'
	icon_state = "telescreen"
	state_broken_preset = null
	state_nopower_preset = null
	light_color = "#ffffbb"
	network = list("thunder")
	density = FALSE

/obj/machinery/computer/security/telescreen/update_icon()
	icon_state = initial(icon_state)
	if(stat & BROKEN)
		icon_state += "b"
		playsound(src, 'sound/effects/Glassbr3.ogg', VOL_EFFECTS_MASTER)
	return

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, why do they never have anything interesting on these things?"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "entertainment"
	state_broken_preset = null
	state_nopower_preset = null
	light_color = "#ea4444"

/obj/machinery/computer/security/wooden_tv
	name = "security camera monitor"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "security_det"
	state_broken_preset = null
	state_nopower_preset = null
	light_color = "#3550b6"

/obj/machinery/computer/security/wooden_tv/miami
	name = "security camera monitor"
	desc = "An old TV hooked into the stations camera network."
	icon_state = "security_det_miami"
	state_broken_preset = null
	state_nopower_preset = null
	light_color = "#f535aa"

/obj/machinery/computer/security/mining
	name = "outpost camera monitor"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "miningcameras"
	network = list("MINE")

/obj/machinery/computer/security/engineering
	name = "alarms monitoring cameras"
	desc = "Used to monitor fires and breaches."
	icon_state = "engineeringcameras"
	state_broken_preset = "powerb"
	state_nopower_preset = "power0"
	network = list("Power Alarms","Atmosphere Alarms","Fire Alarms")
	light_color = "#b88b2e"

/obj/machinery/computer/security/engineering/drone
	name = "drone monitoring cameras"
	desc = "Used to monitor drones and engineering borgs."
	network = list("Engineering Robots")

/obj/machinery/computer/security/nuclear
	name = "head mounted camera monitor"
	desc = "Used to access the built-in cameras in helmets."
	icon_state = "syndicam"
	state_broken_preset = "tcbossb"
	state_nopower_preset = "tcboss0"
	network = list("NUKE")
	light_color = "#a91515"

/obj/machinery/computer/security/nuclear/shiv
	name = "pilot camera monitor"
	desc = "Console used by fighter pilot to monitor the battlefield."
	network = list("shiv")

/obj/machinery/computer/security/abductor_ag
	name = "agent observation monitor"
	desc = "Used to access the cameras in agent helmet."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera"
	state_broken_preset = null
	state_nopower_preset = null
	light_color = "#642850"
	network = list()
	var/team

/obj/machinery/computer/security/abductor_ag/attack_hand(mob/user)
	if(network.len < 1)
		to_chat(user, "<span class='notice'>Monitor network doesn't established. Activate helmet at first.</span>")
		return
	else
		..()

/obj/machinery/computer/security/abductor_hu
	name = "human observation monitor"
	desc = "Shows how subjects are living."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "camera_alt"
	state_broken_preset = null
	state_nopower_preset = null
	network = list("SS13", "SECURITY UNIT")
	light_color = "#642850"

/obj/machinery/computer/security/bodycam
	name = "bodycam monitoring computer"
	desc = "Used to access the security body cameras."
	icon_state = "laptop_security"
	state_broken_preset = "laptopb"
	state_nopower_preset = "laptop0"
	network = list("SECURITY UNIT")
	req_one_access = list(access_hos)

#undef DEFAULT_MAP_SIZE
