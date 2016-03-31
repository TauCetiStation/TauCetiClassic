// BIOMASS (Note that this code is very similar to Space Vine code)
/obj/structure/cellular_biomass_black
	name = "The Goo"
	desc = "Space barf from another dimension. It just keeps spreading!"
	icon = 'tauceti/icons/mob/alien.dmi'
	icon_state = "resin"

	anchored = 1
	density = 1
	opacity = 1

	var/grip = 0
	var/health = 100
	var/energy = 0

	var/obj/effect/cellular_biomass_black_controller/master = null

/obj/structure/cellular_biomass_black/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		return 0
	
/obj/structure/cellular_biomass_black/New()
		..()

/obj/structure/cellular_biomass_black/Destroy()
	if(master)
		master.biomass_cells -= src
		master.growth_queue -= src
	master = null
	..()
	return QDEL_HINT_QUEUE

/obj/structure/cellular_biomass_black/proc/healthcheck()
	if(health <=0)
		qdel(src)
	return

/obj/structure/cellular_biomass_black/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return

/obj/structure/cellular_biomass_black/ex_act(severity)
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

/obj/structure/cellular_biomass_black/blob_act()
	health-=50
	healthcheck()
	return

/obj/structure/cellular_biomass_black/meteorhit()
	health-=100
	healthcheck()
	return

/obj/structure/cellular_biomass_black/attack_hand()
	..()
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	return

/obj/structure/cellular_biomass_black/attack_paw()
	return attack_hand()

/obj/structure/cellular_biomass_black/attack_alien()
	return attack_hand()

/obj/structure/cellular_biomass_black/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	health -= W.force
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	return 


/obj/structure/cellular_biomass_black/grass
	density = 0
	opacity = 0
	health = 20
	layer = 2
	energy = 4

/obj/structure/cellular_biomass_black/grass/light
	luminosity = 4
	light_color = "#710F8C"
	icon_state = "weednode"


/obj/structure/cellular_biomass_black/grass/light/New()
	..()
	set_light(luminosity)

/obj/effect/cellular_biomass_black_controller
	var/list/obj/structure/cellular_biomass_black/biomass_cells = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the cellular_biomass_blacksss..s' size to something less than 20 plots, it won't grow anymore.

/obj/effect/cellular_biomass_black_controller/New()
	if(!istype(src.loc,/turf/simulated/floor))
		qdel(src)
		return
	spawn_cellular_biomass_black_piece(src.loc)
	SSobj.processing |= src

/obj/effect/cellular_biomass_black_controller/Destroy()
	growth_queue.Cut()
	for(var/obj/structure/cellular_biomass_black/str in biomass_cells)
		str.master = null
	SSobj.processing.Remove(src)
	return ..()

/obj/effect/cellular_biomass_black_controller/proc/spawn_cellular_biomass_black_piece(var/turf/location, var/obj/structure/cellular_biomass_black/parent)
	var/newgrip = 0
	if (parent)
		if(istype(location,/turf/simulated))
			newgrip = 4
		else
			newgrip = parent.grip - 1
	if(!parent || newgrip > 0)
		var/obj/structure/cellular_biomass_black/BM = new(location)
		if (istype(location,/turf/space))
			location:ChangeTurf(/turf/simulated/floor/plating)
		var/random = rand(1,15)
		location.icon_state = "ironsand[random]"
		location.color = "gray"
		BM.grip = newgrip
		growth_queue += BM
		biomass_cells += BM
		BM.master = src

/obj/effect/cellular_biomass_black_controller/process()
	if(!biomass_cells)
		qdel(src) //space  biomass_cells exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src)
		return

	var/length = min(5, max(50, biomass_cells.len / 5))
	var/list/obj/structure/cellular_biomass_black/queue_end = list()

	var/i = 0
	for(var/obj/structure/cellular_biomass_black/BM in growth_queue)
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

/obj/structure/cellular_biomass_black/proc/grow()
	energy = calcEnergy(src.loc)
	if(energy >= 4)
		if(prob(6))
			new /obj/structure/cellular_biomass_black/grass/light(src.loc)
		else
			var/obj/structure/cellular_biomass_black/grass/BM = new(src.loc)
			BM.icon_state = pick("weeds","weeds1","weeds2")
		if(prob(8))
			var/list/critters = typesof(/mob/living/simple_animal/hostile/asteroid)
			var/chosen = pick(critters)
			var/mob/living/simple_animal/hostile/C = new chosen
			C.loc = src.loc
		qdel(src)

/obj/structure/cellular_biomass_black/proc/spread()
	if(qdeleted(src))
		return
	var/turf/T = src.loc
	var/turf/S = get_step(T,pick(1,2,4,8))
	if(locate(/obj/structure/cellular_biomass_black, S))
		return
	if(istype(S,/turf/simulated/wall))
		if(calcEnergy(S)==3)
			S.blob_act()
			return 
	if ((locate(/obj/machinery/door, S) || locate(/obj/structure/window, S)) && prob(90))
		return
	for(var/atom/A in S)//Hit everything in the turf
		A.blob_act()
	if(T.CanPass(src,S) && master)
		master.spawn_cellular_biomass_black_piece(S, src)

/obj/structure/cellular_biomass_black/proc/calcEnergy(var/turf/S)
	return (getEnergy(S, 1) + getEnergy(S, 2) + getEnergy(S, 4) + getEnergy(S, 8))

/obj/structure/cellular_biomass_black/proc/getEnergy(var/turf/S, var/side)
	var/turf/T = get_step(S, side)
	if(locate(/obj/structure/cellular_biomass_black) in T)
		return 1
	return 0

/proc/cellular_biomass_black_infestation()
	spawn() //to stop the secrets panel hanging
		var/list/turf/simulated/floor/turfs = list() //list of all the empty floor turfs in the hallway areas
		for(var/areapath in typesof(/area/hallway))
			var/area/A = locate(areapath)
			for(var/area/B in A.related)
				for(var/turf/simulated/floor/F in B.contents)
					if(!F.contents.len)
						turfs += F

		if(turfs.len) //Pick a turf to spawn at if we can
			var/turf/simulated/floor/T = pick(turfs)
			new/obj/effect/cellular_biomass_black_controller(T) //spawn a controller at turf
			message_admins("\blue Event: Cellular spawned at [T.loc.loc] ([T.x],[T.y],[T.z])")

/mob/living/simple_animal/hostile/creature
	name = "creature"
	desc = "A sanity-destroying otherthing."
	icon = 'icons/mob/critter.dmi'
	speak_emote = list("gibbers")
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 25
	melee_damage_upper = 50
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = "creature"
	speed = 4