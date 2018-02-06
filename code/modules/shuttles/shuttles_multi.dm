/datum/shuttle/autodock/multi
	var/list/destination_tags
	var/list/destinations_cache = list()
	var/last_cache_rebuild_time = 0


/datum/shuttle/autodock/multi/proc/set_destination(destination_key, mob/user)
	if(moving_status != SHUTTLE_IDLE)
		return
	next_location = destinations_cache[destination_key]

/datum/shuttle/autodock/multi/proc/get_destinations()
	if(last_cache_rebuild_time < SSshuttle.last_landmark_registration_time)
		build_destinations_cache()
	return destinations_cache

/datum/shuttle/autodock/multi/proc/build_destinations_cache()
	last_cache_rebuild_time = world.time
	destinations_cache.Cut()
	for(var/destination_tag in destination_tags)
		var/obj/effect/shuttle_landmark/landmark = SSshuttle.registered_shuttle_landmarks[destination_tag]
		if(istype(landmark))
			destinations_cache["[landmark.name]"] = landmark


//Antag play announcements when they leave/return to their home area
/datum/shuttle/autodock/multi/antag
	warmup_time = 3 //SECONDS

	var/obj/effect/shuttle_landmark/home_waypoint

	var/cloaked = TRUE
	var/announcer
	var/arrival_message
	var/departure_message
	var/return_warning = FALSE

/datum/shuttle/autodock/multi/antag/New()
	..()
	if(home_waypoint)
		home_waypoint = locate(home_waypoint)
	else
		home_waypoint = current_location

/datum/shuttle/autodock/multi/antag/post_move(destination)
	if(current_location == home_waypoint)
		announce_arrival()
	else if(next_location == home_waypoint)
		announce_departure()
	..()

/datum/shuttle/autodock/multi/antag/proc/announce_departure()
	if(cloaked || !departure_message || !announcer)
		return
	command_alert(departure_message, announcer)

/datum/shuttle/autodock/multi/antag/proc/announce_arrival()
	if(cloaked || !arrival_message || !announcer)
		return
	command_alert(arrival_message, announcer)

/datum/shuttle/autodock/multi/antag/set_destination(destination_key, mob/user)
	if(return_warning && destination_key == home_waypoint.name)
		to_chat(user, "<span class='danger'>Returning to your home base will end your mission. If you are sure, press the button again.</span>")
		return_warning = FALSE
		addtimer(CALLBACK(src, .proc/reset_warning), 10 SECONDS)
		return
	..()

/datum/shuttle/autodock/multi/antag/proc/reset_warning()
	return_warning = TRUE
