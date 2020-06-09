
var/global/list/space_surprises = list(		/obj/item/weapon/pickaxe/silver					=4,
											/obj/item/weapon/pickaxe/drill					=4,
											/obj/item/weapon/pickaxe/drill/jackhammer		=4,
											/obj/item/weapon/twohanded/sledgehammer			=3,
											/obj/item/weapon/pickaxe/diamond				=3,
											/obj/item/weapon/pickaxe/drill/diamond_drill	=3,
											/obj/item/weapon/pickaxe/gold					=3,
											/obj/item/weapon/pickaxe/plasmacutter			=2,
											/obj/structure/closet/syndicate/resources		=2,
											/obj/item/weapon/melee/energy/sword/pirate		=1,
											/obj/mecha/working/ripley/mining				=1
											)

var/global/list/spawned_surprises = list()

/proc/spawn_room(atom/start_loc,x_size,y_size,wall,floor , clean = 0 , name)
	var/list/room_turfs = list("walls"=list(),"floors"=list())

	//world << "Room spawned at [start_loc.x],[start_loc.y],[start_loc.z]"
	if(!wall)
		wall = pick(/turf/simulated/wall/r_wall,/turf/simulated/wall,/obj/structure/alien/resin/wall)
	if(!floor)
		floor = pick(/turf/simulated/floor,/turf/simulated/floor/engine)

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
	switch(alert("Wall type",null,"Reinforced wall","Regular wall","Resin wall"))
		if("Reinforced wall")
			wall=/turf/simulated/wall/r_wall
		if("Regular wall")
			wall=/turf/simulated/wall
		if("Resin wall")
			wall=/obj/structure/alien/resin/wall
	switch(alert("Floor type",null,"Regular floor","Reinforced floor"))
		if("Regular floor")
			floor=/turf/simulated/floor
		if("Reinforced floor")
			floor=/turf/simulated/floor/engine
	if(x && y && z && wall && floor && x_len && y_len)
		spawn_room(locate(x,y,z),x_len,y_len,wall,floor,clean)
	return


//////////////

/proc/make_mining_asteroid_secret(size = 5)
	var/valid = 0
	var/turf/T = null
	var/sanity = 0
	var/list/room = null
	var/list/turfs = null


	turfs = get_area_turfs(/area/asteroid/mine/unexplored)

	if(!turfs.len)
		return 0

	while(!valid)
		valid = 1
		sanity++
		if(sanity > 100)
			return 0

		T=pick(turfs)
		if(!T)
			return 0

		var/list/surroundings = list()

		surroundings += range(7, locate(T.x,T.y,T.z))
		surroundings += range(7, locate(T.x+size,T.y,T.z))
		surroundings += range(7, locate(T.x,T.y+size,T.z))
		surroundings += range(7, locate(T.x+size,T.y+size,T.z))

		if(locate(/area/asteroid/mine/explored) in surroundings)			// +5s are for view range
			valid = 0
			continue

		if(locate(/turf/space) in surroundings)
			valid = 0
			continue

		if(locate(/area/asteroid/artifactroom) in surroundings)
			valid = 0
			continue

		if(locate(/turf/simulated/floor/plating/airless/asteroid) in surroundings)
			valid = 0
			continue

	if(!T)
		return 0

	room = spawn_room(T,size,size,,,1)

	if(room)
		T = pick(room["floors"])
		if(T)
			var/surprise = null
			valid = 0
			while(!valid)
				surprise = pickweight(space_surprises)
				if(surprise in spawned_surprises)
					if(prob(20))
						valid++
					else
						continue
				else
					valid++

			spawned_surprises.Add(surprise)
			new surprise(T)

	return 1
