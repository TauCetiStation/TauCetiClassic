//I will need to recode parts of this but I am way too tired atm

#define BLOB_NODE_MAX_PATH 10
#define BLOB_CORE_MAX_PATH 15

/obj/structure/blob
	name = "blob"
	icon = 'icons/mob/blob.dmi'
	light_range = 3
	desc = "Some blob creature thingy."
	density = FALSE
	anchored = TRUE
	can_block_air = TRUE
	layer = BELOW_MOB_LAYER
	max_integrity = 30
	var/health_timestamp = 0
	var/brute_resist = 4
	var/fire_resist = 1
	var/mob/camera/blob/OV //Optional

	resistance_flags = CAN_BE_HIT

/obj/structure/blob/atom_init()
	track_blobtile()
	set_dir(pick(1, 2, 4, 8))
	. = ..()
	update_icon()
	for(var/atom/A in loc)
		A.blob_act()
	update_nearby_tiles()
	blob_tiles_grown_total++

/obj/structure/blob/Destroy()
	blobs -= src
	if(isturf(loc)) //Necessary because Expand() is retarded and spawns a blob and then deletes it
		playsound(src, 'sound/effects/splat.ogg', VOL_EFFECTS_MASTER)
	update_nearby_tiles()
	return ..()

/obj/structure/blob/proc/track_blobtile()
	blobs += src

/obj/structure/blob/CanPass(atom/movable/mover, turf/target, height=0)
	if(!height)
		return FALSE
	if(istype(mover) && mover.checkpass(PASSBLOB))
		return TRUE
	return FALSE


/obj/structure/blob/process()
	Life()
	return

/obj/structure/blob/run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir)
	switch(damage_type)
		if(BRUTE)
			return damage_amount / brute_resist
		if(BURN)
			return damage_amount / fire_resist

/obj/structure/blob/atom_break(damage_flag)
	. = ..()
	update_icon()

/obj/structure/blob/atom_fix()
	. = ..()
	update_icon()

/obj/structure/blob/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	var/damage = clamp(0.01 * exposed_temperature, 0, 4)
	. = take_damage(damage, BURN, FIRE, FALSE)

/obj/structure/blob/proc/Life()
	return

/obj/structure/blob/proc/PulseAnimation()
	flick("[icon_state]_glow", src)
	return

/obj/structure/blob/proc/RegenHealth()
	// All blobs heal over time when pulsed, but it has a cool down
	if(health_timestamp > world.time)
		return
	if(get_integrity() < max_integrity)
		repair_damage(1)
		health_timestamp = world.time + 1 SECOND


/obj/structure/blob/proc/Pulse(max_pulse_path = BLOB_NODE_MAX_PATH, origin_dir = 0) //Todo: Fix spaceblob expand

	//set background = 1

	var/to_pulse = max_pulse_path

	var/dirn = origin_dir
	if(!dirn)
		dirn = pick(cardinal)

	var/obj/structure/blob/CurBlob = src
	var/list/blobs_affected = list()
	blobs_affected += src

	while(to_pulse > 0)
		var/turf/T = get_step(CurBlob, dirn)
		var/obj/structure/blob/NextBlob = locate(/obj/structure/blob) in T
		if(!NextBlob)
			CurBlob.expand(T) // No blob here so try and expand
			break
		var/prev_dir = reverse_dir[dirn]
		dirn = pick(cardinal - prev_dir)
		CurBlob = NextBlob
		blobs_affected += CurBlob
		to_pulse -= 1

	for (var/obj/structure/blob/B in blobs_affected)
		B.run_action()
		B.RegenHealth()

	return


/obj/structure/blob/proc/run_action()
	PulseAnimation()


/obj/structure/blob/proc/expand(turf/T = null, prob = 1)
	if(prob && !prob(get_integrity()))
		return
	if(isspaceturf(T) && prob(75))
		return
	if(!T)
		var/list/dirs = list(1,2,4,8)
		for(var/i = 1 to 4)
			var/dirn = pick(dirs)
			dirs.Remove(dirn)
			T = get_step(src, dirn)
			if(!(locate(/obj/structure/blob) in T))
				break
			T = null

	if(!T)
		return
	var/obj/structure/blob/normal/B = new /obj/structure/blob/normal(src.loc)
	B.density = TRUE
	if(T.Enter(B))//Attempt to move into the tile
		B.density = initial(B.density)
		B.loc = T
	else
		T.blob_act()//If we cant move in hit the turf
		B.loc = null //So we don't play the splat sound, see Destroy()
		qdel(B)

	for(var/atom/A in T)//Hit everything in the turf
		A.blob_act()

/obj/structure/blob/ex_act(severity)
	var/damage = 150 - (severity * 5)
	take_damage(damage, BRUTE, BOMB, FALSE)

/obj/structure/blob/blob_act()
	return

/obj/structure/blob/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM
		L.blob_act()

/obj/structure/blob/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', VOL_EFFECTS_MASTER)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER)
		if(BURN)
			playsound(loc, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)


/obj/structure/blob/attack_animal(mob/living/simple_animal/M)
	if(M.faction == "blob") //No friendly slams
		return
	. = ..()
	if(.)
		visible_message("<span class='danger'>The [src.name] has been attacked by \the [M].</span>")

/obj/structure/blob/proc/change_to(type, overmind)
	if(!ispath(type))
		error("[type] is an invalid type for the blob.")
	var/obj/structure/blob/B = new type(loc)
	if(overmind)
		B.OV = overmind
	qdel(src)
	return B

/obj/structure/blob/normal
	icon_state = "blob"
	integrity_failure = 0.5

/obj/structure/blob/normal/update_icon()
	if(get_integrity() <= max_integrity * integrity_failure)
		icon_state = "blob_damaged"
	else
		icon_state = "blob"

/* // Used to create the glow sprites. Remember to set the animate loop to 1, instead of infinite!

var/global/datum/blob_colour/B = new()

/datum/blob_colour/New()
	..()
	var/icon/I = 'icons/mob/blob.dmi'
	I += rgb(35, 35, 0)
	if(isfile("icons/mob/blob_result.dmi"))
		fdel("icons/mob/blob_result.dmi")
	fcopy(I, "icons/mob/blob_result.dmi")

*/

/obj/structure/blob/tunelled
	icon_state = "blob"
	light_range = 0

/obj/structure/blob/tunelled/track_blobtile()
	return

/obj/structure/blob/tunelled/factory
	name = "factory blob"
	icon_state = "blob_factory"

/obj/structure/blob/tunelled/update_icon()
	return
