#define MINE_SCI_SHUTTLE_COOLDOWN 150

#define STATION_DOCK /area/shuttle/mining/station
#define MINE_DOCK /area/shuttle/mining/outpost
#define SCI_DOCK /area/shuttle/research/outpost

var/obj/machinery/computer/mine_sci_shuttle/flight_comp/autopilot

/obj/machinery/computer/mine_sci_shuttle
	name = "Mine-Science Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"

/obj/machinery/computer/mine_sci_shuttle/attackby(obj/item/I as obj, mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/mine_sci_shuttle/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/mine_sci_shuttle/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/mine_sci_shuttle/attack_hand(mob/user as mob)
	user.set_machine(src)

	var/dat
	if(autopilot)
		dat = {"Location: [autopilot.mine_sci_curr_location]<br>
		Ready to move[max(autopilot.lastMove + MINE_SCI_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((autopilot.lastMove + MINE_SCI_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
		<a href='?src=\ref[src];"mine"=1'>Mining Station</a> |
		<a href='?src=\ref[src];"station"=1'>Research Outpost</a> |
		<a href='?src=\ref[src];"sci"=1'>NSS Exodus</a><br>
		<a href='?src=\ref[user];mach_close=flightcomputer'>Close</a>"}
	else
		dat = "Cannot find shuttle"

	user << browse(dat, "window=flightcomputer;size=575x450")
	onclose(user, "flightcomputer")
	return

/obj/machinery/computer/mine_sci_shuttle/Topic(href, href_list)
	if(..())
		return

	usr.machine = src
	src.add_fingerprint(usr)

	if(!in_range(src, usr))
		usr << "\red Too far."
		return
	if(!autopilot)
		usr << "\red Shuttle not found!"
		return
	if(autopilot.moving)
		usr << "\blue Shuttle is already moving."
		return

	var/result = FALSE
	if(href_list["mine])
		result = autopilot.mine_sci_move_to(MINE_DOCK)
	else if(href_list["sci"])
		result = autopilot.mine_sci_move_to(SCI_DOCK)
	else if(href_list["station"])
		result = autopilot.mine_sci_move_to(STATION_DOCK)
	if(result)
		usr << "\blue Shuttle recieved message and will be sent shortly."

	updateUsrDialog()
	return

//-------------------------------------------
//------------FLIGHT COMPUTER----------------
//-------------------------------------------

/obj/machinery/computer/mine_sci_shuttle/flight_comp
	name = "Shuttle Console"
	icon = 'tauceti/modules/_locations/shuttles/computer_shuttle_mining.dmi'
	var/area/mine_sci_curr_location
	var/moving = 0
	var/lastMove = 0

/obj/machinery/computer/mine_sci_shuttle/flight_comp/New()
	mine_sci_curr_location = locate(STATION_DOCK)
	autopilot = src

/obj/machinery/computer/mine_sci_shuttle/flight_comp/proc/mine_sci_move_to(area/destination as area)
	if(moving)
		return FALSE
	if(lastMove + MINE_SCI_SHUTTLE_COOLDOWN > world.time)
		return FALSE
	var/area/dest_location = locate(destination)
	if(mine_sci_curr_location == dest_location)
		return FALSE

	moving = TRUE
	lastMove = world.time
	addtimer(src, "mine_sci_do_move", MINE_SCI_SHUTTLE_COOLDOWN, TRUE, dest_location)
	return TRUE

/obj/machinery/computer/mine_sci_shuttle/flight_comp/proc/mine_sci_do_move(area/destination as area)
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

#undef MINE_SCI_SHUTTLE_COOLDOWN

#undef STATION_DOCK
#undef MINE_DOCK
#undef SCI_DOCK