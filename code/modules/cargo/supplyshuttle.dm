//Config stuff
var/list/mechtoys = list(
	/obj/item/toy/prize/ripley,
	/obj/item/toy/prize/fireripley,
	/obj/item/toy/prize/deathripley,
	/obj/item/toy/prize/gygax,
	/obj/item/toy/prize/durand,
	/obj/item/toy/prize/honk,
	/obj/item/toy/prize/marauder,
	/obj/item/toy/prize/seraph,
	/obj/item/toy/prize/mauler,
	/obj/item/toy/prize/odysseus,
	/obj/item/toy/prize/phazon
)

//SUPPLY PACKS MOVED TO /code/defines/obj/supplypacks.dm

/obj/structure/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/stationobjs.dmi' //Change this.
	icon_state = "plasticflaps"
	density = 0
	anchored = 1
	layer = 4
	explosion_resistance = 5

/obj/structure/plasticflaps/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	if(istype(caller, /obj/machinery/bot/mulebot))
		return TRUE

	if(isliving(caller))
		var/mob/living/M = caller
		if(!M.ventcrawler || !M.lying)
			return FALSE

	return TRUE

/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(istype(A) && A.checkpass(PASSGLASS))
		return prob(60)

	var/obj/structure/stool/bed/B = A
	if (istype(A, /obj/structure/stool/bed) && B.buckled_mob)//if it's a bed/chair and someone is buckled, it will not pass
		return FALSE

	else if(istype(A, /mob/living)) // You Shall Not Pass!
		var/mob/living/M = A
		if(M.throwing) // so disposal outlets can throw mobs through plastic flaps
			return TRUE
		if(istype(M, /mob/living/simple_animal/hostile))
			return FALSE
		if(!M.lying && !istype(M, /mob/living/carbon/monkey) && !istype(M, /mob/living/carbon/slime) && !istype(M, /mob/living/simple_animal/mouse) && !istype(M, /mob/living/silicon/robot/drone))  //If your not laying down, or a small creature, no pass.
			return FALSE
	return ..()

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(50))
				qdel(src)
		if (3)
			if (prob(5))
				qdel(src)

/obj/structure/plasticflaps/explosion_proof/ex_act(severity)
	return

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "Airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."

/obj/structure/plasticflaps/mining/atom_init() //set the turf below the flaps to block air
	var/turf/T = get_turf(loc)
	if(T)
		T.blocks_air = 1
	. = ..()

/obj/structure/plasticflaps/mining/Destroy() //lazy hack to set the turf to allow air to pass if it's a simulated floor
	var/turf/T = get_turf(loc)
	if(T)
		if(istype(T, /turf/simulated/floor))
			T.blocks_air = 0
	return ..()
