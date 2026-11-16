// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/structure/spacevine
	name = "space vines"
	desc = "An extremely expansionistic species of vine."
	icon = 'icons/obj/flora/spacevines/vines.dmi'
	icon_state = "Light1"
	anchored = TRUE
	density = FALSE
	layer = 5
	pass_flags = PASSTABLE | PASSGRILLE
	var/energy = 0
	var/obj/effect/spacevine_controller/master = null
	var/block_light = TRUE

	var/obj/structure/spacevine/connected
	var/datum/beam/vine

	max_integrity = 50
	resistance_flags = CAN_BE_HIT

/obj/structure/spacevine/Destroy()
	if(master)
		master.vines -= src
		master.growth_queue -= src
		master = null

	if(connected)
		connected.connected = null
		connected = null
	if(vine)
		vine.End()
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

	spawn_initial_piece(get_turf(src))
	START_PROCESSING(SSobj, src)

/obj/effect/spacevine_controller/proc/spawn_initial_piece(turf/T)
	for(var/direction in global.cardinal)
		var/turf/step = T
		for(var/i in 1 to 3)
			var/new_step = get_step(step, direction)
			if(!can_enter_turf(src, new_step, step))
				spawn_spacevine_piece(step, direction)
				return

			step = new_step

	qdel(src)

/obj/effect/spacevine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/spacevine_controller/proc/spawn_spacevine_piece(turf/location, direction)
	for(var/obj/structure/spacevine/vine in location.contents)
		if(vine.dir == direction)
			return

	var/obj/structure/spacevine/SV = new vine_type(location)
	SV.dir = direction
	SV.pixel_x = X_OFFSET(24, direction)
	SV.pixel_y = Y_OFFSET(24, direction)

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

		if(prob(10))
			if(!SV.connected)
				SV.throw_vine()
			else if(SV.vine && SV.vine.elements.len)
				var/obj/effect/ebeam/spacevine/piece = pick(SV.vine.elements)
				piece.grow()

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

/obj/structure/spacevine/proc/throw_vine()
	if(connected || vine)
		return
	var/turf/L = get_turf(src)
	for(var/turf/T in getline(L, get_ranged_target_turf(src, pick(global.alldirs - dir), 4)))
		for(var/obj/structure/spacevine/check_vine in T.contents)
			if(!check_vine)
				continue

			if(check_vine.connected)
				continue

			connected = check_vine
			vine = Beam(check_vine, /obj/effect/ebeam/spacevine::icon_state, /obj/effect/ebeam/spacevine::icon, time=INFINITY, maxdistance=10, beam_type=/obj/effect/ebeam/spacevine, loose_factor = 0.5, dense_beam = FALSE)
			check_vine.vine = vine
			return

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
	if(!master)
		return

	var/list/possible_dirs = (dir in list(NORTH, SOUTH)) ? list(EAST, WEST) : list(NORTH, SOUTH)
	var/direction = pick(possible_dirs)
	var/turf/step = get_step(src,direction)
	if(!step)
		return

	if(!can_enter_turf(src, step))
		var/turf/T = get_turf(src)
		for(var/obj/structure/spacevine/vine in T.contents)
			if(vine.dir == get_dir(step, T))
				return

		master.spawn_spacevine_piece(T, direction)
		return

	if(!isfloorturf(step))
		return

	var/turf/simulated/floor/F = step
	for(var/new_dir in global.cardinal)
		step = get_step(F, new_dir)
		if(can_enter_turf(src, step, F))
			continue

		master.spawn_spacevine_piece(F, new_dir)
		return

	var/turf/around_the_corner = get_step(F, dir)
	if(!can_enter_turf(src, F, around_the_corner))
		return
	var/turf/wall = get_step(get_turf(src), dir)
	if(!can_enter_turf(src, wall, around_the_corner))
		master.spawn_spacevine_piece(around_the_corner, get_dir(around_the_corner, wall))

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



/obj/effect/ebeam/spacevine
	icon = 'icons/obj/flora/spacevines/vines.dmi'
	icon_state = "vine"
	layer = INFRONT_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_ICON

/obj/effect/ebeam/spacevine/CanPass(atom/movable/mover, turf/target, height=0)
	if(!density)
		return TRUE
	if (mover.pass_flags & (PASSTABLE | PASSCRAWL) || istype(mover, /obj/effect/meteor) || mover.throwing)
		return TRUE
	if(istype(mover, /obj/structure/spacevine))
		return TRUE
	else
		return FALSE

/obj/effect/ebeam/spacevine/proc/grow()
	owner.beam_type = /obj/effect/ebeam/spacevine/medium
	owner.icon = /obj/effect/ebeam/spacevine/medium::icon
	owner.icon_state = /obj/effect/ebeam/spacevine/medium::icon_state
	owner.loose_factor = 0.75
	owner.recalculate(force_redraw = TRUE)

/obj/effect/ebeam/spacevine/ex_act(severity)
	switch(severity)
		if(EXPLODE_HEAVY)
			if(prob(10))
				return
		if(EXPLODE_LIGHT)
			if(prob(50))
				return
	owner.End()

/obj/effect/ebeam/spacevine/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume) //hotspots kill vines
	if(exposed_temperature > T0C+100)
		owner.End()

/obj/effect/ebeam/spacevine/attackby(obj/item/weapon/W, mob/user)
	if (!W || !user || !W.type) return
	var/temperature = W.get_current_temperature()
	if(W.sharp || iscutter(W) > 0 || temperature > 3000)
		owner.End()
	else
		return ..()

/obj/effect/ebeam/spacevine/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', VOL_EFFECTS_MASTER, 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', VOL_EFFECTS_MASTER, 100, TRUE)

/obj/effect/ebeam/spacevine/medium
	decoration_icon = 'icons/obj/flora/spacevines/vine_decoration.dmi'

	destroy_particle = /particles/leaves/spacevine_destroy

/obj/effect/ebeam/spacevine/medium/grow()
	owner.beam_type = /obj/effect/ebeam/spacevine/heavy
	owner.icon = /obj/effect/ebeam/spacevine/heavy::icon
	owner.icon_state = /obj/effect/ebeam/spacevine/heavy::icon_state
	owner.loose_factor = 1
	owner.dense_beam = TRUE
	owner.recalculate(force_redraw = TRUE)

/obj/effect/ebeam/spacevine/heavy
	decoration_icon = 'icons/obj/flora/spacevines/heavyvine_decoration.dmi'

	idle_particle = /particles/leaves/spacevine
	destroy_particle = /particles/leaves/spacevine_destroy

/obj/effect/ebeam/spacevine/heavy/grow()
	return
