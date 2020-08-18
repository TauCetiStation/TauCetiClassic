//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/proc/invalidateCameraCache()
	for(var/obj/machinery/computer/security/s in computer_list)
		s.camera_cache = null
	for(var/datum/alarm/A in datum_alarm_list)
		A.cameras = list()

/obj/machinery/computer/security
	name = "security camera monitor"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"
	state_broken_preset = "securityb"
	state_nopower_preset = "security0"
	circuit = /obj/item/weapon/circuitboard/security
	light_color = "#a91515"
	var/obj/machinery/camera/current = null
	var/last_pic = 1.0
	var/list/network = list("SS13")
	var/mapping = 0//For the overview file, interesting bit of code.

	var/camera_cache = null

/obj/machinery/computer/security/check_eye(mob/user)
	if ((get_dist(user, src) > 1 || user.incapacitated() || user.blinded) && !issilicon(user) && !isobserver(user))
		return null
	if (!current || !current.can_use()) //camera doesn't work
		reset_current()
	var/list/viewing = viewers(src)
	if(isrobot(user) && !viewing.Find(user))
		return null
	user.reset_view(current)
	return 1

/obj/machinery/computer/security/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	if(stat & (NOPOWER|BROKEN)) return
	if(user.stat) return

	var/data[0]

	data["current"] = 0

	if(isnull(camera_cache))
		cameranet.process_sort()

		var/cameras[0]
		for(var/obj/machinery/camera/C in cameranet.cameras)
			if(!can_access_camera(C))
				continue

			var/cam = C.nano_structure()
			cameras[++cameras.len] = cam

			if(C == current)
				data["current"] = cam

		var/list/camera_list = list("cameras" = cameras)
		camera_cache = replacetext(json_encode(camera_list), "'", "`")
	else
		if(current)
			data["current"] = current.nano_structure()


	if(ui)
		ui.load_cached_data(camera_cache)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "sec_camera.tmpl", "Camera Console", 900, 600)

		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "sec_camera_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "sec_camera_map_header.tmpl")

		ui.load_cached_data(camera_cache)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/security/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["switchTo"])
		if(usr.blinded)
			return FALSE
		var/obj/machinery/camera/C = locate(href_list["switchTo"]) in cameranet.cameras
		if(!C)
			return FALSE
		switch_to_camera(usr, C)
	else if(href_list["reset"])
		if(usr.blinded)
			return FALSE
		reset_current()
		usr.check_eye(current)

/obj/machinery/computer/security/attack_ghost(mob/user) // this should not ever be opened to ghots, there is simply no point (even for admin) and also this thing eats up ALOT of resources.
	return

/obj/machinery/computer/security/attack_hand(mob/user)
	if (!network)
		world.log << "A computer lacks a network at [x],[y],[z]."
		return
	if (!istype(network, /list))
		world.log << "The computer at [x],[y],[z] has a network that is not a list!"
		return

	..()

/obj/machinery/computer/security/proc/can_access_camera(obj/machinery/camera/C)
	var/list/shared_networks = src.network & C.network
	if(shared_networks.len)
		return 1
	return 0

/obj/machinery/computer/security/proc/switch_to_camera(mob/user, obj/machinery/camera/C)
	//don't need to check if the camera works for AI because the AI jumps to the camera location and doesn't actually look through cameras.
	if(isAI(user))
		var/mob/living/silicon/ai/A = user
		// Only allow non-carded AIs to view because the interaction with the eye gets all wonky otherwise.
		if(!A.is_in_chassis())
			return 0

		A.eyeobj.setLoc(get_turf(C))
		A.client.eye = A.eyeobj
		return 1
	set_current(C)
	if(!check_eye(user))
		return 0
	use_power(50)
	return 1

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
		switch_to_camera(user,jump_to)

/obj/machinery/computer/security/proc/set_current(obj/machinery/camera/C)
	if(current == C)
		return

	if(current)
		reset_current()

	src.current = C
	if(current)
		var/mob/living/L = current.loc
		if(istype(L))
			L.tracking_initiated()

/obj/machinery/computer/security/proc/reset_current()
	if(current)
		var/mob/living/L = current.loc
		if(istype(L))
			L.tracking_cancelled()
	current = null

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
	density = 0

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

/obj/machinery/computer/security/mining
	name = "outpost camera monitor"
	desc = "Used to access the various cameras on the outpost."
	icon_state = "miningcameras"
	network = list("MINE")

/obj/machinery/computer/security/engineering
	name = "engineering camera monitor"
	desc = "Used to monitor fires and breaches."
	icon_state = "engineeringcameras"
	state_broken_preset = "powerb"
	state_nopower_preset = "power0"
	network = list("Engineering","Power Alarms","Atmosphere Alarms","Fire Alarms")
	light_color = "#b88b2e"

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
	network = list("SS13")
	light_color = "#642850"
