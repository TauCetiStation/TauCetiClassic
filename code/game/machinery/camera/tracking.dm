/mob/living/silicon/ai
	var/max_locations = 5
	var/list/stored_locations = list()

/mob/living/silicon/ai/proc/InvalidTurf(turf/T)
	if(!T)
		return 1
	if(is_centcom_level(T.z))
		return 1
	if(!SSmapping.has_level(T.z))
		return 1
	return 0

/mob/living/silicon/ai/proc/get_camera_list()

	if(src.stat == DEAD)
		return

	var/list/L = list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		L.Add(C)

	camera_sort(L)

	var/list/T = list()
	T["Cancel"] = "Cancel"
	for (var/obj/machinery/camera/C in L)
		var/list/tempnetwork = C.network&src.network
		if (tempnetwork.len)
			T[text("[][]", C.c_tag, (C.can_use() ? null : " (Deactivated)"))] = C

	track = new()
	track.cameras = T
	return T


/mob/living/silicon/ai/proc/ai_camera_list(camera in get_camera_list())

	if(uses_legs)
		to_chat(src, "Not in mobility mode.")
		return

	if(src.stat == DEAD)
		to_chat(src, "You can't list the cameras because you are dead!")
		return

	if (!camera || camera == "Cancel")
		return 0

	var/obj/machinery/camera/C = track.cameras[camera]
	track = null
	eyeobj.setLoc(C)

	return

/mob/living/silicon/ai/proc/ai_store_location(loc as text)
	set category = "AI Commands"
	set name = "Store Camera Location"
	set desc = "Stores your current camera location by the given name."

	if(stored_locations.len >= max_locations)
		to_chat(src, "<span class='warning'>Cannot store additional locations. Remove one first</span>")
		return

	loc = trim(loc)
	if(!loc)
		to_chat(src, "<span class='warning'>Must supply a location name</span>")
		return

	if(loc in stored_locations)
		to_chat(src, "<span class='warning'>There is already a stored location by this name</span>")
		return

	var/L = eyeobj.getLoc()
	if (InvalidTurf(get_turf(L)))
		to_chat(src, "<span class='warning'>Unable to store this location</span>")
		return

	stored_locations[loc] = L
	to_chat(src, "Location '[loc]' stored")

/mob/living/silicon/ai/proc/sorted_stored_locations()
	return sortList(stored_locations)

/mob/living/silicon/ai/proc/ai_goto_location(loc in sorted_stored_locations())
	set category = "AI Commands"
	set name = "Goto Camera Location"
	set desc = "Returns to the selected camera location."

	if (!(loc in stored_locations))
		to_chat(src, "<span class='warning'>Location [loc] not found</span>")
		return

	var/L = stored_locations[loc]
	eyeobj.setLoc(L)

/mob/living/silicon/ai/proc/ai_remove_location(loc in sorted_stored_locations())
	set category = "AI Commands"
	set name = "Delete Camera Location"
	set desc = "Deletes the selected camera location."

	if (!(loc in stored_locations))
		to_chat(src, "<span class='warning'>Location [loc] not found</span>")
		return

	stored_locations.Remove(loc)
	to_chat(src, "Location [loc] removed")

// Used to allow the AI is write in mob names/camera name from the CMD line.
/datum/trackable
	var/list/names = list()
	var/list/namecounts = list()
	var/list/humans = list()
	var/list/others = list()
	var/list/cameras = list()

/mob/living/silicon/ai/proc/trackable_mobs()

	if(usr.stat == DEAD)
		return list()

	var/datum/trackable/TB = new()
	for(var/mob/living/M as anything in living_list)
		// Easy checks first.
		// Don't detect mobs on Centcom. Since the wizard den is on Centcomm, we only need this.
		if(InvalidTurf(get_turf(M)))
			continue
		if(M == usr)
			continue
		if(M.invisibility)//cloaked
			continue
		if(SEND_SIGNAL(M, COMSIG_LIVING_CAN_TRACK) & COMPONENT_CANT_TRACK)
			continue

		 // Now, are they viewable by a camera? (This is last because it's the most intensive check)
		if(!near_camera(M))
			continue

		// Human check
		var/human = ishuman(M) ? TRUE : FALSE

		var/name = M.name
		if (name in TB.names)
			TB.namecounts[name]++
			name = text("[] ([])", name, TB.namecounts[name])
		else
			TB.names.Add(name)
			TB.namecounts[name] = 1
		if(human)
			TB.humans[name] = M
		else
			TB.others[name] = M

	var/list/targets = list()
	targets.Add("Cancel")
	targets.Add(sortList(TB.humans) + sortList(TB.others))
	src.track = TB
	return targets

/mob/living/silicon/ai/proc/ai_camera_track(target_name in trackable_mobs())

	if(src.stat == DEAD)
		to_chat(src, "You can't track with camera because you are dead!")
		return
	if(target_name == "Cancel")
		return 0
	if(!target_name)
		src.cameraFollow = null

	var/mob/target = (isnull(track.humans[target_name]) ? track.others[target_name] : track.humans[target_name])

	src.track = null
	ai_actual_track(target)

/mob/living/silicon/ai/proc/ai_cancel_tracking(forced = 0)
	if(!cameraFollow)
		return

	to_chat(src, "Follow camera mode [forced ? "terminated" : "ended"].")
	cameraFollow.tracking_cancelled()
	cameraFollow = null

/mob/living/silicon/ai/proc/ai_actual_track(mob/living/target)
	if(!istype(target) || uses_legs)	return
	var/mob/living/silicon/ai/U = usr

	U.cameraFollow = target
	to_chat(U, "Now tracking [target.name] on camera.")
	target.tracking_initiated()

	spawn (0)
		while (U.cameraFollow == target)
			if (U.cameraFollow == null)
				return
			if(SEND_SIGNAL(target, COMSIG_LIVING_CAN_TRACK) & COMPONENT_CANT_TRACK)
				to_chat(U, "Follow camera mode terminated.")
				return

			if(istype(target.loc,/obj/effect/dummy))
				to_chat(U, "Follow camera mode ended.")
				U.cameraFollow = null
				return

			if (!near_camera(target))
				to_chat(U, "Target is not near any active cameras.")
				sleep(100)
				continue

			if(U.eyeobj)
				U.eyeobj.setLoc(get_turf(target))
			else
				view_core()
				return
			sleep(10)

/proc/near_camera(mob/living/M)
	if (!isturf(M.loc))
		return 0
	if(isrobot(M))
		var/mob/living/silicon/robot/R = M
		if(!(R.camera && R.camera.can_use()) && !cameranet.checkCameraVis(M))
			return 0
	else if(!cameranet.checkCameraVis(M))
		return 0
	return 1

/obj/machinery/camera/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	if (!can_use() || user.uses_legs)
		return
	user.eyeobj.setLoc(get_turf(src))


/mob/living/silicon/ai/attack_ai(mob/user)
	ai_camera_list()

/proc/camera_sort(list/L)
	var/obj/machinery/camera/a
	var/obj/machinery/camera/b

	for (var/i = L.len, i > 0, i--)
		for (var/j = 1 to i - 1)
			a = L[j]
			b = L[j + 1]
			if (a.c_tag_order != b.c_tag_order)
				if (a.c_tag_order > b.c_tag_order)
					L.Swap(j, j + 1)
			else
				if (sorttext(a.c_tag, b.c_tag) < 0)
					L.Swap(j, j + 1)
	return L

/mob/living/proc/tracking_initiated()

/mob/living/silicon/robot/tracking_initiated()
	tracking_entities++
	if(tracking_entities == 1 && has_zeroth_law())
		to_chat(src, "<span class='warning'>Internal camera is currently being accessed.</span>")

/mob/living/proc/tracking_cancelled()

/mob/living/silicon/robot/tracking_initiated()
	tracking_entities--
	if(!tracking_entities && has_zeroth_law())
		to_chat(src, "<span class='notice'>Internal camera is no longer being accessed.</span>")
