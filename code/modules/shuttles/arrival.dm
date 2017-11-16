#define ARRIVAL_SHUTTLE_MOVE_TIME 20
#define ARRIVAL_SHUTTLE_COOLDOWN 25

//Arrival Shuttle
/obj/machinery/computer/shuttle_control/arrival
	name = "Arrival Shuttle Console"
	icon_state = "wagon"
	shuttle_tag = "Arrival Shuttle"

//Shuttle datum
/datum/shuttle/autodock/ferry/arrival
	name = "Arrival Shuttle"
	location = 1
	warmup_time = 10
	shuttle_area = /area/shuttle/arrival/pre_game
	dock_target = "arrival_shuttle"
	waypoint_station = "nav_arrival_start"
	waypoint_offsite = "nav_arrival_out"
	landmark_transition = "nav_arrival_inter"
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

/datum/shuttle/autodock/ferry/arrival/proc/try_move_from_station()
	if(moving_status != SHUTTLE_IDLE || location)
		return
	for(var/check_area in shuttle_area)
		if(SSshuttle.forbidden_atoms_check(check_area))
			addtimer(CALLBACK(src, .proc/try_move_from_station), 600)
			return
	launch(src) //Yes, we use ourself

/datum/shuttle/autodock/ferry/arrival/pre_move(obj/effect/shuttle_landmark/destination)
	..()
	var/dest_is_trans = destination == landmark_transition
	for(var/area/s_area in shuttle_area)
		s_area.parallax_movedir = dest_is_trans ? WEST : 0
		if(dest_is_trans)
			for(var/obj/machinery/light/small/L in s_area)
				L.brightness_color = initial(L.brightness_color)
				L.color = initial(L.color)
				L.update(0)

	if(direction && dest_is_trans) //Moving from station
		announcer.autosay(department_note, "Arrivals Alert System")

/datum/shuttle/autodock/ferry/arrival/post_move(obj/effect/shuttle_landmark/destination)
	..()
	if(destination == landmark_transition)
		for(var/area/s_area in shuttle_area)
			addtimer(CALLBACK(s_area, /area.proc/parallax_slowdown), ARRIVAL_SHUTTLE_MOVE_TIME*10 - PARALLAX_LOOP_TIME)

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

//Shuttle onboard controller
/obj/machinery/embedded_controller/radio/simple_docking_controller/arrival/shuttle
	id_tag = "arrival_shuttle"

//Station dock
/obj/effect/shuttle_landmark/arrival/start
	name = "Station"
	landmark_tag = "nav_arrival_start"
	docking_controller = "arrival_dock"

/obj/machinery/embedded_controller/radio/docking_port_multi/arrival/station
	id_tag = "arrival_dock"
	child_tags_txt = "arrival_dock1;arrival_dock2"
	child_names_txt = "Airlock 1 ;Airlock 2 "

/obj/machinery/embedded_controller/radio/airlock/docking_port_multi/arrival/slave1
	id_tag = "arrival_dock1"
	master_tag = "arrival_dock"

/obj/machinery/embedded_controller/radio/airlock/docking_port_multi/arrival/slave2
	id_tag = "arrival_dock2"
	master_tag = "arrival_dock"

//Offsite dock
/obj/effect/shuttle_landmark/arrival/out
	name = "Velocity"
	landmark_tag = "nav_arrival_out"
	docking_controller = "arrival_velocity"

/obj/machinery/embedded_controller/radio/simple_docking_controller/arrival/velocity
	id_tag = "arrival_velocity"

/obj/effect/shuttle_landmark/arrival/inter
	name = "Transit Area"
	landmark_tag = "nav_arrival_inter"

#undef ARRIVAL_SHUTTLE_MOVE_TIME
#undef ARRIVAL_SHUTTLE_COOLDOWN
