/datum/map_generator_module/flora/forest
	turf_type = /turf/environment/grass

/datum/map_generator_module/flora/forest/place_flora(turf/T, noise)
	var/result
	switch(noise)
		if (0 to 60)
			result = "lake"
		if (61 to 200)
			if(prob(10))
				result = "trees"
			else
				result = "flora"
		if (201 to 255)
			result = "rock"

	switch(result)
		if("flora")
			if(prob(20))
				return FALSE

			var/grass = pick(/obj/structure/flora/ausbushes/fullgrass, /obj/structure/flora/ausbushes/sparsegrass)

			var/bush = pick(typesof(/obj/structure/flora/ausbushes) - list(/obj/structure/flora/ausbushes/fullgrass, /obj/structure/flora/ausbushes/sparsegrass) + typesof(/obj/structure/flora/junglebush) + /obj/structure/flora/rock/jungle)

			new grass(T)
			new bush(T)

			if(prob(1) && prob(5))
				new /mob/living/simple_animal/hostile/mimic/copy/flora(T)

		if("trees")
			if(prob(80))
				new /obj/structure/flora/tree/jungle(T)
			else
				new /obj/structure/flora/tree/jungle/small(T)
		if("lake")
			T.ChangeTurf(/turf/environment/grass/lake)

		if("rock")
			T.ChangeTurf(/turf/simulated/mineral/random/caves/high_chance)
		else
			return FALSE

	return TRUE

/datum/map_generator_module/border/tree
	spawnableAtoms = list(/obj/structure/flora/tree/jungle/unbreakable = 100)
