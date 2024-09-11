//separate dm since hydro is getting bloated already

/obj/structure/glowshroom
	name = "glowshroom"
	anchored = TRUE
	opacity = 0
	density = FALSE
	icon = 'icons/obj/lighting.dmi'
	icon_state = "glowshroomf"
	layer = 2.1
	light_power = 0.7
	light_color = "#80b82e"

	max_integrity = 30
	resistance_flags = CAN_BE_HIT

	var/potency = 30
	var/delay = 1200
	var/floor = 0
	var/yield = 3
	var/spreadChance = 40
	var/spreadIntoAdjacentChance = 60
	var/evolveChance = 2
	var/lastTick = 0
	var/spreaded = 1

/obj/structure/glowshroom/single
	spreadChance = 0

/obj/structure/glowshroom/atom_init()

	. = ..()

	set_dir(CalcDir())

	if(!floor)
		switch(dir) //offset to make it be on the wall rather than on the floor
			if(NORTH)
				pixel_y = 32
			if(SOUTH)
				pixel_y = -32
			if(EAST)
				pixel_x = 32
			if(WEST)
				pixel_x = -32
		icon_state = "glowshroom[rand(1,3)]"
	else //if on the floor, glowshroom on-floor sprite
		icon_state = "glowshroomf"

	START_PROCESSING(SSobj, src)

	set_light(round(potency/10), light_power, light_color)
	lastTick = world.timeofday

/obj/structure/glowshroom/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/glowshroom/process()
	if(!spreaded)
		return
	STOP_PROCESSING(SSobj, src)
	if(((world.timeofday - lastTick) > delay) || ((world.timeofday - lastTick) < 0))
		lastTick = world.timeofday
		spreaded = 0

		for(var/i=1,i<=yield,i++)
			if(prob(spreadChance))
				var/list/possibleLocs = list()
				var/spreadsIntoAdjacent = 0

				if(prob(spreadIntoAdjacentChance))
					spreadsIntoAdjacent = 1

				for(var/turf/simulated/floor/plating/airless/asteroid/earth in view(3,src))
					if(spreadsIntoAdjacent || !locate(/obj/structure/glowshroom) in view(1,earth))
						possibleLocs += earth

				if(!possibleLocs.len)
					break

				var/turf/newLoc = pick(possibleLocs)

				var/shroomCount = 0 //hacky
				var/placeCount = 1
				for(var/obj/structure/glowshroom/shroom in newLoc)
					shroomCount++
				for(var/wallDir in cardinal)
					var/turf/isWall = get_step(newLoc,wallDir)
					if(isWall.density)
						placeCount++
				if(shroomCount >= placeCount)
					continue

				var/obj/structure/glowshroom/child = new /obj/structure/glowshroom(newLoc)
				child.potency = potency
				child.yield = yield
				child.delay = delay
				child.modify_max_integrity(get_integrity())

				spreaded++

		if(prob(evolveChance)) //very low chance to evolve on its own
			potency += rand(4,6)

/obj/structure/glowshroom/proc/CalcDir(turf/location = loc)
	//set background = 1
	var/direction = 16

	for(var/wallDir in cardinal)
		var/turf/newTurf = get_step(location,wallDir)
		if(newTurf.density)
			direction |= wallDir

	for(var/obj/structure/glowshroom/shroom in location)
		if(shroom == src)
			continue
		if(shroom.floor) //special
			direction &= ~16
		else
			direction &= ~shroom.dir

	var/list/dirList = list()

	for(var/i=1,i<=16,i <<= 1)
		if(direction & i)
			dirList += i

	if(dirList.len)
		var/newDir = pick(dirList)
		if(newDir == 16)
			floor = 1
			newDir = 1
		return newDir

	floor = 1
	return 1

/obj/structure/glowshroom/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_type == BURN && damage_amount)
		playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/glowshroom/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		take_damage(5, BURN, FIRE, FALSE)

/obj/structure/glowshroom/turn_light_off()
	visible_message("<span class='warning'>\The [src] withers away!</span>")
	qdel(src)
