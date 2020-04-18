/obj/effect/scrap_pile_generator
	name = "Gererates Scrap Pile"
	icon_state = "rock"

/obj/effect/scrap_pile_generator/atom_init(mapload, heap_size = 1)
	. = ..()
	var/size = 0
	var/maintype = /obj/random/scrap/dense_weighted
	var/subtype = /obj/random/scrap/sparse_weighted
	switch(heap_size)
		if(1)
			size = pick(5, 5, 7, 7, 12)
			maintype = /obj/random/scrap/sparse_weighted
		if(2)
			size = pick(7, 12, 20)
		if(3)
			size = pick(20, 20, 30)
			maintype = /obj/random/scrap/dense_even

	var/list/makescrap = new/list()
	var/list/makesparse = new/list()
	makescrap += src.loc

	for(var/i = 0 to size)
		var/turf/toAdd = get_step(pick(makescrap), pick(alldirs))
		if(!toAdd.density)
			makescrap |= toAdd
	for(var/turf/T in makescrap)
		for(var/todir in cardinal)
			makesparse |= get_step(T, todir)
	makesparse -= makescrap
	for(var/turf/T in makescrap)
		if(!(locate(/obj/structure/scrap) in T.contents))
			new maintype(T)
	for(var/turf/T in makesparse)
		if(!(locate(/obj/structure/scrap) in T.contents))
			new subtype(T)

/turf/simulated/mineral/airfull
	basetype = /turf/simulated/floor/plating/ironsand
	name = "Mineral deposit"
	icon_state = "rock"

/turf/simulated/mineral/airfull/junkyard

/turf/proc/surround_by_scrap()
	var/turf/A
	for (var/newdir in alldirs)
		A = get_step(src, newdir)
		if(!A.density && !(locate(/obj/structure/scrap) in A.contents))
			new /obj/random/scrap/dense_weighted(A)

/turf/proc/resource_definition()
	LAZYINITLIST(resources)
	LAZYSET(resources, "silicates", rand(3,6))
	LAZYSET(resources, "carbonaceous rock", rand(3,6))
	LAZYSET(resources, "iron", rand(2,4))
	LAZYSET(resources, "gold", rand(0,4))
	LAZYSET(resources, "silver", rand(0,1))
	LAZYSET(resources, "uranium", rand(0,4))
	LAZYSET(resources, "diamond", rand(0,1))
	LAZYSET(resources, "phoron", rand(2,4))
	LAZYSET(resources, "osmium", rand(0,2))
	LAZYSET(resources, "hydrogen", rand(2,4))

/turf/simulated/floor/plating/ironsand/junkyard
	var/dug = 0
	has_resources = 1

/turf/simulated/floor/plating/ironsand/junkyard/surround_by_scrap()
	if(prob(1))
		new /obj/item/blueprints/junkyard(src)
	if(prob(2))
		new /obj/structure/scrap/poor/structure(src)
	if(prob(4))
		new /obj/effect/glowshroom(src)
	if(prob(4))
		new /obj/random/scrap/sparse_weighted(src)
	if(prob(6))
		var/decals_spawn = pick(/obj/effect/decal/cleanable/generic ,/obj/effect/decal/cleanable/ash, /obj/effect/decal/cleanable/molten_item, /obj/effect/decal/cleanable/vomit, /obj/effect/decal/cleanable/blood/oil)
		new decals_spawn(src)
	if(prob(6))
		new /obj/random/foods/food_trash(src)

	return 1

/turf/simulated/floor/plating/ironsand/update_air_properties()
	return // Critical fix :joypain:

/turf/simulated/floor/plating/ironsand/junkyard/safe
	icon_state = "ironsand2"
/turf/simulated/floor/plating/ironsand/junkyard/challenging
	icon_state = "ironsand3"
/turf/simulated/floor/plating/ironsand/junkyard/dangerous
	icon_state = "ironsand4"

/turf/simulated/floor/plating/ironsand/junkyard/safe/surround_by_scrap()
	if(..())
		if(prob(1))
			new /obj/effect/scrap_pile_generator(src, 1)
			return
		if(prob(1))
			new /obj/effect/landmark/junkyard_bum(src)
			return
		if(prob(1))
			new /obj/random/mobs/peacefull(src)


/turf/simulated/floor/plating/ironsand/junkyard/challenging/surround_by_scrap()
	if(..())
		if(prob(1))
			new /obj/effect/scrap_pile_generator(src, 2)
			return
		if(prob(1) && prob(30))
			new /obj/random/mobs/moderate(src)

/turf/simulated/floor/plating/ironsand/junkyard/dangerous/surround_by_scrap()
	if(..())
		if(prob(1))
			new /obj/effect/scrap_pile_generator(src, 3)
			return
		if(prob(1))
			new /obj/random/mobs/dangerous(src)
			if(prob(10))
				new /obj/random/mobs/peacefull(src)


/turf/simulated/floor/plating/ironsand/junkyard/attackby(obj/item/weapon/W, mob/user)
	if(!W || !user)
		return 0
	if(istype(W, /obj/item/weapon/shovel))
		var/turf/T = user.loc
		if(!istype(T, /turf))
			return 0
		if (!dug)
			if(!user.is_busy() && W.use_tool(src, user, 60))
				if(!dug) //someone else digged here
					visible_message("<span class='notice'>\The [user] shovels new grave.</span>")
					new /obj/structure/pit(src)
					dug = 1
		return
	..(W,user)
