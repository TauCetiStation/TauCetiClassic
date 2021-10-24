#define OFFICER_SHUTTLE_MOVE_TIME 600
#define OFFICER_SHUTTLE_COOLDOWN 400


/obj/machinery/computer/officer_shuttle
	name = "Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	var/department_note = "Velocity transport shuttle departed from station."
	var/arrival_note = "Velocity Transport Shuttle docked with the station."
	var/obj/item/device/radio/intercom/radio
	var/moving = 0
	var/area/curr_location
	var/area/from_area
	var/lastMove = 0


/obj/machinery/computer/officer_shuttle/atom_init()
	radio = new (src)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/officer_shuttle/atom_init_late()
	curr_location = locate(/area/shuttle/officer/velocity)

/obj/machinery/computer/officer_shuttle/proc/officer_move_to(area/destination)
	if(moving)	return
	if(lastMove + OFFICER_SHUTTLE_COOLDOWN > world.time)	return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)	return

	from_area = curr_location
	moving = 1
	lastMove = world.time

	if(curr_location == locate(/area/shuttle/officer/station))
		SSshuttle.undock_act(/area/station/hallway/secondary/entry, "arrival_officer")
		SSshuttle.undock_act(curr_location, "arrival_officer")
		radio.autosay(department_note, "Arrivals Alert System")
	else if(curr_location == locate(/area/shuttle/officer/velocity))
		SSshuttle.undock_act(/area/velocity, "velocity_officer")
		SSshuttle.undock_act(curr_location, "arrival_officer")
	else if(curr_location == locate(/area/shuttle/officer/centcom))
		SSshuttle.undock_act(/area/centcom/evac, "centcomm_officer")
		SSshuttle.undock_act(curr_location, "arrival_officer")

	var/area/transit_location = locate(/area/shuttle/officer/transit)
	transit_location.parallax_movedir = WEST
	curr_location.move_contents_to(transit_location)
	curr_location = transit_location
	SSshuttle.shake_mobs_in_area(transit_location, WEST)

	if(from_area == locate(/area/shuttle/officer/velocity) && dest_location == locate(/area/shuttle/officer/centcom))
		sleep(OFFICER_SHUTTLE_MOVE_TIME)
	else if(from_area == locate(/area/shuttle/officer/velocity) && dest_location == locate(/area/shuttle/officer/station))
		sleep(OFFICER_SHUTTLE_MOVE_TIME/2)
	else if(from_area == locate(/area/shuttle/officer/centcom) && dest_location == locate(/area/shuttle/officer/velocity))
		sleep(OFFICER_SHUTTLE_MOVE_TIME)
	else if(from_area == locate(/area/shuttle/officer/centcom) && dest_location == locate(/area/shuttle/officer/station))
		sleep(OFFICER_SHUTTLE_MOVE_TIME)
	else if(from_area == locate(/area/shuttle/officer/station) && dest_location == locate(/area/shuttle/officer/velocity))
		sleep(OFFICER_SHUTTLE_MOVE_TIME/2)
	else if(from_area == locate(/area/shuttle/officer/station) && dest_location == locate(/area/shuttle/officer/centcom))
		sleep(OFFICER_SHUTTLE_MOVE_TIME)

	curr_location.move_contents_to(dest_location)
	SSshuttle.shake_mobs_in_area(dest_location, WEST)

	if(dest_location == locate(/area/shuttle/officer/station))
		SSshuttle.dock_act(/area/station/hallway/secondary/entry, "arrival_officer")
		SSshuttle.dock_act(dest_location, "arrival_officer")
		radio.autosay(arrival_note, "Arrivals Alert System")
	else if(dest_location == locate(/area/shuttle/officer/velocity))
		SSshuttle.dock_act(/area/velocity, "velocity_officer")
		SSshuttle.dock_act(dest_location, "arrival_officer")
	else if(dest_location == locate(/area/shuttle/officer/centcom))
		SSshuttle.dock_act(/area/centcom/evac, "centcomm_officer")
		SSshuttle.dock_act(dest_location, "arrival_officer")

	curr_location = dest_location

	moving = 0
	return 1

/obj/machinery/computer/officer_shuttle/attackby(obj/item/I, mob/user)
	return attack_hand(user)

/obj/machinery/computer/officer_shuttle/ui_interact(mob/user)
	var/dat = {"Location: [curr_location]<br>
			Ready to move[max(lastMove + OFFICER_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + OFFICER_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
		<a href='?src=\ref[src];velocity=1'>NTS Velocity</a> |
		<a href='?src=\ref[src];station=1'>[station_name()]</a> |
		<a href='?src=\ref[src];centcomm=1'>Centcomm</a><br>"}

	var/datum/browser/popup = new(user, "computer", "[src.name]", 575, 450)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/officer_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["velocity"])
		officer_move_to(/area/shuttle/officer/velocity)
	else if(href_list["station"])
		officer_move_to(/area/shuttle/officer/station)
	else if(href_list["centcomm"])
		officer_move_to(/area/shuttle/officer/centcom)

	updateUsrDialog()
