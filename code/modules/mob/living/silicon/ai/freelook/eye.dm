// AI EYE
//
// A mob that the AI controls to look around the station with.
// It streams chunks as it moves around, which will show it what the AI can and cannot see.

/mob/camera/Eye
	name = "Inactive AI Eye"
	icon = 'icons/mob/AI.dmi'
	icon_state = "eye"
	alpha = 127
	var/list/visibleCameraChunks = list()
	var/mob/living/master = null
	invisibility = INVISIBILITY_AI_EYE
	var/image/ghostimage = null

/mob/camera/Eye/ai
	var/mob/living/silicon/ai/ai = null

/mob/camera/Eye/ai/atom_init()
	. = ..()
	ai_eyes_list += src

/mob/camera/Eye/ai/Destroy()
	ai_eyes_list -= src
	ai = null
	return ..()

/mob/camera/Eye/atom_init()
	ghostimage = image(src.icon,src,src.icon_state)
	ghost_darkness_images |= ghostimage //so ghosts can see the AI eye when they disable darkness
	ghost_sightless_images |= ghostimage //so ghosts can see the AI eye when they disable ghost sight
	updateallghostimages()
	. = ..()

/mob/camera/Eye/Destroy()
	if (ghostimage)
		ghost_darkness_images -= ghostimage
		ghost_sightless_images -= ghostimage
		qdel(ghostimage)
		ghostimage = null
		updateallghostimages()
	master = null
	return ..()

// Movement code. Returns 0 to stop air movement from moving it.
/mob/camera/Eye/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	return FALSE

// Hide popout menu verbs
/mob/camera/Eye/examinate(atom/A as mob|obj|turf in view())
	set popup_menu = 0
	set src = usr.contents
	return 0

/mob/camera/Eye/pointed()
	set popup_menu = 0
	set src = usr.contents
	return 0

// Use this when setting the aiEye's location.
// It will also stream the chunk that the new loc is in.

/mob/camera/Eye/setLoc(T)
	if(master)
		T = get_turf(T)
		loc = T
		cameranet.visibility(src)
		if(master.client)
			master.client.eye = src
		update_parallax_contents()
		return 1

/mob/camera/Eye/ai/setLoc(T)
	if(..() && ai && ai.holo && isturf(ai.loc))
		ai.holo.move_hologram()

/mob/camera/Eye/proc/getLoc()
	if(isturf(loc))
		return loc

// AI MOVEMENT
// Intiliaze the eye by assigning it's "ai" variable to us. Then set it's loc to us.
/mob/living/silicon/ai/proc/create_eye()
	if(eyeobj)
		return
	eyeobj = new()
	eyeobj.master = src
	eyeobj.ai = src
	eyeobj.setLoc(loc)
	eyeobj.name = "[src.name] (AI Eye)" // Give it a name

/mob/living/silicon/ai/Destroy()
	if(eyeobj)
		eyeobj.master = null
		eyeobj.ai = null
		qdel(eyeobj) // No AI, no Eye
		eyeobj = null
	return ..()

/atom/proc/move_camera_by_click()
	if(istype(usr, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = usr
		if(AI.eyeobj && AI.client.eye == AI.eyeobj)
			AI.cameraFollow = null
			AI.eyeobj.setLoc(src)

// This will move the AIEye. It will also cause lights near the eye to light up, if toggled.
// This is handled in the proc below this one.

/client/proc/AIMove(n, direct, mob/living/silicon/ai/user)		//Needs to be removed in favor of remote_control and relaymove()

	var/initial = initial(user.sprint)
	var/max_sprint = 50

	if(user.cooldown && user.cooldown < world.timeofday) // 3 seconds
		user.sprint = initial

	for(var/i = 0; i < max(user.sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(user.eyeobj, direct))
		if(step)
			user.eyeobj.setLoc(step)

	user.cooldown = world.timeofday + 5
	if(user.acceleration)
		user.sprint = min(user.sprint + 0.5, max_sprint)
	else
		user.sprint = initial

	user.cameraFollow = null

	//user.unset_machine() //Uncomment this if it causes problems.
	//user.lightNearbyCamera()


// Return to the Core.

/mob/living/silicon/ai/proc/view_core()
	camera = null
	cameraFollow = null
	unset_machine()

	if(eyeobj && loc)
		eyeobj.loc = loc
	else
		to_chat(src, "ERROR: Eyeobj not found. Creating new eye...")
		eyeobj = new(src.loc)
		eyeobj.master = src
		eyeobj.ai = src
		eyeobj.name = "[src.name] (AI Eye)" // Give it a name

	if(client && client.eye)
		client.eye = src
	for(var/datum/camerachunk/c in eyeobj.visibleCameraChunks)
		c.remove(eyeobj)

/mob/living/silicon/ai/proc/toggle_acceleration()
	set category = "AI Commands"
	set name = "Toggle Camera Acceleration"

	acceleration = !acceleration
	to_chat(usr, "Camera acceleration has been toggled [acceleration ? "on" : "off"].")
