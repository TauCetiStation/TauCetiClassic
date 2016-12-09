#define MINE_SCI_SHUTTLE_COOLDOWN 150

#define STATION_DOCK /area/shuttle/mining/station
#define MINE_DOCK /area/shuttle/mining/outpost
#define SCI_DOCK /area/shuttle/research/outpost

#define M_S_SHUTTLE_FLOOR /turf/simulated/shuttle/floor/mining

var/global/obj/machinery/computer/mine_sci_shuttle/flight_comp/autopilot = null
var/global/area/mine_sci_curr_location = null

/obj/machinery/computer/mine_sci_shuttle
	name = "Mine-Science Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	circuit = /obj/item/weapon/circuitboard/mine_sci_shuttle

/obj/machinery/computer/mine_sci_shuttle/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/mine_sci_shuttle/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/computer/mine_sci_shuttle/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)

	var/dat
	if(autopilot)
		var/shuttle_location = "NSS Exodus"
		if(istype(autopilot.mine_sci_curr_location, MINE_DOCK))
			shuttle_location = "Mining Station"
		else if(istype(autopilot.mine_sci_curr_location, SCI_DOCK))
			shuttle_location = "Research Outpost"
		dat = {"Location: [shuttle_location]<br>
		Ready to move[max(autopilot.lastMove + MINE_SCI_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((autopilot.lastMove + MINE_SCI_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
		<a href='?src=\ref[src];mine=1'>Mining Station</a> |
		<a href='?src=\ref[src];station=1'>NSS Exodus</a> |
		<a href='?src=\ref[src];sci=1'>Research Outpost</a><br>
		<a href='?src=\ref[user];mach_close=flightcomputer'>Close</a>"}
	else
		dat = "Cannot find shuttle"

	user << browse(dat, "window=flightcomputer;size=575x450")
	onclose(user, "flightcomputer")
	return

/obj/machinery/computer/mine_sci_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(!autopilot)
		to_chat(usr, "\red Shuttle not found!")
		return FALSE
	if(autopilot.moving)
		to_chat(usr, "\blue Shuttle is already moving.")
		return FALSE

	var/result = FALSE
	if(href_list["mine"])
		result = autopilot.mine_sci_move_to(MINE_DOCK)
	else if(href_list["sci"])
		result = autopilot.mine_sci_move_to(SCI_DOCK)
	else if(href_list["station"])
		result = autopilot.mine_sci_move_to(STATION_DOCK)
	if(result)
		to_chat(usr, "\blue Shuttle recieved message and will be sent shortly.")

	updateUsrDialog()

//-------------------------------------------
//------------FLIGHT COMPUTER----------------
//-------------------------------------------

/obj/machinery/computer/mine_sci_shuttle/flight_comp
	name = "Shuttle Console"
	icon = 'code/modules/locations/shuttles/computer_shuttle_mining.dmi'
	var/area/mine_sci_curr_location
	var/moving = 0
	var/lastMove = 0

/obj/machinery/computer/mine_sci_shuttle/flight_comp/New()
	..()
	var/area/my_area = get_area(src)
	if(istype(get_turf(src),M_S_SHUTTLE_FLOOR) &&\
		   is_type_in_list(my_area,list(STATION_DOCK, MINE_DOCK, SCI_DOCK))) //if we build console not in shuttle area
		autopilot = src
		dir = WEST
		if(!mine_sci_curr_location)
			mine_sci_curr_location = my_area

/obj/machinery/computer/mine_sci_shuttle/flight_comp/Destroy()
	if(autopilot == src) //if we have more than one flight comp! (look imbossible)
		autopilot = null
	return ..()

/obj/machinery/computer/mine_sci_shuttle/flight_comp/proc/mine_sci_move_to(area/destination)
	if(moving)
		return FALSE
	if((lastMove + MINE_SCI_SHUTTLE_COOLDOWN) > world.time)
		return FALSE
	var/area/dest_location = locate(destination)
	if(mine_sci_curr_location == dest_location)
		return FALSE

	moving = TRUE
	lastMove = world.time
	addtimer(src, "mine_sci_do_move", MINE_SCI_SHUTTLE_COOLDOWN, TRUE, dest_location)
	return TRUE

/obj/machinery/computer/mine_sci_shuttle/flight_comp/proc/mine_sci_do_move(area/destination)
	if(moving)
		var/list/dstturfs = list()
		var/throwx = world.maxx

		for(var/turf/T in destination)
			dstturfs += T
			if(T.x < throwx)
				throwx = T.x

		// hey you, get out of the way!
		for(var/turf/T in dstturfs)
			// find the turf to move things to
			var/turf/D = locate(throwx - 1, T.y, T.z)
			for(var/atom/movable/AM as mob|obj in T)
				AM.Move(D)

			if(istype(T, /turf/simulated))
				qdel(T)

		for(var/mob/living/carbon/bug in destination) // If someone somehow is still in the shuttle's docking area...
			bug.gib()

		for(var/mob/living/simple_animal/pest in destination) // And for the other kind of bug...
			pest.gib()

		mine_sci_curr_location.move_contents_to(destination)

		for(var/mob/M in destination)
			if(M.client)
				spawn(0)
					if(M.buckled)
						shake_camera(M, 3, 1) // buckled, not a lot of shaking
					else
						shake_camera(M, 10, 1) // unbuckled, HOLY SHIT SHAKE THE ROOM
			if(istype(M, /mob/living/carbon))
				if(!M.buckled)
					M.Weaken(3)

		mine_sci_curr_location = destination
		moving = FALSE

#undef M_S_SHUTTLE_FLOOR

#undef MINE_SCI_SHUTTLE_COOLDOWN

#undef STATION_DOCK
#undef MINE_DOCK
#undef SCI_DOCK
