/obj/structure/cellular_biomass/lair
	layer = 3
	health = 120
	var/spawn_chance = 1
	var/active = 1
	var/spawned_mob = /mob/living/simple_animal/hostile/carp
	var/obj/lair_life_monitor/life_monitor = null

/obj/structure/cellular_biomass/lair/atom_init(mapload, spawned_mob_type)
	START_PROCESSING(SSobj, src)
	spawned_mob = spawned_mob_type
	spawn_mob()

/obj/structure/cellular_biomass/lair/proc/spawn_mob()
	var/mob/living/my_mob = new spawned_mob(src.loc)
	life_monitor = new /obj/lair_life_monitor(src, my_mob)

/obj/structure/cellular_biomass/lair/process()
	if(!active)
		return
	if(life_monitor)
		life_monitor.check()
	else
		if(prob(spawn_chance))
			spawn_mob()


/obj/structure/cellular_biomass/lair/Destroy()
	if(life_monitor)
		qdel(life_monitor)
	STOP_PROCESSING(SSobj, src)
	..()
	return QDEL_HINT_QUEUE

//Mob anal probe

/obj/lair_life_monitor
	var/obj/structure/cellular_biomass/lair/lair_to_report

/obj/lair_life_monitor/atom_init(mapload, obj/structure/cellular_biomass/lair/lair , mob/living/my_mob)
	if(!lair || ! my_mob)
		return INITIALIZE_HINT_QDEL
	loc = my_mob
	lair_to_report = lair

/obj/lair_life_monitor/proc/check()
	if(!ismob(src.loc))
		return
	var/mob/living/my_mob = src.loc
	if(get_dist(my_mob,lair_to_report) > 30 || my_mob.z != lair_to_report.z)
		qdel(src)
	if(!(my_mob && my_mob.health > 0))
		qdel(src)

/obj/lair_life_monitor/Destroy()
	if(lair_to_report)
		lair_to_report.life_monitor = null
		lair_to_report = null
	..()
	return QDEL_HINT_QUEUE
