/datum/map_generator_module/flora/snow
	turf_type = /turf/environment/snow

/datum/map_generator_module/flora/snow/place_flora(turf/T, noise)
	var/result
	switch(noise)
		if (0 to 60)
			result = "ice"
		if (61 to 80)
			if(prob(1) && prob(5))
				result = "mine_rocks"
		if (81 to 200)
			if(prob(1) && prob(15))
				result = "mine_rocks"
			else
				result = "flora"
		if (201 to 255)
			if(prob(1))
				result = "mine_rocks"

	switch(result)
		if("flora")
			if(!prob(35))
				return FALSE
			var/snow_flora = pick(
				prob(65);/obj/structure/flora/grass/both,
				prob(35);/obj/structure/flora/bush,
				prob(10);/obj/structure/flora/tree/pine,
				prob(10);/obj/structure/flora/tree/dead
				)

			new snow_flora(T)

			if(prob(1) && prob(5))
				new /mob/living/simple_animal/hostile/mimic/copy/flora(T)

		if("mine_rocks")
			new /obj/structure/flora/mine_rocks(T)
		if("ice")
			T.ChangeTurf(/turf/environment/snow/ice)
		else
			return FALSE

	return TRUE

/datum/map_generator_module/bottom_layer/snow
	spawnableTurfs = list(/turf/environment/snow = 100)

/datum/map_generator_module/border/pine_tree
	spawnableAtoms = list(/obj/structure/flora/tree/pine/unbreakable = 100)
