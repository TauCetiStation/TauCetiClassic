/datum/shuttle/autodock/ferry
	var/location = 0	//0 = at area_station, 1 = at area_offsite
	var/direction = 0	//0 = going to station, 1 = going to offsite.

	var/obj/effect/shuttle_landmark/waypoint_station
	var/obj/effect/shuttle_landmark/waypoint_offsite

/datum/shuttle/autodock/ferry/New(_name)
	if(waypoint_station)
		waypoint_station = locate(waypoint_station)
	if(waypoint_offsite)
		waypoint_offsite = locate(waypoint_offsite)

	..(_name, get_location_waypoint(location))

	next_location = get_location_waypoint(!location)

//Gets the shuttle landmark associated with the given location (defaults to current location)
/datum/shuttle/autodock/ferry/proc/get_location_waypoint(location_id = null)
	if (isnull(location_id))
		location_id = location

	if (!location_id)
		return waypoint_station
	return waypoint_offsite

/datum/shuttle/autodock/ferry/jump(jump_dist, obj/effect/shuttle_landmark/destination, obj/effect/shuttle_landmark/interim, travel_time)
	direction = !location
	..()

/datum/shuttle/autodock/ferry/post_move()
	..()
	location = (next_location == waypoint_station) ? 0 : 1

/datum/shuttle/autodock/ferry/process_arrived()
	..()
	next_location = get_location_waypoint(!location)
