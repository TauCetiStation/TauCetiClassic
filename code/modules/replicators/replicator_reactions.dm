/atom
	var/is_disintegrating = FALSE

// This proc is the reaction to a replicator's disintegration.
// Return TRUE if item is succesfully disintegrated.
// This proc should handle disintegration of the item, as well as any error messages to the replicator.
/atom/proc/replicator_act(mob/living/simple_animal/replicator)
	return FALSE

// Return a negative value if you don't want the auto-replicator to try disintegrating this.
// Anything that doesn't implement replicator_act should return a negative value.
/atom/proc/get_replicator_material_amount()
	return -1 // 1 if you want them to disassemble everything, 0 if you want them to concentrate

/atom/proc/can_be_auto_disintegrated()
	return TRUE

// Disintegration time per 1 unit of material. By default is 1
/atom/proc/get_unit_disintegration_time()
	var/tick_modifier = 1.0
	if(flags & CONDUCT)
		tick_modifier *= REPLICATOR_REWARD_CONDUCTIVE_TICK_MODIFIER

	return REPLICATOR_TICKS_PER_MATERIAL * tick_modifier

/* TURFS */
/turf/simulated/floor/get_replicator_material_amount()
	if(type == basetype)
		return -1

	return 1

/turf/simulated/floor/replicator_act(mob/living/simple_animal/replicator/R)
	if(is_plating())
		R.try_spawn_node(src)
		ChangeTurf(/turf/simulated/floor/plating/airless/catwalk/forcefield)
		return TRUE

	if(broken)
		break_tile_to_plating()
		return TRUE

	break_tile()
	return TRUE


/turf/simulated/floor/engine/replicator_act(mob/living/simple_animal/replicator/R)
	R.try_spawn_node(src)
	ChangeTurf(/turf/simulated/floor/plating/airless/catwalk/forcefield)
	return TRUE


/turf/simulated/floor/plating/airless/catwalk/replicator_act(mob/living/simple_animal/replicator/R)
	R.try_spawn_node(src)
	ChangeTurf(/turf/simulated/floor/plating/airless/catwalk/forcefield)
	return TRUE


/turf/simulated/floor/plating/airless/catwalk/forcefield/get_replicator_material_amount()
	return -1


// wall turns into barrier
/turf/simulated/wall/get_replicator_material_amount()
	return 1

/turf/simulated/wall/replicator_act(mob/living/simple_animal/replicator/R)
	var/turf/T = get_turf(src)
	if(T.can_place_replicator_forcefield())
		new /obj/structure/replicator_forcefield(T)
	dismantle_wall()
	return TRUE


/* MOBS */
/mob/living/can_be_auto_disintegrated()
	return stat == DEAD || lying || crawling

/mob/living/get_replicator_material_amount()
	if(stat == DEAD)
		return w_class * 4
	return -1

/mob/living/get_unit_disintegration_time()
	. = REPLICATOR_TICKS_PER_MATERIAL / 4
	if(stat == DEAD)
		. *= REPLICATOR_REWARD_DEAD_BODIES_TICK_MODIFIER
	else
		. *= REPLICATOR_PUNISH_LIVE_MOBS_TICK_MODIFIER

/mob/living/replicator_act(mob/living/simple_animal/replicator/R)
	var/list/equipment = get_equipped_items()
	if(length(equipment) > 0)
		var/attempts = 3
		while(attempts > 0)
			attempts -= 1
			var/obj/item/I = pick(equipment)
			if(unEquip(I, R.loc))
				return FALSE

	gib()
	return TRUE



/mob/living/simple_animal/replicator/can_be_auto_disintegrated()
	return stat == DEAD

/mob/living/simple_animal/replicator/get_replicator_material_amount()
	return REPLICATOR_COST_REPLICATE

/mob/living/simple_animal/replicator/get_unit_disintegration_time()
	return ..() * REPLICATOR_RECLAIM_REPLICATOR_TICK_MODIFIER

/mob/living/simple_animal/replicator/replicator_act(mob/living/simple_animal/replicator/R)
	gib()
	return TRUE


/* OBJS */
/obj/structure/get_replicator_material_amount()
	return w_class

/obj/structure/replicator_act(mob/living/simple_animal/replicator/R)
	deconstruct(TRUE)
	return TRUE


// Power is needed for Transponders!
/obj/structure/cable/can_be_auto_disintegrated()
	return FALSE


/obj/structure/window/replicator_act(mob/living/simple_animal/replicator/R)
	var/turf/T = get_turf(src)
	if(is_fulltile() && T.can_place_replicator_forcefield())
		new /obj/structure/replicator_forcefield(T)
	deconstruct(TRUE)
	return TRUE


/obj/structure/object_wall/replicator_act(mob/living/simple_animal/replicator/R)
	var/turf/T = get_turf(src)
	if(T.can_place_replicator_forcefield())
		new /obj/structure/replicator_forcefield(T)
	deconstruct(TRUE)
	return TRUE


/obj/structure/inflatable/replicator_act(mob/living/simple_animal/replicator/R)
	var/turf/T = get_turf(src)
	if(T.can_place_replicator_forcefield())
		new /obj/structure/replicator_forcefield(T)
	deconstruct(TRUE)
	return TRUE


/obj/structure/replicator_forcefield/get_replicator_material_amount()
	return -1


/obj/structure/forcefield_node/get_replicator_material_amount()
	return -1


/obj/structure/bluespace_corridor/can_be_auto_disintegrated()
	return FALSE

/obj/structure/bluespace_corridor/get_replicator_material_amount()
	return 1

/obj/structure/bluespace_corridor/get_unit_disintegration_time()
	return ..() * REPLICATOR_RECLAIM_OWN_STRUCTURES_TICK_MODIFIER

/obj/structure/bluespace_corridor/replicator_act(mob/living/simple_animal/replicator/R)
	deconstruct(TRUE)
	if(R.auto_construct_type == type && isturf(R.loc))
		R.try_construct(R.loc)

	return TRUE


/obj/structure/replicator_barricade/can_be_auto_disintegrated()
	return FALSE

/obj/structure/replicator_barricade/get_replicator_material_amount()
	return 5

/obj/structure/replicator_barricade/get_unit_disintegration_time()
	return ..() * REPLICATOR_RECLAIM_OWN_STRUCTURES_TICK_MODIFIER


/obj/structure/stabilization_field/get_replicator_material_amount()
	return -1


/obj/structure/cable/power_rune/can_be_auto_disintegrated()
	return FALSE

/obj/structure/cable/power_rune/get_replicator_material_amount()
	return 0

/obj/structure/cable/power_rune/get_unit_disintegration_time()
	return ..() * REPLICATOR_RECLAIM_OWN_STRUCTURES_TICK_MODIFIER


/obj/structure/particle_accelerator/can_be_auto_disintegrated()
	return FALSE

/obj/structure/particle_accelerator/get_unit_disintegration_time()
	return ..() * REPLICATOR_PUNISH_GRIEFING_TICK_MODIFIER


// Can be used for navigation across the station. Why damage such infrastructure?
/obj/structure/disposalpipe/can_be_auto_disintegrated()
	return FALSE


/obj/machinery/get_replicator_material_amount()
	return w_class

/obj/machinery/replicator_act(mob/living/simple_animal/replicator/R)
	// dismantle and fall into pieces
	deconstruct(TRUE)
	return TRUE


/obj/machinery/door/replicator_act(mob/living/simple_animal/replicator/R)
	var/turf/T = get_turf(src)
	if(T.can_place_replicator_forcefield())
		new /obj/structure/replicator_barricade(T)
	deconstruct(TRUE)
	return TRUE


/obj/machinery/field_generator/can_be_auto_disintegrated()
	return FALSE


// Vents and pipes are used to transport through the station.
/obj/machinery/atmospherics/can_be_auto_disintegrated()
	return FALSE

/obj/machinery/atmospherics/get_unit_disintegration_time()
	return ..() * REPLICATOR_PUNISH_GRIEFING_TICK_MODIFIER


/obj/machinery/atmospherics/components/can_be_auto_disintegrated()
	return welded

/obj/machinery/atmospherics/components/get_unit_disintegration_time()
	return ..() * REPLICATOR_PUNISH_GRIEFING_TICK_MODIFIER

/obj/machinery/atmospherics/components/replicator_act(mob/living/simple_animal/replicator/R)
	if(welded)
		welded = !welded
		update_icon()
		R.visible_message("<span class='notice'>\The [R] [welded ? "welds \the [src] shut" : "unwelds \the [src]"].</span>", \
			"<span class='notice'>You [welded ? "weld \the [src] shut" : "unweld \the [src]"].</span>", \
			"You hear welding.")
		return TRUE
	deconstruct(TRUE)
	return TRUE



/obj/machinery/portable_atmospherics/can_be_auto_disintegrated()
	return FALSE


// Power is needed for the Transponders.
/obj/machinery/power/can_be_auto_disintegrated()
	return FALSE


/obj/machinery/power/smes/get_unit_disintegration_time()
	return ..() * REPLICATOR_PUNISH_GRIEFING_TICK_MODIFIER


/obj/machinery/swarm_powered/bluespace_transponder/can_be_auto_disintegrated()
	return FALSE

// Refund!
/obj/machinery/swarm_powered/bluespace_transponder/get_replicator_material_amount()
	return REPLICATOR_COST_TRANSPONDER

/obj/machinery/swarm_powered/bluespace_transponder/get_unit_disintegration_time()
	return ..() * REPLICATOR_RECLAIM_OWN_STRUCTURES_TICK_MODIFIER


/obj/machinery/power/replicator_generator/can_be_auto_disintegrated()
	return FALSE

/obj/machinery/power/replicator_generator/get_replicator_material_amount()
	return REPLICATOR_COST_GENERATOR

/obj/machinery/replicator_generator/get_unit_disintegration_time()
	return ..() * REPLICATOR_RECLAIM_OWN_STRUCTURES_TICK_MODIFIER


/obj/machinery/swarm_powered/bluespace_catapult/get_replicator_material_amount()
	return -1


/obj/item/get_replicator_material_amount()
	return w_class

/obj/item/replicator_act(mob/living/simple_animal/replicator/R)
	deconstruct(TRUE)
	return TRUE

/obj/item/stack/get_replicator_material_amount()
	return amount

// Raw materials are eaten much faster.
/obj/item/stack/get_unit_disintegration_time()
	return ..() * REPLICATOR_REWARD_STACKS_TICK_MODIFIER
