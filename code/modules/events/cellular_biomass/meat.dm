// SPACE VINES (Note that this code is very similar to Biomass code)
/obj/structure/meatvine
	name = "meat clump"
	desc = "What is that?!"
	icon = 'icons/obj/cellular/meat.dmi'
	icon_state = "tile_1"
	anchored = TRUE
	density = FALSE
	layer = LOW_OBJ_LAYER
	pass_flags = PASSTABLE | PASSGRILLE

	var/energy = 0
	var/obj/effect/meatvine_controller/master = null

	var/feromone_weight = 1

	var/list/lair_generators = list(/mob/living, /obj/item/weapon/reagent_containers/food/snacks, /obj/item/weapon/flora)

	max_integrity = 20
	resistance_flags = CAN_BE_HIT

	var/list/meat_side_overlays

/obj/structure/meatvine/floor/atom_init()
	. = ..()

	icon_state = pick(list("tile_1", "tile_2", "tile_3", "tile_4"))

/obj/structure/meatvine/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir)
	. = ..()
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

/obj/structure/window/thin/meatvine
	name = "meat clump"
	desc = "What is that?!"

	icon = 'icons/obj/cellular/meat.dmi'
	icon_state = "border"
	opacity = TRUE

	drops = null
	destroy_sounds = list('sound/effects/blobattack.ogg')

	flags = ON_BORDER
	can_be_unanchored = FALSE

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

/obj/structure/meatvine/Destroy()
	if(master)
		master.vines -= src
		master.growth_queue -= src
		master = null
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
	var/turf/T = src.loc
	if(prob(feromone_weight))
		master.spawn_spacevine_piece(T, /obj/structure/meatvine/heavy)
		qdel(src)
	else if(prob(0.1))
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
	var/obj/machinery/atmospherics/components/unary/Vent = locate(/obj/machinery/atmospherics/components/unary/vent_pump) in loc.contents
	if(!Vent)
		Vent = locate(/obj/machinery/atmospherics/components/unary/vent_scrubber) in loc.contents
	if(!Vent)
		return


	var/list/vents = list()
	var/datum/pipeline/entry_vent_parent = Vent.PARENT1
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in entry_vent_parent.other_atmosmch)
		vents.Add(temp_vent)
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in entry_vent_parent.other_atmosmch)
		vents.Add(temp_vent)
	if(!vents.len)
		return

	var/obj/machinery/atmospherics/components/unary/vent_pump/exit_vent = pick(vents)
	var/obj/structure/meatvine/Vine = locate() in exit_vent.loc.contents

	if(!Vine)
		master.spawn_spacevine_piece( exit_vent.loc, /obj/structure/meatvine/lair )

	return

/obj/structure/meatvine/lair/grow()
	if(!Mob)
		var/mobtype = pick(/mob/living/simple_animal/hostile/meatvine, /mob/living/simple_animal/hostile/meatvine/range)
		Mob = new mobtype(loc)
		current_beam = new(src, Mob, time = INFINITY, beam_icon_state = "meat", btype = /obj/effect/ebeam/meat)
		INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))
		Mob.AddComponent(/datum/component/bounded, src, 0, 3)
		return

	if(Mob.stat == DEAD)
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
	pressure = round(environment.return_pressure())

	if(pressure < ONE_ATMOSPHERE * 0.90)
		environment.adjust_multi_temp("oxygen", MOLES_CELLSTANDARD / 2 * O2STANDARD, T20C, "nitrogen", MOLES_CELLSTANDARD / 2 * N2STANDARD, T20C)

/obj/effect/ebeam/meat
	name = "meat"
	icon_state = "meat"

/mob/living/simple_animal/hostile/meatvine
	name = "Horrible creature"
	desc = "What is that?!"
	icon = 'icons/obj/cellular/meat.dmi'
	icon_state = "mob"
	icon_living = "mob"
	icon_dead = "mob_dead"
	faction = "meat"
	w_class = SIZE_HUMAN
	health = 60
	maxHealth = 60
	melee_damage = 15
	move_speed = 0
	see_in_dark = 10

	environment_smash = TRUE
	search_objects = 1
	wanted_objects = list(/obj/machinery/light, /obj/machinery/light/small, /obj/machinery/light/smart, /obj/machinery/bot/secbot/beepsky, /obj/machinery/camera)

	stat_attack = 1

	pass_flags = PASSTABLE


/mob/living/simple_animal/hostile/meatvine/range
	ranged = TRUE
	projectilesound = 'sound/effects/blobattack.ogg'
	projectiletype = /obj/item/projectile/meatbullet

	minimum_distance = 2

/obj/item/projectile/meatbullet
	icon_state = "meat"
	damage = 10
	damage_type = BRUTE

/obj/structure/meatvine/proc/spread()
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
		for(var/obj/structure/window/thin/meatvine/Vine in T)
			if(Vine.dir == obstructed_dir)
				return

		var/obj/structure/window/thin/meatvine/Vine = new /obj/structure/window/thin/meatvine(src.loc)
		Vine.dir = obstructed_dir

/obj/effect/meatvine_controller
	var/list/obj/structure/meatvine/vines = list()
	var/list/growth_queue = list()
	var/reached_collapse_size
	var/reached_slowdown_size
	//What this does is that instead of having the grow minimum of 1, required to start growing, the minimum will be 0,
	//meaning if you get the spacevines' size to something less than 20 plots, it won't grow anymore.

	var/slowdown_size = 200
	var/collapse_size = 1000

/obj/effect/meatvine_controller/atom_init()
	. = ..()
	if(!isfloorturf(loc))
		return INITIALIZE_HINT_QDEL

	spawn_spacevine_piece(src.loc)
	START_PROCESSING(SSobj, src)

/obj/effect/meatvine_controller/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/meatvine_controller/proc/spawn_spacevine_piece(turf/location, piece_type = /obj/structure/meatvine/floor)
	var/obj/structure/meatvine/SV = new piece_type(location)
	growth_queue += SV
	vines += SV
	SV.master = src

/obj/effect/meatvine_controller/process()
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

	var/length = min( slowdown_size , vines.len)
	if(reached_collapse_size)
		length = 25
	else if(reached_slowdown_size)
		if(!prob(25))
			length = min( slowdown_size , vines.len / 10 )
		else
			length = 0

	if(!length)
		return

	var/i = 0
	var/list/obj/structure/meatvine/queue_end = list()

	for( var/obj/structure/meatvine/SV in growth_queue )
		i++
		queue_end += SV
		growth_queue -= SV
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
