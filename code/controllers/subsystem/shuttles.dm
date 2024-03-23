#define SHUTTLEARRIVETIME 600		// 10 minutes = 600 seconds
#define SHUTTLELEAVETIME 180		// 3 minutes = 180 seconds
#define SHUTTLETRANSITTIME 120		// 2 minutes = 120 seconds

#define SHUTTLE_IN_TRANSIT 0
#define SHUTTLE_AT_STATION 1
#define SHUTTLE_AT_CENTCOM 2

#define SUPPLY_DOCKZ 2          //Z-level of the Dock.
#define SUPPLY_STATIONZ 1       //Z-level of the Station.
#define SUPPLY_STATION_AREATYPE /area/shuttle/supply/station //Type of the supply shuttle area for station
#define SUPPLY_DOCK_AREATYPE /area/shuttle/supply/velocity	//Type of the supply shuttle area for dock

SUBSYSTEM_DEF(shuttle)
	name = "Shuttles"

	init_order = SS_INIT_SHUTTLES
	wait       = SS_WAIT_SHUTTLES

	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME

	msg_lobby = "Заправляем шаттлы..."

		//emergency shuttle stuff
	var/alert = 0				//0 = emergency, 1 = crew cycle
	var/location = 0			//0 = somewhere far away (in spess), 1 = at SS13, 2 = returned from SS13
	var/online = 0
	var/direction = 1			//-1 = going back to central command, 1 = going to SS13, 2 = in transit to centcom (not recalled)
	var/endtime					// timeofday that shuttle arrives
	var/timelimit				//important when the shuttle gets called for more than shuttlearrivetime
		//timeleft = 360 //600
	var/time_for_fake_recall = 0 // used in rounds to prevent "ON NOES, IT MUST [INSERT ROUND] BECAUSE SHUTTLE CAN'T BE CALLED"
	var/fake_recall = 0 // flag if we need to make fake recall, gamemode fractions set it. Does nothing for crew transfer vote
	var/deny_shuttle = 0		//for admins not allowing it to be called.
	var/departed = 0

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
	var/at_station = TRUE
	var/movetime = 1200
	var/moving = 0
	var/eta_timeofday
	var/eta
		//pod stuff
	var/list/pod_station_area

	var/status_display_last_mode

		//announce stuff
	var/datum/announcement/station/shuttle/crew_called/announce_crew_called = new
	var/datum/announcement/station/shuttle/crew_recalled/announce_crew_recalled = new
	var/datum/announcement/station/shuttle/crew_docked/announce_crew_docked = new
	var/datum/announcement/station/shuttle/crew_left/announce_crew_left = new

	var/datum/announcement/station/shuttle/emer_called/announce_emer_called = new
	var/datum/announcement/station/shuttle/emer_recalled/announce_emer_recalled = new
	var/datum/announcement/station/shuttle/emer_docked/announce_emer_docked = new
	var/datum/announcement/station/shuttle/emer_left/announce_emer_left = new

	//var/datum/round_event/shuttle_loan/shuttle_loan

/datum/controller/subsystem/shuttle/Initialize(timeofday)
	ordernum = rand(1, 9000)
	pod_station_area = typecacheof(list(/area/shuttle/escape_pod1/station, /area/shuttle/escape_pod2/station, /area/shuttle/escape_pod3/station, /area/shuttle/escape_pod4/station))

	if(!global.exports_list.len)
		setupExports()

	for(var/typepath in subtypesof(/datum/supply_pack))
		var/datum/supply_pack/P = new typepath()
		supply_packs[ckey(P.name)] = P		//Convert to canonical form to avoid possible problems resulting from punctuation

	..()

/datum/controller/subsystem/shuttle/fire()
	if(moving == 1)
		var/ticksleft = (eta_timeofday - REALTIMEOFDAY)
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
	var/static/last_es_sound = 0
	switch(location)
		if(SHUTTLE_IN_TRANSIT)
			/* --- Shuttle is in transit to Central Command from SS13 --- */
			if(direction == 2)
				if(timeleft < PARALLAX_LOOP_TIME / 10)
					var/area/stop_parallax = locate(/area/shuttle/escape/transit)
					stop_parallax.parallax_slowdown()
					stop_parallax = locate(/area/shuttle/escape_pod1/transit)
					stop_parallax.parallax_slowdown()
					stop_parallax = locate(/area/shuttle/escape_pod2/transit)
					stop_parallax.parallax_slowdown()
					stop_parallax = locate(/area/shuttle/escape_pod3/transit)
					stop_parallax.parallax_slowdown()
					stop_parallax = locate(/area/shuttle/escape_pod4/transit)
					stop_parallax.parallax_slowdown()
				if(timeleft > 0)
					return FALSE

				/* --- Shuttle has arrived at Centrcal Command --- */
				else
					// turn off the star spawners
					/*
					for(var/obj/effect/starspawner/S in not_world)
						S.spawning = 0
					*/

					location = SHUTTLE_AT_CENTCOM

					//main shuttle
					var/area/start_location = locate(/area/shuttle/escape/transit)
					var/area/end_location = locate(/area/shuttle/escape/centcom)

					start_location.move_contents_to(end_location, null, NORTH)

					for(var/mob/M in end_location)
						M.playsound_local(null, 'sound/effects/escape_shuttle/es_cc_docking.ogg', VOL_EFFECTS_MASTER, null, FALSE)
					shake_mobs_in_area(end_location, SOUTH)

					dock_act(end_location, "shuttle_escape")
					dock_act(/area/centcom/evac, "shuttle_escape")


							//pods
					pod_docking(/area/shuttle/escape_pod1/transit, /area/shuttle/escape_pod1/centcom, "pod1")
					pod_docking(/area/shuttle/escape_pod2/transit, /area/shuttle/escape_pod2/centcom, "pod2")
					pod_docking(/area/shuttle/escape_pod3/transit, /area/shuttle/escape_pod3/centcom, "pod3")
					pod_docking(/area/shuttle/escape_pod4/transit, /area/shuttle/escape_pod4/centcom, "pod4")
					online = 0

					return TRUE

					/* --- Shuttle has docked centcom after being recalled --- */
			if(timeleft>timelimit)
				online = 0
				direction = 1
				endtime = null
				return FALSE

			else if((time_for_fake_recall != 0) && (timeleft <= time_for_fake_recall))
				log_admin("Gamemode fake-recalled the shuttle.")
				message_admins("<span class='notice'>Gamemode fake-recalled the shuttle.</span>")
				recall()
				time_for_fake_recall = 0
				return FALSE

			else if(timeleft == 22)
				if(last_es_sound < world.time)
					var/area/escape_hallway = locate(/area/station/hallway/secondary/exit)
					for(var/obj/effect/landmark/sound_source/shuttle_docking/SD in escape_hallway)
						playsound(SD, 'sound/effects/escape_shuttle/es_ss_docking.ogg', VOL_EFFECTS_MASTER, null, FALSE, null, -2, voluminosity = FALSE)
					last_es_sound = world.time + 10
				return FALSE

					/* --- Shuttle has docked with the station - begin countdown to transit --- */
			else if(timeleft <= 0)
				location = SHUTTLE_AT_STATION
				var/area/start_location = locate(/area/shuttle/escape/centcom)
				var/area/end_location = locate(/area/shuttle/escape/station)

				clean_arriving_area(end_location)

				start_location.move_contents_to(end_location)

				dock_act(end_location, "shuttle_escape")
				dock_act(/area/station/hallway/secondary/exit, "arrival_escape")

				settimeleft(SHUTTLELEAVETIME)
				if(alert == 0)
					announce_emer_docked.play()
				else
					announce_crew_docked.play()

				world.send2bridge(
					type = list(BRIDGE_ROUNDSTAT),
					attachment_title = "The shuttle docked to the station",
					attachment_msg = "Join now: <[BYOND_JOIN_LINK]>",
					attachment_color = BRIDGE_COLOR_ROUNDSTAT,
				)

				return TRUE

		if(SHUTTLE_AT_STATION)
			// Just before it leaves, close the damn doors!
			var/static/station_doors_bolted = FALSE

			if(!station_doors_bolted && timeleft < 10)
				station_doors_bolted = TRUE

				undock_act(/area/shuttle/escape/station, "shuttle_escape")
				undock_act(/area/station/hallway/secondary/exit, "arrival_escape")

			if(timeleft > 0)
				if(timeleft == 13)
					if(last_es_sound < world.time)
						var/area/pre_location = locate(/area/shuttle/escape/station)
						for(var/mob/M in pre_location)
							M.playsound_local(null, 'sound/effects/escape_shuttle/es_undocking.ogg', VOL_EFFECTS_MASTER, null, FALSE)
							CHECK_TICK
						last_es_sound = world.time + 10
				if(timeleft == 10)
					if(last_es_sound < world.time)
						for(var/mob/M in player_list)
							if(is_type_in_typecache(get_area(M), pod_station_area))
								M.playsound_local(null, 'sound/effects/escape_shuttle/ep_undocking.ogg', VOL_EFFECTS_MASTER, null, FALSE)
							CHECK_TICK
						last_es_sound = world.time + 10
				return FALSE

			/* --- Shuttle leaves the station, enters transit --- */
			else

				departed = 1 // It's going!
				location = SHUTTLE_IN_TRANSIT // in deep space
				direction = 2 // heading to centcom

				//main shuttle
				var/area/start_location = locate(/area/shuttle/escape/station)
				var/area/end_location = locate(/area/shuttle/escape/transit)
				end_location.parallax_movedir = NORTH
				settimeleft(SHUTTLETRANSITTIME)
				start_location.move_contents_to(end_location, null, NORTH)

				// Some aesthetic turbulance shaking
				for(var/mob/M in end_location)
					M.playsound_local(null, 'sound/effects/escape_shuttle/es_acceleration.ogg', VOL_EFFECTS_MASTER, null, FALSE)
				shake_mobs_in_area(end_location, SOUTH)

				//pods
				try_launch_pod(/area/shuttle/escape_pod1/station, /area/shuttle/escape_pod1/transit, EAST, WEST, "pod1")
				try_launch_pod(/area/shuttle/escape_pod2/station, /area/shuttle/escape_pod2/transit, EAST, WEST, "pod2")
				try_launch_pod(/area/shuttle/escape_pod3/station, /area/shuttle/escape_pod3/transit, EAST, WEST, "pod3")
				try_launch_pod(/area/shuttle/escape_pod4/station, /area/shuttle/escape_pod4/transit, WEST, EAST, "pod4")
				try_launch_pod(/area/shuttle/escape_pod5/station, /area/shuttle/escape_pod5/transit, NORTH, SOUTH, "pod5")
				try_launch_pod(/area/shuttle/escape_pod6/station, /area/shuttle/escape_pod6/transit, NORTH, SOUTH, "pod6")
				if(alert == 0)
					undock_act(/area/station/maintenance/chapel || /area/station/maintenance/bridge, "pod1")
					undock_act(/area/station/maintenance/medbay || /area/station/maintenance/bridge || /area/station/civilian/gym, "pod2")
					undock_act(/area/station/maintenance/dormitory || /area/station/maintenance/brig || /area/station/security/prison, "pod3")
					undock_act(/area/station/maintenance/engineering || /area/station/maintenance/brig, "pod4")
					undock_act(/area/station/hallway/secondary/entry, "pod5")
					undock_act(/area/station/hallway/secondary/entry, "pod6")
					announce_emer_left.play()
				else
					announce_crew_left.play()

				start_transit()

				return TRUE

		else
			return TRUE

/**
 * Cleans passed area, gibs any mob inside area, unachored movable gets moved, everything else will be qdeled
 *
 * vars:
 * * arriving_area (required) area that is gonna get used in proc
 */
/datum/controller/subsystem/shuttle/proc/clean_arriving_area(area/arriving_area)
	var/throw_y = world.maxy
	for(var/turf/turf_to_check in arriving_area)
		if(turf_to_check.y < throw_y)
			throw_y = turf_to_check.y
		var/turf/target_turf = locate(turf_to_check.x, throw_y - 1, turf_to_check.z)
		for(var/i in turf_to_check.contents)
			var/atom/movable/thing = i
			if(isliving(thing))
				var/mob/living/mob_to_gib = thing
				mob_to_gib.gib()
			else
				if(istype(thing, /obj/singularity))
					continue
				if(!thing.anchored)
					thing.Move(target_turf)
				else
					qdel(thing)
			CHECK_TICK

/datum/controller/subsystem/shuttle/proc/shake_mobs_in_area(area/A, fall_direction)
	for(var/mob/M in A)
		if(M.client)
			if(M.buckled || issilicon(M))
				shake_camera(M, 2, 1) // buckled, not a lot of shaking
			else
				shake_camera(M, 4, 2)// unbuckled, HOLY SHIT SHAKE THE ROOM
				M.Stun(1)
				M.Weaken(3)
		if(isliving(M) && !issilicon(M) && !M.buckled)
			var/mob/living/L = M
			if(isturf(L.loc))
				for(var/i=0, i < 5, i++)
					var/turf/T = L.loc
					var/hit = 0
					T = get_step(T, fall_direction)
					if(T.density)
						hit = 1
						if(i > 1)
							L.adjustBruteLoss(10)
						break
					else
						for(var/atom/movable/AM in T.contents)
							if(AM.density)
								hit = 1
								if(i > 1)
									L.adjustBruteLoss(10)
									if(isliving(AM))
										var/mob/living/bumped = AM
										bumped.adjustBruteLoss(10)
								break
					if(hit)
						break
					step(L, fall_direction)
		CHECK_TICK

/datum/controller/subsystem/shuttle/proc/dock_act(area_type, door_tag)
	//todo post_signal? & doors with door_tag near shuttle zone
	var/area/A = ispath(area_type) ? locate(area_type) : area_type

	for(var/obj/machinery/door/DOOR in A)
		if(DOOR.dock_tag == door_tag)
			if(istype(DOOR, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/D = DOOR
				D.unbolt()
			else if(istype(DOOR, /obj/machinery/door/unpowered))
				var/obj/machinery/door/unpowered/D = DOOR
				D.locked = 0
				D.open()

/datum/controller/subsystem/shuttle/proc/undock_act(area_type, door_tag)
	//todo post_signal? & doors with door_tag near shuttle zone
	var/area/A = ispath(area_type) ? locate(area_type) : area_type

	for(var/obj/machinery/door/DOOR in A)
		if(DOOR.dock_tag == door_tag)
			if(istype(DOOR, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/D = DOOR
				D.close_unsafe(TRUE)
			else if(istype(DOOR, /obj/machinery/door/unpowered))
				var/obj/machinery/door/unpowered/D = DOOR
				D.close()
				D.locked = 1

/datum/controller/subsystem/shuttle/proc/send()
	var/area/from
	var/area/dest
	switch(at_station)
		if(1)
			from = locate(SUPPLY_STATION_AREATYPE)
			dest = locate(SUPPLY_DOCK_AREATYPE)
			undock_act(/area/station/cargo/storage, "supply_dock")
			dock_act(/area/velocity, "velocity_dock")
			at_station = 0
		if(0)
			from = locate(SUPPLY_DOCK_AREATYPE)
			dest = locate(SUPPLY_STATION_AREATYPE)
			dock_act(/area/station/cargo/storage, "supply_dock")
			undock_act(/area/velocity, "velocity_dock")
			at_station = 1
	moving = 0

	clean_arriving_area(dest)
	from.move_contents_to(dest)

//Check whether the shuttle is allowed to move
/datum/controller/subsystem/shuttle/proc/can_move()
	if(moving) return FALSE
	if(!at_station) return TRUE

	var/area/shuttle = locate(/area/shuttle/supply/station)
	if(!shuttle) return FALSE

	if(forbidden_atoms_check(shuttle))
		return FALSE

	return TRUE

//To stop things being sent to centcom which should not be sent to centcom. Recursively checks for these types.
/datum/controller/subsystem/shuttle/proc/forbidden_atoms_check(atom/A)
	if(isliving(A))
		return TRUE
	if(istype(A,/obj/item/weapon/disk/nuclear))
		return TRUE
	if(istype(A,/obj/machinery/nuclearbomb))
		return TRUE
	if(istype(A,/obj/item/device/radio/beacon))
		return TRUE

	for(var/i=1, i<=A.contents.len, i++)
		var/atom/B = A.contents[i]
		if(.(B))
			return TRUE

	//Sellin
/datum/controller/subsystem/shuttle/proc/sell()
	var/shuttle_at
	if(at_station)
		shuttle_at = SUPPLY_STATION_AREATYPE
	else
		shuttle_at = SUPPLY_DOCK_AREATYPE

	var/area/shuttle = locate(shuttle_at)
	if(!shuttle)
		return

	if(!global.exports_list.len) // No exports list? Generate it!
		setupExports()

	var/msg = ""
	var/sold_atoms = ""

	for(var/atom/movable/AM in shuttle)
		if(AM.anchored)
			continue
		sold_atoms += export_item_and_contents(AM, contraband, hacked, dry_run = FALSE)

	if(sold_atoms)
		sold_atoms += "."

	for(var/a in global.exports_list)
		var/datum/export/E = a
		var/export_text = E.total_printout()
		if(!export_text)
			continue

		msg += export_text + "\n"
		var/tax = round(E.total_cost * SSeconomy.tax_cargo_export * 0.01)
		charge_to_account(global.station_account.account_number, global.station_account.owner_name, "Налог на экспорт", "НТС Велосити", tax)
		charge_to_account(global.cargo_account.account_number, global.cargo_account.owner_name, "Прибыль с экспорта", "НТС Велосити", E.total_cost - tax)
		E.export_end()

	centcom_message = msg
	//log_investigate("Shuttle contents sold for [SSshuttle.points - presale_points] credits. Contents: [sold_atoms || "none."] Message: [SSshuttle.centcom_message || "none."]", INVESTIGATE_CARGO)


//Buyin
/datum/controller/subsystem/shuttle/proc/buy()
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
			if(!A.simulated)
				continue
			if(istype(A, /obj/machinery/light))
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

		SSStatistics.score.stuffshipped++
		CHECK_TICK

	SSshuttle.shoppinglist.Cut()
	return


/datum/controller/subsystem/shuttle/proc/incall(coeff = 1)
	if(deny_shuttle && alert == 1) //crew transfer shuttle does not gets recalled by gamemode
		return
	var/obj/machinery/status_display/S = status_display_list[1]
	status_display_last_mode = S.mode
	for(var/obj/machinery/status_display/Screen in status_display_list)
		Screen.mode = 1
		Screen.update()
	if(endtime)
		if(direction == -1)
			setdirection(1)
	else
		settimeleft(get_shuttle_arrive_time()*coeff)
		online = 1
		if(fake_recall)
			time_for_fake_recall = rand(300,500)		//turning on the red lights in hallways


/datum/controller/subsystem/shuttle/proc/get_shuttle_arrive_time()
	return SHUTTLEARRIVETIME

/datum/controller/subsystem/shuttle/proc/shuttlealert(X)
	alert = X

/datum/controller/subsystem/shuttle/proc/recall()
	if(direction == 1)
		var/timeleft = timeleft()
		for(var/obj/machinery/status_display/Screen in status_display_list)
			if(Screen.mode == 1) 	// we don't need to change the mode if the mode is already non-shuttle-ETA
				Screen.mode = status_display_last_mode
				Screen.update()

		if(alert == 0)
			if(timeleft >= get_shuttle_arrive_time())
				return
			announce_emer_recalled.play()
			setdirection(-1)
			online = 1

			return
		else //makes it possible to send shuttle back.
			announce_crew_recalled.play()
			setdirection(-1)
			online = 1
			alert = 0 // set alert back to 0 after an admin recall
			return

	// returns the time (in seconds) before shuttle arrival
	// note if direction = -1, gives a count-up to SHUTTLEARRIVETIME
/datum/controller/subsystem/shuttle/proc/timeleft()
	if(online)
		var/timeleft = round((endtime - REALTIMEOFDAY)/10 ,1)
		if(direction == 1 || direction == 2)
			return timeleft
		else
			return get_shuttle_arrive_time()-timeleft
	else
		return get_shuttle_arrive_time()

	// sets the time left to a given delay (in seconds)
/datum/controller/subsystem/shuttle/proc/settimeleft(delay)
	endtime = REALTIMEOFDAY + delay * 10
	timelimit = delay

	// sets the shuttle direction
	// 1 = towards SS13, -1 = back to centcom
/datum/controller/subsystem/shuttle/proc/setdirection(dirn)
	if(direction == dirn)
		return
	direction = dirn
	// if changing direction, flip the timeleft by SHUTTLEARRIVETIME
	var/ticksleft = endtime - REALTIMEOFDAY
	endtime = REALTIMEOFDAY + (get_shuttle_arrive_time()*10 - ticksleft)
	return

/datum/controller/subsystem/shuttle/proc/check_emag(area/escape_pod)
	var/obj/item/device/radio/intercom/pod/int = locate(/obj/item/device/radio/intercom/pod) in escape_pod
	if(isnull(int))
		return
	return int.emagged

/datum/controller/subsystem/shuttle/proc/try_launch_pod(area/escape_pod_start, area/escape_pod_end, move_content_dir, shake_dir, loc_name)
	if(!locate(escape_pod_start) in all_areas)
		return
	var/area/start = locate(escape_pod_start)
	var/area/transit = locate(escape_pod_end)
	if(alert == 0 || check_emag(start))
		var/ep_shot_sound_type = 'sound/effects/escape_shuttle/ep_lucky_shot.ogg'
		if(prob(33))
			ep_shot_sound_type = 'sound/effects/escape_shuttle/ep_unlucky_shot.ogg'
		transit.parallax_movedir = move_content_dir
		start.move_contents_to(transit, null, move_content_dir)
		for(var/mob/M in transit)
			M.playsound_local(null, ep_shot_sound_type, VOL_EFFECTS_MASTER, null, FALSE)
		shake_mobs_in_area(transit, shake_dir)
		undock_act(start, loc_name)

/datum/controller/subsystem/shuttle/proc/pod_docking(area/start, area/end, loc_name)
	var/area/transit = locate(start)
	var/area/centcom = locate(end)
	if(prob(5) || check_emag(transit)) // 5% that they survive
		transit.move_contents_to(centcom, null, NORTH)
		dock_act(centcom, loc_name)
		dock_act(/area/centcom/evac, loc_name)
	shake_mobs_in_area(centcom, EAST)


/datum/controller/subsystem/shuttle/proc/set_eta_timeofday(flytime = SSshuttle.movetime)
	eta_timeofday = (REALTIMEOFDAY + flytime) % MIDNIGHT_ROLLOVER

/datum/controller/subsystem/shuttle/proc/start_transit()
	SSrating.start_rating_collection()

/obj/effect/bgstar
	name = "star"
	var/speed = 10
	var/direction = SOUTH
	layer = TURF_LAYER

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
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/starspawner
	invisibility = INVISIBILITY_ABSTRACT
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
