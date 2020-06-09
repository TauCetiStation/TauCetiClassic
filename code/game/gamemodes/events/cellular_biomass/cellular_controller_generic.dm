/obj/effect/cellular_biomass_controller
	var/list/biomass = list()
	var/list/biomass_cores = list()
	var/list/growth_queue = list()
	var/state = 1                // 1 = growing 0 = dying
	var/grip_streingth = 5       // range for turfs to expand in space.
	var/grow_speed = 5           // lower this value to speed up growth. 1 will process without cooldown.
	var/core_grow_chance = 5     // chance to spawn light core
	var/living_grow_chance = 6   // chance to spawn lair or mob
	var/mark_grow_chance = 25    // chance to spawn decoration
	var/faction = "generic"      // currentrly unused. Will be used to merge/battle biomes

	var/walls_type =     /obj/structure/cellular_biomass/wall
	var/insides_type =   /obj/structure/cellular_biomass/grass
	var/living_type =     /obj/structure/cellular_biomass/lair
	var/landmarks_type = /obj/effect/decal/cleanable/cellular
	var/cores_type =     /obj/structure/cellular_biomass/core

/obj/effect/cellular_biomass_controller/atom_init()
	. = ..()
	if(!istype(loc, /turf/simulated/floor))
		return INITIALIZE_HINT_QDEL
	spawn_cellular_biomass_core(loc)
	spawn_cellular_biomass_piece(loc)
	START_PROCESSING(SSobj, src)

/obj/effect/cellular_biomass_controller/proc/remove_biomass(obj/structure/cellular_biomass/removed)
	if(istype(removed, /obj/structure/cellular_biomass/wall))
		growth_queue -= removed
	if(istype(removed, /obj/structure/cellular_biomass/core))
		biomass_cores -= removed
	biomass -= removed
	removed.master = null

/obj/effect/cellular_biomass_controller/Destroy()
	growth_queue.Cut()
	for(var/obj/structure/cellular_biomass/str in growth_queue)
		str.master = null
	STOP_PROCESSING(SSobj, src)
	return ..()



/obj/effect/cellular_biomass_controller/proc/alive()
	if(!growth_queue)
		return 0
	if(!biomass_cores)
		return 0
	if(!growth_queue.len)
		return 0
	if(!biomass_cores.len)
		return 0
	return 1

/obj/effect/cellular_biomass_controller/proc/isdying()
	if(!biomass)
		return 0
	if(!biomass.len)
		return 0
	return 1

/obj/effect/cellular_biomass_controller/proc/death()
	for(var/obj/structure/cellular_biomass/todie in biomass)
		todie.color = "gray"
	state = 0

/obj/effect/cellular_biomass_controller/process()
	if(state)
		if(!alive())
			death()
		process_walls()
		process_cores()
	else
		if(!isdying())
			qdel(src)
			return
		process_dying()

/obj/effect/cellular_biomass_controller/proc/process_walls()
	var/length = max(5,  growth_queue.len / grow_speed)
	var/list/queue_end = list()
	var/i = 0
	for(var/obj/structure/cellular_biomass/wall/BM in growth_queue)
		i++
		growth_queue -= BM
		if(check_grow_wall(BM))
			spread_wall(BM)
			queue_end += BM
		if(i >= length)
			break
	growth_queue = growth_queue + queue_end

/obj/effect/cellular_biomass_controller/proc/process_dying()
	var/length = min(rand(3)+1,  biomass.len)
	for(var/i = 0 to length)
		qdel(pick(biomass))

/obj/effect/cellular_biomass_controller/proc/process_cores()
	return 1

/obj/effect/cellular_biomass_controller/proc/calcEnergy(turf/S)
	return (getEnergy(S, 1) + getEnergy(S, 2) + getEnergy(S, 4) + getEnergy(S, 8))

/obj/effect/cellular_biomass_controller/proc/getEnergy(turf/S, side)
	if(locate(/obj/structure/cellular_biomass) in get_step(S, side))
		return 1
	return 0

/obj/effect/cellular_biomass_controller/proc/spread_wall(obj/structure/cellular_biomass/wall/growing)
	var/turf/T = growing.loc
	var/turf/S = get_step(T,pick(1,2,4,8))
	if(locate(/obj/structure/cellular_biomass, S))
		return
	if(istype(S,/turf/simulated/wall) || istype(S,/turf/simulated/mineral))
		if(calcEnergy(S)==3)
			S.blob_act()
		return
	if(T.CanPass(growing,S))
		for(var/obj/A in S) //Del everything.
			qdel(A)
		spawn_cellular_biomass_piece(S, growing)
	if ((locate(/obj/machinery/door, S) || locate(/obj/structure/window, S)) && prob(90))
		return
	for(var/atom/A in S) //Hit everything in the turf
		A.blob_act()


/obj/effect/cellular_biomass_controller/proc/check_grow_wall(obj/structure/cellular_biomass/wall/growing)
	if(calcEnergy(growing.loc) >= 4)
		grow_wall(growing)
		qdel(growing)
		return 0
	return 1

/obj/effect/cellular_biomass_controller/proc/grow_wall(obj/structure/cellular_biomass/wall/growing)
	spawn_cellular_biomass_inside(growing.loc)
	if(prob(core_grow_chance))
		spawn_cellular_biomass_core(growing.loc)
		return
	if(prob(living_grow_chance))
		spawn_cellular_biomass_living(growing.loc)
		return
	if(prob(mark_grow_chance))
		spawn_cellular_biomass_mark(growing.loc)
		return

/obj/effect/cellular_biomass_controller/proc/spawn_cellular_biomass_core(loc)
	var/obj/structure/cellular_biomass/core/ncore = new cores_type(loc)
	biomass_cores += ncore
	biomass += ncore
	ncore.set_master(src)

/obj/effect/cellular_biomass_controller/proc/spawn_cellular_biomass_living(loc)
	var/obj/structure/cellular_biomass/living = new living_type(loc)
	if(!QDELETED(living))
		biomass += living
		living.set_master(src)

/obj/effect/cellular_biomass_controller/proc/spawn_cellular_biomass_mark(loc)
	new landmarks_type(loc)

/obj/effect/cellular_biomass_controller/proc/spawn_cellular_biomass_inside(loc)
	var/obj/structure/cellular_biomass/newinside = new insides_type(loc)
	biomass += newinside
	newinside.set_master(src)

/obj/effect/cellular_biomass_controller/proc/spawn_cellular_biomass_piece(turf/location, obj/structure/cellular_biomass/parent)
	var/newgrip = 0
	if (parent)
		if(istype(location,/turf/simulated))
			newgrip = grip_streingth
		else
			newgrip = parent.grip - 1
	if(!parent || newgrip > 0)
		var/obj/structure/cellular_biomass/BM = new walls_type(location)
		if (istype(location,/turf/space))
			location:ChangeTurf(/turf/simulated/floor/plating/ironsand)
		BM.grip = newgrip
		growth_queue += BM
		biomass += BM
		BM.set_master(src)
