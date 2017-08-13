/turf/simulated/mineral/airfull
	basetype = /turf/simulated/floor/plating/ironsand
	name = "Mineral deposit"
	icon_state = "rock"

/turf/simulated/mineral/airfull/junkyard/New()
	..()


/turf/proc/surround_by_scrap()
	var/turf/A
	for (var/newdir in alldirs)
		A = get_step(src, newdir)
		if(!A.density && !locate(/obj/structure/scrap in A.contents))
			new /obj/random/scrap/dense_weighted(A)




/turf/simulated/floor/plating/ironsand/junkyard/surround_by_scrap()
	//create glowshrooms
	if(prob(4))
		new /obj/effect/glowshroom(src)
		return
	//create dump
	if(prob(1))
		var/size = pick(7, 7, 7, 12, 12, 20)
		var/list/makescrap = new/list()
		var/list/makesparse = new/list()
		makescrap += src
		for(var/i = 0 to size)
			makescrap |= get_step(pick(makescrap), pick(alldirs))
		for(var/turf/T in makescrap)
			for(var/todir in cardinal)
				makesparse |= get_step(T, todir)
		makesparse -= makescrap
		for(var/turf/T in makescrap)
			if(!locate(/obj/structure/scrap in T.contents))
				new /obj/random/scrap/dense_weighted(T)
		for(var/turf/T in makesparse)
			if(!locate(/obj/structure/scrap in T.contents))
				new /obj/random/scrap/sparse_weighted(T)
		return
	if(prob(1))
		new /obj/effect/landmark/junkyard_bum(src)
		return
	if(prob(10))
		if(!locate(/obj/structure/scrap in contents))
			new /obj/random/scrap/sparse_weighted(src)
