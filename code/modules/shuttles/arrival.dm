#define ARRIVAL_SHUTTLE_MOVE_TIME 20 //seconds
#define ARRIVAL_SHUTTLE_COOLDOWN 25 //seconds

//Arrival Shuttle
/obj/machinery/computer/shuttle_control/arrival
	name = "Arrival Shuttle Console"
	icon_state = "wagon"
	shuttle_tag = "Arrival Shuttle"

//Shuttle datum
/datum/shuttle/autodock/ferry/arrival
	name = "Arrival Shuttle"
	location = SHUTTLE_LOCATION_OFFSITE
	warmup_time = 10 //seconds
	shuttle_area = /area/shuttle/arrival
	dock_target = "arrival_shuttle"
	waypoint_station = "nav_arrival_station"
	waypoint_offsite = "nav_arrival_velocity"
	landmark_transition = "nav_arrival_trans"
	transition_parallax_movedir = WEST
	move_time = ARRIVAL_SHUTTLE_MOVE_TIME
	move_cooldown = ARRIVAL_SHUTTLE_COOLDOWN
	var/obj/item/device/radio/intercom/announcer
	var/arrival_note = "Arrival shuttle docked with the NSS Exodus."
	var/department_note = "Arrival shuttle left the NSS Exodus."

/datum/shuttle/autodock/ferry/arrival/New(_name, obj/effect/shuttle_landmark/start_waypoint)
	..()
	announcer = new ()

/datum/shuttle/autodock/ferry/arrival/Destroy()
	QDEL_NULL(announcer)
	return ..()

/datum/shuttle/autodock/ferry/arrival/can_launch()
	. = ..()
	if(!. || location)
		return
	for(var/check_area in shuttle_area)
		if(SSshuttle.forbidden_atoms_check(check_area))
			return FALSE

/datum/shuttle/autodock/ferry/arrival/proc/try_move_from_station()
	if(location)
		return
	if(!launch(src)) //Yes, we use ourself
		addtimer(CALLBACK(src, .proc/try_move_from_station), 600)

/datum/shuttle/autodock/ferry/arrival/pre_move(obj/effect/shuttle_landmark/destination)
	..()
	if(destination == landmark_transition)
		for(var/area/s_area in shuttle_area)
			for(var/obj/machinery/light/small/L in s_area)
				L.brightness_color = initial(L.brightness_color)
				L.color = initial(L.color)
				L.update(0)

		if(direction) //Moving from station
			announcer.autosay(department_note, "Arrivals Alert System")

/datum/shuttle/autodock/ferry/arrival/arrived()
	..()
	if(!location) //Arrived at station
		announcer.autosay(arrival_note, "Arrivals Alert System")
		addtimer(CALLBACK(src, .proc/try_move_from_station), 600)

/datum/shuttle/autodock/ferry/arrival/launch_initiated()
	..()
	for(var/area/s_area in shuttle_area)
		for(var/obj/machinery/light/small/L in s_area)
			L.brightness_color = "#00ff00"
			L.color = "#00ff00"
			L.update(0)

/*
Tags:
	shuttle:
		simple_docking_controller:
			id_tag: "arrival_shuttle"
			name: "Arrival Shuttle Docking Port Controller"

	velocity dock:
		simple_docking_controller:
			id_tag: "arrival_velocity"
			name: "Arrival Shuttle Docking Port Controller"

	station dock:
		docking_port_multi:
			child_tags_txt: "arrival_dock1;arrival_dock2"
			id_tag: "arrival_dock"
			name: "Arrival Shuttle Docking Port Controller"
		airlock/docking_port_multi_slave: (west)
			master_tag: "arrival_dock"
			id_tag: "arrival_dock1"
			name: "Arrival Shuttle Docking Port Controller #1"
		airlock/docking_port_multi_slave: (east)
			master_tag: "arrival_dock"
			id_tag: "arrival_dock2"
			name: "Arrival Shuttle Docking Port Controller #2"
*/

//Station dock
/obj/effect/shuttle_landmark/arrival/start
	name = "Station"
	landmark_tag = "nav_arrival_station"
	docking_controller = "arrival_dock"

/obj/effect/shuttle_landmark/arrival/velocity
	name = "Velocity"
	landmark_tag = "nav_arrival_velocity"
	docking_controller = "arrival_velocity"

/obj/effect/shuttle_landmark/arrival/transition
	name = "Transit Area"
	landmark_tag = "nav_arrival_trans"

#undef ARRIVAL_SHUTTLE_MOVE_TIME
#undef ARRIVAL_SHUTTLE_COOLDOWN
