var/datum/subsystem/shuttle/SSshuttle

#define SHUTTLEARRIVETIME 600		// 10 minutes = 600 seconds
#define SHUTTLELEAVETIME 180		// 3 minutes = 180 seconds
#define SHUTTLETRANSITTIME 120		// 2 minutes = 120 seconds

#define SHUTTLE_IN_TRANSIT 0
#define SHUTTLE_AT_STATION 1
#define SHUTTLE_AT_CENTCOM 2

#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.
#define SUPPLY_STATION_AREATYPE /area/supply/station //Type of the supply shuttle area for station
#define SUPPLY_DOCK_AREATYPE /area/supply/dock	//Type of the supply shuttle area for dock

#define TIME_FOR_UNDOCKING 4

/datum/subsystem/shuttle
	name = "Shuttles"

	init_order = SS_INIT_SHUTTLES
	wait       = SS_WAIT_SHUTTLES

	flags = SS_KEEP_TIMING | SS_NO_TICK_CHECK

		//emergency shuttle stuff
	var/alert = 0				//0 = emergency, 1 = crew cycle
	var/location = 0			//0 = somewhere far away (in spess), 1 = at SS13, 2 = returned from SS13
	var/online = 0
	var/direction = 1			//-1 = going back to central command, 1 = going to SS13, 2 = in transit to centcom (not recalled)
	var/endtime					// timeofday that shuttle arrives
	var/timelimit				//important when the shuttle gets called for more than shuttlearrivetime
		//timeleft = 360 //600
	var/fake_recall = 0			//Used in rounds to prevent "ON NOES, IT MUST [INSERT ROUND] BECAUSE SHUTTLE CAN'T BE CALLED"
	var/always_fake_recall = 0
	var/deny_shuttle = 0		//for admins not allowing it to be called.
	var/departed = 0

		//supply shuttle stuff
	var/points = 5000
	// When TRUE, these vars allow exporting emagged/contraband items, and add some special interactions to existing exports.
	var/contraband = FALSE
	var/hacked = FALSE
	var/centcom_message = ""
		//control
	var/ordernum
	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/list/supply_packs = list()
		//shuttle movement
	var/at_station = 0
	var/movetime = 1200
	var/moving = 0
	var/eta_timeofday
	var/eta
		//shuttles list
	var/list/datum/shuttle/shuttles = list()
	var/datum/shuttle/shuttle_suply = null
	var/datum/shuttle/autodock/ferry/emergency/emergency_shuttle = null
	var/list/processing = list()
		//docking controllers
	var/list/registered_shuttle_landmarks = list()
	var/last_landmark_registration_time = 0


/datum/subsystem/shuttle/New()
	NEW_SS_GLOBAL(SSshuttle)

/datum/subsystem/shuttle/Initialize(timeofday)
	ordernum = rand(1, 9000)

	for(var/typepath in subtypesof(/datum/supply_pack))
		var/datum/supply_pack/P = new typepath()
		supply_packs[P.name] = P

	for(var/shuttle_type in subtypesof(/datum/shuttle))
		var/datum/shuttle/shuttle = shuttle_type
		if(!initial(shuttle.name))
			continue
		shuttle = new shuttle()

	..()

/datum/subsystem/shuttle/fire()
	var/static/list/pods_station = list(
		/area/shuttle/escape_pod1/station,
		/area/shuttle/escape_pod2/station,
		/area/shuttle/escape_pod3/station,
		/area/shuttle/escape_pod5/station
	)

	var/static/list/pods_transit = list(
		/area/shuttle/escape_pod1/transit,
		/area/shuttle/escape_pod2/transit,
		/area/shuttle/escape_pod3/transit,
		/area/shuttle/escape_pod5/transit
	)

	var/static/list/pods_centcom = list(
		/area/shuttle/escape_pod1/centcom,
		/area/shuttle/escape_pod2/centcom,
		/area/shuttle/escape_pod3/centcom,
		/area/shuttle/escape_pod5/centcom
	)

	for(var/datum/shuttle/shuttle in processing)
		if(shuttle.process_state)
			shuttle.process()

	if(moving == 1)
		var/ticksleft = (eta_timeofday - world.timeofday)
		if(ticksleft > 0)
			eta = round(ticksleft/600,1)
		else
			eta = 0
			send()

	//What a mess below...
	if(!online)
		return
	var/timeleft = timeleft()
	if(timeleft > 1e5)		// midnight rollover protection
		timeleft = 0
	switch(location)
		if(SHUTTLE_IN_TRANSIT)
			/* --- Shuttle is in transit to Central Command from SS13 --- */
			if(direction == 2)
				if(timeleft > 0)
					return 0

				//pods
				for(var/i in 1 to length(pods_transit))
					if(prob(5)) // 5% that they survive
						var/area/start_location = locate(pods_transit[i])
						var/area/end_location = locate(pods_centcom[i])
						start_location.move_contents_to(end_location, null, NORTH)

						for(var/obj/machinery/door/D in end_location)
							D.open()
							CHECK_TICK

						for(var/mob/M in end_location)
							if(M.client)
								if(M.buckled)
									shake_camera(M, 4, 1) // buckled, not a lot of shaking
								else
									shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
							if(iscarbon(M))
								if(!M.buckled)
									M.Weaken(5)
							CHECK_TICK

				online = FALSE

				return 1

					/* --- Shuttle has docked centcom after being recalled --- */
			if(timeleft > timelimit)
				online = FALSE
				direction = 1
				endtime = null
				return 0

			else if((fake_recall != 0) && (timeleft <= fake_recall))
				recall()
				fake_recall = 0
				return 0

					/* --- Shuttle has docked with the station - begin countdown to transit --- */
			else if(timeleft <= TIME_FOR_UNDOCKING)
				emergency_shuttle.launch(src)
				return 1

		if(SHUTTLE_AT_STATION)
			if(timeleft > TIME_FOR_UNDOCKING)
				return 0

			emergency_shuttle.launch(src)
			/* --- Shuttle leaves the station, enters transit --- */

			if(timeleft > 0)
				return 0

			//pods
			if(alert == 0) // Crew Transfer not for pods
				//pods
				for(var/i in 1 to length(pods_station))
					var/area/start_location = locate(pods_station[i])
					var/area/end_location = locate(pods_transit[i])
					for(var/obj/machinery/door/D in start_location)
						D.close()
						CHECK_TICK

					start_location.move_contents_to(end_location, null, NORTH)

					for(var/mob/M in end_location)
						if(M.client)
							if(M.buckled)
								shake_camera(M, 4, 1) // buckled, not a lot of shaking
							else
								shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
						if(iscarbon(M))
							if(!M.buckled)
								M.Weaken(5)
						CHECK_TICK

				captain_announce("The Emergency Shuttle has left the station. Estimate [round(timeleft()/60,1)] minutes until the shuttle docks at Central Command.")
			else
				captain_announce("The Crew Transfer Shuttle has left the station. Estimate [round(timeleft()/60,1)] minutes until the shuttle docks at Central Command.")

			return 1

		else
			return 1

/datum/subsystem/shuttle/proc/register_landmark(shuttle_landmark_tag, obj/effect/shuttle_landmark/shuttle_landmark)
	if (registered_shuttle_landmarks[shuttle_landmark_tag])
		CRASH("Attempted to register shuttle landmark with tag [shuttle_landmark_tag], but it is already registered!")
	if (istype(shuttle_landmark))
		registered_shuttle_landmarks[shuttle_landmark_tag] = shuttle_landmark
		last_landmark_registration_time = world.time


/datum/subsystem/shuttle/proc/send()
	var/area/from
	var/area/dest
	var/area/the_shuttles_way
	switch(at_station)
		if(1)
			from = locate(SUPPLY_STATION_AREATYPE)
			dest = locate(SUPPLY_DOCK_AREATYPE)
			the_shuttles_way = from
			at_station = 0
		if(0)
			from = locate(SUPPLY_DOCK_AREATYPE)
			dest = locate(SUPPLY_STATION_AREATYPE)
			the_shuttles_way = dest
			at_station = 1
	moving = 0

	//Do I really need to explain this loop?
	for(var/mob/living/unlucky_person in the_shuttles_way)
		unlucky_person.gib()
		CHECK_TICK

	from.move_contents_to(dest)

//Check whether the shuttle is allowed to move
/datum/subsystem/shuttle/proc/can_move()
	if(moving) return 0
	if(!at_station) return 1

	var/area/shuttle = locate(/area/supply/station)
	if(!shuttle) return 0

	if(forbidden_atoms_check(shuttle))
		return 0

	return 1

//To stop things being sent to centcom which should not be sent to centcom. Recursively checks for these types.
/datum/subsystem/shuttle/proc/forbidden_atoms_check(atom/A)
	if(istype(A,/mob/living))
		return 1
	if(istype(A,/obj/item/weapon/disk/nuclear))
		return 1
	if(istype(A,/obj/machinery/nuclearbomb))
		return 1
	if(istype(A,/obj/item/device/radio/beacon))
		return 1

	for(var/i=1, i<=A.contents.len, i++)
		var/atom/B = A.contents[i]
		if(.(B))
			return 1

	//Sellin
/datum/subsystem/shuttle/proc/sell()
	var/shuttle_at
	if(at_station)
		shuttle_at = SUPPLY_STATION_AREATYPE
	else
		shuttle_at = SUPPLY_DOCK_AREATYPE

	var/area/shuttle = locate(shuttle_at)
	if(!shuttle)
		return

	if(!exports_list.len) // No exports list? Generate it!
		setupExports()

	var/msg = ""
	var/sold_atoms = ""

	for(var/atom/movable/AM in shuttle)
		if(AM.anchored)
			continue
		sold_atoms += export_item_and_contents(AM, contraband, hacked, dry_run = FALSE)

	if(sold_atoms)
		sold_atoms += "."

	for(var/a in exports_list)
		var/datum/export/E = a
		var/export_text = E.total_printout()
		if(!export_text)
			continue

		msg += export_text + "\n"
		SSshuttle.points += E.total_cost
		E.export_end()

	centcom_message = msg
	//investigate_log("Shuttle contents sold for [SSshuttle.points - presale_points] credits. Contents: [sold_atoms || "none."] Message: [SSshuttle.centcom_message || "none."]", "cargo")


//Buyin
/datum/subsystem/shuttle/proc/buy()
	if(!shoppinglist.len)
		return

	var/shuttle_at
	if(at_station)
		shuttle_at = SUPPLY_STATION_AREATYPE
	else
		shuttle_at = SUPPLY_DOCK_AREATYPE

	var/area/shuttle = locate(shuttle_at)
	if(!shuttle)
		return

	var/list/clear_turfs = list()

	for(var/turf/T in shuttle)
		if(T.density)
			continue
		var/contcount
		for(var/atom/A in T.contents)
			if(istype(A,/atom/movable/lighting_overlay))
				continue
			if(istype(A,/obj/machinery/light))
				continue
			contcount++
		if(contcount)
			continue
		clear_turfs += T
		CHECK_TICK

	for(var/S in shoppinglist)
		if(!clear_turfs.len)
			break
		var/i = rand(1,clear_turfs.len)
		var/turf/pickedloc = clear_turfs[i]
		clear_turfs.Cut(i,i+1)

		var/datum/supply_order/SO = S

		SO.generate(pickedloc)
		if(SO.object.dangerous)
			message_admins("[SO.object.name] ordered by [key_name_admin(SO.orderer_ckey)] has shipped.")

		score["stuffshipped"]++
		CHECK_TICK

	SSshuttle.shoppinglist.Cut()
	return


/datum/subsystem/shuttle/proc/incall(coeff = 1)
	if(deny_shuttle && alert == 1) //crew transfer shuttle does not gets recalled by gamemode
		return
	if(endtime)
		if(direction == -1)
			setdirection(1)
	else
		settimeleft(get_shuttle_arrive_time()*coeff)
		online = 1
		if(always_fake_recall)
			fake_recall = rand(300,500)		//turning on the red lights in hallways

/datum/subsystem/shuttle/proc/get_shuttle_arrive_time()
	// During mutiny rounds, the shuttle takes twice as long.
	if(ticker && istype(ticker.mode,/datum/game_mode/mutiny))
		return SHUTTLEARRIVETIME * 2

	return SHUTTLEARRIVETIME

/datum/subsystem/shuttle/proc/shuttlealert(X)
	alert = X

/datum/subsystem/shuttle/proc/recall()
	if(direction == 1)
		var/timeleft = timeleft()
		if(alert == 0)
			if(timeleft >= get_shuttle_arrive_time())
				return
			captain_announce("The emergency shuttle has been recalled.")
			world << sound('sound/AI/shuttlerecalled.ogg')
			setdirection(-1)
			online = 1
			return
		else //makes it possible to send shuttle back.
			captain_announce("The shuttle has been recalled.")
			setdirection(-1)
			online = 1
			alert = 0 // set alert back to 0 after an admin recall
			return

	// returns the time (in seconds) before shuttle arrival
	// note if direction = -1, gives a count-up to SHUTTLEARRIVETIME
/datum/subsystem/shuttle/proc/timeleft()
	if(online)
		var/timeleft = round((endtime - world.timeofday)/10 ,1)
		if(direction == 1 || direction == 2)
			return timeleft
		else
			return get_shuttle_arrive_time()-timeleft
	else
		return get_shuttle_arrive_time()

	// sets the time left to a given delay (in seconds)
/datum/subsystem/shuttle/proc/settimeleft(delay)
	endtime = world.timeofday + delay * 10
	timelimit = delay

	if(emergency_shuttle.finish_sound_timer && emergency_shuttle.sound_landing && deltimer(emergency_shuttle.finish_sound_timer))
		emergency_shuttle.finish_sound_timer = addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, emergency_shuttle.next_location, emergency_shuttle.sound_landing, 100, 0, 7), max(delay * 10 - 100, 5), TIMER_STOPPABLE)

	if(emergency_shuttle.finish_jump_timer && deltimer(emergency_shuttle.finish_jump_timer))
		emergency_shuttle.finish_jump_timer = addtimer(CALLBACK(emergency_shuttle, /datum/shuttle/proc/long_jump_end, emergency_shuttle.next_location, emergency_shuttle.start_location), delay * 10, TIMER_STOPPABLE)


	// sets the shuttle direction
	// 1 = towards SS13, -1 = back to centcom
/datum/subsystem/shuttle/proc/setdirection(dirn)
	if(direction == dirn)
		return
	direction = dirn
	// if changing direction, flip the timeleft by SHUTTLEARRIVETIME
	var/ticksleft = endtime - world.timeofday
	endtime = world.timeofday + (get_shuttle_arrive_time()*10 - ticksleft)
	return

/obj/effect/bgstar
	name = "star"
	var/speed = 10
	var/direction = SOUTH
	layer = 2 // TURF_LAYER

/obj/effect/bgstar/New()
	..()
	pixel_x += rand(-2,30)
	pixel_y += rand(-2,30)
	var/starnum = pick("1", "1", "1", "2", "3", "4")

	icon_state = "star"+starnum

	speed = rand(2, 5)

/obj/effect/bgstar/proc/startmove()

	while(src)
		sleep(speed)
		step(src, direction)
		for(var/obj/effect/starender/E in loc)
			qdel(src)


/obj/effect/starender
	invisibility = 101

/obj/effect/starspawner
	invisibility = 101
	var/spawndir = SOUTH
	var/spawning = 0

/obj/effect/starspawner/West
	spawndir = WEST

/obj/effect/starspawner/proc/startspawn()
	spawning = 1
	while(spawning)
		sleep(rand(2, 30))
		var/obj/effect/bgstar/S = new/obj/effect/bgstar(locate(x,y,z))
		S.direction = spawndir
		spawn()
			S.startmove()

#undef TIME_FOR_UNDOCKING
