/obj/item/weapon/grenade/flashbang
	name = "flashbang"
	icon_state = "flashbang"
	item_state = "flashbang"
	origin_tech = "materials=2;combat=1"
	var/banglet = FALSE
	var/flashbang_range = 7 //how many tiles away the mob will be stunned.

/obj/item/weapon/grenade/flashbang/prime()
	..()

	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return

	var/datum/effect/effect/system/spark_spread/S = new
	S.set_up(rand(5, 9), FALSE, src)
	S.start()
	new /obj/effect/dummy/lighting_obj(flashbang_turf, LIGHT_COLOR_WHITE, (flashbang_range + 2), 4, 2)

	for(var/obj/structure/closet/L in hear(flashbang_range, flashbang_turf))
		if(locate(/mob/living/carbon) in L)
			for(var/mob/living/carbon/M in L)
				bang(flashbang_turf, M)

	for(var/mob/living/carbon/M in hear(flashbang_range, flashbang_turf))
		bang(flashbang_turf, M)

	for(var/obj/effect/blob/B in hear(flashbang_range + 1, flashbang_turf))	//Blob damage here
		var/damage = round(30 / (get_dist(B, flashbang_turf) + 1))
		B.health -= damage
		B.update_icon()

	qdel(src)

/obj/item/weapon/grenade/flashbang/proc/bang(turf/T , mob/living/carbon/M)	// Added a new proc called 'bang' that takes a location and a person to be banged.
	to_chat(M, "<span class='warning'><B>BANG</B></span>")
	playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER, null, null, 5)

//Checking for protections
	var/eye_safety = 0
	var/ear_safety = 0
	if(iscarbon(M))
		eye_safety = M.eyecheck()
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.l_ear, /obj/item/clothing/ears/earmuffs) || istype(H.r_ear, /obj/item/clothing/ears/earmuffs))
				ear_safety += 2
			if(HULK in M.mutations)
				ear_safety += 1
			if(istype(H.head, /obj/item/clothing/head/helmet))
				ear_safety += 1

//Flashing everyone
	if(eye_safety < 1)
		M.flash_eyes()
		M.Stun(2)
		M.Weaken(10)

//Now applying sound
	var/distance = get_dist(M, T)
	if((distance <= 2 || loc == M.loc || loc == M))
		if(ear_safety > 1)
			M.Stun(1.5)
		else if(ear_safety > 0)
			M.Stun(2)
			M.Weaken(1)
		else
			M.Stun(10)
			M.Weaken(3)
			if((prob(14) || (M == loc && prob(70))))
				M.ear_damage += rand(1, 10)
			else
				M.ear_damage += rand(0, 5)
				M.ear_deaf = max(M.ear_deaf, 15)

	else if(distance <= 5)
		if(!ear_safety)
			M.Stun(8)
			M.ear_damage += rand(0, 3)
			M.ear_deaf = max(M.ear_deaf, 10)

	else if(!ear_safety)
		M.Stun(4)
		M.ear_damage += rand(0, 1)
		M.ear_deaf = max(M.ear_deaf, 5)

//This really should be in mob not every check
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/internal/eyes/IO = H.organs_by_name[O_EYES]
		if(IO.damage >= IO.min_bruised_damage)
			to_chat(M, "<span class='warning'>Your eyes start to burn badly!</span>")
			if(!banglet && !(istype(src , /obj/item/weapon/grenade/clusterbuster)))
				if(IO.damage >= IO.min_broken_damage)
					to_chat(M, "<span class='warning'>You can't see anything!</span>")
		if(H.species.name == SHADOWLING) // BBQ from shadowling ~Zve
			H.adjustFireLoss(rand(15, 25))
	if(M.ear_damage >= 15)
		to_chat(M, "<span class='warning'>Your ears start to ring badly!</span>")
		if(!banglet && !(istype(src , /obj/item/weapon/grenade/clusterbuster)))
			if(prob(M.ear_damage - 5))
				to_chat(M, "<span class='warning'>You can't hear anything!</span>")
				M.sdisabilities |= DEAF
	else if(M.ear_damage >= 5)
		to_chat(M, "<span class='warning'>Your ears start to ring!</span>")
	M.update_icons()

////////////////////
//Clusterbang
////////////////////
/obj/item/weapon/grenade/clusterbuster
	desc = "Use of this weapon may constiute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"
	var/payload = /obj/item/weapon/grenade/flashbang/cluster
	var/numspawned = 4

/obj/item/weapon/grenade/clusterbuster/prime()
	update_icon()

	for(var/i in 1 to numspawned)
		new /obj/item/weapon/grenade/clusterbuster/segment(loc, payload)	//Creates 'segments' that launches a few more payloads

	playsound(src, 'sound/weapons/armbomb.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	qdel(src)


//////////////////////
//Clusterbang segment
//////////////////////
/obj/item/weapon/grenade/clusterbuster/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"
	numspawned = 2

/obj/item/weapon/grenade/clusterbuster/segment/atom_init(mapload, payload_type = /obj/item/weapon/grenade/flashbang/cluster)
	. = ..()
	icon_state = "clusterbang_segment_active"
	payload = payload_type
	active = TRUE
	walk_away(src,loc,rand(1,4))
	addtimer(CALLBACK(src, .proc/prime), rand(15,60))

/obj/item/weapon/grenade/clusterbuster/segment/prime()
	for(var/i in 1 to numspawned)
		var/obj/item/weapon/grenade/P = new payload(src.loc)
		P.active = 1
		walk_away(P,loc,rand(1,4))
		addtimer(CALLBACK(P, /obj/item/weapon/grenade.proc/prime), rand(15,60))
	playsound(src, 'sound/weapons/armbomb.ogg', VOL_EFFECTS_MASTER, null, null, -3)
	qdel(src)

//////////////////////////////////
//The payload spawner effect
/////////////////////////////////

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
