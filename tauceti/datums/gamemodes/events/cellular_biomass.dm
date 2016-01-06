// BIOMASS (Note that this code is very similar to Space Vine code)
/obj/effect/cellular_biomass
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

	var/obj/effect/cellular_biomass_controller/master = null

	New()
		..()
		var/turf/T = get_turf(src)
		T.thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT


	Destroy()
		density = 0
		var/turf/T = get_turf(src)
		T.thermal_conductivity = initial(T.thermal_conductivity)
		if(master)
			master.biomass_cells -= src
			master.growth_queue -= src
		..()

/obj/effect/cellular_biomass/proc/healthcheck()
	if(health <=0)
		density = 0
		Destroy(src)
	return

/obj/effect/cellular_biomass/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return

/obj/effect/cellular_biomass/ex_act(severity)
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

/obj/effect/cellular_biomass/blob_act()
	health-=50
	healthcheck()
	return

/obj/effect/cellular_biomass/meteorhit()
	health-=100
	healthcheck()
	return

/obj/effect/cellular_biomass/hitby(AM as mob|obj)
	..()
	for(var/mob/O in viewers(src, null))
		O.show_message("\red <B>[src] was hit by [AM].</B>", 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 10
	else
		tforce = AM:throwforce
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health = max(0, health - tforce)
	healthcheck()
	..()
	return

/obj/effect/cellular_biomass/attack_hand()
	if (HULK in usr.mutations)
		usr << "\blue You easily destroy the [name]."
		for(var/mob/O in oviewers(src))
			O.show_message("\red [usr] destroys the [name]!", 1)
		health = 0
	else
		usr << "\blue You claw at the [name]."
		for(var/mob/O in oviewers(src))
			O.show_message("\red [usr] claws at the [name]!", 1)
		health -= rand(5,10)
	healthcheck()
	return

/obj/effect/cellular_biomass/attack_paw()
	return attack_hand()

/obj/effect/cellular_biomass/attack_alien()
	if (islarva(usr))//Safety check for larva. /N
		return
	usr << "\green You claw at the [name]."
	for(var/mob/O in oviewers(src))
		O.show_message("\red [usr] claws at the resin!", 1)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	health -= rand(40, 60)
	if(health <= 0)
		usr << "\green You slice the [name] to pieces."
		for(var/mob/O in oviewers(src))
			O.show_message("\red [usr] slices the [name] apart!", 1)
	healthcheck()
	return

/obj/effect/cellular_biomass/attackby(obj/item/weapon/W as obj, mob/user as mob)

	var/aforce = W.force
	health = max(0, health - aforce)
	playsound(loc, 'sound/effects/attackblob.ogg', 100, 1)
	healthcheck()
	..()
	return


/obj/effect/cellular_biomass/grass
	density = 0
	opacity = 0
	health = 20
	layer = 2
	energy = 4

/obj/effect/cellular_biomass/grass/light
	luminosity = 3
	icon_state = "weednode"

/obj/effect/cellular_biomass_controller
	var/list/obj/effect/cellular_biomass/biomass_cells = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the cellular_biomasssss..s' size to something less than 20 plots, it won't grow anymore.

	New()
		if(!istype(src.loc,/turf/simulated/floor))
			Destroy(src)

		spawn_cellular_biomass_piece(src.loc)
		processing_objects.Add(src)

	Destroy()
		processing_objects.Remove(src)
		..()

	proc/spawn_cellular_biomass_piece(var/turf/location, var/obj/effect/cellular_biomass/parent)
		var/newgrip = 0
		if (parent)
			if(istype(location,/turf/simulated))
				newgrip = 4
			else
				newgrip = parent.grip - 1
		if(!parent || newgrip > 0)
			if (istype(location,/turf/space))
				location:ChangeTurf(/turf/simulated/floor/plating/airless)
			var/random = rand(1,15)
			location.icon_state = "ironsand[random]"
			location.color = "gray"

			var/obj/effect/cellular_biomass/BM = new(location)

			BM.grip = newgrip
			growth_queue += BM
			biomass_cells += BM
			BM.master = src

	process()
		if(!biomass_cells)
			Destroy(src) //space  biomass_cells exterminated. Remove the controller
			return
		if(!growth_queue)
			Destroy(src) //Sanity check
			return

		var/length = min(5, max(50, biomass_cells.len / 5))

		var/list/obj/effect/cellular_biomass/queue_end = list()

		var/i = 0
		for( var/obj/effect/cellular_biomass/BM in growth_queue )
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

/obj/effect/cellular_biomass/proc/grow()
	energy = calcEnergy(src.loc)
	if(energy >= 4)
		if(prob(6))
			new /obj/effect/cellular_biomass/grass/light(src.loc)
		else
			if(prob(4))
				var/list/critters = typesof(/mob/living/simple_animal/hostile/asteroid)
				var/chosen = pick(critters)
				var/mob/living/simple_animal/hostile/C = new chosen
				C.loc = src.loc

			var/obj/effect/cellular_biomass/grass/BM = new(src.loc)
			BM.icon_state = pick("weeds","weeds1","weeds2")

		//if(air_master)
		//		air_master.mark_for_update(get_turf(src))
		Destroy(src)


/obj/effect/cellular_biomass/proc/spread()
	var/turf/T = src.loc
	//var/turfs[4]
	//turfs.Add(get_step(T, 1),get_step(T, 2),get_step(T, 4),get_step(T, 8))
	var/turf/S = get_step(T,pick(1,2,4,8))
	if(istype(S,/turf/simulated/wall))
		if(calcEnergy(S)==3)
			S.blob_act()
	else
		if(!locate(/obj/effect/cellular_biomass,S))
			if(S.Enter(src,src.loc))
				if(master)
					for(var/atom/A in S)//Hit everything in the turf
						A.blob_act()
					for(var/atom/A in S)//Hit everything in the turf
						A.ex_act(2)
					master.spawn_cellular_biomass_piece(S, src)
			else
				if((locate(/obj/machinery/door, S) || locate(/obj/structure/window, S)) && prob(10))
					for(var/atom/A in S)//Hit everything in the turf
						A.ex_act(2)
					for(var/atom/A in S)//Hit everything in the turf one more time
						A.blob_act()
				else
					for(var/atom/A in S)//Hit everything in the turf
						A.ex_act(2)
					for(var/atom/A in S)//Hit everything in the turf one more time
						A.blob_act()

	return 0

/obj/effect/cellular_biomass/proc/calcEnergy(var/turf/S)
	var/cellular_biomass = 0
	cellular_biomass += getEnergy(S, 1)
	cellular_biomass += getEnergy(S, 2)
	cellular_biomass += getEnergy(S, 4)
	cellular_biomass += getEnergy(S, 8)
	return cellular_biomass

/obj/effect/cellular_biomass/proc/getEnergy(var/turf/S, var/NSEW)
	var/turf/T = get_step(S, NSEW)
	if(locate(/obj/effect/cellular_biomass) in T)
		return 1


/obj/effect/cellular_biomass/ex_act(severity)
	switch(severity)
		if(1.0)
			Destroy(src)
			return
		if(2.0)
			if (prob(90))
				Destroy(src)
				return
		if(3.0)
			if (prob(50))
				Destroy(src)
				return
	return

/obj/effect/cellular_biomass/temperature_expose(null, temp, volume) //hotspots kill cellular_biomass
	Destroy(src)



/proc/cellular_biomass_infestation()

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
			new/obj/effect/cellular_biomass_controller(T) //spawn a controller at turf
			message_admins("\blue Event: Cellular spawned at [T.loc.loc] ([T.x],[T.y],[T.z])")
