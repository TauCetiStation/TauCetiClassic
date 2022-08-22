/datum/map_generator_module/flora/trash
	turf_type = /turf/environment/ironsand

/datum/map_generator_module/flora/trash/place_flora(turf/T, noise)
	var/result
	switch(noise)
		if(120 to 125, 230 to 255)
			result = "rocks"
		if(0 to 20)
			result = "clearing"
		if(20 to 25, 115 to 120, 125 to 130, 225 to 230)
			result = "big_trash"
		if(25 to 30, 100 to 115, 130 to 145, 210 to 225)
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
