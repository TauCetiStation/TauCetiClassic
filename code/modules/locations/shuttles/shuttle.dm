#define SHUTTLE_RAM_DAMAGE 1
#define SHUTTLE_FLYING_TIME 30 SECONDS
#define SHUTTLE_DOCKING_TIME 3 SECONDS
var/global/dock_ids = 1
var/global/list/all_docking_ports = list() //Все докпорты и лендинги.
var/global/list/all_transit_spaces = list() //Транзитные лендинги на цк используемые для перелётов между слоями.
var/global/list/all_shuttles = list() //Все шаттлы.
/datum/dock
	var/name = "DockName"
	var/dir

	var/bounds_x = 1
	var/bounds_y = 1

	var/dock_id = 1


	var/occupied = FALSE //док занят стоящим на нём шаттлом.

	var/list/landing_coords = list("x" = 0, "y" = 0, "z" = 0)

	var/list/connected_things = list() //вещи, которые к доку привязаны. Пока используется для посадочных площадок.

	var/transit = FALSE //транзитный док - при стыковке с ним мы не открываем двери автоматически.

	var/reserved = FALSE //док зарезервирован и к нему летит шаттл.

	var/shuttleDock = FALSE

/datum/dock/landing_pad
	name = "PadName"

/datum/dock/proc/connect_to(list/Things)
	for(var/thing in Things)
		connected_things += thing
		RegisterSignal(thing, list(COMSIG_PARENT_QDELETING), PROC_REF(thing_destroyed))
	return

/datum/dock/landing_pad/connect_to(list/Things)
	connected_things = Things
	for(var/obj/structure/landing_pole/Pole in connected_things)
		RegisterSignal(Pole, list(COMSIG_PARENT_QDELETING), PROC_REF(thing_destroyed), Pole)
		RegisterSignal(Pole, list(COMSIG_MOVABLE_MOVED), PROC_REF(thing_destroyed))

		Pole.connect_landing(src)

/datum/dock/proc/thing_destroyed(atom/A)
	connected_things -= A
	if(shuttleDock)
		return

	for(var/atom/movable/thing in connected_things)
		if(thing.x != landing_coords["x"] || thing.y != landing_coords["y"] || thing.z != landing_coords["z"])
			thing.x = landing_coords["x"]
			thing.y = landing_coords["y"]
			thing.z = landing_coords["z"]

		switch(dir)
			if(NORTH, SOUTH)
				bounds_x = 1
			if(WEST, EAST)
				bounds_y = 1
		return
	qdel(src)

/datum/dock/landing_pad/thing_destroyed(atom/A)
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
	for(var/obj/structure/landing_pole/Pole in connected_things)
		Pole.landing_lights_on()

	..()

/datum/dock/landing_pad/end_landing()
	for(var/obj/structure/landing_pole/Pole in connected_things)
		Pole.landing_lights_off()

	..()

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

/datum/dock/proc/bolt_unbolt(bolt = TRUE) //Открываем/Зкарываем двери дока. Немного костыльно, лучше переписать на коннект как у лендингов.
	if(!connected_things.len)
		return

	for(var/obj/machinery/door/Door in connected_things)
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
				Unpowered.close()
				Unpowered.locked = 1
			else
				Unpowered.locked = 0

	return TRUE

/datum/dock/proc/prepare_landing() //Подготовиться к посадке. Пока только для лендингов - включаются лампочки посадочной площадки.
	reserved = TRUE
	addtimer(CALLBACK(src,PROC_REF(end_landing)), 5 SECONDS)
	return

/datum/dock/proc/end_landing() //Завершаем подготовку к посадке. Вырубаем лампочки у лендингов.
	reserved = FALSE
	return

/proc/get_dock_by_id(list/docks_list, dock_id)
	for(var/datum/dock/Dock in docks_list)
		if(Dock.dock_id != dock_id)
			continue

		return Dock

	return FALSE


/proc/add_docking_port(name, dir, x, y, z, list/docks_list) //Здесь мы проверяем есть ли на этом месте рядом уже док и если есть, то вместо добавления нового дока мы расширяем старый. Сделано пока для двойных шлюзов.
	var/turf/T = locate(x, y, z)
	if(!T)
		return
	var/airlock = locate(/obj/machinery/door) in T.contents
	if(!airlock)
		airlock = locate(/obj/structure/inflatable/door) in T.contents

	for(var/datum/dock/port in docks_list)
		if(port.landing_coords["x"] == x && port.landing_coords["y"] == y && port.landing_coords["z"] == z)
			return FALSE
		if(port.dir != dir)
			continue

		switch(dir)
			if(NORTH, SOUTH)
				if(!((port.landing_coords["x"] - x) in list(1, -1)))
					continue

				if(port.bounds_x > 1 || port.bounds_y > 1)
					break

				port.bounds_x = 2
				if(port.landing_coords["x"] > x)
					port.landing_coords["x"] = x
				if(airlock)
					port.connect_to(list(airlock))
				return

			if(EAST, WEST)
				if(!((port.landing_coords["y"] - y) in list(1, -1)))
					continue

				if(port.bounds_x > 1 || port.bounds_y > 1)
					break

				port.bounds_y = 2
				if(port.landing_coords["y"] > y)
					port.landing_coords["y"] = y
				if(airlock)
					port.connect_to(list(airlock))
				return

	var/datum/dock/newport = new/datum/dock(name, dir, x, y, z)
	if(airlock)
		newport.connect_to(list(airlock))
	return newport

/proc/get_shuttle_by_id(grid_id)
	for(var/datum/shuttle/Shuttle in all_shuttles)
		if(Shuttle.grid_id != grid_id)
			continue

		return Shuttle

	return null


/datum/shuttle
	var/name = "Shuttle"
	var/grid_id

	var/dir
	var/z_level

	var/list/tiles //турфы шаттла.
	var/list/outer_shell //Внешние стены-объекты шаттла.
	var/list/airlocks //собственные доки шаттла которыми он стыкуется.

	var/list/nearest_mask = list(
							                   list(NORTH, 0, 1),
							  list(WEST, -1, 0),                 list(EAST, 1, 0),
							                   list(SOUTH, 0, -1)
							)

	var/datum/dock/dockedBy //Док, которым мы пристыкованы.
	var/datum/dock/dockedTo //Док, к которому мы пристыкованы.

	var/area/shuttle/ShuttleArea //Область шаттла.

	var/bounds_x
	var/bounds_y

	var/list/min_cords = list("x" = 0, "y" = 0)
	var/list/max_cords = list("x" = 0, "y" = 0)

	var/datum/dock/Birthplace //Док в котором шаттл был создан. Нужен для антажных и прочих ЦК шаттлов чтобы иметь возможность напрямую в него вернуться откуда угодно.
	var/list/StoredDestinations = list() //Список z-слоёв на которые шаттл может перемещаться. Изначально наполняется Станционным и Шахтёрским слоём.

	var/is_moving = FALSE //Шаттл находится в движении.

/datum/shuttle/New(obj/machinery/computer/shuttle_console/Cons, grid)
	dir = Cons.dir
	z_level = Cons.z
	name = Cons.shuttleName

	grid_id = grid

	var/turf/Starting = get_turf(Cons)

	try_generate_shuttle(Starting)
	ShuttleArea = create_shuttle_area()
	ShuttleArea.power_change()
	check_docked()

	all_shuttles += src

	StoredDestinations += list(list("name" = ZTRAIT_STATION, "z" = SSmapping.level_by_trait(ZTRAIT_STATION)))
	StoredDestinations += list(list("name" = ZTRAIT_MINING, "z" = SSmapping.level_by_trait(ZTRAIT_MINING)))

/datum/shuttle/Destroy()
	all_shuttles -= src

	for(var/datum/dock/Airlock in airlocks)
		qdel(Airlock)

	ShuttleArea.contents = null
	qdel(ShuttleArea)

	return ..()

/datum/shuttle/proc/try_generate_shuttle(turf/Starting) //Генерирует шаттл с нуля.
	if(!Starting.grid_id)
		Starting.grid_id = grid_id

	tiles = list()
	outer_shell = list()
	airlocks = list()

	tiles[Starting] = list("x" = 0, "y" = 0)
	check_tile_neighbours(Starting, 0, 0, Starting)

	bounds_x = max_cords["x"] - min_cords["x"] + 1
	bounds_y = max_cords["y"] - min_cords["y"] + 1

/datum/shuttle/proc/recalculate_bounds()
	min_cords = list("x" = 0, "y" = 0)
	max_cords = list("x" = 0, "y" = 0)

	var/list/allthings = tiles + outer_shell

	for(var/Thing in allthings)
		var/list/thing_cordinates = allthings[Thing]

		if(thing_cordinates["x"] > max_cords["x"])
			max_cords["x"] = thing_cordinates["x"]

		if(thing_cordinates["x"] < min_cords["x"])
			min_cords["x"] = thing_cordinates["x"]

		if(thing_cordinates["y"] > max_cords["y"])
			max_cords["y"] = thing_cordinates["y"]

		if(thing_cordinates["y"] < min_cords["y"])
			min_cords["y"] = thing_cordinates["y"]

	bounds_x = max_cords["x"] - min_cords["x"] + 1
	bounds_y = max_cords["y"] - min_cords["y"] + 1

/datum/shuttle/proc/check_tile_neighbours(turf/T, x_offset, y_offset, turf/Original) //Проходится по всем тайлам вокруг пока не добавит все тайлы, стены и докпорты.
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
				check_tile_neighbours(CheckingTurf, x_offset + mask_params[2], y_offset + mask_params[3], Original)
				continue

			for(var/obj/structure/Struct in CheckingTurf.contents)
				if(Struct in outer_shell)
					continue checking_directions
				if((!istype(Struct, /obj/structure/window/shuttle) && !istype(Struct, /obj/structure/object_wall)) || Struct.grid_id != grid_id)
					continue

				outer_shell[Struct] = list("x" = x_offset + mask_params[2], "y" = y_offset + mask_params[3])
				check_tile_neighbours(CheckingTurf, x_offset + mask_params[2], y_offset + mask_params[3], Original)
				continue checking_directions

				CHECK_TICK

			var/obj/machinery/door/Airlock = locate(/obj/machinery/door) in T.contents
			if(Airlock)
				var/datum/dock/added = add_docking_port(name, mask_params[1], x_offset + Original.x, y_offset + Original.y, Original.z, airlocks)
				if(added)
					added.shuttleDock = TRUE
					airlocks[added] = list("x" = x_offset, "y" = y_offset)

/datum/shuttle/proc/regenerate_airlocks()
	if(is_moving)
		return
	is_moving = TRUE
	undock()

	for(var/datum/dock/Dock in airlocks)
		qdel(Dock)

	airlocks = list()

	for(var/turf/T in tiles)
		check_for_airlocks(T)

	check_docked()
	is_moving = FALSE

/datum/shuttle/proc/check_for_airlocks(turf/T, x_offset, y_offset, turf/Original)
	var/turf/CheckingTurf

	var/obj/machinery/door/Airlock = locate(/obj/machinery/door) in T.contents
	if(!Airlock)
		return

	var/list/coords = tiles[T]

	checking_directions:
		for(var/list/mask_params in nearest_mask)
			CheckingTurf = get_step(T, mask_params[1])

			if(CheckingTurf in tiles)
				continue

			for(var/obj/structure/Struct in CheckingTurf.contents)
				if(Struct in outer_shell)
					continue checking_directions

			var/datum/dock/added = add_docking_port(name, mask_params[1], x_offset + Original.x, y_offset + Original.y, Original.z, airlocks)
			if(!added)
				return

			added.shuttleDock = TRUE
			airlocks[added] = list("x" = coords["x"], "y" = coords["y"])


/datum/shuttle/proc/create_shuttle_area() //Создаётся собственная область шаттла.
	var/area/shuttle/new_shuttle/A = new
	A.name = name
	A.tag="[A.type]_[md5(name+grid_id)]"
	for(var/turf/T in tiles)
		var/area/old_area = T.loc
		if(old_area)
			T.under_shuttle_area = old_area

		A.contents += T
		T.change_area(old_area, A)
	A.update_areasize()

	return A


/datum/shuttle/proc/check_docked() //Единичная проверка на то, пристыкован ли наш только что созданный шаттл.
	if(dockedBy && dockedTo)
		return

	var/list/z_level_docks = global.all_docking_ports["[z_level]"]
	for(var/datum/dock/landing_pad/Pad in z_level_docks)
		var/datum/dock/port = pick(airlocks)
		if(!(InRange(port.landing_coords["x"], list(Pad.landing_coords["x"], Pad.landing_coords["x"] + Pad.bounds_x)) && InRange(port.landing_coords["y"], list(Pad.landing_coords["y"], Pad.landing_coords["y"] + Pad.bounds_y))))
			continue
		dock(port, Pad)
		if(is_centcom_level(z_level))
			Birthplace = Pad
		return

	for(var/datum/dock/dock in z_level_docks)
		for(var/datum/dock/port in airlocks)
			if(dock.dir != global.reverse_dir[port.dir])
				continue

			var/turf/T = get_step(locate(dock.landing_coords["x"], dock.landing_coords["y"], dock.landing_coords["z"]), dock.dir)
			if(!T || T.x != (port.landing_coords["x"]) || T.y != (port.landing_coords["y"]))
				continue

			dock(port, dock)
			if(is_centcom_level(z_level))
				Birthplace = dock
			return

/datum/shuttle/proc/dock(datum/dock/docked_by, datum/dock/docked_to)
	if(!(is_centcom_level(docked_to.landing_coords["z"]) && docked_to.transit))
		is_moving = FALSE
	dockedBy = docked_by
	if(!docked_to.transit)
		dockedBy.dock()

	dockedTo = docked_to
	dockedTo.dock()

/datum/shuttle/proc/undock()
	is_moving = TRUE
	dockedBy.undock()
	dockedBy = null

	dockedTo.undock()
	dockedTo = null

/datum/shuttle/proc/set_dir(new_dir) //Поворачиваем собственный дир шаттла и его внутренние координаты.
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

/datum/shuttle/proc/get_landing_pad_rotation(datum/dock/landing_pad/LandOn) //Получаем повороты для шаттла, чтобы он уместился на площадке.
	var/list/rotations = list()

	if(bounds_x <= LandOn.bounds_x && bounds_y <= LandOn.bounds_y)
		rotations += list(360, 180)

	if(bounds_x <= LandOn.bounds_y && bounds_y <= LandOn.bounds_x)
		rotations += list(90, 270)

	if(!rotations.len)
		return FALSE

	return pick(rotations)

/datum/shuttle/proc/check_can_move(datum/dock/DockTo) //Проверка на то, можем ли мы двигаться до дока.
	if(!DockTo)
		return FALSE

	if(is_moving)
		return FALSE

	if(DockTo.occupied || DockTo.reserved)
		return FALSE

	return TRUE

/datum/shuttle/proc/fly_to_dock(datum/dock/DockTo) //Перелёт до конкретного дока.
	if(!check_can_move(DockTo))
		return FALSE
	if(DockTo.landing_coords["z"] == z_level)
		for(var/datum/dock/ShuttleDock in airlocks)
			if(can_move_to(ShuttleDock, DockTo))
				return try_move(ShuttleDock, DockTo)
		return FALSE

	var/datum/dock/Transit
	for(var/datum/dock/landing_pad/Space in global.all_transit_spaces)
		if(!check_can_move(Space))
			continue
		Transit = Space
		break
	if(!Transit)
		return FALSE

	var/datum/dock/DockBy
	for(var/datum/dock/ShuttleDock in airlocks)
		if(!can_move_to(ShuttleDock, Transit) || !can_move_to(ShuttleDock, DockTo))
			continue
		DockBy = ShuttleDock
		break

	if(!DockBy)
		return FALSE

	DockTo.reserved = TRUE

	addtimer(CALLBACK(src,PROC_REF(end_transit), DockBy, DockTo), SHUTTLE_FLYING_TIME)

	return try_move(DockBy, Transit)

/datum/shuttle/proc/fly_to_z_level(z_lvl) //Перелёт до любой посадочной площадки слоя.
	if(z_lvl == z_level)
		return FALSE

	var/list/dockports = all_docking_ports["[z_lvl]"]

	var/list/landing_spaces = list()
	for(var/datum/dock/landing_pad/Pad in dockports)
		if(!check_can_move(Pad))
			continue
		landing_spaces += Pad
	if(!landing_spaces.len)
		return FALSE

	var/datum/dock/Transit
	for(var/datum/dock/landing_pad/Space in global.all_transit_spaces)
		if(!check_can_move(Space))
			continue
		Transit = Space
		break
	if(!Transit)
		return FALSE

	var/datum/dock/DockTo
	var/datum/dock/DockBy
	for(var/datum/dock/landing_pad/Pad in landing_spaces)
		for(var/datum/dock/ShuttleDock in airlocks)
			if(!can_move_to(ShuttleDock, Transit) || !can_move_to(ShuttleDock, Pad))
				continue
			DockBy = ShuttleDock
			break
		DockTo = Pad
		break

	if(!DockBy || !DockTo)
		return FALSE

	DockTo.reserved = TRUE

	addtimer(CALLBACK(src,PROC_REF(end_transit), DockBy, DockTo), SHUTTLE_FLYING_TIME)

	return try_move(DockBy, Transit)

/datum/shuttle/proc/end_transit(datum/dock/DockBy, datum/dock/DockTo)
	if(!try_move(DockBy, DockTo))
		is_moving = FALSE
		DockTo.reserved = FALSE

		var/list/destination = pick(StoredDestinations)
		fly_to_z_level(destination["z"])


/datum/shuttle/proc/can_move_to(datum/dock/DockBy, datum/dock/DockTo) //Проверка на то, можем ли мы пристыковаться к доку/площадке физически.
	var/list/moving_order
	var/rotation
	if(istype(DockTo, /datum/dock/landing_pad))
		rotation = get_landing_pad_rotation(DockTo)
		if(!rotation)
			return FALSE
		rotation = rotation % 360
		moving_order = check_pad(DockTo, rotation, only_check = TRUE)
	else
		rotation = (dir2angle(DockTo.dir) - dir2angle(global.reverse_dir[DockBy.dir])) % 360
		if(rotation < 0)
			rotation += 360

		moving_order = check_dock(DockBy, DockTo, rotation, only_check = TRUE)

	if(!moving_order)
		return FALSE

	return TRUE

/datum/shuttle/proc/try_move(datum/dock/DockBy, datum/dock/DockTo) //Начало движения шаттла к доку.
	var/list/moving_order
	var/rotation
	if(istype(DockTo, /datum/dock/landing_pad))
		rotation = get_landing_pad_rotation(DockTo)
		if(!rotation)
			return FALSE
		rotation = rotation % 360

		moving_order = check_pad(DockTo, rotation)
	else
		rotation = (dir2angle(DockTo.dir) - dir2angle(global.reverse_dir[DockBy.dir])) % 360
		if(rotation < 0)
			rotation += 360

		moving_order = check_dock(DockBy, DockTo, rotation)

	if(!moving_order)
		return FALSE
	undock()

	DockTo.prepare_landing()

	addtimer(CALLBACK(src,PROC_REF(shuttle_move), moving_order, rotation, DockBy, DockTo), SHUTTLE_DOCKING_TIME)
	return TRUE

/datum/shuttle/proc/shuttle_move(list/moving_order, rotation, datum/dock/DockBy, datum/dock/DockTo) //Перемещение шаттла и всего что в нём к доку.

	set_dir(turn(dir, -rotation))
	var/shake_dir = ShuttleArea.parallax_movedir ? global.reverse_dir[dir] : dir
	if(DockTo in global.all_transit_spaces)
		ShuttleArea.parallax_movedir = global.reverse_dir[dir]
	else
		ShuttleArea.parallax_movedir = 0

	for(var/list/MovingList in moving_order)
		var/turf/Destination_Turf = MovingList[2]
		for(var/atom/movable/Mov in Destination_Turf.contents)
			crush_object(Mov)

			CHECK_TICK

	var/list/mobs_to_shake = list()

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
				mobs_to_shake += M

				CHECK_TICK


		else if(istype(Thing, /obj/structure))
			var/obj/structure/Struct = Thing
			outer_shell[Struct] = new_relative_coordinates
			Struct.forceMove(Destination_Turf)
			Struct.set_dir(turn(Struct.dir, -rotation))

		else if(istype(Thing, /datum/dock))
			var/datum/dock/Airlock = Thing
			Airlock.landing_coords["x"] = Destination_Turf.x
			Airlock.landing_coords["y"] = Destination_Turf.y
			Airlock.landing_coords["z"] = Destination_Turf.z
			Airlock.dir = angle2dir(dir2angle(Airlock.dir) + rotation)
			airlocks[Airlock] = new_relative_coordinates

	for(var/mob/M in mobs_to_shake)
		shake_mob(M, shake_dir)

	z_level = DockTo.landing_coords["z"]

	addtimer(CALLBACK(src,PROC_REF(dock), DockBy, DockTo), SHUTTLE_DOCKING_TIME)


/datum/shuttle/proc/shake_mob(mob/M, fall_direction) //Дёргаем мобов торможением/разгоном.
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

/datum/shuttle/proc/crush_object(atom/movable/A) //Уничтожаем объекты под шаттлом.
	if(isliving(A))
		var/mob/living/mob_to_gib = A
		mob_to_gib.gib()
	else
		if(istype(A, /obj/singularity))
			return

		if(!A.anchored)
			var/turf/T = get_step(get_turf(A), dir)
			A.throw_at(T, 30, SHUTTLE_RAM_DAMAGE * (tiles.len + outer_shell.len))
			//A.take_damage(SHUTTLE_RAM_DAMAGE * (tiles.len + outer_shell.len), attack_dir = dir) //Не уверен или throw_at уже должен накидывать урон?
		else
			qdel(A)

/datum/shuttle/proc/check_pad(datum/dock/landing_pad/LandOn, rotation, only_check = FALSE) //Проверка возможности сесть на посадочную площадку.
	var/bounds_x_holder = (rotation in list(90, 270)) ? bounds_y : bounds_x
	var/bounds_y_holder = (rotation in list(90, 270)) ? bounds_x : bounds_y
	var/min_cords_holder = apply_rotation_to_relative_coordinates(min_cords, rotation)
	var/max_cords_holder = apply_rotation_to_relative_coordinates(max_cords, rotation)

	if(max_cords_holder["x"] < min_cords_holder["x"])
		var/hold = min_cords_holder["x"]
		min_cords_holder["x"] = max_cords_holder["x"]
		max_cords_holder["x"] = hold

	if(max_cords_holder["y"] < min_cords_holder["y"])
		var/hold = min_cords_holder["y"]
		min_cords_holder["y"] = max_cords_holder["y"]
		max_cords_holder["y"] = hold

	var/turf/destination_turf = locate(LandOn.landing_coords["x"] + round((LandOn.bounds_x - bounds_x_holder) / 2) - min_cords_holder["x"], LandOn.landing_coords["y"] + round((LandOn.bounds_y - bounds_y_holder) / 2) - min_cords_holder["y"], LandOn.landing_coords["z"])
	if(!destination_turf)
		return FALSE
	var/list/destination_turf_coordinates = list("x" = destination_turf.x, "y" = destination_turf.y, "z" = destination_turf.z)

	return generate_moving_order(destination_turf_coordinates, list(0, 0), rotation, only_check)

/datum/shuttle/proc/check_dock(datum/dock/DockBy, datum/dock/DockTo, rotation, only_check = FALSE) //Проверка возможности пристыковаться к доку.
	var/list/relative_dock_coordinates = apply_rotation_to_relative_coordinates(airlocks[DockBy], rotation)
	var/turf/destination_turf = get_step(locate(DockTo.landing_coords["x"], DockTo.landing_coords["y"], DockTo.landing_coords["z"]), DockTo.dir)
	if(!destination_turf)
		return FALSE
	var/list/destination_turf_coordinates = list("x" = destination_turf.x, "y" = destination_turf.y, "z" = destination_turf.z)

	return generate_moving_order(destination_turf_coordinates, relative_dock_coordinates, rotation, only_check)

/datum/shuttle/proc/generate_moving_order(list/destination_turf_coordinates, list/relative_dock_coordinates, rotation, only_check) //Проход по всем тайлам, стенам и шлюзам, проверка на то, помещаются ли они на месте и если да, то генерация листа перелёта в котором указан начальный турф, конечный турф и новые относительные координаты каждой части шаттла.
	var/list/moving_order = list()// list(movingObject, destinationTurf, newRelativeCoordinates)

	var/list/relative_object_coordinates
	var/turf/Destination
	for(var/turf/T in tiles)
		relative_object_coordinates = apply_rotation_to_relative_coordinates(tiles[T], rotation)
		Destination = locate(destination_turf_coordinates["x"] + relative_object_coordinates["x"] - relative_dock_coordinates["x"], destination_turf_coordinates["y"] + relative_object_coordinates["y"] - relative_dock_coordinates["y"], destination_turf_coordinates["z"])
		if(!Destination || Destination.density || locate(/obj/structure/window/shuttle) in Destination.contents || locate(/obj/structure/object_wall) in Destination.contents)
			return FALSE

		if(!only_check)
			moving_order += list(list(T, Destination, relative_object_coordinates))


	for(var/obj/structure/Struct in outer_shell)
		relative_object_coordinates = apply_rotation_to_relative_coordinates(outer_shell[Struct], rotation)
		Destination = locate(destination_turf_coordinates["x"] + relative_object_coordinates["x"] - relative_dock_coordinates["x"], destination_turf_coordinates["y"] + relative_object_coordinates["y"] - relative_dock_coordinates["y"], destination_turf_coordinates["z"])
		if(!Destination || Destination.density)
			return FALSE

		if(!only_check)
			moving_order += list(list(Struct, Destination, relative_object_coordinates))

	for(var/datum/dock/Airlock in airlocks)
		relative_object_coordinates = apply_rotation_to_relative_coordinates(airlocks[Airlock], rotation)
		Destination = locate(destination_turf_coordinates["x"] + relative_object_coordinates["x"] - relative_dock_coordinates["x"], destination_turf_coordinates["y"] + relative_object_coordinates["y"] - relative_dock_coordinates["y"], destination_turf_coordinates["z"])
		if(!Destination)
			return FALSE

		if(!only_check)
			moving_order += list(list(Airlock, Destination, relative_object_coordinates))

	return only_check ? TRUE : moving_order


/datum/shuttle/proc/apply_rotation_to_relative_coordinates(list/coordinates, rotation) //Крутим относительные координаты частей шаттла на градус.
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

/obj/effect/docking_port //Мапперская заглушка для создания докпорта.
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


/obj/effect/landing_pad //Мапперская заглушка для создания посадочной площадки.
	name = "Space"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "landing_pad"

	var/bounds_x = 0
	var/bounds_y = 0

	var/transit = FALSE

/obj/effect/landing_pad/atom_init()
	. = ..()
	if(bounds_x && bounds_y)
		setup_pad()

	return INITIALIZE_HINT_QDEL

/obj/effect/landing_pad/proc/setup_pad()
	var/list/z_layer_docks = global.all_docking_ports["[z]"]
	if(!z_layer_docks)
		global.all_docking_ports["[z]"] = list()

	var/area/A = get_area(src)
	var/padName = (A && (name == "padName")) ? A.name : name

	var/datum/dock/landing_pad/New_Pad = new(padName, NORTH, x, y, z, bounds_x, bounds_y)
	New_Pad.transit = transit
	global.all_docking_ports["[z]"] += New_Pad

/obj/effect/landing_pad/size10
	icon_state = "landing_pad_10"
	bounds_x = 10
	bounds_y = 10

/obj/effect/landing_pad/size20
	icon_state = "landing_pad_20"
	bounds_x = 20
	bounds_y = 20

/obj/effect/landing_pad/size30
	icon_state = "landing_pad_30"
	bounds_x = 30
	bounds_y = 30

/obj/effect/landing_pad/centcom_transit //Мапперская заглушка для создания транзитных областей на ЦК через которые шаттлы летят со слоя на слой.
	name = "Transit Space"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "landing_pad"

	bounds_x = 30
	bounds_y = 30

/obj/effect/landing_pad/centcom_transit/setup_pad()
	var/datum/dock/landing_pad/New_Pad = new(name, NORTH, x, y, z, bounds_x, bounds_y)
	New_Pad.transit = TRUE
	global.all_transit_spaces += New_Pad



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

	New_Pad.transit = FALSE
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
	exposure_icon_state = "rotating_cones" //Почему-то не работает. Не знаю почему, если выставить этот экспожур настенной лампе или мусорке - то будет работать. А у столбика нет.

	set_light(2, 10, COLOR_RED)

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
			Landing.thing_destroyed(src)


ADD_TO_GLOBAL_LIST(/obj/machinery/computer/shuttle_console, shuttle_consoles)
/obj/machinery/computer/shuttle_console
	name = "Shuttle Console"
	cases = list("консоль шаттла", "консоли шаттла", "консоли шаттла", "консоль шаттла", "консолью шаттла", "консоли шаттла")
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	state_broken_preset = "commb"
	state_nopower_preset = "comm0"
	//circuit = /obj/item/weapon/circuitboard/shuttle

	var/datum/shuttle/Shuttle
	var/shuttleName = "Shuttle"

	var/grid_id

/obj/machinery/computer/shuttle_console/proc/generate_shuttle()
	var/turf/T = get_turf(src)
	if(!T || !T.grid_id)
		return

	Shuttle = new /datum/shuttle(src, T.grid_id)

/obj/machinery/computer/shuttle_console/proc/try_find_shuttle()
	var/turf/T = get_turf(src)
	if(!T)
		return

	var/id_holder = null
	var/on_a_grid = FALSE

	if(grid_id)
		id_holder = grid_id
	if(T.grid_id)
		id_holder = T.grid_id
		on_a_grid = TRUE

	if(!id_holder)
		return
	Shuttle = get_shuttle_by_id(id_holder)
	if(!(Shuttle && on_a_grid))
		return

	Shuttle.regenerate_airlocks()


/obj/machinery/computer/shuttle_console/ui_interact(mob/user)
	if(!Shuttle)
		try_find_shuttle()
		if(!Shuttle)
			to_chat(user, "Ведётся поиск шаттла...")
			return

	tgui_interact(user)

/obj/machinery/computer/shuttle_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "ShuttleConsole", name)
		ui.open()

/obj/machinery/computer/shuttle_console/tgui_static_data(mob/user)
	var/list/data = list()
	data["nanomapPayload"] = SSmapping.tgui_nanomap_payload()

	var/list/birthplace_data = null
	if(Shuttle.Birthplace)
		birthplace_data = list("name" = Shuttle.Birthplace.name, "dir" = Shuttle.Birthplace.dir, "bounds_x" = Shuttle.Birthplace.bounds_x, "bounds_y" = Shuttle.Birthplace.bounds_y, "x" = Shuttle.Birthplace.landing_coords["x"], "y" = Shuttle.Birthplace.landing_coords["y"], "occupied" = Shuttle.Birthplace.occupied, "reserved" = Shuttle.Birthplace.reserved, "dock_id" = Shuttle.Birthplace.dock_id)

	data["birthplace"] = birthplace_data

	var/list/levels_data = list()
	for(var/list/level in Shuttle.StoredDestinations)
		levels_data += list(level)

	data["levels"] = levels_data

	data["shuttlename"] = Shuttle.name

	return data

/obj/machinery/computer/shuttle_console/tgui_data(mob/user)
	var/list/data = list()
	var/list/docks_data = list()
	if(!is_centcom_level(z))
		var/list/docks_z_level = global.all_docking_ports["[z]"]
		for(var/datum/dock/Dock in docks_z_level)
			docks_data += list(list("name" = Dock.name, "dir" = Dock.dir, "bounds_x" = Dock.bounds_x, "bounds_y" = Dock.bounds_y, "x" = Dock.landing_coords["x"], "y" = Dock.landing_coords["y"], "occupied" = Dock.occupied, "reserved" = Dock.reserved, "dock_id" = Dock.dock_id))

	data["docks"] = docks_data

	data["ismoving"] = Shuttle.is_moving

	data["docked_to_id"] = Shuttle.dockedTo ? Shuttle.dockedTo.dock_id : 0

	data["currentZ"] = z

	return data

/obj/machinery/computer/shuttle_console/tgui_act(action, params)
	. = ..()
	if(.)
		return

	if(action == "fly_to_dock")
		var/dock_id = text2num(params["dock_id"])
		var/list/docks_z_level = global.all_docking_ports["[z]"]
		if(!dock_id)
			return FALSE

		var/datum/dock/DockTo = get_dock_by_id(docks_z_level, dock_id)
		if(!DockTo)
			return FALSE

		if(!Shuttle.fly_to_dock(DockTo))
			to_chat(usr, "Невозможно пристыковаться к выбранному доку.")

		return TRUE

	if(action == "fly_to_level")
		var/level_num = text2num(params["level_id"])
		if(!level_num)
			return FALSE

		if(!Shuttle.fly_to_z_level(level_num))
			to_chat(usr, "Транзитные пути заняты.")

		return TRUE

/obj/machinery/computer/shuttle_console/attackby(obj/item/I, mob/user)
	if(!istype(I, /obj/item/weapon/disk/level_information))
		return ..()

	var/obj/item/weapon/disk/level_information/Disk = I

	if(!Shuttle)
		to_chat(user, "Нет шаттла для загрузки координат.")
		return

	Shuttle.StoredDestinations += list(Disk.sector_coordinates)
	qdel(Disk)
	to_chat(user, "Координаты сектора успешно загружены.")
	return


#undef SHUTTLE_DOCKING_TIME
#undef SHUTTLE_FLYING_TIME
#undef SHUTTLE_RAM_DAMAGE
