// BIOMASS (Note that this code is very similar to Space Vine code)
/obj/effect/biomass
	name = "biomass"
	desc = "Space barf from another dimension. It just keeps spreading!"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "stage1"
	anchored = 1
	density = 0
	layer = 5
	pass_flags = PASSTABLE | PASSGRILLE
	var/energy = 0
	var/obj/effect/biomass_controller/master = null

/obj/effect/biomass/Destroy()
	if(master)
		master.vines -= src
		master.growth_queue -= src
	return ..()

/obj/effect/biomass/attackby(obj/item/weapon/W, mob/user)
	if (!W || !user || !W.type) return
	switch(W.type)
		if(/obj/item/weapon/circular_saw) qdel(src)
		if(/obj/item/weapon/kitchenknife) qdel(src)
		if(/obj/item/weapon/scalpel) qdel(src)
		if(/obj/item/weapon/twohanded/fireaxe) qdel(src)
		if(/obj/item/weapon/hatchet) qdel(src)
		if(/obj/item/weapon/melee/energy) qdel(src)

		//less effective weapons
		if(/obj/item/weapon/wirecutters)
			if(prob(25)) qdel(src)
		if(/obj/item/weapon/shard)
			if(prob(25)) qdel(src)

		else //weapons with subtypes
			if(istype(W, /obj/item/weapon/melee/energy/sword)) qdel(src)
			else if(iswelder(W))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.use(0, user)) qdel(src)
			else
				return
	return ..()

/obj/effect/biomass_controller
	var/list/obj/effect/biomass/vines = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the biomasssss..s' size to something less than 20 plots, it won't grow anymore.

/obj/effect/biomass_controller/atom_init()
	. = ..()
	if(!istype(loc, /turf/simulated/floor))
		return INITIALIZE_HINT_QDEL

	spawn_biomass_piece(loc)
	START_PROCESSING(SSobj, src)

/obj/effect/biomass_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/biomass_controller/proc/spawn_biomass_piece(turf/location)
	var/obj/effect/biomass/BM = new(location)
	growth_queue += BM
	vines += BM
	BM.master = src

/obj/effect/biomass_controller/process()
	if(!vines)
		qdel(src) //space  vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return
	if(vines.len >= 250 && !reached_collapse_size)
		reached_collapse_size = 1
	if(vines.len >= 30 && !reached_slowdown_size )
		reached_slowdown_size = 1

	var/maxgrowth = 0
	if(reached_collapse_size)
		maxgrowth = 0
	else if(reached_slowdown_size)
		if(prob(25))
			maxgrowth = 1
		else
			maxgrowth = 0
	else
		maxgrowth = 4
	var/length = min( 30 , vines.len / 5 )
	var/i = 0
	var/growth = 0
	var/list/obj/effect/biomass/queue_end = list()

	for( var/obj/effect/biomass/BM in growth_queue )
		i++
		queue_end += BM
		growth_queue -= BM
		if(BM.energy < 2) //If tile isn't fully grown
			if(prob(20))
				BM.grow()

		if(BM.spread())
			growth++
			if(growth >= maxgrowth)
				break
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end

/obj/effect/biomass/proc/grow()
	if(!energy)
		src.icon_state = "stage2"
		energy = 1
		src.opacity = 0
		src.density = 0
		layer = 5
	else
		src.icon_state = "stage3"
		src.opacity = 0
		src.density = 1
		energy = 2

/obj/effect/biomass/proc/spread()
	var/direction = pick(cardinal)
	var/step = get_step(src,direction)
	if(istype(step,/turf/simulated/floor))
		var/turf/simulated/floor/F = step
		if(!locate(/obj/effect/biomass,F))
			if(F.Enter(src))
				if(master)
					master.spawn_biomass_piece( F )
					return 1
	return 0

/obj/effect/biomass/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(90))
				qdel(src)
				return
		if(3.0)
			if (prob(50))
				qdel(src)
				return
	return

/obj/effect/biomass/fire_act(null, temperature, volume) //hotspots kill biomass
	if(temperature > T0C+100)
		qdel(src)
