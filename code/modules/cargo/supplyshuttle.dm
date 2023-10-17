//Config stuff
var/global/list/mechtoys = list(
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
	density = FALSE
	anchored = TRUE
	can_block_air = TRUE
	layer = 4

	resistance_flags = CAN_BE_HIT

/obj/structure/plasticflaps/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	if(istype(caller, /obj/machinery/bot/mulebot))
		return TRUE

	if(isliving(caller))
		var/mob/living/M = caller
		if(!M.ventcrawler || !M.lying)
			return FALSE

	return TRUE

/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(!istype(A))
		return FALSE
	if(A.checkpass(PASSGLASS)) // for laser projectile
		return prob(60)
	if(A.checkpass(PASSTABLE))
		return TRUE

	var/obj/structure/stool/bed/B = A
	if (istype(A, /obj/structure/stool/bed) && B.buckled_mob) //if it's a bed/chair and someone is buckled, it will not pass
		return FALSE

	else if(isliving(A)) // You Shall Not Pass!
		var/mob/living/M = A
		if(M.throwing) // so disposal outlets can throw mobs through plastic flaps
			return TRUE
		if(istype(M, /mob/living/simple_animal/hostile))
			return FALSE
		if(!M.lying) //If your not laying down, or a small creature, no pass.
			return FALSE
	return ..()

/obj/structure/plasticflaps/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/mineral/plastic(loc, 5)
	..()

/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(95))
				return
	qdel(src)

/obj/structure/plasticflaps/explosion_proof
	resistance_flags = FULL_INDESTRUCTIBLE

/obj/structure/plasticflaps/explosion_proof/ex_act(severity)
	return

/obj/structure/plasticflaps/mining
	name = "Airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."
