/obj/item/weapon/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	origin_tech = "materials=2;combat=1"
	var/banglet = 0

	prime()
		..()
		for(var/obj/structure/closet/L in hear(7, get_turf(src)))
			if(locate(/mob/living/carbon/, L))
				for(var/mob/living/carbon/M in L)
					bang(get_turf(src), M)


		for(var/mob/living/carbon/M in hear(7, get_turf(src)))
			bang(get_turf(src), M)

		for(var/obj/effect/blob/B in hear(8,get_turf(src)))       		//Blob damage here
			var/damage = round(30/(get_dist(B,get_turf(src))+1))
			B.health -= damage
			B.update_icon()

		new/obj/effect/effect/smoke/flashbang(src.loc)
		qdel(src)
		return

	proc/bang(turf/T , mob/living/carbon/M)						// Added a new proc called 'bang' that takes a location and a person to be banged.
		to_chat(M, "\red <B>BANG</B>")
		playsound(src.loc, 'sound/effects/bang.ogg', 50, 1, 5)

//Checking for protections
		var/eye_safety = 0
		var/ear_safety = 0
		if(iscarbon(M))
			eye_safety = M.eyecheck()
			if(ishuman(M))
				if(istype(M:l_ear, /obj/item/clothing/ears/earmuffs) || istype(M:r_ear, /obj/item/clothing/ears/earmuffs))
					ear_safety += 2
				if(HULK in M.mutations)
					ear_safety += 1
				if(istype(M:head, /obj/item/clothing/head/helmet))
					ear_safety += 1

//Flashing everyone
		if(eye_safety < 1)
			M.flash_eyes()
			M.Stun(2)
			M.Weaken(10)



//Now applying sound
		if((get_dist(M, T) <= 2 || src.loc == M.loc || src.loc == M))
			if(ear_safety > 0)
				M.Stun(2)
				M.Weaken(1)
			else
				M.Stun(10)
				M.Weaken(3)
				if ((prob(14) || (M == src.loc && prob(70))))
					M.ear_damage += rand(1, 10)
				else
					M.ear_damage += rand(0, 5)
					M.ear_deaf = max(M.ear_deaf,15)

		else if(get_dist(M, T) <= 5)
			if(!ear_safety)
				M.Stun(8)
				M.ear_damage += rand(0, 3)
				M.ear_deaf = max(M.ear_deaf,10)

		else if(!ear_safety)
			M.Stun(4)
			M.ear_damage += rand(0, 1)
			M.ear_deaf = max(M.ear_deaf,5)

//This really should be in mob not every check
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
			if (E.damage >= E.min_bruised_damage)
				to_chat(M, "\red Your eyes start to burn badly!")
				if(!banglet && !(istype(src , /obj/item/weapon/grenade/clusterbuster)))
					if (E.damage >= E.min_broken_damage)
						to_chat(M, "\red You can't see anything!")
			if(H.species.name == "Shadowling") // BBQ from shadowling ~Zve
				H.adjustFireLoss(rand(15,25))
		if (M.ear_damage >= 15)
			to_chat(M, "\red Your ears start to ring badly!")
			if(!banglet && !(istype(src , /obj/item/weapon/grenade/clusterbuster)))
				if (prob(M.ear_damage - 10 + 5))
					to_chat(M, "\red You can't hear anything!")
					M.sdisabilities |= DEAF
		else
			if (M.ear_damage >= 5)
				to_chat(M, "\red Your ears start to ring!")
		M.update_icons()

/obj/effect/effect/smoke/flashbang
	name = "illumination"
	time_to_live = 10
	opacity = 0
	icon_state = "sparks"

////////////////////
//Clusterbang
////////////////////
/obj/item/weapon/grenade/clusterbuster
	desc = "Use of this weapon may constiute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"
	var/payload = /obj/item/weapon/grenade/flashbang/cluster

/obj/item/weapon/grenade/clusterbuster/prime()
	update_icon()
	var/numspawned = rand(4,8)
	var/again = 0

	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			again++
			numspawned--

	while(again)
		new /obj/item/weapon/grenade/clusterbuster/segment(loc, payload)//Creates 'segments' that launches a few more payloads
		again--
	new /obj/effect/payload_spawner(loc, payload, numspawned)//Launches payload

	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	qdel(src)


//////////////////////
//Clusterbang segment
//////////////////////
/obj/item/weapon/grenade/clusterbuster/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"

/obj/item/weapon/grenade/clusterbuster/segment/New(var/loc, var/payload_type = /obj/item/weapon/grenade/flashbang/cluster)
	..()
	icon_state = "clusterbang_segment_active"
	payload = payload_type
	active = 1
	walk_away(src,loc,rand(1,4))
	addtimer(src, "prime", rand(15,60))

/obj/item/weapon/grenade/clusterbuster/segment/prime()

	new /obj/effect/payload_spawner(loc, payload, rand(4,8))

	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	qdel(src)

//////////////////////////////////
//The payload spawner effect
/////////////////////////////////
/obj/effect/payload_spawner/New(var/turf/newloc,var/type, var/numspawned as num)

	for(var/loop = numspawned ,loop > 0, loop--)
		var/obj/item/weapon/grenade/P = new type(loc)
		P.active = 1
		walk_away(P,loc,rand(1,4))

		addtimer(P, "prime", rand(15,60))
	qdel(src)

/obj/item/weapon/grenade/flashbang/cluster
	icon_state = "flashbang_active"

/obj/item/weapon/grenade/clusterbuster/emp
	name = "Electromagnetic Storm"
	payload = /obj/item/weapon/grenade/empgrenade

/obj/item/weapon/grenade/clusterbuster/syndieminibomb
	name = "SyndiWrath"
	payload = /obj/item/weapon/grenade/syndieminibomb

/obj/item/weapon/grenade/clusterbuster/spawner_manhacks
	name = "iViscerator"
	payload = /obj/item/weapon/grenade/spawnergrenade/manhacks

/obj/item/weapon/grenade/clusterbuster/spawner_spesscarp
	name = "Invasion of the Space Carps"
	payload = /obj/item/weapon/grenade/spawnergrenade/spesscarp

/obj/item/weapon/grenade/clusterbuster/soap
	name = "Slipocalypse"
	payload = /obj/item/weapon/grenade/spawnergrenade/syndiesoap