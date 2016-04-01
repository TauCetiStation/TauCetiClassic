// BIOMASS (Note that this code is very similar to Space Vine code)
/obj/structure/cellular_biomass
	name = "Cellular horror"
	desc = "Monstrum from another dimension. It just keeps spreading!"
	icon = 'tauceti/datums/gamemodes/events/meatland_cellular.dmi'
	icon_state = "bloodwall_1"

	anchored = 1
	density = 1
	opacity = 1

	var/grip = 0
	var/health = 100
	var/energy = 0

	var/obj/effect/cellular_biomass_controller/master = null

/obj/structure/cellular_biomass/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 0

/obj/structure/cellular_biomass/New()
	icon_state = "bloodwall_[pick(1,1,2,2,3,4)]"

/obj/structure/cellular_biomass/Destroy()
	if(master)
		master.biomass_cells -= src
		master.growth_queue -= src
	master = null
	..()
	return QDEL_HINT_QUEUE

/obj/structure/cellular_biomass/grass/Destroy()
	for(var/obj/effect/decal/cleanable/bluespace/clean in src.loc)
		qdel(clean)
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
	switch(severity)
		if(1.0)
			health-=100
		if(2.0)
			health-=50
		if(3.0)
			if (prob(50))
				health-=50
			else
				health-=25
	healthcheck()
	return

/obj/structure/cellular_biomass/blob_act()
	health-=50
	healthcheck()
	return

/obj/structure/cellular_biomass/meteorhit()
	health-=100
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


/obj/structure/cellular_biomass/grass
	icon_state = "weed_1"
	color = "#ff8888"
	density = 0
	opacity = 0
	health = 20
	layer = 2
	energy = 4

/obj/structure/cellular_biomass/grass/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

/obj/structure/cellular_biomass/grass/New()
	icon_state = "bloodfloor_[pick(1,2,3)]"

/obj/structure/cellular_biomass/grass/light
	density = 1
	layer = 3
	health = 60
	luminosity = 3
	light_color = "#710F8C"
	icon_state = "light_1"

/obj/structure/cellular_biomass/grass/light/New()
	icon_state = "light_[pick(1,2)]"
	set_light(luminosity)

/obj/effect/cellular_biomass_controller
	var/list/obj/structure/cellular_biomass/biomass_cells = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the cellular_biomasssss..s' size to something less than 20 plots, it won't grow anymore.

/obj/effect/cellular_biomass_controller/New()
	if(!istype(src.loc,/turf/simulated/floor))
		qdel(src)
		return
	spawn_cellular_biomass_piece(src.loc)
	SSobj.processing |= src

/obj/effect/cellular_biomass_controller/Destroy()
	growth_queue.Cut()
	for(var/obj/structure/cellular_biomass/str in biomass_cells)
		str.master = null
	SSobj.processing.Remove(src)
	return ..()

/obj/effect/cellular_biomass_controller/proc/spawn_cellular_biomass_piece(var/turf/location, var/obj/structure/cellular_biomass/parent)
	var/newgrip = 0
	if (parent)
		if(istype(location,/turf/simulated))
			newgrip = 5
		else
			newgrip = parent.grip - 1
	if(!parent || newgrip > 0)
		var/obj/structure/cellular_biomass/BM = new(location)
		if (istype(location,/turf/space))
			location:ChangeTurf(/turf/simulated/floor/plating)
		var/random = pick(1,1,1,2,2,3)
		location.icon_state = "bloodfloor_[random]"
		BM.grip = newgrip
		growth_queue += BM
		biomass_cells += BM
		BM.master = src

/obj/effect/cellular_biomass_controller/process()
	if(!biomass_cells)
		qdel(src) //space  biomass_cells exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src)
		return

	var/length = min(5, max(50, biomass_cells.len / 5))
	var/list/obj/structure/cellular_biomass/queue_end = list()

	var/i = 0
	for(var/obj/structure/cellular_biomass/BM in growth_queue)
		i++
		growth_queue -= BM
		BM.grow()
		if(BM)
			if(BM.energy < 4)
				queue_end += BM
			BM.spread()
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end

/obj/structure/cellular_biomass/proc/grow()
	energy = calcEnergy(src.loc)
	if(energy >= 4)
		if(prob(5))
			new /obj/structure/cellular_biomass/grass/light(src.loc)
		else
			if(prob(30))
				new /obj/effect/decal/cleanable/cellular(src.loc)
		if(prob(8))
			var/list/critters = subtypesof(/mob/living/simple_animal/hostile/cellular)
			var/chosen = pick(critters)
			var/mob/living/simple_animal/hostile/C = new chosen
			C.loc = src.loc
		new /obj/structure/cellular_biomass/grass(src.loc)
		qdel(src)

/obj/structure/cellular_biomass/proc/spread(src.loc)
	if(qdeleted(src))
		return
	var/turf/T = src.loc
	var/turf/S = get_step(T,pick(1,2,4,8))
	if(locate(/obj/structure/cellular_biomass, S))
		return
	if(istype(S,/turf/simulated/wall))
		if(calcEnergy(S)==3)
			S.blob_act()
		return
	if(S.Enter(src) && master)
		for(var/obj/A in S)//Del everything.
			qdel(A)
		master.spawn_cellular_biomass_piece(S, src)
	if ((locate(/obj/machinery/door, S) || locate(/obj/structure/window, S)) && prob(90))
		return
	for(var/atom/A in S)//Hit everything in the turf
		A.blob_act()


/obj/structure/cellular_biomass/proc/calcEnergy(var/turf/S)
	return (getEnergy(S, 1) + getEnergy(S, 2) + getEnergy(S, 4) + getEnergy(S, 8))

/obj/structure/cellular_biomass/proc/getEnergy(var/turf/S, var/side)
	var/turf/T = get_step(S, side)
	if(locate(/obj/structure/cellular_biomass) in T)
		return 1
	return 0

/mob/living/simple_animal/hostile/cellular
	name = "insane creature"
	desc = "A sanity-destroying otherthing."
	icon = 'tauceti/datums/gamemodes/events/meatland_cellular.dmi'
	speak_emote = list("gibbers")
	attacktext = "slaps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = "creature"

/mob/living/simple_animal/hostile/cellular/creep_standing
	icon_state = "light"
	icon_living = "light"
	icon_dead = "light-dead"
	health = 160
	maxHealth = 160
	melee_damage_lower = 25
	melee_damage_upper = 50
	attacktext = "brutally chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = "creature"
	speed = 8

/mob/living/simple_animal/hostile/cellular/maniac
	speak_emote = list("gibbers")
	icon_state = "sovmeat"
	icon_living = "sovmeat"
	icon_dead = "sovmeat-dead"
	health = 50
	maxHealth = 50
	melee_damage_lower = 10
	melee_damage_upper = 18
	speed = 0

//stupid copy
/mob/living/simple_animal/hostile/cellular/creature
	icon_state = "horrormeat"
	icon_living = "horrormeat"
	icon_dead = "horrormeat-dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 20
	melee_damage_upper = 30
	speed = 3

/mob/living/simple_animal/hostile/cellular/changeling
	icon_state = "livingflesh"
	icon_living = "livingflesh"
	icon_dead = "livingflesh-dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 20
	melee_damage_upper = 30
	speed = 3

/mob/living/simple_animal/hostile/cellular/death()
	..()
	if(prob(80))
		visible_message("<b>[src]</b> blows apart!")
		new /obj/effect/gibspawner/generic(src.loc)
		new /obj/effect/gibspawner/generic(src.loc)
	qdel(src)
	return

/obj/effect/decal/cleanable/cellular
	name = "horror"
	desc = "You don't whant to know what is this..."
	icon = 'tauceti/datums/gamemodes/events/meatland_cellular.dmi'
	icon_state = "creep_1"
	random_icon_states = list("creep_1", "creep_2", "creep_3", "creep_4", "creep_5", "creep_6", "creep_7", "creep_8", "creep_9")