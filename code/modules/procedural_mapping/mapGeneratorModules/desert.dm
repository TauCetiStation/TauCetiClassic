/datum/map_generator_module/flora/desert
	turf_type = /turf/environment/sand

/datum/map_generator_module/flora/desert/place_flora(turf/T, noise)
	var/result
	switch(noise)
		if (0 to 170)
			if(prob(1))
				result = "flora"
		if (171 to 255)
			result = "rock"

	switch(result)
		if("flora")
			if(prob(1))
				new /obj/structure/pit/closed/grave(T)
			else
				var/bush = pick(
					/obj/structure/flora/ausbushes,
					/obj/structure/flora/ausbushes/fernybush,
					/obj/structure/flora/ausbushes/palebush,
					/obj/structure/flora/ausbushes/sunnybush,
					/obj/structure/flora/ausbushes/grassybush,
					/obj/structure/flora/rock/jungle,
					/obj/structure/flora/junglebush)

				new bush(T)

				if(prob(1) && prob(5))
					new /mob/living/simple_animal/hostile/mimic/copy/flora(T)

		if("rock")
			T.ChangeTurf(/turf/simulated/mineral/random/caves/high_chance)
		else
			return FALSE

	return TRUE

/datum/map_generator_module/border/rock
	spawnableTurfs = list(/turf/unsimulated/wall/rock = 100)
