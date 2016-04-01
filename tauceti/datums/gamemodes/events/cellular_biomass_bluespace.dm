// BIOMASS (Note that this code is very similar to Space Vine code)
/obj/structure/cellular_biomass_blue
	name = "Reality error"
	desc = "This is (F&_@#D+Q@DQ@!"
	icon = 'tauceti/datums/gamemodes/events/bluespace_cellular.dmi'
	icon_state = "bluewall_1"

	anchored = 1
	density = 1
	opacity = 1

	var/grip = 0
	var/health = 100
	var/energy = 0

	var/obj/effect/cellular_biomass_blue_controller/master = null

/obj/structure/cellular_biomass_blue/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 0

/obj/structure/cellular_biomass_blue/Destroy()
	if(master)
		master.biomass_cells -= src
		master.growth_queue -= src
	master = null
	..()
	return QDEL_HINT_QUEUE

/obj/structure/cellular_biomass_blue/grass/Destroy()
	for(var/obj/effect/decal/cleanable/bluespace/clean in src.loc)
		qdel(clean)
	..()
/obj/structure/cellular_biomass_blue/proc/healthcheck()
	if(health <=0)
		qdel(src)
	return

/obj/structure/cellular_biomass_blue/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()
	return

/obj/structure/cellular_biomass_blue/ex_act(severity)
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

/obj/structure/cellular_biomass_blue/blob_act()
	health-=50
	healthcheck()
	return

/obj/structure/cellular_biomass_blue/meteorhit()
	health-=100
	healthcheck()
	return

/obj/structure/cellular_biomass_blue/attack_hand()
	..()
	playsound(loc, 'sound/effects/EMPulse.ogg', 50, 1)
	return

/obj/structure/cellular_biomass_blue/attack_paw()
	return attack_hand()

/obj/structure/cellular_biomass_blue/attack_alien()
	return attack_hand()

/obj/structure/cellular_biomass_blue/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	health -= W.force
	playsound(loc, 'sound/effects/EMPulse.ogg', 50, 1)
	healthcheck()
	return


/obj/structure/cellular_biomass_blue/grass
	icon_state = "bluegrass_1" //	color = "#00FFFF"
	density = 0
	opacity = 0
	health = 20
	layer = 2
	energy = 4

/obj/structure/cellular_biomass_blue/grass/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1

/obj/structure/cellular_biomass_blue/grass/light
	layer = 3
	health = 60
	luminosity = 4
	light_color = "#00FFFF"
	icon_state = "light_1"

/obj/structure/cellular_biomass_blue/grass/light/New()
	set_light(luminosity)

/obj/effect/cellular_biomass_blue_controller
	var/list/obj/structure/cellular_biomass_blue/biomass_cells = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size

/obj/effect/cellular_biomass_blue_controller/New()
	if(!istype(src.loc,/turf/simulated/floor))
		qdel(src)
		return
	spawn_cellular_biomass_blue_piece(src.loc)
	SSobj.processing |= src

/obj/effect/cellular_biomass_blue_controller/Destroy()
	growth_queue.Cut()
	for(var/obj/structure/cellular_biomass_blue/str in biomass_cells)
		str.master = null
	SSobj.processing.Remove(src)
	return ..()

/obj/effect/cellular_biomass_blue_controller/proc/spawn_cellular_biomass_blue_piece(var/turf/location, var/obj/structure/cellular_biomass_blue/parent)
	var/newgrip = 0
	if (parent)
		if(istype(location,/turf/simulated))
			newgrip = 5
		else
			newgrip = parent.grip - 1
	if(!parent || newgrip > 0)
		var/obj/structure/cellular_biomass_blue/BM = new(location)
		if (istype(location,/turf/space))
			location:ChangeTurf(/turf/simulated/floor/plating)
		BM.grip = newgrip
		growth_queue += BM
		biomass_cells += BM
		BM.master = src

/obj/effect/cellular_biomass_blue_controller/process()
	if(!biomass_cells)
		qdel(src) //space  biomass_cells exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src)
		return

	var/length = min(5, max(50, biomass_cells.len / 5))
	var/list/obj/structure/cellular_biomass_blue/queue_end = list()

	var/i = 0
	for(var/obj/structure/cellular_biomass_blue/BM in growth_queue)
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

/obj/structure/cellular_biomass_blue/proc/grow()
	energy = calcEnergy(src.loc)
	if(energy >= 4)
		if(prob(5))
			new /obj/structure/cellular_biomass_blue/grass/light(src.loc)
		else
			if(prob(30))
				new /obj/effect/decal/cleanable/bluespace(src.loc)
		if(prob(8))
			var/list/critters = subtypesof(/mob/living/simple_animal/hostile/bluespace)
			var/chosen = pick(critters)
			var/mob/living/simple_animal/hostile/C = new chosen
			C.loc = src.loc
		new /obj/structure/cellular_biomass_blue/grass(src.loc)
		qdel(src)

/obj/structure/cellular_biomass_blue/proc/spread(src.loc)
	if(qdeleted(src))
		return
	var/turf/T = src.loc
	var/turf/S = get_step(T,pick(1,2,4,8))
	if(locate(/obj/structure/cellular_biomass_blue, S))
		return
	if(istype(S,/turf/simulated/wall))
		if(calcEnergy(S)==3)
			S.blob_act()
		return
	if(S.Enter(src) && master)
		for(var/obj/A in S)//Del everything.
			qdel(A)
		master.spawn_cellular_biomass_blue_piece(S, src)
	if ((locate(/obj/machinery/door, S) || locate(/obj/structure/window, S)) && prob(90))
		return
	for(var/atom/A in S)//Hit everything in the turf
		A.blob_act()


/obj/structure/cellular_biomass_blue/proc/calcEnergy(var/turf/S)
	return (getEnergy(S, 1) + getEnergy(S, 2) + getEnergy(S, 4) + getEnergy(S, 8))

/obj/structure/cellular_biomass_blue/proc/getEnergy(var/turf/S, var/side)
	var/turf/T = get_step(S, side)
	if(locate(/obj/structure/cellular_biomass_blue) in T)
		return 1
	return 0

/mob/living/simple_animal/hostile/bluespace
	name = "Moving Glitch"
	desc = "It's impossible to deEF*E((F((F(CVP"
	icon = 'tauceti/datums/gamemodes/events/bluespace_cellular.dmi'
	speak_emote = list("buzzing")
	attacktext = "discarges"
	attack_sound = 'sound/weapons/blaster.ogg'
	faction = "bluespace"
	health = 35
	maxHealth = 35
	melee_damage_lower = 1
	melee_damage_upper = 15
	speed = 1

/mob/living/simple_animal/hostile/bluespace/meelee
	icon_state = "bluemob_1"
	icon_living = "bluemob_1"
	icon_dead = "bluemob_1"

/mob/living/simple_animal/hostile/bluespace/ranged
	icon_state = "bluemob_2"
	icon_living = "bluemob_2"
	icon_dead = "bluemob_2"

/mob/living/simple_animal/hostile/bluespace/death()
	..()
	visible_message("<b>[src]</b> vanishes!")
	qdel(src)
	return

/mob/living/simple_animal/hostile/bluespace/meelee/bullet_act()
	visible_message("<b>[src]</b> duplicates!")
	new /mob/living/simple_animal/hostile/bluespace/meelee(src.loc)
	return

/mob/living/simple_animal/hostile/bluespace/ranged/attackby(obj/item/weapon/W as obj, mob/user as mob)
	visible_message("<b>[src]</b> duplicates!")
	new /mob/living/simple_animal/hostile/bluespace/ranged(src.loc)
	return

/obj/effect/decal/cleanable/bluespace
	name = "Glitch"
	desc = "(W#_F(AWI_+AIGgggg"
	icon = 'tauceti/datums/gamemodes/events/bluespace_cellular.dmi'
	icon_state = "creep_1"
	random_icon_states = list("decal_1", "decal_2", "decal_3", "decal_4", "decal_5")