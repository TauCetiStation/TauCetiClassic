/datum/map_generator_module/flora/trash
	turf_type = /turf/environment/ironsand
	persistance = 0.75

/datum/map_generator_module/flora/trash/place_flora(turf/T, noise)
	var/result
	switch(noise)
		if(120 to 125, 230 to 255)
			result = "rocks"
		if(0 to 40)
			result = "clearing"
		if(40 to 45, 115 to 120, 125 to 130, 225 to 230)
			result = "big_trash"
		if(45 to 50, 110 to 115, 130 to 135, 220 to 225)
			result = "trash"
		else
			result = "random"

	switch(result)
		if("rocks")
			T.ChangeTurf(/turf/simulated/mineral/airfull/junkyard)
		if("clearing")
			if(prob(30))
				new /obj/effect/glowshroom(T)
		if("big_trash")
			new /obj/random/scrap/dense_weighted(T)
		if("trash")
			if(prob(80))
				new /obj/random/scrap/sparse_weighted(T)
		if("random")
			T.surround_by_scrap()

	return TRUE

/datum/map_generator_module/bottom_layer/ironsand
	spawnableTurfs = list(/turf/environment/ironsand = 100)

/datum/map_generator_module/border/ironwall
	spawnableTurfs = list(/turf/unsimulated/wall/iron = 100)
