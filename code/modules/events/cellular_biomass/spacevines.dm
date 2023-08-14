// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/structure/spacevine
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = TRUE
	density = FALSE
	layer = 5
	pass_flags = PASSTABLE | PASSGRILLE
	var/energy = 0
	var/obj/effect/spacevine_controller/master = null
	var/block_light = TRUE

	max_integrity = 50
	resistance_flags = CAN_BE_HIT

/obj/structure/spacevine/Destroy()
	if(master)
		master.vines -= src
		master.growth_queue -= src
		master = null
	return ..()

/obj/structure/spacevine/attackby(obj/item/weapon/W, mob/user)
	if (!W || !user || !W.type) return
	var/temperature = W.get_current_temperature()
	if(W.sharp || iscutter(W) > 0 || temperature > 3000)
		qdel(src)
	else
		return ..()
		//Plant-b-gone damage is handled in its entry in chemistry-reagents.dm

/obj/structure/spacevine/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/structure/spacevine/attack_hand(mob/user)
	user_unbuckle_mob(user)
	user.SetNextMove(CLICK_CD_MELEE)

/obj/structure/spacevine/attack_paw(mob/user)
	user_unbuckle_mob(user)
	user.SetNextMove(CLICK_CD_MELEE)


/obj/structure/spacevine/diona
	opacity = FALSE
	block_light = FALSE


/obj/effect/spacevine_controller
	var/list/obj/structure/spacevine/vines = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the spacevines' size to something less than 20 plots, it won't grow anymore.

	var/vine_type = /obj/structure/spacevine

	var/slowdown_size = 30
	var/collapse_size = 250

/obj/effect/spacevine_controller/diona
	vine_type = /obj/structure/spacevine/diona
	opacity = FALSE

/obj/effect/spacevine_controller/atom_init()
	. = ..()
	if(!isfloorturf(loc))
		return INITIALIZE_HINT_QDEL

	spawn_spacevine_piece(src.loc)
	START_PROCESSING(SSobj, src)

/obj/effect/spacevine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/spacevine_controller/proc/spawn_spacevine_piece(turf/location)
	var/obj/structure/spacevine/SV = new vine_type(location)
	growth_queue += SV
	vines += SV
	SV.master = src

/obj/effect/spacevine_controller/process()
	if(!vines)
		qdel(src) //space  vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return
	if(vines.len >= collapse_size && !reached_collapse_size)
		reached_collapse_size = 1
	if(vines.len >= slowdown_size && !reached_slowdown_size )
		reached_slowdown_size = 1

	var/length = 0
	if(reached_collapse_size)
		length = 0
	else if(reached_slowdown_size)
		if(prob(25))
			length = 1
		else
			length = 0
	else
		length = 1
	length = min( slowdown_size , max( length , vines.len / 5 ) )
	var/i = 0
	var/list/obj/structure/spacevine/queue_end = list()

	for( var/obj/structure/spacevine/SV in growth_queue )
		i++
		queue_end += SV
		growth_queue -= SV
		if(SV.energy < 2) //If tile isn't fully grown
			if(prob(20))
				SV.grow()
		else //If tile is fully grown
			if(prob(25))
				var/mob/living/carbon/C = locate() in SV.loc
				if(C)
					SV.buckle_mob(C)

		//if(prob(25))
		SV.spread()
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end
	//sleep(5)
	//process()

/obj/structure/spacevine/proc/grow()
	if(!energy)
		src.icon_state = pick("Med1", "Med2", "Med3")
		energy = 1
		if(block_light)
			opacity = TRUE
		layer = 5
	else
		src.icon_state = pick("Hvy1", "Hvy2", "Hvy3")
		energy = 2

// simpler checks and removed user buckle
/obj/structure/spacevine/can_buckle(mob/living/M)
	if(M.buckled || buckled_mob)
		return FALSE
	return M.stat != DEAD

/obj/structure/spacevine/user_buckle_mob(mob/living/M, mob/user)
	return

/obj/structure/spacevine/buckle_mob(mob/living/M)
	. = ..()
	if(.)
		to_chat(M, "<span class='danger'>The vines [pick("wind", "tangle", "tighten")] around you!</span>")

/obj/structure/spacevine/proc/spread()
	var/direction = pick(cardinal)
	var/step = get_step(src,direction)
	if(isfloorturf(step))
		var/turf/simulated/floor/F = step
		if(!locate(/obj/structure/spacevine,F))
			if(F.Enter(src))
				if(master)
					master.spawn_spacevine_piece( F )

/obj/structure/spacevine/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(10))
				return
		if(EXPLODE_LIGHT)
			if(prob(50))
				return
	qdel(src)

/obj/structure/spacevine/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume) //hotspots kill vines
	if(exposed_temperature > T0C+100)
		qdel(src)
