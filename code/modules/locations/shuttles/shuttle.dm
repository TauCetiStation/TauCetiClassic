var/global/dock_ids = 1
var/global/list/all_docking_ports = list()
var/global/list/all_shuttles = list()
/datum/dock
	var/name = "DockName"
	var/dir
	var/size = 1

	var/bounds_x = 1
	var/bounds_y = 1

	var/dock_id = 1


	var/occupied = FALSE

	var/list/landing_coords = list("x" = 0, "y" = 0, "z" = 0)

	var/list/connected_things = list()

	var/transit = FALSE

/datum/dock/landing_pad
	name = "PadName"

/datum/dock/landing_pad/transit
	name = "Transit Space"
	transit = TRUE

/datum/dock/proc/connect_to(list/Things)
	return

/datum/dock/landing_pad/connect_to(list/Things)
	connected_things = Things
	for(var/obj/structure/landing_pole/Pole in connected_things)
		RegisterSignal(Pole, list(COMSIG_PARENT_QDELETING), PROC_REF(pole_destroyed))
		RegisterSignal(Pole, list(COMSIG_MOVABLE_MOVED), PROC_REF(pole_destroyed))

		Pole.connect_landing(src)

/datum/dock/landing_pad/proc/pole_destroyed()
	for(var/obj/structure/landing_pole/Pole in connected_things)
		Pole.landing_destroyed()
		UnregisterSignal(Pole, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))

		Pole.disconnect_landing()

	qdel(src)

/datum/dock/landing_pad/dock()
	occupied = TRUE
	return

/datum/dock/landing_pad/undock()
	occupied = FALSE
	return

/datum/dock/landing_pad/prepare_landing()
	for(var/obj/structure/landing_pole/Pole in poles)
		Pole.landing_lights_on()


/datum/dock/New(name, dir, X, Y, Z, size_X = 1, size_Y = 1)
	src.name = name
	src.dir = dir
	landing_coords["x"] = X
	landing_coords["y"] = Y
	landing_coords["z"] = Z

	bounds_x = size_X
	bounds_y = size_Y

	dock_id = dock_ids
	dock_ids++

/datum/dock/Destroy()
	all_docking_ports["[landing_coords["z"]]"] -= src

	return ..()

/datum/dock/proc/dock()
	occupied = TRUE
	return bolt_unbolt(FALSE)

/datum/dock/proc/undock()
	occupied = FALSE
	return bolt_unbolt(TRUE)

/datum/dock/proc/bolt_unbolt(bolt = TRUE)
	var/turf/T = locate(landing_coords["x"], landing_coords["y"], landing_coords["z"])
	if(!T)
		return FALSE

	var/list/turfs_to_check = list(T)
	if(size == 2)
		switch(dir)
			if(NORTH, SOUTH)
				T = get_step(T, EAST)
			if(EAST, WEST)
				T = get_step(T, NORTH)

		if(!T)
			return FALSE

		turfs_to_check += T


	for(var/turf/Door_Turf in turfs_to_check)
		for(var/obj/machinery/door/Door in Door_Turf)
			if(istype(Door, /obj/machinery/door/airlock))
				var/obj/machinery/door/airlock/canBeBolted = Door
				if(bolt)
					canBeBolted.close_unsafe(TRUE)
					canBeBolted.bolt()
				else
					canBeBolted.unbolt()
			else if(istype(Door, /obj/machinery/door/unpowered))
				var/obj/machinery/door/unpowered/Unpowered = Door
				if(bolt)
					Unpowered.locked = 1
					Unpowered.close()
				else
					Unpowered.locked = 0
					Unpowered.open()

	return TRUE

/datum/dock/proc/prepare_landing()
	return

/proc/get_dock_by_id(list/docks_list, dock_id)
	for(var/datum/dock/Dock in docks_list)
		if(Dock.dock_id != dock_id)
			continue

		return Dock

	return FALSE


/proc/add_docking_port(name, dir, x, y, z, list/docks_list)
	for(var/datum/dock/port in docks_list)
		if(port.dir != dir || port.size == 2)
			continue

		switch(dir)
			if(NORTH, SOUTH)
				if(!(port.landing_coords["x"] - x in list(1, -1)))
					continue

				port.size = 2
				if(port.landing_coords["x"] > x)
					port.landing_coords["x"] = x

				return

			if(EAST, WEST)
				if(!(port.landing_coords["y"] - y in list(1, -1)))
					continue

				port.size = 2
				if(port.landing_coords["y"] > y)
					port.landing_coords["y"] = y

				return

	return new/datum/dock(name, dir, x, y, z)

/proc/get_shuttle_by_id(list/shuttles_list, grid_id)
	for(var/datum/shuttle/Shuttle in shuttles_list)
		if(Shuttle.grid_id != grid_id)
			continue

		return Shuttle

	return FALSE


/datum/shuttle
	var/name = "Shuttle"
	var/grid_id

	var/dir
	var/z_level

	var/list/tiles
	var/list/outer_shell
	var/list/airlocks

	var/obj/machinery/computer/shuttle_console/Console

	var/list/nearest_mask = list(
							                   list(NORTH, 0, 1),
							  list(WEST, -1, 0),                 list(EAST, 1, 0),
							                   list(SOUTH, 0, -1)
							)

	var/datum/dock/dockedBy
	var/datum/dock/dockedTo

	var/area/shuttle/ShuttleArea

	var/bounds_x
	var/bounds_y

	var/list/min_cords = list("x" = 0, "y" = 0)
	var/list/max_cords = list("x" = 0, "y" = 0)

/datum/shuttle/New(obj/machinery/computer/shuttle_console/Cons, grid)
	dir = Cons.dir
	z_level = Cons.z
	Console = Cons
	name = Cons.shuttleName

	grid_id = grid

	try_generate_shuttle()
	ShuttleArea = create_shuttle_area()

	all_shuttles += src

/datum/shuttle/Destroy()
	all_shuttles -= src

	for(var/datum/dock/Airlock in airlocks)
		qdel(Airlock)

	ShuttleArea.contents = null
	qdel(ShuttleArea)

/datum/shuttle/proc/try_generate_shuttle()
	var/turf/Starting = get_turf(Console)
	if(!Starting.grid_id)
		Starting.grid_id = grid_id

	tiles = list()
	outer_shell = list()
	airlocks = list()

	tiles[Starting] = list("x" = 0, "y" = 0)
	check_tile_neighbours(Starting, 0, 0)

/datum/shuttle/proc/check_tile_neighbours(turf/T, x_offset, y_offset)
	var/turf/CheckingTurf

	if(x_offset > max_cords["x"])
		max_cords["x"] = x_offset

	if(x_offset < min_cords["x"])
		min_cords["x"] = x_offset

	if(y_offset > max_cords["y"])
		max_cords["y"] = y_offset

	if(y_offset < min_cords["y"])
		min_cords["y"] = y_offset

	checking_directions:
		for(var/list/mask_params in nearest_mask)
			CheckingTurf = get_step(T, mask_params[1])

			if(CheckingTurf in tiles)
				continue

			if(CheckingTurf.grid_id == grid_id)
				tiles[CheckingTurf] = list("x" = x_offset + mask_params[2], "y" = y_offset + mask_params[3])
				check_tile_neighbours(CheckingTurf, x_offset + mask_params[2], y_offset + mask_params[3])
				continue

			for(var/obj/structure/Struct in CheckingTurf.contents)
				if(Struct in outer_shell)
					continue checking_directions
				if((!istype(Struct, /obj/structure/window/shuttle) && !istype(Struct, /obj/structure/object_wall)) || Struct.grid_id != grid_id)
					continue

				outer_shell[Struct] = list("x" = x_offset + mask_params[2], "y" = y_offset + mask_params[3])
				check_tile_neighbours(CheckingTurf, x_offset + mask_params[2], y_offset + mask_params[3])
				continue checking_directions

				CHECK_TICK

			var/obj/machinery/door/Airlock = locate(/obj/machinery/door) in T.contents
			if(Airlock)
				var/datum/dock/added = add_docking_port(name, mask_params[1], x_offset + Console.x, y_offset + Console.y, Console.z, airlocks)
				if(added)
					airlocks[added] = list("x" = x_offset, "y" = y_offset)

	bounds_x = max_cords["x"] - min_cords["x"] + 1
	bounds_y = max_cords["y"] - min_cords["y"] + 1


/datum/shuttle/proc/create_shuttle_area()
	var/area/shuttle/A = new
	A.name = name
	A.tag="[A.type]_[md5(name+grid_id)]"
	A.power_equip = 0
	A.power_light = 0
	A.power_environ = 0
	for(var/turf/T in tiles)
		var/area/old_area = T.loc
		if(old_area)
			T.under_shuttle_area = old_area

		A.contents += T
		T.change_area(old_area, A)
	A.update_areasize()
	A.power_change()

	return A


/datum/shuttle/proc/check_docked()
	var/list/z_level_docks = global.all_docking_ports["[z_level]"]
	for(var/datum/dock/dock in z_level_docks)
		for(var/datum/dock/port in airlocks)
			if(dock.dir != global.reverse_dir[port.dir])
				continue

			var/turf/T = get_step(locate(dock.landing_coords["x"], dock.landing_coords["y"], dock.landing_coords["z"]), dock.dir)
			if(!T || T.x != (port.landing_coords["x"]) || T.y != (port.landing_coords["y"]))
				continue

			dock(port, dock)
			return

/datum/shuttle/proc/dock(datum/dock/docked_by, datum/dock/docked_to)
	dockedBy = docked_by
	dockedBy.dock()

	dockedTo = docked_to
	dockedTo.dock()

/datum/shuttle/proc/undock()
	dockedBy.undock()
	dockedBy = null

	dockedTo.undock()
	dockedTo = null

/datum/shuttle/proc/set_dir(new_dir)
	var/old_dir = dir
	dir = new_dir

	var/rotation = (dir2angle(global.reverse_dir[dir]) - dir2angle(old_dir)) % 360
	if(rotation < 0)
		rotation += 360

	min_cords = apply_rotation_to_relative_coordinates(min_cords, rotation)
	max_cords = apply_rotation_to_relative_coordinates(max_cords, rotation)

	if(max_cords["x"] < min_cords["x"])
		var/x_holder = min_cords["x"]
		min_cords["x"] = max_cords["x"]
		max_cords["x"] = x_holder

	if(max_cords["y"] < min_cords["y"])
		var/y_holder = min_cords["y"]
		min_cords["y"] = max_cords["y"]
		max_cords["y"] = y_holder

	bounds_x = max_cords["x"] - min_cords["x"] + 1
	bounds_y = max_cords["y"] - min_cords["y"] + 1

/datum/shuttle/proc/get_landing_pad_rotation(datum/dock/landing_pad/LandOn)
	var/list/rotations = list()

	if(bounds_x <= LandOn.bounds_x && bounds_y <= LandOn.bounds_y)
		rotations += list(0, 180)

	if(bounds_x <= LandOn.bounds_y && bounds_y <= LandOn.bounds_x)
		rotations += list(90, 270)

	if(!rotations.len)
		return FALSE

	return pick(rotations)

/datum/shuttle/proc/try_move(datum/dock/DockBy, datum/dock/DockTo)
	var/list/moving_order
	var/rotation = 0
	if(istype(DockTo, /datum/dock/landing_pad))
		rotation = get_landing_pad_rotation(DockTo)
		if(!rotation)
			return FALSE

		moving_order = check_pad(DockTo, rotation)
	else
		rotation = (dir2angle(DockTo.dir) - dir2angle(global.reverse_dir[DockBy.dir])) % 360
		if(rotation < 0)
			rotation += 360

		moving_order = check_dock(DockBy, DockTo, rotation)

	if(!moving_order)
		return FALSE

	undock()

	set_dir(turn(dir, -rotation))

	for(var/list/MovingList in moving_order)
		var/Thing = MovingList[1]
		var/turf/Destination_Turf = MovingList[2]
		var/list/new_relative_coordinates = MovingList[3]

		if(istype(Thing, /turf))
			var/turf/T = Thing
			var/old_icon_state1 = T.icon_state
			var/old_icon1 = T.icon

			var/old_dir = T.dir

			Destination_Turf.save_turf_to_undershuttle_params()

			Destination_Turf = T.Shuttle_MoveTurf(Destination_Turf)

			Destination_Turf.grid_id = grid_id

			ShuttleArea.contents += Destination_Turf
			Destination_Turf.change_area(Destination_Turf.under_shuttle_area, ShuttleArea)

			Destination_Turf.set_dir(turn(old_dir, -rotation))

			if(!isenvironmentturf(Destination_Turf))
				Destination_Turf.icon_state = old_icon_state1
				Destination_Turf.icon = old_icon1


			var/turf/simulated/ST = T
			if(istype(ST) && ST.zone)
				var/turf/simulated/SX = Destination_Turf
				if(!SX.air)
					SX.make_air()
				SX.air.copy_from(ST.zone.air)
				ST.zone.remove(ST)

			tiles -= T
			tiles[Destination_Turf] = new_relative_coordinates

			for(var/obj/O in T)
				if(istype(O, /obj/effect/portal))
					qdel(O)
					continue
				if(!O.simulated)
					continue
				O.forceMove(Destination_Turf)
				O.set_dir(turn(O.dir, -rotation))
				O.update_parallax_contents()

				CHECK_TICK

			for(var/mob/M in T)
				if(!istype(M,/mob) || istype(M, /mob/camera))
					continue
				M.forceMove(Destination_Turf, TRUE, TRUE)
				M.update_parallax_contents()
				if(!M.buckled)
					M.set_dir(turn(M.dir, -rotation))

				shake_mob(M, dir)

				CHECK_TICK


		else
			var/obj/structure/Struct = Thing
			outer_shell[Struct] = new_relative_coordinates
			Struct.forceMove(Destination_Turf)
			Struct.set_dir(turn(Struct.dir, -rotation))

	if(!DockTo.transit)
		dock(DockBy, DockTo)


/datum/shuttle/proc/shake_mob(mob/M, fall_direction)
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


/datum/shuttle/proc/check_pad(datum/dock/landing_pad/LandOn, rotation)
	var/bounds_x_holder = (rotation in list(0, 180)) ? bounds_x : bounds_y
	var/bounds_y_holder = (rotation in list(0, 180)) ? bounds_y : bounds_x
	var/min_cords_holder = apply_rotation_to_relative_coordinates(min_cords, rotation)
	var/max_cords_holder = apply_rotation_to_relative_coordinates(max_cords, rotation)

	if(max_cords_holder["x"] < min_cords_holder["x"])
		min_cords_holder["x"] = max_cords_holder["x"]

	if(max_cords_holder["y"] < min_cords_holder["y"])
		min_cords_holder["y"] = max_cords_holder["y"]

	var/turf/destination_turf = locate(LandOn.landing_coords["x"] + round((LandOn.bounds_x - bounds_x_holder) / 2) - min_cords_holder["x"], LandOn.landing_coords["y"] + round((LandOn.bounds_y - bounds_y_holder) / 2) - min_cords_holder["y"], LandOn.landing_coords["z"])
	if(!destination_turf)
		return FALSE
	var/list/destination_turf_coordinates = list("x" = destination_turf.x, "y" = destination_turf.y, "z" = destination_turf.z)

	return generate_moving_order(destination_turf_coordinates, list(0, 0), rotation)

/datum/shuttle/proc/check_dock(datum/dock/DockBy, datum/dock/DockTo, rotation)
	var/list/relative_dock_coordinates = apply_rotation_to_relative_coordinates(airlocks[DockBy], rotation)
	var/turf/destination_turf = get_step(locate(DockTo.landing_coords["x"], DockTo.landing_coords["y"], DockTo.landing_coords["z"]), DockTo.dir)
	if(!destination_turf)
		return FALSE
	var/list/destination_turf_coordinates = list("x" = destination_turf.x, "y" = destination_turf.y, "z" = destination_turf.z)

	return generate_moving_order(destination_turf_coordinates, relative_dock_coordinates, rotation)

/datum/shuttle/proc/generate_moving_order(list/destination_turf_coordinates, list/relative_dock_coordinates, rotation)
	var/list/moving_order = list()// list(movingObject, destinationTurf, newRelativeCoordinates)

	var/list/relative_object_coordinates
	var/turf/Destination
	for(var/turf/T in tiles)
		relative_object_coordinates = apply_rotation_to_relative_coordinates(tiles[T], rotation)
		Destination = locate(destination_turf_coordinates["x"] + relative_object_coordinates["x"] - relative_dock_coordinates["x"], destination_turf_coordinates["y"] + relative_object_coordinates["y"] - relative_dock_coordinates["y"], destination_turf_coordinates["z"])
		if(!Destination || Destination.density || locate(/obj/structure/window/shuttle) in Destination.contents || locate(/obj/structure/object_wall) in Destination.contents)
			return FALSE

		moving_order += list(list(T, Destination, relative_object_coordinates))


	for(var/obj/structure/Struct in outer_shell)
		relative_object_coordinates = apply_rotation_to_relative_coordinates(outer_shell[Struct], rotation)
		Destination = locate(destination_turf_coordinates["x"] + relative_object_coordinates["x"] - relative_dock_coordinates["x"], destination_turf_coordinates["y"] + relative_object_coordinates["y"] - relative_dock_coordinates["y"], destination_turf_coordinates["z"])
		if(Destination.density)
			return FALSE

		moving_order += list(list(Struct, Destination, relative_object_coordinates))

	for(var/datum/dock/Airlock in airlocks)
		relative_object_coordinates = apply_rotation_to_relative_coordinates(airlocks[Airlock], rotation)
		Airlock.landing_coords["x"] = destination_turf_coordinates["x"] + relative_object_coordinates["x"] - relative_dock_coordinates["x"]
		Airlock.landing_coords["y"] = destination_turf_coordinates["y"] + relative_object_coordinates["y"] - relative_dock_coordinates["y"]
		Airlock.landing_coords["z"] = destination_turf_coordinates["z"]

		Airlock.dir = angle2dir(dir2angle(Airlock.dir) + rotation)

		airlocks[Airlock] = relative_object_coordinates

	return moving_order


/datum/shuttle/proc/apply_rotation_to_relative_coordinates(list/coordinates, rotation)
	if(rotation == 0)
		return coordinates
	var/X_holder = coordinates["x"]
	var/Y_holder = coordinates["y"]
	switch(rotation)
		if(90)
			return list("x" = Y_holder, "y" = -X_holder)
		if(180)
			return list("x" = -X_holder, "y" = -Y_holder)
		if(270)
			return list("x" = -Y_holder, "y" = X_holder)


/obj/machinery/computer/shuttle_console
	name = "Shuttle Console"
	cases = list("консоль шаттла", "консоли шаттла", "консоли шаттла", "консоль шаттла", "консолью шаттла", "консоли шаттла")
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	state_broken_preset = "commb"
	state_nopower_preset = "comm0"
	//circuit = /obj/item/weapon/circuitboard/shuttle

	var/datum/shuttle/Shuttle
	var/shuttleName = "ShuttleName"

	var/datum/dock/ShuttleDock
	var/datum/dock/StationDock

/obj/machinery/computer/shuttle_console/atom_init()
	. = ..()

	var/turf/T = get_turf(src)
	if(T.grid_id)
		Shuttle = new(src, T.grid_id)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/shuttle_console/atom_init_late()
	if(!Shuttle)
		return

	Shuttle.check_docked()

/obj/machinery/computer/shuttle_console/ui_interact(mob/user)
	var/dat
	var/list/docks_z_level = global.all_docking_ports["[z]"]
	dat += "Available docks:<br>"
	for(var/datum/dock/port in docks_z_level)
		dat += "<a href='byond://?src=\ref[src];dock=[port.dock_id]'>Dock: [port.name]; Direction: [port.dir]; Size: [port.size]; X: [port.landing_coords["x"]]; Y: [port.landing_coords["y"]]</a><br>"

	dat += "<br>Choose airlock:<br>"
	for(var/datum/dock/airlock in Shuttle.airlocks)
		dat += "<a href='byond://?src=\ref[src];airlock=[airlock.dock_id]'>Direction: [airlock.dir]; Size: [airlock.size]; X: [airlock.landing_coords["x"]]; Y: [airlock.landing_coords["y"]]</a><br>"


	dat += "<a href='byond://?src=\ref[src];fly=1'>Перелёт</a><br>"

	var/datum/browser/popup = new(user, "flightcomputer", "[capitalize(CASE(src, NOMINATIVE_CASE))]", 365, 200)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/shuttle_console/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	var/result = FALSE
	if(href_list["dock"])
		var/DockNum = text2num(href_list["dock"])
		if(DockNum)
			var/list/docks_z_level = global.all_docking_ports["[z]"]
			StationDock = get_dock_by_id(docks_z_level, DockNum)
			to_chat(usr, "<span class='notice'>Выбран стыковочный шлюз [StationDock.name].</span>")
	else if(href_list["airlock"])
		var/datum/dock/DockNum = text2num(href_list["airlock"])
		if(DockNum)
			ShuttleDock = get_dock_by_id(Shuttle.airlocks, DockNum)
			to_chat(usr, "<span class='notice'>Выбран [ShuttleDock.size == 2 ? "двойной" : "одинарный"] стыковочный шлюз [dir2text(ShuttleDock.dir)].</span>")
	else if(href_list["fly"])
		if(!ShuttleDock || !StationDock)
			to_chat(usr, "<span class='notice'>Не выбран пункт назначения.</span>")
			return
		if(Shuttle.dockedTo && StationDock == Shuttle.dockedTo)
			to_chat(usr, "<span class='notice'>Шаттл уже пристыкован к выбранному шлюзу.</span>")
			return

		if(StationDock.occupied || !Shuttle.try_move(ShuttleDock, StationDock))
			to_chat(usr, "Невозможно пристыковаться к выбранному доку.")
			return

	if(result)
		lastMove = world.time
		to_chat(usr, "<span class='notice'>Шаттл получил запрос и будет отправлен в ближайшее время.</span>")

	updateUsrDialog()





/obj/effect/docking_port
	name = "dockName"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "docking_port"

/obj/effect/docking_port/atom_init()
	. = ..()
	setup_port()

	return INITIALIZE_HINT_QDEL

/obj/effect/docking_port/proc/setup_port()
	var/list/z_layer_docks = global.all_docking_ports["[z]"]
	if(!z_layer_docks)
		global.all_docking_ports["[z]"] = list()

	var/datum/dock/added = add_docking_port(name, dir, x, y, z, global.all_docking_ports["[z]"])
	if(added)
		global.all_docking_ports["[z]"] += added


/obj/structure/landing_pole
	name = "Landing Area Pole"
	desc = "Обозначает границы посадочной площадки."

	icon = 'icons/obj/shuttle.dmi'
	icon_state = "landing_pole"

	var/datum/dock/landing_pad/Landing

	var/trying_to_setup_pad = FALSE

/obj/structure/landing_pole/atom_init()
	. = ..()

	if(anchored && !Landing)
		setup_pad()

/obj/structure/landing_pole/proc/setup_pad()
	trying_to_setup_pad = TRUE
	var/list/outcome = try_setup_field(global.cardinal, prev_dir = list(EAST, WEST))

	if(!outcome.len)
		return

	outcome -= src


	var/max_x = 0
	var/min_x = 255
	var/max_y = 0
	var/min_y = 255

	for(var/obj/structure/landing_pole/Pole in outcome)
		if(Pole.x < min_x)
			min_x = Pole.x
		else if(Pole.x > max_x)
			max_x = Pole.x

		if(Pole.y < min_y)
			min_y = Pole.y
		else if(Pole.y > max_y)
			max_y = Pole.y

	var/bounds_x = max_x - min_x + 1
	var/bounds_y = max_y - min_y + 1

	var/turf/T = loc
	var/area/A = T.loc

	var/datum/dock/landing_pad/New_Pad = new(A.name, NORTH, min_x, min_y, z, bounds_x, bounds_y)

	New_Pad.connect_to(outcome)
	global.all_docking_ports["[z]"] += New_Pad

/obj/structure/landing_pole/proc/try_setup_field(list/directions, prev_dir = null)
	if(!directions.len)
		return list(src)
	var/list/outcome = list()
	choose_direction:
		for(var/direction in directions - prev_dir)
			var/obj/structure/landing_pole/NextPole
			var/turf/T = get_turf(src)
			for(var/dist in 1 to 15)
				T = get_step(T, direction)
				if(!T || T.density)
					continue choose_direction
				NextPole = locate(/obj/structure/landing_pole) in T
				if(NextPole && NextPole.anchored && !NextPole.Landing)
					break
				NextPole = null

			if(!NextPole)
				return list()

			outcome = NextPole.try_setup_field(directions - direction, prev_dir = global.reverse_dir[direction])

			if(!outcome.len)
				continue
			break

	if(!outcome.len)
		return list()

	return outcome += src

/obj/structure/landing_pole/proc/landing_destroyed()
	Landing = null

/obj/structure/landing_pole/proc/connect_landing(datum/dock/landing_pad/Land)
	Landing = Land
	trying_to_setup_pad = FALSE

	lights_on()

/obj/structure/landing_pole/proc/disconnect_landing()
	Landing = null
	glow_icon_state = null

	lights_off()

/obj/structure/landing_pole/proc/landing_lights_on()
	set_light(0)
	glow_icon_state = "landing_light_running"
	exposure_icon_state = "rotating_cones"

	set_light(2, 10, COLOR_RED)

	update_bloom()

	addtimer(CALLBACK(src,PROC_REF(landing_lights_off)), 10 SECONDS)

/obj/structure/landing_pole/proc/landing_lights_off()
	lights_off()

	if(Landing)
		lights_on()
		return

/obj/structure/landing_pole/proc/lights_on()
	glow_icon_state = "landing_light"

	set_light(2, 3, COLOR_GREEN)

/obj/structure/landing_pole/proc/lights_off()
	glow_icon_state = null
	exposure_icon_state = null
	set_light(0)

/obj/structure/landing_pole/attack_hand()
	if(!Landing && !trying_to_setup_pad)
		setup_pad()
	..()

/obj/structure/landing_pole/attackby(obj/item/W, mob/user)
	if(iswrenching(W))
		if(!anchored)
			if(!isturf(src.loc) || isspaceturf(src.loc))
				return

		anchored = !anchored
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)

		if(Landing)
			Landing.pole_destroyed()
