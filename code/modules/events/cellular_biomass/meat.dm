/obj/structure/meatvineborder
	name = "meat clump"
	desc = "What is that?!"
	icon = 'icons/obj/cellular/meat.dmi'
	icon_state = "border"

	anchored = TRUE
	density = TRUE
	opacity = TRUE

	flags = ON_BORDER

	can_block_air = TRUE


/obj/structure/meatvineborder/CanPass(atom/movable/mover, turf/target, height=0)
	if(get_dir(loc, target) & dir)
		return FALSE
	return TRUE

/obj/structure/meatvineborder/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, origin)
	if(dir == to_dir)
		return FALSE

	return TRUE

/obj/structure/meatvineborder/CheckExit(atom/movable/O, target)
	if(get_dir(O.loc, target) == dir)
		return FALSE
	return TRUE




/obj/structure/meatvine
	name = "meat clump"
	desc = "What is that?!"
	icon = 'icons/obj/cellular/meat.dmi'
	icon_state = "tile_1"
	anchored = TRUE
	density = FALSE
	layer = LOW_OBJ_LAYER
	pass_flags = PASSTABLE | PASSGRILLE

	armor = list(MELEE = 50, BULLET = 30, LASER = 0, ENERGY = 100, BOMB = -10, BIO = 100, FIRE = -100, ACID = -200)

	var/obj/effect/meatvine_controller/master = null

	var/feromone_weight = 1

	var/list/lair_generators = list(/mob/living, /obj/item/weapon/reagent_containers/food/snacks, /obj/item/weapon/flora)

	max_integrity = 20
	resistance_flags = CAN_BE_HIT

	var/list/meat_side_overlays

	var/list/borders_overlays = list()

/obj/structure/meatvine/proc/rot()
	color = "#55ffff"
	master = null

	var/turf/T = get_turf(src)

	for(var/obj/structure/meatvineborder/Vine in T)
		Vine.color = "#55ffff"

/obj/structure/meatvine/update_icon()
	for(var/overlay in borders_overlays)
		cut_overlay(overlay)

	var/turf/T = get_turf(src)

	for(var/direction in alldirs)
		var/turf/step = get_step(T, direction)
		var/obj/structure/meatvine/Vine = locate(/obj/structure/meatvine, step)

		if(Vine)
			continue

		var/image/Overlay = image(icon = 'icons/obj/cellular/meat.dmi', icon_state = "tile_edge", dir = direction)
		Overlay.pixel_x = X_OFFSET(32, direction)
		Overlay.pixel_y = Y_OFFSET(32, direction)

		borders_overlays += Overlay
		add_overlay(Overlay)

/obj/structure/meatvine/proc/update_borders()
	update_icon()

	var/turf/T = get_turf(src)

	for(var/direction in alldirs)
		var/turf/step = get_step(T, direction)
		var/obj/structure/meatvine/Vine = locate(/obj/structure/meatvine, step)

		if(!Vine)
			continue

		Vine.update_icon()

/obj/structure/meatvine/papameat
	name = "papa meat"
	desc = "You feel a combination of fear and disgust, just by looking at that thing."
	icon = 'icons/obj/cellular/papameat.dmi'
	icon_state = "papameat"
	density = TRUE

	pass_flags = PASSTABLE

	max_integrity = 1000

	pixel_x = -48
	pixel_y = -48

	var/healed = FALSE

	var/obj/effect/abstract/particle_holder/Particle

/obj/structure/meatvine/papameat/update_icon()
	return

/obj/structure/meatvine/papameat/atom_init()
	. = ..()

	master = new(loc)

	START_PROCESSING(SSobj, src)

	Particle = new(src, /particles/papameat)

	set_light(3, 1, "#ff6533")

/obj/structure/meatvine/papameat/Destroy()
	puff_gas(TRUE)
	master.die()
	STOP_PROCESSING(SSobj, src)
	qdel(Particle)
	..()

/obj/structure/meatvine/papameat/process()
	var/integrity_percent = round(get_integrity()/max_integrity)

	switch(integrity_percent)
		if(75)
			if(prob(10))
				transfer_feromones(2)

		if(50)
			if(prob(10))
				transfer_feromones(5)

			if(prob(1))
				var/mobtype = pick(/mob/living/simple_animal/hostile/meatvine, /mob/living/simple_animal/hostile/meatvine/range)
				new mobtype(loc)

			if(healed && (master.vines.len <= master.collapse_size) && master.reached_collapse_size)
				master.reached_collapse_size = FALSE

		if(25)
			if(prob(20))
				puff_gas(TRUE)
			if(healed && (master.vines.len >= master.slowdown_size) && master.reached_slowdown_size)
				master.reached_slowdown_size = FALSE

	if(!healed)
		if(!repair_damage(10))
			healed = TRUE

/obj/structure/meatvine/papameat/grow()
	return

/obj/structure/meatvine/proc/puff_gas(big = FALSE)
	if(big)
		reagents.add_reagent_list(list("thermopsis" = 301, "potassium" = 33, "sugar" = 33, "phosphorus" = 33))
		return

	reagents.add_reagent_list(list("thermopsis" = 140, "potassium" = 20, "sugar" = 20, "phosphorus" = 20))
	return

/obj/structure/meatvine/floor/atom_init()
	. = ..()

	icon_state = pick(list("tile_1", "tile_2", "tile_3", "tile_4"))

/obj/structure/meatvine/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir)
	. = ..()
	if(damage_type != BURN)
		transfer_feromones(3)

/obj/structure/meatvine/proc/transfer_feromones(amount)
	if(prob(5))
		spread()
		grow()

	feromone_weight += 10
	if(amount <= 1)
		return

	var/turf/T = src.loc
	for(var/direction in cardinal)
		var/turf/step = get_step(T, direction)
		var/obj/structure/meatvine/Vine = locate(/obj/structure/meatvine, step)

		if(!Vine)
			continue

		Vine.transfer_feromones(amount - 1)

/obj/structure/meatvine/heavy
	icon = 'icons/obj/cellular/meat_wall.dmi'
	icon_state = "box"
	density = TRUE
	opacity = TRUE
	pass_flags = null

	smooth = SMOOTH_TRUE

	max_integrity = 50
	resistance_flags = CAN_BE_HIT

	can_block_air = TRUE

/obj/structure/meatvineborder/heavy/CanPass(atom/movable/mover, turf/target, height=0)
	return FALSE

/obj/structure/meatvineborder/heavy/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, origin)
	return FALSE

/obj/structure/meatvineborder/heavy/CheckExit(atom/movable/O, target)
	return FALSE

/obj/structure/meatvine/lair
	icon_state = "lair_1"
	density = FALSE
	opacity = FALSE
	pass_flags = null

	max_integrity = 30
	resistance_flags = CAN_BE_HIT

	var/mob/living/simple_animal/hostile/meatvine/Mob
	var/datum/beam/current_beam = null

/obj/structure/meatvine/lair/atom_init()
	. = ..()
	icon_state = pick(list("lair_1", "lair_2", "lair_3"))

	set_light(2, 1, "#ff6533")

/obj/structure/meatvine/lair/Destroy()
	puff_gas(TRUE)

	..()

/obj/structure/meatvine/atom_init()
	. = ..()

	checking_items:
		for(var/obj/item/Item in src.loc.contents)
			for(var/generator_type in lair_generators)
				if(istype(Item, generator_type))
					continue checking_items

			Item.try_wrap_up("meat", "meatthings")

	for(var/obj/structure/closet/Closet in src.loc.contents)
		Closet.try_wrap_up("meat", "meatthings")

	var/datum/reagents/R = new/datum/reagents(400)
	reagents = R
	R.my_atom = src

	update_borders()

/obj/structure/meatvine/Destroy()
	if(master)
		master.vines -= src
		master.growth_queue -= src
		master = null

	update_borders()
	return ..()

/obj/structure/meatvine/can_buckle(mob/living/M)
	if(M.buckled || buckled_mob)
		return FALSE
	return M.stat != DEAD

/obj/structure/meatvine/user_buckle_mob(mob/living/M, mob/user)
	return

/obj/structure/meatvine/buckle_mob(mob/living/M)
	. = ..()
	if(.)
		to_chat(M, "<span class='danger'>The vines [pick("wind", "tangle", "tighten")] around you!</span>")

/obj/structure/meatvine/proc/grow()
	if(!master)
		return

	if(master.isdying)
		return

	var/turf/T = src.loc
	if(prob(feromone_weight))
		master.spawn_spacevine_piece(T, /obj/structure/meatvine/heavy)
		qdel(src)
	else if(prob(1))
		master.spawn_spacevine_piece(T, /obj/structure/meatvine/lair)
		qdel(src)
	else
		for(var/generator_type in lair_generators)
			var/atom/thing = locate(generator_type, T)
			if(!thing)
				continue
			if(istype(thing, /mob/living))
				var/mob/living/Mob = thing

				if(Mob.stat != DEAD || istype(Mob, /mob/living/simple_animal/hostile/meatvine))
					continue

				Mob.try_wrap_up("meat", "meatthings")

			else
				qdel(thing)

			master.spawn_spacevine_piece(T, /obj/structure/meatvine/lair)
			qdel(src)

	return

/obj/structure/meatvine/heavy/grow()
	if(!master)
		return
	if(master.isdying)
		return

	var/obj/machinery/atmospherics/components/unary/Vent = locate(/obj/machinery/atmospherics/components/unary/vent_pump) in loc.contents
	if(!Vent)
		Vent = locate(/obj/machinery/atmospherics/components/unary/vent_scrubber) in loc.contents
	if(!Vent)
		return ..()


	var/list/vents = list()
	var/datum/pipeline/entry_vent_parent = Vent.PARENT1
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmosmch)
		vents.Add(temp_vent)
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in entry_vent_parent.other_atmosmch)
		vents.Add(temp_vent)
	if(!vents.len)
		return ..()

	var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
	var/obj/structure/meatvine/Vine = locate() in exit_vent.loc.contents

	if(!Vine)
		master.spawn_spacevine_piece( exit_vent.loc, /obj/structure/meatvine/lair )

	return

/obj/structure/meatvine/lair/grow()
	if(!master)
		return

	if(master.isdying)
		return

	if(!Mob)
		var/mobtype = pick(/mob/living/simple_animal/hostile/meatvine, /mob/living/simple_animal/hostile/meatvine/range)
		Mob = new mobtype(loc)
		current_beam = new(src, Mob, time = INFINITY, beam_icon_state = "meat", btype = /obj/effect/ebeam/meat)
		INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))
		Mob.AddComponent(/datum/component/bounded, src, 0, 3)
		puff_gas()
		return

	if(Mob.stat == DEAD)
		qdel(Mob.GetComponent(/datum/component/bounded))
		QDEL_NULL(current_beam)
		Mob = null
		return

	Mob.adjustBruteLoss(-10)
	Mob.adjustToxLoss(-5)
	Mob.adjustOxyLoss(-5)

	var/turf/T = get_turf(src)
	if(isspaceturf(T) || !istype(T, /turf/simulated))
		return

	var/datum/gas_mixture/environment = T.return_air()
	var/pressure = round(environment.return_pressure())

	if(pressure < ONE_ATMOSPHERE * 0.90)
		environment.adjust_multi_temp("oxygen", MOLES_CELLSTANDARD / 2 * O2STANDARD, T20C, "nitrogen", MOLES_CELLSTANDARD / 2 * N2STANDARD, T20C)
		puff_gas()

/obj/structure/meatvine/lair/rot()
	..()
	if(Mob)
		qdel(Mob.GetComponent(/datum/component/bounded))
	QDEL_NULL(current_beam)
	Mob = null

/obj/effect/ebeam/meat
	name = "meat"
	icon_state = "meat"

/mob/living/simple_animal/hostile/meatvine
	name = "Horrible creature"
	desc = "What is that?!"
	icon = 'icons/obj/cellular/meat.dmi'
	icon_state = "mob1"
	icon_living = "mob1"
	icon_dead = "mob1_dead"
	faction = "meat"
	w_class = SIZE_HUMAN
	health = 60
	maxHealth = 60
	melee_damage = 30
	move_speed = 0
	see_in_dark = 10

	environment_smash = TRUE
	search_objects = 1
	wanted_objects = list(/obj/machinery/light, /obj/machinery/light/small, /obj/machinery/light/smart, /obj/machinery/bot/secbot/beepsky, /obj/machinery/camera)

	stat_attack = 1

	pass_flags = PASSTABLE

/mob/living/simple_animal/hostile/meatvine/death()
	var/datum/reagents/R = new/datum/reagents(200)
	reagents = R
	R.my_atom = src

	R.add_reagent_list(list("thermopsis" = 140, "potassium" = 20, "sugar" = 20, "phosphorus" = 20))

	return ..()


/mob/living/simple_animal/hostile/meatvine/range
	icon_state = "mob2"
	icon_living = "mob2"
	icon_dead = "mob2_dead"
	ranged = TRUE
	projectilesound = 'sound/effects/blobattack.ogg'
	projectiletype = /obj/item/projectile/meatbullet

	minimum_distance = 2

/obj/item/projectile/meatbullet
	icon_state = "meat"
	damage = 25
	damage_type = BRUTE

/obj/structure/meatvine/proc/spread()
	if(!master || master.isdying)
		return

	var/turf/T = src.loc
	var/direction = pick(cardinal)
	var/step = get_step(src,direction)
	if(isfloorturf(step))
		var/turf/simulated/floor/F = step
		if(!locate(/obj/structure/meatvine,F))
			if(can_enter_turf(src, F) || locate(/obj/machinery, F) || locate(/obj/structure/closet, F))
				if(master)
					master.spawn_spacevine_piece( F )
					return
	else
		var/obstructed_dir = get_dir(T, step)
		for(var/obj/structure/meatvineborder/Vine in T)
			if(Vine.dir == obstructed_dir)
				return

		var/obj/structure/meatvineborder/Vine = new /obj/structure/meatvineborder(src.loc)
		Vine.dir = obstructed_dir

/obj/effect/meatvine_controller
	var/list/obj/structure/meatvine/vines = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	var/isdying = FALSE
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the spacevines' size to something less than 20 plots, it won't grow anymore.

	var/slowdown_size = 200
	var/collapse_size = 1000

/obj/effect/meatvine_controller/atom_init()
	. = ..()
	if(!isfloorturf(loc))
		return INITIALIZE_HINT_QDEL

	var/obj/structure/meatvine/SV = locate() in src.loc
	if(!SV)
		spawn_spacevine_piece(src.loc)
	else
		SV.master = src
		growth_queue += SV
		vines += SV

	START_PROCESSING(SSobj, src)

/obj/effect/meatvine_controller/proc/die()
	isdying = TRUE

/obj/effect/meatvine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/meatvine_controller/proc/spawn_spacevine_piece(turf/location, piece_type = /obj/structure/meatvine/floor)
	var/obj/structure/meatvine/SV = new piece_type(location)
	SV.master = src
	growth_queue += SV
	vines += SV

/obj/effect/meatvine_controller/process()
	if(!vines.len)
		qdel(src) //space  vines exterminated. Remove the controller
		return
	if(!growth_queue)
		qdel(src) //Sanity check
		return
	if(vines.len >= collapse_size && !reached_collapse_size)
		reached_collapse_size = 1
	if(vines.len >= slowdown_size && !reached_slowdown_size)
		reached_slowdown_size = 1

	var/length = min( slowdown_size , vines.len)
	if(reached_collapse_size)
		length = 25
	else if(reached_slowdown_size)
		length = min( slowdown_size , vines.len / 10 )

	if(!length)
		return

	var/i = 0
	var/list/obj/structure/meatvine/queue_end = list()

	for( var/obj/structure/meatvine/SV in growth_queue )
		i++
		growth_queue -= SV

		if(isdying)
			SV.rot()
			vines -= SV
		else
			queue_end += SV
			if(prob(20))
				SV.grow()
				continue
			else //If tile is fully grown
				if(prob(25))
					var/mob/living/carbon/C = locate() in SV.loc
					if(C)
						if(!C.buckled)
							SV.buckle_mob(C)
						else
							C.try_wrap_up("meat", "meatthings")


			if(!reached_collapse_size)
				SV.spread()
		if(i >= length)
			break

	growth_queue = growth_queue + queue_end
	//sleep(5)
	//process()
