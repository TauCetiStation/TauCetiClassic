/datum/catastrophe_event/unknown_shuttle
	name = "Unknown shuttle"

	one_time_event = TRUE

	weight = 100

	event_type = "neutral"
	steps = 1

/datum/catastrophe_event/unknown_shuttle/on_step()
	switch(step)
		if(1)
			var/turf/space/T = find_spot()
			if(!T)
				return

			var/datum/map_template/unknown_shuttle/template = unknown_shuttle_templates[pick(unknown_shuttle_templates)]
			if(!template)
				return

			template.load(T, centered = TRUE)

			announce(CYRILLIC_EVENT_UNKNOWN_SHUTTLE_1)
			message_admins("Unknown shuttle was created in [T.x],[T.y],[T.z] [ADMIN_JMP(T)]")


/datum/catastrophe_event/unknown_shuttle/proc/find_spot()
	var/try_count = 0
	while(try_count < 20)
		try_count += 1

		var/turf/space/T = locate(rand(20, world.maxx - 20), rand(20, world.maxy - 20), ZLEVEL_STATION)
		if(!istype(T))
			continue

		var/good = TRUE
		for(var/turf/simulated/G in orange(20, T))
			good = FALSE
			break
		if(good)
			return T
	return null

/datum/map_template/unknown_shuttle
	var/shuttle_id

/datum/map_template/unknown_shuttle/proc/id()
	if(shuttle_id)
		return shuttle_id
	else
		return null

/datum/map_template/unknown_shuttle/shuttle1
	name = "Unknown Shuttle 1"
	shuttle_id = "unknown_shuttle1"
	mappath = "maps/templates/catastrophe/unknown_shuttles/shuttle1.dmm"

/datum/map_template/unknown_shuttle/shuttle2
	name = "Unknown Shuttle 2"
	shuttle_id = "unknown_shuttle2"
	mappath = "maps/templates/catastrophe/unknown_shuttles/shuttle2.dmm"

/datum/map_template/unknown_shuttle/shuttle3
	name = "Unknown Shuttle 3"
	shuttle_id = "unknown_shuttle3"
	mappath = "maps/templates/catastrophe/unknown_shuttles/shuttle3.dmm"

/datum/map_template/unknown_shuttle/shuttle4
	name = "Unknown Shuttle 4"
	shuttle_id = "unknown_shuttle4"
	mappath = "maps/templates/catastrophe/unknown_shuttles/shuttle4.dmm"