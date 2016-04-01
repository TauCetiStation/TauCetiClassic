/obj/effect/cellular_biomass_controller
	var/list/biomass_walls = list()
	var/list/biomass_cores = list()
	var/list/biomass_lairs = list()

	var/list/growth_queue = list()

	var/grip_streingth = 4
	var/grow_speed = 5
	var/core_grow_chance = 5
	var/lair_grow_chance = 6
	var/mark_grow_chance = 30

	var/walls_type =     /obj/structure/cellular_biomass/wall
	var/insides_type =   /obj/structure/cellular_biomass/grass
	var/lairs_type =     /obj/structure/cellular_biomass/lair
	var/landmarks_type = /obj/effect/decal/cleanable/cellular
	var/cores_type =     /obj/structure/cellular_biomass/core

/obj/effect/cellular_biomass_controller/New()
	if(!istype(src.loc,/turf/simulated/floor))
		qdel(src)
		return
	spawn_cellular_biomass_core(src.loc)
	spawn_cellular_biomass_piece(src.loc)
	SSobj.processing |= src

/obj/effect/cellular_biomass_controller/proc/remove_biomass(var/obj/structure/cellular_biomass/removed)
	if(istype(removed, /obj/structure/cellular_biomass/wall))
		biomass_walls -= removed
		growth_queue -= removed
	if(istype(removed, /obj/structure/cellular_biomass/core))
		biomass_cores -= removed
	if(istype(removed, /obj/structure/cellular_biomass/lair))
		biomass_lairs -= removed
	removed.master = null

/obj/effect/cellular_biomass_controller/Destroy()
	death()
	growth_queue.Cut()
	for(var/obj/structure/cellular_biomass/str in biomass_cells)
		str.master = null
	SSobj.processing.Remove(src)
	return ..()

/obj/effect/cellular_biomass_controller/proc/spawn_cellular_biomass_piece(var/turf/location, var/obj/structure/cellular_biomass/parent)
	var/newgrip = 0
	if (parent)
		if(istype(location,/turf/simulated))
			newgrip = grip_streingth
		else
			newgrip = parent.grip - 1
	if(!parent || newgrip > 0)
		var/obj/structure/cellular_biomass/BM = new walls_type(location)
		if (istype(location,/turf/space))
			location:ChangeTurf(/turf/simulated/floor/plating)
		BM.grip = newgrip
		growth_queue += BM
		biomass_cells += BM
		BM.master = src

/obj/effect/cellular_biomass_controller/proc/alive()
	. = 1
	if(!biomass_cells)
		return 0
	if(!growth_queue)
		return 0
	if(!biomass_cores)
		return 0

/obj/effect/cellular_biomass_controller/proc/death()
	for(var/obj/structure/gr in biomass_grass)
		gr.color = "gray"
	for(var/obj/structure/gr in biomass_walls)
		gr.color = "gray"
	for(var/obj/structure/gr in biomass_cores)
		gr.set_light(0)
		gr.color = "gray"

/obj/effect/cellular_biomass_controller/process()
	if(!alive())
		qdel(src)
		return
	process_walls()
	process_lairs()
	process_cores()

/obj/effect/cellular_biomass_controller/proc/process_lairs()
	for(var/obj/structure/cellular_biomass_black/lair/BL in biomass_lairs)
		BL.process()

/obj/effect/cellular_biomass_controller/proc/process_walls()
	var/length = min(5,  biomass_cells.len / grow_speed)
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

/obj/effect/cellular_biomass_controller/proc/process_cores()
	return 1


/obj/effect/cellular_biomass_controller/proc/calcEnergy(var/turf/S)
	return (getEnergy(S, 1) + getEnergy(S, 2) + getEnergy(S, 4) + getEnergy(S, 8))

/obj/effect/cellular_biomass_controller/proc/getEnergy(var/turf/S, var/side)
	if(locate(/obj/structure/cellular_biomass) in get_step(S, side))
		return 1
	return 0

/obj/effect/cellular_biomass_controller/proc/spread_wall(var/obj/structure/cellular_biomass/wall/growing)
	var/turf/T = growing.loc
	var/turf/S = get_step(T,pick(1,2,4,8))
	if(locate(/obj/structure/cellular_biomass, S))
		return
	if(istype(S,/turf/simulated/wall))
		if(calcEnergy(S)==3)
			S.blob_act()
		return
	if ((locate(/obj/machinery/door, S) || locate(/obj/structure/window, S)) && prob(90))
		return
	for(var/atom/A in S)//Hit everything in the turf
		A.blob_act()
	if(T.CanPass(growing,S))
		for(var/obj/A in S) //Del everything.
			qdel(A)
		spawn_cellular_biomass_piece(S, growing)

/obj/effect/cellular_biomass_controller/proc/check_grow_wall(var/obj/structure/cellular_biomass/wall/growing)
	if(calcEnergy(growing.loc) >= 4)
		grow_wall(growing)
		return 0
	return 1

/obj/effect/cellular_biomass_controller/proc/grow_wall(var/obj/structure/cellular_biomass/wall/growing)
	spawn_cellular_biomass_inside(growing.loc)
	if(prob(core_grow_chance))
		spawn_cellular_biomass_core(growing.loc)
		return
	if(prob(lair_grow_chance))
		spawn_cellular_biomass_lair(growing.loc)
		return
	if(prob(mark_grow_chance))
		spawn_cellular_biomass_mark(growing.loc)
		return
	qdel(growing)

/obj/effect/cellular_biomass_controller/proc/spawn_cellular_biomass_core(loc)
	var/obj/structure/cellular_biomass/core/ncore = new cores_type(loc)
	biomass_cores += ncore
	ncore.master = src

/obj/effect/cellular_biomass_controller/proc/spawn_cellular_biomass_lair(loc)
	var/obj/structure/cellular_biomass/lair/ncore = new lairs_type(loc)
	biomass_lairs += ncore
	ncore.master = src

/obj/effect/cellular_biomass_controller/proc/spawn_cellular_biomass_mark(loc)
	new landmarks_type(loc)

/obj/effect/cellular_biomass_controller/proc/spawn_cellular_biomass_inside(loc)
	new insides_type(loc)

////////////////////////////
//      BASIC CLASS     ////
////////////////////////////

/obj/structure/cellular_biomass
	name = "basic biomass"
	desc = "basic biomass"
	icon = null
	icon_state = "null"

	anchored = 1
	density = 0
	opacity = 0

	var/grip = 0
	var/health = 100
	var/obj/effect/cellular_biomass_controller/master = null

/obj/structure/cellular_biomass/Destroy()
	if(master)
		master.remove_biomass(src)
	..()
	return QDEL_HINT_QUEUE

/obj/structure/cellular_biomass/proc/healthcheck()
	if(health <=0)
		qdel(src)
	return

/obj/structure/cellular_biomass/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return

/obj/structure/cellular_biomass/ex_act(severity)
	health -= 100 / severity
	healthcheck()
	return

/obj/structure/cellular_biomass/blob_act()
	health -= 50
	healthcheck()
	return

/obj/structure/cellular_biomass/meteorhit()
	health -= 100
	healthcheck()
	return

/obj/structure/cellular_biomass/attack_hand()
	..()
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	return

/obj/structure/cellular_biomass/attack_paw()
	return attack_hand()

/obj/structure/cellular_biomass/attack_alien()
	return attack_hand()

/obj/structure/cellular_biomass/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	health -= W.force
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	return

////////////////////////////
// WALLS GRASS AND CORES////
////////////////////////////

/obj/structure/cellular_biomass/wall
	anchored = 1
	density = 1
	opacity = 1
	layer = 4
/obj/structure/cellular_biomass/wall/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 0

/obj/structure/cellular_biomass/grass
	health = 40
	layer = 2

/obj/structure/cellular_biomass/grass/New()
	icon_state = "bloodfloor_[pick(1,2,3)]"

/obj/structure/cellular_biomass/core
	layer = 3
	health = 120
	luminosity = 3
	light_color = "#710F8C"
	icon_state = "light_1"

/obj/structure/cellular_biomass/core/New()
	icon_state = "light_[pick(1,2)]"
	set_light(luminosity)

/obj/structure/cellular_biomass/core/process()
	health = max(120, health + 1)





////////////////////////
// MOBS ANS LAIRS   ////
////////////////////////

/obj/structure/cellular_biomass/lair
	layer = 3
	health = 120
	var/spawned_mob = /mob/living/simple_animal/hostile/cellular/
	var/my_mob = null

/obj/structure/cellular_biomass/lair/New()
	spawned_mob = pick(subtypesof(spawned_mob))
	spawn_mob()

/obj/structure/cellular_biomass/lair/proc/spawn_mob()
	my_mob = new spawned_mob(src.loc)
	new_mob.my_lair = src

/obj/structure/cellular_biomass/lair/process()
	if(prob(5) && !my_mob)
		spawn_mob()

/obj/structure/cellular_biomass/lair/Destroy()
	if(my_mob)
		my_mob.my_lair = null
	my_mob = null
	..()

/mob/living/simple_animal/hostile/cellular
	var/obj/structure/cellular_biomass/lair/my_lair = null

/mob/living/simple_animal/hostile/cellular/death()
	if(my_lair)
		my_lair.my_mob = null
	my_lair = null
	..()

/mob/living/simple_animal/hostile/cellular/Destroy()
	if(my_lair)
		my_lair.my_mob = null
	my_lair = null
	..()

/obj/effect/decal/cleanable/cellular
	name = "horror"
	desc = "You don't whant to know what is this..."
	icon = 'tauceti/datums/gamemodes/events/meatland_cellular.dmi'
	icon_state = "creep_1"
	random_icon_states = list("creep_1", "creep_2", "creep_3", "creep_4", "creep_5", "creep_6", "creep_7", "creep_8", "creep_9")