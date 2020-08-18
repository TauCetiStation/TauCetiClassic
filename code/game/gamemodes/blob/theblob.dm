//I will need to recode parts of this but I am way too tired atm

#define BLOB_NODE_MAX_PATH 10
#define BLOB_CORE_MAX_PATH 15

/obj/effect/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	light_range = 3
	desc = "Some blob creature thingy."
	density = 0
	opacity = TRUE
	anchored = 1
	layer = BELOW_MOB_LAYER
	var/health = 30
	var/health_timestamp = 0
	var/brute_resist = 4
	var/fire_resist = 1

/obj/effect/blob/atom_init()
	blobs += src
	dir = pick(1, 2, 4, 8)
	update_icon()
	. = ..()
	for(var/atom/A in loc)
		A.blob_act()
	update_nearby_tiles()

/obj/effect/blob/Destroy()
	blobs -= src
	if(isturf(loc)) //Necessary because Expand() is retarded and spawns a blob and then deletes it
		playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)
	update_nearby_tiles()
	return ..()


/obj/effect/blob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0))	return 0
	if(istype(mover) && mover.checkpass(PASSBLOB))	return 1
	return 0


/obj/effect/blob/process()
	Life()
	return

/obj/effect/blob/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	var/damage = clamp(0.01 * exposed_temperature / fire_resist, 0, 4 - fire_resist)
	if(damage)
		health -= damage
		update_icon()

/obj/effect/blob/proc/Life()
	return

/obj/effect/blob/proc/PulseAnimation()
	flick("[icon_state]_glow", src)
	return

/obj/effect/blob/proc/RegenHealth()
	// All blobs heal over time when pulsed, but it has a cool down
	if(health_timestamp > world.time)
		return 0
	if(health < initial(health))
		health++
		update_icon()
		health_timestamp = world.time + 10 // 1 seconds


/obj/effect/blob/proc/Pulse(max_pulse_path = BLOB_NODE_MAX_PATH, origin_dir = 0) //Todo: Fix spaceblob expand

	//set background = 1

	var/to_pulse = max_pulse_path

	var/dirn = origin_dir
	if(!dirn)
		dirn = pick(cardinal)

	var/obj/effect/blob/CurBlob = src
	var/list/blobs_affected = list()
	blobs_affected += src

	while(to_pulse > 0)
		var/turf/T = get_step(CurBlob, dirn)
		var/obj/effect/blob/NextBlob = (locate(/obj/effect/blob) in T)
		if(!NextBlob)
			CurBlob.expand(T) // No blob here so try and expand
			break
		var/prev_dir = reverse_dir[dirn]
		dirn = pick(cardinal - prev_dir)
		CurBlob = NextBlob
		blobs_affected += CurBlob
		to_pulse -= 1

	for (var/obj/effect/blob/B in blobs_affected)
		B.run_action()
		B.RegenHealth()

	return


/obj/effect/blob/proc/run_action()
	PulseAnimation()
	return 0


/obj/effect/blob/proc/expand(turf/T = null, prob = 1)
	if(prob && !prob(health))	return
	if(istype(T, /turf/space) && prob(75)) 	return
	if(!T)
		var/list/dirs = list(1,2,4,8)
		for(var/i = 1 to 4)
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			T = get_step(src, dirn)
			if(!(locate(/obj/effect/blob) in T))	break
			else	T = null

	if(!T)	return 0
	var/obj/effect/blob/normal/B = new /obj/effect/blob/normal(src.loc, min(src.health, 30))
	B.density = 1
	if(T.Enter(B,src))//Attempt to move into the tile
		B.density = initial(B.density)
		B.loc = T
	else
		T.blob_act()//If we cant move in hit the turf
		B.loc = null //So we don't play the splat sound, see Destroy()
		qdel(B)

	for(var/atom/A in T)//Hit everything in the turf
		A.blob_act()
	return 1

/obj/effect/blob/ex_act(severity)
	var/damage = 150
	health -= ((damage/brute_resist) - (severity * 5))
	update_icon()
	return


/obj/effect/blob/bullet_act(obj/item/projectile/Proj)
	..()
	switch(Proj.damage_type)
	 if(BRUTE)
		 health -= (Proj.damage/brute_resist)
	 if(BURN)
		 health -= (Proj.damage/fire_resist)

	update_icon()
	return 0

/obj/effect/blob/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM
		L.blob_act()


/obj/effect/blob/attackby(obj/item/weapon/W, mob/user)
	if(user.a_intent != INTENT_HARM)
		return

	. = ..()
	playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
	var/damage = 0
	switch(W.damtype)
		if("fire")
			damage = (W.force / max(src.fire_resist,1))
			if(iswelder(W))
				playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)
		if("brute")
			damage = (W.force / max(src.brute_resist,1))

	health -= damage
	update_icon()

/obj/effect/blob/attack_animal(mob/living/simple_animal/M)
	..()
	playsound(src, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
	src.visible_message("<span class='danger'>The [src.name] has been attacked by \the [M].</span>")
	var/damage = M.melee_damage
	if(!damage) // Avoid divide by zero errors
		return
	damage /= max(src.brute_resist, 1)
	health -= damage
	update_icon()
	return

/obj/effect/blob/proc/change_to(type)
	if(!ispath(type))
		error("[type] is an invalid type for the blob.")
	new type(src.loc)
	qdel(src)

/obj/effect/blob/normal
	icon_state = "blob"
	health = 21

/obj/effect/blob/normal/update_icon()
	if(health <= 0)
		qdel(src)
	else if(health <= 15)
		icon_state = "blob_damaged"
	else
		icon_state = "blob"

/obj/effect/blob/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(temperature > T0C+200)
		health -= 1 * temperature
		update_icon()

/* // Used to create the glow sprites. Remember to set the animate loop to 1, instead of infinite!

var/datum/blob_colour/B = new()

/datum/blob_colour/New()
	..()
	var/icon/I = 'icons/mob/blob.dmi'
	I += rgb(35, 35, 0)
	if(isfile("icons/mob/blob_result.dmi"))
		fdel("icons/mob/blob_result.dmi")
	fcopy(I, "icons/mob/blob_result.dmi")

*/
