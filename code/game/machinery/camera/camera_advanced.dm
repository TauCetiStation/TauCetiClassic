/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the station."
	icon_state = "cameras"

	circuit = /obj/item/weapon/circuitboard/camera_advanced
	light_color = "#a91515"

	var/lock_override = NONE
	var/list/z_lock = list() // Lock use to these z levels. Do not! set this directly, use lock_override flags

	var/mob/camera/Eye/remote/eyeobj
	var/mob/living/current_user = null

	var/list/networks = list("SS13")

	var/list/actions = list()
	var/datum/action/camera_off/off_action = new
	var/datum/action/camera_jump/jump_action = new

/obj/machinery/computer/camera_advanced/atom_init()
	. = ..()
	actions += off_action
	actions += jump_action
	if(lock_override)
		if(lock_override & CAMERA_LOCK_STATION)
			z_lock |= SSmapping.levels_by_trait(ZTRAIT_STATION)
		if(lock_override & CAMERA_LOCK_MINING)
			z_lock |= SSmapping.levels_by_trait(ZTRAIT_MINING)
		if(lock_override & CAMERA_LOCK_CENTCOM)
			z_lock |= SSmapping.levels_by_trait(ZTRAIT_CENTCOM)

/obj/machinery/computer/camera_advanced/Destroy()
	if(current_user)
		current_user.unset_machine()
		current_user = null
	QDEL_NULL(eyeobj)
	QDEL_NULL(off_action)
	QDEL_NULL(jump_action)
	actions.Cut()
	return ..()

/obj/machinery/computer/camera_advanced/proc/CreateEye()
	eyeobj = new()
	eyeobj.origin = src

/obj/machinery/computer/camera_advanced/proc/GrantActions(mob/living/user)
	if(off_action)
		off_action.target = user
		off_action.Grant(user)


	if(jump_action)
		jump_action.target = user
		jump_action.Grant(user)


/obj/machinery/computer/camera_advanced/proc/remove_eye_control(mob/living/user)
	if(!user)
		CRASH("Attempted to call remove_eye_control() proc with null user")
	for(var/V in actions)
		var/datum/action/A = V
		A.Remove(user)
	for(var/V in eyeobj.visibleCameraChunks)
		var/datum/camerachunk/C = V
		C.remove(eyeobj)
	if(user.client)
		user.reset_view(null)
		if(eyeobj.user_camera_icon && user.client)
			user.client.images -= eyeobj.user_image
	eyeobj.master = null
	user.remote_control = null

	current_user = null
	user.unset_machine()

/obj/machinery/computer/camera_advanced/check_eye(mob/user)
	if( (stat & (NOPOWER|BROKEN)) || (!Adjacent(user) && !user.has_unlimited_silicon_privilege) || user.eye_blind || user.incapacitated() )
		user.unset_machine()
		return FALSE
	return TRUE

/obj/machinery/computer/camera_advanced/on_unset_machine(mob/M)
	if(M == current_user)
		remove_eye_control(M)
	..()

/obj/machinery/computer/camera_advanced/interact(mob/user)
	user.machine = src
	var/mob/living/L = user
	if(!eyeobj)
		CreateEye()

	if(!eyeobj.eye_initialized)
		var/camera_location
		var/turf/myturf = get_turf(src)
		if(z_lock.len && !(myturf.z in z_lock))
			to_chat(user, "<span class='warning'>ERROR: system unable to access local camera network.</span>")
		else
			camera_location = myturf

		if(camera_location)
			eyeobj.eye_initialized = TRUE
			give_eye_control(L)
			eyeobj.setLoc(camera_location)
		else
			user.unset_machine()
	else
		give_eye_control(L)
		eyeobj.setLoc(eyeobj.loc)


/obj/machinery/computer/camera_advanced/attack_hand(mob/user)
	if(!is_operational())
		return
	if(current_user)
		to_chat(user, "<span class='warning'>The console is already in use!</span>")
		return
	..()

/obj/machinery/computer/camera_advanced/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/computer/camera_advanced/attack_ai(mob/user)
	return //AIs would need to disable their own camera procs to use the console safely. Bugs happen otherwise.

/obj/machinery/computer/camera_advanced/proc/give_eye_control(mob/user)
	GrantActions(user)
	current_user = user
	eyeobj.master = user
	eyeobj.name = "Camera Eye ([user.name])"
	user.remote_control = eyeobj
	user.reset_view(eyeobj)
	eyeobj.setLoc(eyeobj.loc)
	if(eyeobj.user_camera_icon && user.client)
		user.client.images += eyeobj.user_image

/mob/camera/Eye/remote
	name = "Inactive Camera Eye"
	var/obj/machinery/computer/camera_advanced/origin
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = FALSE
	var/eye_initialized = FALSE
	var/user_camera_icon = null		//How icon appears to user. If you want eye to be invisible to anyone but user, use this instead of "icon" variable.
	var/image/user_image = null
	var/allowed_area_type = null

/mob/camera/Eye/remote/atom_init()
	if(!user_image && user_camera_icon)
		user_image = image(icon = user_camera_icon,loc = src,icon_state = icon_state,layer = LIGHTING_LAYER+1)
	. = ..()

/mob/camera/Eye/remote/Destroy()
	if(origin && master)
		origin.remove_eye_control(master)
	origin = null
	master = null
	return ..()

/mob/camera/Eye/remote/relaymove(mob/user,direct)
	var/initial = initial(sprint)
	var/max_sprint = 50

	if(cooldown && cooldown < world.timeofday) // 3 seconds
		sprint = initial

	for(var/i = 0; i < max(sprint, initial); i += 20)
		var/turf/movement = get_step(src, direct)
		if(movement)
			setLoc(movement)

	cooldown = world.timeofday + 5
	if(acceleration)
		sprint = min(sprint + 0.5, max_sprint)
	else
		sprint = initial

/mob/camera/Eye/remote/setLoc(turf/T)
	if (allowed_area_type != null && !istype(get_area(T), allowed_area_type))
		return
	..()

/datum/action/camera_off
	name = "End Camera View"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "camera_off"
	action_type = AB_INNATE

/datum/action/camera_off/Activate()
	if(!target || !isliving(target))
		return
	var/mob/living/C = target
	var/mob/camera/Eye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/console = remote_eye.origin
	console.remove_eye_control(target)

/datum/action/camera_jump
	name = "Jump To Camera"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "camera_jump"
	action_type = AB_INNATE

/datum/action/camera_jump/Activate()
	if(!target || !isliving(target))
		return

	var/mob/living/C = target
	var/mob/camera/Eye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin

	var/list/L = list()

	for (var/obj/machinery/camera/cam in cameranet.cameras)
		if(origin.z_lock.len && !(cam.z in origin.z_lock))
			continue
		L.Add(cam)

	camera_sort(L)

	var/list/T = list()

	for (var/obj/machinery/camera/netcam in L)
		if (length(netcam.network & origin.networks))
			if (remote_eye.allowed_area_type != null && !istype(get_area(netcam), remote_eye.allowed_area_type))
				continue
			T["[netcam.c_tag][netcam.can_use() ? null : " (Deactivated)"]"] = netcam

	var/camera = input("Choose which camera you want to view", "Cameras") as null|anything in T
	var/obj/machinery/camera/final = T[camera]
	if(final)
		remote_eye.setLoc(get_turf(final))