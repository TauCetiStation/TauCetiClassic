#define OFFICER_SHUTTLE_MOVE_TIME 600
#define OFFICER_SHUTTLE_COOLDOWN 400


/obj/machinery/computer/officer_shuttle
	name = "Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	var/arrival_note = "" //arriving message
	var/department_note = "" //departing message
	var/obj/item/device/radio/intercom/radio
//	var/location = 0 // 0 - Velocity 1 - transit 2 - Exodus 3 - Centcomm
	var/moving = 0 //moving or not
	var/area/curr_location //current location
	var/area/from_area
	var/lastMove = 0


/obj/machinery/computer/officer_shuttle/New()
	curr_location= locate(/area/shuttle/officer/velocity)
	radio = new (src)

/obj/machinery/computer/officer_shuttle/proc/officer_move_to(area/destination as area)
	if(moving)	return
	if(lastMove + OFFICER_SHUTTLE_COOLDOWN > world.time)	return
	var/area/dest_location = locate(destination)
	if(curr_location == dest_location)	return

	from_area = curr_location
	moving = 1
	lastMove = world.time
	if(curr_location == locate(/area/shuttle/officer/station))
		radio.autosay(department_note, "Arrivals Alert System")
	var/area/transit_location = locate(/area/shuttle/officer/transit)
	curr_location.move_contents_to(transit_location, null, EAST)
	curr_location = transit_location
	if(from_area == locate(/area/shuttle/officer/velocity) && dest_location == locate(/area/shuttle/officer/centcomm))
		sleep(OFFICER_SHUTTLE_MOVE_TIME)
	else if(from_area == locate(/area/shuttle/officer/velocity) && dest_location == locate(/area/shuttle/officer/station))
		sleep(OFFICER_SHUTTLE_MOVE_TIME/2)
	else if(from_area == locate(/area/shuttle/officer/centcomm) && dest_location == locate(/area/shuttle/officer/velocity))
		sleep(OFFICER_SHUTTLE_MOVE_TIME)
	else if(from_area == locate(/area/shuttle/officer/centcomm) && dest_location == locate(/area/shuttle/officer/station))
		sleep(OFFICER_SHUTTLE_MOVE_TIME)
	else if(from_area == locate(/area/shuttle/officer/station) && dest_location == locate(/area/shuttle/officer/velocity))
		sleep(OFFICER_SHUTTLE_MOVE_TIME/2)
	else if(from_area == locate(/area/shuttle/officer/station) && dest_location == locate(/area/shuttle/officer/centcomm))
		sleep(OFFICER_SHUTTLE_MOVE_TIME)

	curr_location.move_contents_to(dest_location)
	if(dest_location == locate(/area/shuttle/officer/station))
		radio.autosay(arrival_note, "Arrivals Alert System")
	curr_location = dest_location

	moving = 0
	return 1

/obj/machinery/computer/officer_shuttle/attackby(obj/item/I as obj, mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/officer_shuttle/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/officer_shuttle/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/officer_shuttle/attack_hand(mob/user as mob)
	user.set_machine(src)

	var/dat = {"Location: [curr_location]<br>
	Ready to move[max(lastMove + OFFICER_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((lastMove + OFFICER_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
	<a href='?src=\ref[src];velocity=1'>NTS Velocity</a><br>
	<a href='?src=\ref[src];station=1'>NSS Exodus</a> |
	<a href='?src=\ref[src];centcomm=1'>Centcomm</a>
	<a href='?src=\ref[user];mach_close=computer'>Close</a>"}

	user << browse(dat, "window=computer;size=575x450")
	onclose(user, "computer")
	return

/obj/machinery/computer/officer_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["velocity"])
		officer_move_to(/area/shuttle/officer/velocity)
	else if(href_list["station"])
		officer_move_to(/area/shuttle/officer/station)
	else if(href_list["centcomm"])
		officer_move_to(/area/shuttle/officer/centcomm)

	updateUsrDialog()


/area/shuttle/officer
	name = "Officer Shuttle"

/area/shuttle/officer/velocity
	name = "NTS Velocity"
	icon_state = "shuttle2"

/area/shuttle/officer/transit
	icon_state = "shuttle"

/area/shuttle/officer/station
	name = "NSS Exodus"
	icon_state = "shuttle"

/area/shuttle/officer/centcomm
	name = "Centcomm"
	icon_state = "shuttle"
