
var/global/list/space_surprises = list(
	/obj/item/weapon/pickaxe/silver					= 4,
	/obj/item/weapon/pickaxe/drill					= 4,
	/obj/item/weapon/pickaxe/drill/jackhammer		= 4,
	/obj/item/weapon/sledgehammer					= 3,
	/obj/item/weapon/pickaxe/diamond				= 3,
	/obj/item/weapon/pickaxe/drill/diamond_drill	= 3,
	/obj/item/weapon/pickaxe/gold					= 3,
	/obj/item/weapon/gun/energy/laser/cutter		= 2,
	/obj/structure/closet/syndicate/resources		= 2,
	/obj/item/weapon/melee/energy/sword/pirate		= 1,
	/obj/mecha/working/ripley/mining				= 1
	)

var/global/list/spawned_surprises = list()

/proc/spawn_room(atom/start_loc,x_size,y_size,wall,floor , clean = 0 , name)
	var/list/room_turfs = list("walls"=list(),"floors"=list())

	//world << "Room spawned at [COORD(start_loc)]"
	if(!wall)
		wall = pick(/turf/simulated/wall/r_wall, /turf/simulated/wall, /obj/structure/alien/resin/wall, /turf/simulated/wall/mineral/sandstone)
	if(!floor)
		floor = pick(/turf/simulated/floor, /turf/simulated/floor/engine)

	for(var/x = 0,x<x_size,x++)
		for(var/y = 0,y<y_size,y++)
			var/turf/T
			var/cur_loc = locate(start_loc.x+x,start_loc.y+y,start_loc.z)
			if(clean)
				for(var/O in cur_loc)
					qdel(O)

			var/area/asteroid/artifactroom/A = new
			if(name)
				A.name = name
			else
				A.name = "Artifact Room #[start_loc.x][start_loc.y][start_loc.z]"



			if(x == 0 || x==x_size-1 || y==0 || y==y_size-1)
				if(wall == /obj/structure/alien/resin/wall)
					T = new floor(cur_loc)
					new /obj/structure/alien/resin/wall(T)
				else
					T = new wall(cur_loc)
					room_turfs["walls"] += T
			else
				T = new floor(cur_loc)
				room_turfs["floors"] += T

			A.contents += T


	return room_turfs

/proc/admin_spawn_room_at_pos()
	var/wall
	var/floor
	var/x = input("X position","X pos",usr.x) as num
	var/y = input("Y position","Y pos",usr.y) as num
	var/z = input("Z position","Z pos",usr.z) as num
	var/x_len = input("Desired length.","Length",5) as num
	var/y_len = input("Desired width.","Width",5) as num
	var/clean = input("Delete existing items in area?" , "Clean area?", 0) as num
	switch(tgui_alert(usr, "Wall type",, list("Reinforced wall","Regular wall","Resin wall")))
		if("Reinforced wall")
			wall=/turf/simulated/wall/r_wall
		if("Regular wall")
			wall=/turf/simulated/wall
		if("Resin wall")
			wall=/obj/structure/alien/resin/wall
	switch(tgui_alert(usr, "Floor type",, list("Regular floor","Reinforced floor")))
		if("Regular floor")
			floor=/turf/simulated/floor
		if("Reinforced floor")
			floor=/turf/simulated/floor/engine
	if(x && y && z && wall && floor && x_len && y_len)
		spawn_room(locate(x,y,z),x_len,y_len,wall,floor,clean)
	return


/proc/pick_valid_asteroid_room_spawn_turf(size_x, size_y)
	var/valid = FALSE
	var/iterator = 0
	var/list/turfs = get_area_turfs(/area/asteroid/mine/unexplored)
	var/turf/T

	if(!turfs.len)
		return FALSE

	while(!valid)
		valid = TRUE
		iterator++
		if(iterator > 100)
			return FALSE

		T=pick(turfs)
		if(!T)
			return FALSE

		var/list/surroundings = list()

		surroundings += range(7, locate(T.x,T.y,T.z))
		surroundings += range(7, locate(T.x+size_x,T.y,T.z))
		surroundings += range(7, locate(T.x,T.y+size_y,T.z))
		surroundings += range(7, locate(T.x+size_x,T.y+size_y,T.z))

		if(locate(/area/asteroid/mine/explored) in surroundings)			// +5s are for view range
			valid = FALSE
			continue

		if(locate(/turf/environment) in surroundings)
			valid = FALSE
			continue

		if(locate(/area/asteroid/artifactroom) in surroundings)
			valid = FALSE
			continue

		if(locate(/area/asteroid/geode) in surroundings)
			valid = FALSE
			continue

		if(locate(/turf/simulated/floor/plating/airless/asteroid) in surroundings)
			valid = FALSE
			continue

	if(!T)
		return FALSE

	return T

//////////////

/proc/make_mining_asteroid_secret(size = 5)
	var/turf/T = pick_valid_asteroid_room_spawn_turf(size, size)
	if(!T)
		return FALSE

	var/list/room = spawn_room(T,size,size,,,1)

	if(room)
		T = pick(room["floors"])
		if(T)
			var/surprise = null
			var/valid = FALSE
			while(!valid)
				surprise = pickweight(space_surprises)
				if(surprise in spawned_surprises)
					if(prob(20))
						valid = TRUE
					else
						continue
				else
					valid = TRUE

			spawned_surprises.Add(surprise)
			new surprise(T)

	return 1



/proc/make_mining_asteroid_geode()
	var/scale = rand(1, 5)

	var/turf/T = pick_valid_asteroid_room_spawn_turf((scale * 2) + 3, (scale * 2) + 3)
	if(!T)
		return FALSE
	var/turf/Center = locate(T.x + scale, T.y + scale, T.z)

	var/datum/geode/geode_datum = global.geode_by_type[pick(global.geode_by_type)]

	var/list/allturfs = list()
	var/list/allwalls = list()

	var/list/growing = list()
	growing += list(list(get_step(Center, WEST), scale, EAST))
	growing += list(list(get_step(Center, EAST), scale, WEST))
	growing += list(list(get_step(Center, NORTH), scale, SOUTH))
	growing += list(list(get_step(Center, SOUTH), scale, NORTH))

	for(var/i in 1 to 1000)
		if(!growing.len)
			break

		var/list/grow_turf = pop(growing)

		var/turf/simulated/floor/plating/airless/asteroid/Floor = new(grow_turf[1])

		var/area/asteroid/geode/A = new
		A.name = "Geode [geode_datum.name] #[Center.x][Center.y][Center.z]"
		A.contents += Floor

		allturfs += Floor

		if(prob(25))
			var/floor_crystal = geode_datum.floor_crystal
			new floor_crystal(Floor)
		else
			var/item_type = pickweight(geode_datum.items_inside)
			new item_type(Floor)

		for(var/new_dir in (global.cardinal - grow_turf[3]))
			var/turf/this_turf = get_step(Floor, new_dir)
			if(this_turf in allturfs)
				continue

			if(grow_turf[2] <= 0)
				allwalls += this_turf
				allturfs += this_turf
			else
				growing.Insert(1, list(list(this_turf, grow_turf[2] - 1, grow_turf[3])))

	for(var/turf/Wall in allwalls + Center)
		var/turf/simulated/mineral/NewWall = new(Wall)
		NewWall.mineral = geode_datum.wall_mineral
		NewWall.UpdateMineral()
		NewWall.crystal_type = geode_datum.wall_crystal

	var/turf/Floor = get_step(Center, NORTH)
	var/datum/gas_mixture/environment = Floor.return_air()
	environment.adjust_gas_temp(geode_datum.gas_inside, rand(allturfs.len * 50, allturfs.len * 100), rand(T0C - 100, T0C + 100))
