#define LABOR_SHUTTLE_COOLDOWN 150
#define LABOR_SHUTTLE_MOVE_TIME 40

#define STATION_DOCK /area/shuttle/labor/station
#define CAMP_DOCK /area/shuttle/labor/camp

#define LABOR_SHUTTLE_FLOOR /turf/simulated/shuttle/floor/labor

var/global/obj/machinery/computer/labor_shuttle/flight_comp/labor_pilot = null
var/global/area/asteroid/labor_curr_location = null

/obj/machinery/computer/labor_shuttle
	name = "Labor Camp Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	state_broken_preset = "commb"
	state_nopower_preset = "comm0"
	circuit = /obj/item/weapon/circuitboard/labor_shuttle

	var/lastMove = 0

/obj/machinery/computer/labor_shuttle/process()
	if(..())
		if(lastMove + LABOR_SHUTTLE_MOVE_TIME + LABOR_SHUTTLE_COOLDOWN + 20 >= world.time)
			updateUsrDialog()

/obj/machinery/computer/labor_shuttle/ui_interact(mob/user)
	var/dat
	if(labor_pilot)
		var/shuttle_location = station_name()
		if(istype(labor_pilot.labor_curr_location, CAMP_DOCK))
			shuttle_location = "Labor Camp"
		dat += "<ul><li>Location: [shuttle_location]</li>"
		dat += {"<li>Ready to move[max(labor_pilot.lastMove + LABOR_SHUTTLE_MOVE_TIME + LABOR_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((labor_pilot.lastMove + LABOR_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]</li>"}
		dat += "</ul>"
		dat += "<a href='?src=\ref[src];camp=1'>Labor Camp</a> |"
		dat += "<a href='?src=\ref[src];station=1'>[station_name()]</a> |"
	else
		dat = "Cannot find shuttle"

	var/datum/browser/popup = new(user, "flightcomputer", "[src.name]", 365, 200)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/labor_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!labor_pilot)
		to_chat(usr, "<span class='warning'>Shuttle not found!</span>")
		return FALSE
	if(labor_pilot.moving)
		to_chat(usr, "<span class='notice'>Shuttle is already moving.</span>")
		return FALSE

	var/result = FALSE
	if(href_list["camp"])
		result = labor_pilot.labor_move_to(CAMP_DOCK)
	else if(href_list["station"])
		result = labor_pilot.labor_move_to(STATION_DOCK)
	if(result)
		lastMove = world.time
		to_chat(usr, "<span class='notice'>Shuttle recieved message and will be sent shortly.</span>")

	updateUsrDialog()

//-------------------------------------------
//------------FLIGHT COMPUTER----------------
//-------------------------------------------

/obj/machinery/computer/labor_shuttle/flight_comp
	name = "Shuttle Console"
	icon = 'icons/locations/shuttles/computer_shuttle_mining.dmi'
	state_broken_preset = null
	state_nopower_preset = null
	circuit = /obj/item/weapon/circuitboard/labor_shuttle/flight_comp
	var/area/asteroid/labor_curr_location
	var/moving = 0
	lastMove = 0

/obj/machinery/computer/labor_shuttle/flight_comp/atom_init()
	. = ..()
	var/area/my_area = get_area(src)
	if(istype(get_turf(src),LABOR_SHUTTLE_FLOOR) &&\
		   is_type_in_list(my_area, list(STATION_DOCK, CAMP_DOCK))) //if we build console not in shuttle area
		labor_pilot = src
		set_dir(WEST)
		if(!labor_curr_location)
			labor_curr_location = my_area

/obj/machinery/computer/labor_shuttle/flight_comp/process()
	if(..())
		if(lastMove + LABOR_SHUTTLE_COOLDOWN + 20 >= world.time)
			updateUsrDialog()

/obj/machinery/computer/labor_shuttle/flight_comp/Destroy()
	if(labor_pilot == src) //if we have more than one flight comp! (look imbossible)
		labor_pilot = null
	return ..()

/obj/machinery/computer/labor_shuttle/flight_comp/proc/labor_move_to(area/destination)
	if(moving)
		return FALSE
	if((lastMove + LABOR_SHUTTLE_COOLDOWN) > world.time)
		return FALSE
	var/area/dest_location = locate(destination)
	if(labor_curr_location == dest_location)
		return FALSE

	moving = TRUE
	lastMove = world.time
	addtimer(CALLBACK(src, .proc/labor_do_move, dest_location), LABOR_SHUTTLE_COOLDOWN, TIMER_UNIQUE)
	return TRUE

/obj/machinery/computer/labor_shuttle/flight_comp/proc/labor_do_move(area/destination)
	if(moving)
		var/area/transit_location = locate(/area/shuttle/labor/transit)

		if(istype(labor_curr_location, STATION_DOCK))
			SSshuttle.undock_act(/area/station/security/processing, "stat_dock")
			SSshuttle.undock_act(labor_curr_location)
		else if(istype(labor_curr_location, CAMP_DOCK))
			SSshuttle.undock_act(/area/asteroid/labor/camp, "camp_dock")
			SSshuttle.undock_act(labor_curr_location)

		transit_location.parallax_movedir = NORTH
		labor_curr_location.move_contents_to(transit_location)
		SSshuttle.shake_mobs_in_area(transit_location, SOUTH)

		sleep(LABOR_SHUTTLE_MOVE_TIME)
		transit_location.parallax_slowdown()
		sleep(PARALLAX_LOOP_TIME)

		SSshuttle.clean_arriving_area(destination)

		transit_location.move_contents_to(destination)

		SSshuttle.shake_mobs_in_area(destination, NORTH)

		if(istype(destination, STATION_DOCK))
			SSshuttle.dock_act(/area/station/security/processing, "stat_dock")
			SSshuttle.dock_act(destination)
		else if(istype(destination, CAMP_DOCK))
			SSshuttle.dock_act(/area/asteroid/labor/camp, "camp_dock")
			SSshuttle.dock_act(destination)

		labor_curr_location = destination
		moving = FALSE

#undef LABOR_SHUTTLE_FLOOR

#undef LABOR_SHUTTLE_COOLDOWN

#undef STATION_DOCK
#undef CAMP_DOCK
