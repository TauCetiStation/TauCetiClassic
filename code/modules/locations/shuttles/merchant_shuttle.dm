#define MERCHANT_SHUTTLE_COOLDOWN 150

#define STATION_DOCK /area/merchantship/station
#define MERCHANTSTATION_DOCK /area/merchantship/base

var/global/area/merchant_shuttle_location = null
var/global/merchant_shuttle_lastmove = 0
var/global/merchant_shuttle_moving = 0

/obj/machinery/computer/merchant_shuttle
	name = "Merchant Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	var/obj/item/device/radio/intercom/radio

/obj/machinery/computer/merchant_shuttle/atom_init()
	. = ..()
	radio = new (src)
	merchant_shuttle_location = locate(MERCHANTSTATION_DOCK)

/obj/machinery/computer/merchant_shuttle/ui_interact(mob/user)
	var/dat
	var/shuttle_location = "Merchant Base"
	if(istype(merchant_shuttle_location, STATION_DOCK))
		shuttle_location = "NSS Exodus"
	dat = {"Location: [shuttle_location]<br>
	Ready to move[max(merchant_shuttle_lastmove + MERCHANT_SHUTTLE_COOLDOWN - world.time, 0) ? " in [max(round((merchant_shuttle_lastmove + MERCHANT_SHUTTLE_COOLDOWN - world.time) * 0.1), 0)] seconds" : ": now"]<br>
	<a href='?src=\ref[src];base=1'>Merchant Base</a> |
	<a href='?src=\ref[src];station=1'>NSS Exodus</a><br>
	<a href='?src=\ref[user];mach_close=flightcomputer'>Close</a>"}

	user << browse(entity_ja(dat), "window=flightcomputer;size=575x450")
	onclose(user, "flightcomputer")

/obj/machinery/computer/merchant_shuttle/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(merchant_shuttle_moving)
		to_chat(usr, "<span class='notice'>Shuttle is already moving.</span>")
		return FALSE

	var/result = FALSE
	if(href_list["base"])
		result = start_shuttle(MERCHANTSTATION_DOCK)
	else if(href_list["station"])
		result = start_shuttle(STATION_DOCK)
	if(result)
		to_chat(usr, "<span class='notice'>Shuttle recieved message and will be sent shortly.</span>")

	updateUsrDialog()

/obj/machinery/computer/merchant_shuttle/proc/start_shuttle(area/destination)
	if(merchant_shuttle_moving)
		return FALSE
	if((merchant_shuttle_lastmove + MERCHANT_SHUTTLE_COOLDOWN) > world.time)
		return FALSE
	var/area/dest_location = locate(destination)
	if(merchant_shuttle_location == dest_location)
		return FALSE

	merchant_shuttle_moving = TRUE
	merchant_shuttle_lastmove = world.time
	if(merchant_shuttle_location.type == STATION_DOCK)
		SSshuttle.undock_act(/area/merchantstation/station_dock, "arrival_merchant")
	else if(merchant_shuttle_location.type == MERCHANTSTATION_DOCK)
		SSshuttle.undock_act(/area/merchantstation/dock, "arrival_merchant")
	addtimer(CALLBACK(src, .proc/move_shuttle, dest_location), MERCHANT_SHUTTLE_COOLDOWN, TIMER_UNIQUE)
	return TRUE

/obj/machinery/computer/merchant_shuttle/proc/move_shuttle(area/destination)
	if(merchant_shuttle_moving)
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

		merchant_shuttle_location.move_contents_to(destination)
		if(destination.type == STATION_DOCK)
			SSshuttle.dock_act(/area/merchantstation/station_dock, "arrival_merchant")
			radio.autosay("Unknown vessel has docked with the station", "Arrivals Alert System")
		else if(destination.type == MERCHANTSTATION_DOCK)
			SSshuttle.dock_act(/area/merchantstation/dock, "arrival_merchant")

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

		merchant_shuttle_location = destination
		merchant_shuttle_moving = FALSE

#undef MERCHANT_SHUTTLE_COOLDOWN
#undef STATION_DOCK
#undef MERCHANTSTATION_DOCK