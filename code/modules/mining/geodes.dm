/datum/geode
	var/name
	var/wall_mineral
	var/wall_crystal
	var/floor_crystal
	var/items_inside
	var/gas_inside

	var/persistance = 1
	var/amplitude = 1
	var/octaves = 1

/datum/geode/proc/generate_geode_turf(turf/T, noise_level)
	return FALSE

/datum/geode/proc/generate_floor(turf/T)
	if(SSticker.current_state > GAME_STATE_SETTING_UP)
		T.ChangeTurf(/turf/simulated/floor/plating/airless/asteroid)
	else
		T = new/turf/simulated/floor/plating/airless/asteroid(T)
	spawn(2)
		T.update_overlays_full()

	var/turf/simulated/floor/plating/airless/asteroid/Floor = T
	if(prob(25) && floor_crystal)
		new floor_crystal(Floor)
	else if(items_inside)
		var/item_type = pickweight(items_inside)
		new item_type(Floor)

	if(!gas_inside)
		return

	var/datum/gas_mixture/environment = Floor.return_air()
	environment.adjust_gas_temp(gas_inside, rand(50, 100), rand(T0C - 100, T0C + 100))

	for(var/direction in global.cardinal)
		var/turf/G = get_step(T, direction)
		if(!isenvironmentturf(G))
			continue
		generate_wall(G)

/datum/geode/proc/generate_wall(turf/T)
	if(SSticker.current_state > GAME_STATE_SETTING_UP)
		T.ChangeTurf(/turf/simulated/mineral)
	else
		T = new/turf/simulated/mineral(T)
	var/turf/simulated/mineral/Wall = T
	Wall.mineral = wall_mineral
	Wall.UpdateMineral()
	Wall.crystal_type = wall_crystal

	spawn(2)
		Wall.generate_crystals()

/datum/geode/phoron
	name = "Phoron"
	wall_mineral = /mineral/phoron
	wall_crystal = /obj/structure/crystal/wall/phoron
	floor_crystal = /obj/structure/crystal/phoron
	items_inside = list(/obj/item/weapon/ore/phoron = 1)
	gas_inside = "phoron"

	persistance = 0.05
	amplitude = 0.005
	octaves = 5

/datum/geode/phoron/generate_geode_turf(turf/T, noise_level)
	switch(noise_level)
		if(220 to 235)
			generate_floor(T)
			return TRUE

		if(209 to 219, 236 to 255)
			generate_wall(T)
			return TRUE

	return FALSE

/datum/geode/diamond
	name = "Phoron"
	wall_mineral = /mineral/diamond
	wall_crystal = /obj/structure/crystal/wall/diamond
	floor_crystal = /obj/structure/crystal/diamond
	items_inside = list(/obj/item/weapon/ore/diamond = 10, /obj/item/weapon/ore/coal = 1)
	gas_inside = "carbon_dioxide"

	persistance = 0.05
	amplitude = 0.005
	octaves = 5

/datum/geode/diamond/generate_geode_turf(turf/T, noise_level)
	switch(noise_level)
		if(235 to 255)
			generate_floor(T)
			return TRUE

		if(224 to 234)
			generate_wall(T)
			return TRUE

	return FALSE


/obj/structure/crystal
	name = "Basalt"
	icon = 'icons/turf/rocks.dmi'
	icon_state = "basalt"
	anchored = TRUE
	density = TRUE

	max_integrity = 5
	resistance_flags = CAN_BE_HIT

	var/ore_type = /obj/item/weapon/ore/coal
	var/icon_state_variants = 3

/obj/structure/crystal/atom_init()
	. = ..()

	icon_state = "[initial(icon_state)][rand(1, icon_state_variants)]"

/obj/structure/crystal/Destroy()
	new ore_type(loc)

	..()

/obj/structure/crystal/phoron
	name = "Phoron Crystal"
	icon_state = "phoron"
	ore_type = /obj/item/weapon/ore/phoron
	icon_state_variants = 1

/obj/structure/crystal/wall/phoron
	name = "Phoron Crystal"
	icon_state = "phoron_wall"
	ore_type = /obj/item/weapon/ore/phoron
	icon_state_variants = 1

/obj/structure/crystal/diamond
	name = "Diamond Crystal"
	icon_state = "diamond"
	ore_type = /obj/item/weapon/ore/diamond
	icon_state_variants = 1

/obj/structure/crystal/wall/diamond
	name = "Diamond Crystal"
	icon_state = "diamond_wall"
	ore_type = /obj/item/weapon/ore/diamond
	icon_state_variants = 1
