#define UPDATE_BUFFER 25 // 2.5 seconds

// CAMERA CHUNK (REMADE FOR HOMM)
//
// A 16x16 grid of the map with a list of turfs that can be seen, are visible and are dimmed.
// Allows the MAGIC EYE to stream these chunks and know what it can and cannot see.

/datum/camerachunk
	var/list/obscuredTurfs = list()
	var/list/visibleTurfs = list()
	var/list/obscured = list()
	var/list/cameras = list()
	var/list/turfs = list()
	var/list/seenby = list()
	var/visible = 0
	var/changed = 0
	var/updating = 0
	var/x = 0
	var/y = 0
	var/z = 0

// Add an eye to the chunk, then update if changed.

/datum/camerachunk/proc/add(mob/camera/treeofgreed/eye)
	if(!eye)
		return
	eye.visibleCameraChunks += src
	if(eye.client)
		eye.client.images += obscured
	visible++
	seenby += eye
	if(changed && !updating)
		update()

// Remove an eye from the chunk, then update if changed.

/datum/camerachunk/proc/remove(mob/camera/treeofgreed/eye)
	if(!eye)
		return
	eye.visibleCameraChunks -= src
	if(eye.client)
		eye.client.images -= obscured
	seenby -= eye
	if(visible > 0)
		visible--

// Called when a chunk has changed. I.E: A wall was deleted.

/datum/camerachunk/proc/visibilityChanged(turf/loc)
	if(!visibleTurfs[loc])
		return
	hasChanged()

// Updates the chunk, makes sure that it doesn't update too much. If the chunk isn't being watched it will
// instead be flagged to update the next time an Eye moves near it.

/datum/camerachunk/proc/hasChanged(update_now = 0)
	if(visible || update_now)
		if(!updating)
			updating = 1
			spawn(UPDATE_BUFFER) // Batch large changes, such as many doors opening or closing at once
				update()
				updating = 0
	else
		changed = 1

// The actual updating. It gathers the visible turfs from cameras and puts them into the appropiate lists.

/datum/camerachunk/proc/update()

	//set background = 1

	var/list/newVisibleTurfs = list()

	for(var/atom/camera in cameras)

		if(!camera)
			continue

		var/turf/point = locate(src.x + 8, src.y + 8, src.z)
		if(get_dist(point, camera) > 24)
			continue

		for(var/turf/t in hear(8, get_turf(camera)))
			newVisibleTurfs[t] = t


	// Removes turf that isn't in turfs.
	newVisibleTurfs &= turfs

	var/list/visAdded = newVisibleTurfs - visibleTurfs
	var/list/visRemoved = visibleTurfs - newVisibleTurfs

	visibleTurfs = newVisibleTurfs
	obscuredTurfs = turfs - newVisibleTurfs

	for(var/turf in visAdded)
		var/turf/t = turf
		if(t.obscured)
			obscured -= t.obscured
			for(var/mob/camera/treeofgreed/m in seenby)
				if(!m)
					continue
				if(m.client)
					m.client.images -= t.obscured

	for(var/turf in visRemoved)
		var/turf/t = turf
		if(obscuredTurfs[t])
			if(!t.obscured)
				t.obscured = image('icons/effects/cameravis.dmi', t, "black")
				t.obscured.plane = CAMERA_STATIC_PLANE

			obscured += t.obscured
			for(var/mob/camera/treeofgreed/m in seenby)
				if(!m)
					seenby -= m
					continue
				if(m.client)
					m.client.images += t.obscured

// Create a new camera chunk, since the chunks are made as they are needed.

/datum/camerachunk/New(loc, x, y, z)

	// 0xf = 15
	x &= ~0xf
	y &= ~0xf

	src.x = x
	src.y = y
	src.z = z

	for(var/obj/machinery/vending/lepr/LP in range(16, locate(x + 8, y + 8, z)))
		if(LP)
			cameras += LP
	for(var/obj/structure/tree_of_greed/tr in range(16, locate(x + 8, y + 8, z)))
		if(tr)
			cameras += tr
	for(var/mob/living/carbon/human/c in range(16, locate(x + 8, y + 8, z)))
		if(c)
			var/mob/living/carbon/human/H = c
			if(H.homm_species == "lepr")
				cameras += c

	for(var/turf/t in range(10, locate(x + 8, y + 8, z)))
		if(t.x >= x && t.y >= y && t.x < x + 16 && t.y < y + 16)
			turfs[t] = t

	for(var/atom/camera in cameras)
		if(!camera)
			continue
		for(var/turf/t in hear(8, get_turf(camera)))
			visibleTurfs[t] = t

	// Removes turf that isn't in turfs.
	visibleTurfs &= turfs

	obscuredTurfs = turfs - visibleTurfs

	for(var/turf in obscuredTurfs)
		var/turf/t = turf
		if(!t.obscured)
			t.obscured = image('icons/effects/cameravis.dmi', t, "black")
			t.obscured.plane = CAMERA_STATIC_PLANE
		obscured += t.obscured

#undef UPDATE_BUFFER
