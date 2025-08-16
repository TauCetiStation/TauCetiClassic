var/global/dock_ids = 1
/datum/dock
	var/name = "DockName"
	var/dir
	var/size = 1
	var/X
	var/Y
	var/Z

	var/dock_id = 1

/datum/dock/New(name, dir, X, Y, Z)
	src.name = name
	src.dir = dir
	src.X = X
	src.Y = Y
	src.Z = Z

	dock_id = dock_ids
	dock_ids++

/datum/dock/proc/dock()
	return bolt_unbolt(FALSE)

/datum/dock/proc/undock()
	return bolt_unbolt(TRUE)

/datum/dock/proc/bolt_unbolt(bolt = TRUE)
	var/turf/T = locate(X, Y, Z)
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


	for(var/turf/T in turfs_to_check)
		for(var/obj/machinery/door/Door in T)
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
				if(!(port.X - x in list(1, -1)))
					continue

				port.size = 2
				if(port.X > x)
					port.X = x

				return

			if(EAST, WEST)
				if(!(port.Y - y in list(1, -1)))
					continue

				port.size = 2
				if(port.Y > y)
					port.Y = y

				return

	return new/datum/dock(name, dir, x, y, z)


/datum/shuttle
	var/name = "ShuttleName"
	var/grid_id

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

/datum/shuttle/New(obj/machinery/computer/shuttle_console/Cons, grid)
	Console = Cons
	name = Cons.shuttleName

	grid_id = grid

	try_generate_shuttle()

/datum/shuttle/proc/try_generate_shuttle()
	var/turf/Starting = get_turf(Console)
	if(!Starting.grid_id)
		qdel(src)

	tiles = list()
	outer_shell = list()
	airlocks = list()

	tiles[Starting] = list("x" = 0, "y" = 0)
	check_tile_neighbours(Starting, 0, 0)

	ShuttleArea = create_shuttle_area()

/datum/shuttle/proc/check_tile_neighbours(turf/T, x_offset, y_offset)
	var/turf/CheckingTurf

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

			var/obj/machinery/door/Airlock = locate(/obj/machinery/door) in T.contents
			if(Airlock)
				var/datum/dock/added = add_docking_port(name, mask_params[1], x_offset + Console.x, y_offset + Console.y, Console.z, airlocks)
				if(added)
					airlocks[added] = list("x" = x_offset, "y" = y_offset)


/datum/shuttle/proc/create_shuttle_area()
	var/area/shuttle/A = new
	A.name = name
	A.tag="[A.type]_[md5(name)]"
	A.power_equip = 0
	A.power_light = 0
	A.power_environ = 0
	for(var/turf/T in tiles)
		var/area/old_area = T.loc
		if(old_area)
			T.under_shuttle_area = old_area
			old_area.contents -= T

		A.contents += T
		T.change_area(old_area, A)
	A.update_areasize()
	A.power_change()

	return A


/datum/shuttle/proc/check_docked()
	var/list/z_level_docks = global.all_docking_ports["[Console.z]"]
	for(var/datum/dock/dock in z_level_docks)
		for(var/datum/dock/port in airlocks)
			if(dock.dir != angle2dir(dir2angle(port.dir) + 180))
				continue

			var/turf/T = get_step(locate(dock.X, dock.Y, dock.Z), dock.dir)
			if(!T || T.x != (port.X) || T.y != (port.Y))
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

/datum/shuttle/proc/try_move(datum/dock/DockBy, datum/dock/DockTo)
	var/rotation = dir2angle(DockTo.dir) - dir2angle(DockBy.dir) + 180
	if(rotation < 0)
		rotation += 360

	var/list/moving_order = check_dock(DockBy, DockTo, rotation)

	if(!moving_order)
		return FALSE

	undock()

	for(var/list/MovingList in moving_order)
		var/Thing = MovingList[1]
		var/turf/Destination_Turf = MovingList[2]
		var/list/new_relative_coordinates = MovingList[3]

		if(istype(Thing, /turf))
			var/turf/T = Thing
			var/old_icon_state1 = T.icon_state
			var/old_icon1 = T.icon
			Destination_Turf = T.Shuttle_MoveTurf(Destination_Turf)

			Destination_Turf.prev_dir = Destination_Turf.dir
			Destination_Turf.set_dir(turn(Destination_Turf.dir, -rotation))

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

			ShuttleArea.contents -= T
			ShuttleArea.contents += Destination_Turf

			for(var/obj/O in T)
				if(istype(O, /obj/effect/portal))
					qdel(O)
					continue
				if(!O.simulated)
					continue
				O.forceMove(Destination_Turf)
				O.set_dir(turn(O.dir, -rotation))
				O.update_parallax_contents()
			for(var/mob/M in T)
				if(!istype(M,/mob) || istype(M, /mob/camera)) continue // If we need to check for more mobs, I'll add a variable
				M.forceMove(Destination_Turf, TRUE, TRUE)
				M.update_parallax_contents()
				if(!M.buckled)
					M.set_dir(turn(M.dir, -rotation))


		else
			var/obj/structure/Struct = Thing
			outer_shell[Struct] = new_relative_coordinates
			Struct.forceMove(Destination_Turf)
			Struct.set_dir(turn(Struct.dir, -rotation))

	dock(DockBy, DockTo)


/datum/shuttle/proc/check_dock(datum/dock/DockBy, datum/dock/DockTo, rotation)
	var/list/relative_dock_coordinates = apply_rotation_to_relative_coordinates(airlocks[DockBy], rotation)
	var/turf/destination_turf = get_step(locate(DockTo.X, DockTo.Y, DockTo.Z), DockTo.dir)
	var/list/destination_turf_coordinates = list("x" = destination_turf.x, "y" = destination_turf.y, "z" = destination_turf.z)

	var/list/moving_order = list()// list(movingObject, destinationTurf, newRelativeCoordinates)

	var/list/relative_object_coordinates
	var/turf/Destination
	for(var/turf/T in tiles)
		relative_object_coordinates = apply_rotation_to_relative_coordinates(tiles[T], rotation)
		Destination = locate(destination_turf_coordinates["x"] + relative_object_coordinates["x"] - relative_dock_coordinates["x"], destination_turf_coordinates["y"] + relative_object_coordinates["y"] - relative_dock_coordinates["y"], destination_turf_coordinates["z"])
		if(Destination.density)
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
		Airlock.X = destination_turf_coordinates["x"] + relative_object_coordinates["x"] - relative_dock_coordinates["x"]
		Airlock.Y = destination_turf_coordinates["y"] + relative_object_coordinates["y"] - relative_dock_coordinates["y"]
		Airlock.Z = destination_turf_coordinates["z"]

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
		dat += "<a href='byond://?src=\ref[src];dock=[port.dock_id]'>Dock: [port.name]; Direction: [port.dir]; Size: [port.size]; X: [port.X]; Y: [port.Y]</a><br>"

	dat += "<br>Choose airlock:<br>"
	for(var/datum/dock/airlock in Shuttle.airlocks)
		dat += "<a href='byond://?src=\ref[src];airlock=[airlock.dock_id]'>Direction: [airlock.dir]; Size: [airlock.size]; X: [airlock.X]; Y: [airlock.Y]</a><br>"


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

		if(!Shuttle.try_move(ShuttleDock, StationDock))
			to_chat(usr, "Невозможно пристыковаться к выбранному доку.")
			return

	if(result)
		lastMove = world.time
		to_chat(usr, "<span class='notice'>Шаттл получил запрос и будет отправлен в ближайшее время.</span>")

	updateUsrDialog()






var/global/list/all_docking_ports = list()

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
