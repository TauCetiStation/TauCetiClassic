/atom
	var/is_disintegrating = FALSE

// This proc is the reaction to a replicator's disintegration.
// Return TRUE if item is succesfully disintegrated.
// This proc should handle disintegration of the item, as well as any error messages to the replicator.
/atom/proc/replicator_act(mob/living/simple_animal/hostile/replicator)
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

/turf/simulated/floor/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	if(is_plating())
		R.try_spawn_node(src)
		ChangeTurf(/turf/simulated/floor/plating/airless/catwalk/forcefield)
		return TRUE

	if(broken)
		break_tile_to_plating()
		return TRUE

	break_tile()
	return TRUE


/turf/simulated/floor/engine/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	R.try_spawn_node(src)
	ChangeTurf(/turf/simulated/floor/plating/airless/catwalk/forcefield)
	return TRUE


/turf/simulated/floor/beach/water/waterpool/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	R.try_spawn_node(src)
	ChangeTurf(/turf/simulated/floor/plating/airless/catwalk/forcefield)
	return TRUE


/turf/simulated/floor/plating/airless/catwalk/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	R.try_spawn_node(src)
	ChangeTurf(/turf/simulated/floor/plating/airless/catwalk/forcefield)
	return TRUE


/turf/simulated/floor/plating/airless/catwalk/forcefield/get_replicator_material_amount()
	return -1


// wall turns into barrier
/turf/simulated/wall/get_replicator_material_amount()
	return 1

/turf/simulated/wall/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	var/turf/T = get_turf(src)
	if(!(locate(/obj/structure/replicator_forcefield) in T))
		new /obj/structure/replicator_forcefield(T)
		var/obj/structure/replicator_barricade/RB = locate() in T
		if(RB)
			RB.leave_stabilization_field = FALSE
			qdel(RB)
	dismantle_wall()
	return TRUE


/* MOBS */
/mob/living/can_be_auto_disintegrated()
	return stat == DEAD || lying || crawling

/mob/living/get_replicator_material_amount()
	if(stat == DEAD || lying || crawling)
		return w_class * REPLICATOR_MATERIAL_AMOUNT_COEFF_ORGANIC
	return -1

/mob/living/get_unit_disintegration_time()
	. = REPLICATOR_TICKS_PER_MATERIAL / REPLICATOR_MATERIAL_AMOUNT_COEFF_ORGANIC
	switch(stat)
		if(DEAD)
			. *= REPLICATOR_REWARD_DEAD_BODIES_TICK_MODIFIER
			var/list/equipment = get_equipped_items()
			if(length(equipment) > 0)
				. *= 0.5

		if(UNCONSCIOUS)
			. *= REPLICATOR_PUNISH_UNCONSCIOUS_MOBS_TICK_MODIFIER
		else
			. *= REPLICATOR_PUNISH_LIVE_MOBS_TICK_MODIFIER

/mob/living/replicator_act(mob/living/simple_animal/hostile/replicator/R)
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


/mob/living/carbon/human/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	. = ..()
	if(.)
		var/datum/faction/replicators/FR = get_or_create_replicators_faction()
		var/datum/replicator_array_info/RAI = FR.ckey2info[R.last_controller_ckey]
		RAI.eaten_humans += 1


/mob/living/silicon/can_be_auto_disintegrated()
	return stat != CONSCIOUS

/mob/living/silicon/get_replicator_material_amount()
	if(stat != CONSCIOUS)
		return w_class * REPLICATOR_MATERIAL_AMOUNT_COEFF_ORGANIC
	return -1

/mob/living/silicon/get_unit_disintegration_time()
	. = REPLICATOR_TICKS_PER_MATERIAL / REPLICATOR_MATERIAL_AMOUNT_COEFF_ORGANIC
	switch(stat)
		if(DEAD)
			. *= REPLICATOR_REWARD_DEAD_BODIES_TICK_MODIFIER
		if(UNCONSCIOUS)
			. *= REPLICATOR_PUNISH_UNCONSCIOUS_MOBS_TICK_MODIFIER
		else
			. *= REPLICATOR_PUNISH_LIVE_MOBS_TICK_MODIFIER

/mob/living/silicon/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	gib()
	return TRUE


/mob/living/simple_animal/hostile/replicator/can_be_auto_disintegrated()
	return stat == DEAD

/mob/living/simple_animal/hostile/replicator/get_replicator_material_amount()
	if(stat == DEAD)
		return REPLICATOR_COST_REPLICATE
	return REPLICATOR_COST_REPLICATE * health / maxHealth

/mob/living/simple_animal/hostile/replicator/get_unit_disintegration_time()
	return ..() * REPLICATOR_RECLAIM_REPLICATOR_TICK_MODIFIER

/mob/living/simple_animal/hostile/replicator/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	gib()
	return TRUE


/* OBJS */
/obj/effect/energy_field/get_replicator_material_amount()
	return -1


/obj/structure/get_unit_disintegration_time()
	. = ..()
	if(contaminated)
		. *= REPLICATOR_PUNISH_CONTAMINATION_MODIFIER

/obj/structure/get_replicator_material_amount()
	return w_class

/obj/structure/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	deconstruct(TRUE)
	return TRUE


// Power is needed for Transponders!
/obj/structure/cable/can_be_auto_disintegrated()
	return FALSE


/obj/structure/window/fulltile/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	var/turf/T = get_turf(src)
	if(!(locate(/obj/structure/replicator_forcefield) in T))
		new /obj/structure/replicator_forcefield(T)
		var/obj/structure/replicator_barricade/RB = locate() in T
		if(RB)
			RB.leave_stabilization_field = FALSE
			qdel(RB)
	deconstruct(TRUE)
	return TRUE

/obj/structure/window/shuttle/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	var/turf/T = get_turf(src)
	if(!(locate(/obj/structure/replicator_forcefield) in T))
		new /obj/structure/replicator_forcefield(T)
		var/obj/structure/replicator_barricade/RB = locate() in T
		if(RB)
			RB.leave_stabilization_field = FALSE
			qdel(RB)
	deconstruct(TRUE)
	return TRUE

/obj/structure/object_wall/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	var/turf/T = get_turf(src)
	if(!(locate(/obj/structure/replicator_forcefield) in T))
		new /obj/structure/replicator_forcefield(T)
		var/obj/structure/replicator_barricade/RB = locate() in T
		if(RB)
			RB.leave_stabilization_field = FALSE
			qdel(RB)
	deconstruct(TRUE)
	return TRUE


/obj/structure/inflatable/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	var/turf/T = get_turf(src)
	if(!(locate(/obj/structure/replicator_forcefield) in T))
		new /obj/structure/replicator_forcefield(T)
		var/obj/structure/replicator_barricade/RB = locate() in T
		if(RB)
			RB.leave_stabilization_field = FALSE
			qdel(RB)
	deconstruct(TRUE)
	return TRUE


/obj/structure/plasticflaps/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	var/turf/T = get_turf(src)
	if(!(locate(/obj/structure/replicator_forcefield) in T) && !(locate(/obj/structure/replicator_barricade) in T))
		new /obj/structure/replicator_barricade(T)
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

/obj/structure/bluespace_corridor/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	deconstruct(TRUE)
	if(R.auto_construct_type == type && isturf(R.loc))
		R.try_construct(R.loc)

	return TRUE


/obj/structure/replicator_barricade/can_be_auto_disintegrated()
	return FALSE

/obj/structure/replicator_barricade/get_replicator_material_amount()
	return REPLICATOR_COST_RECLAIM_BARRICADE * get_integrity() / max_integrity

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


/obj/machinery/get_unit_disintegration_time()
	. = ..()
	if(contaminated)
		. *= REPLICATOR_PUNISH_CONTAMINATION_MODIFIER

/obj/machinery/get_replicator_material_amount()
	return w_class

/obj/machinery/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	// dismantle and fall into pieces
	deconstruct(TRUE)
	return TRUE


/obj/machinery/door/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	var/turf/T = get_turf(src)
	if(!(locate(/obj/structure/replicator_forcefield) in T) && !(locate(/obj/structure/replicator_barricade) in T))
		new /obj/structure/replicator_barricade(T)
	deconstruct(TRUE)
	return TRUE


/obj/machinery/field_generator/can_be_auto_disintegrated()
	return FALSE


/obj/machinery/shield/get_replicator_material_amount()
	return -1


/obj/machinery/shieldwall/get_replicator_material_amount()
	return -1


// Vents and pipes are used to transport through the station.
/obj/machinery/atmospherics/components/can_be_auto_disintegrated()
	return welded

/obj/machinery/atmospherics/components/get_unit_disintegration_time()
	. = ..()
	if(welded)
		return . * 0.5

/obj/machinery/atmospherics/components/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	if(welded)
		welded = !welded
		update_icon()
		R.visible_message("<span class='notice'>\The [R] [welded ? "welds \the [src] shut" : "unwelds \the [src]"].</span>", \
			"<span class='notice'>You [welded ? "weld \the [src] shut" : "unweld \the [src]"].</span>", \
			"You hear welding.")
		return TRUE
	deconstruct(TRUE)
	return TRUE


// Vents and pipes are used to transport through the station.
/obj/machinery/atmospherics/pipe/can_be_auto_disintegrated()
	return FALSE


/obj/machinery/portable_atmospherics/canister/can_be_auto_disintegrated()
	return FALSE

/obj/machinery/portable_atmospherics/canister/get_unit_disintegration_time()
	return ..() * REPLICATOR_PUNISH_GRIEFING_TICK_MODIFIER


/obj/machinery/atmospherics/components/unary/tank/can_be_auto_disintegrated()
	return FALSE

/obj/machinery/atmospherics/components/unary/tank/can_be_auto_disintegrated()
	return ..() * REPLICATOR_PUNISH_GRIEFING_TICK_MODIFIER


/obj/machinery/telescience_jammer/get_unit_disintegration_time()
	return ..() * REPLICATOR_PUNISH_GRIEFING_TICK_MODIFIER


// Power is needed for the Transponders.
/obj/machinery/power/can_be_auto_disintegrated()
	return FALSE


/obj/machinery/power/smes/get_unit_disintegration_time()
	return ..() * REPLICATOR_PUNISH_GRIEFING_TICK_MODIFIER


/obj/machinery/swarm_powered/bluespace_transponder/can_be_auto_disintegrated()
	return FALSE

// Refund!
/obj/machinery/swarm_powered/bluespace_transponder/get_replicator_material_amount()
	return REPLICATOR_COST_TRANSPONDER * get_integrity() / max_integrity

/obj/machinery/swarm_powered/bluespace_transponder/get_unit_disintegration_time()
	return ..() * REPLICATOR_RECLAIM_OWN_STRUCTURES_TICK_MODIFIER

/obj/machinery/swarm_powered/bluespace_transponder/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	// Not destroyed, dismantled.
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.destroyed_transponders -= 1

	QDEL_NULL(deactivation_signal)
	deconstruct(TRUE)
	return TRUE


/obj/machinery/power/replicator_generator/can_be_auto_disintegrated()
	return FALSE

/obj/machinery/power/replicator_generator/get_replicator_material_amount()
	return REPLICATOR_COST_GENERATOR * get_integrity() / max_integrity

/obj/machinery/power/replicator_generator/get_unit_disintegration_time()
	return ..() * REPLICATOR_RECLAIM_OWN_STRUCTURES_TICK_MODIFIER

/obj/machinery/power/replicator_generator/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	// Not destroyed, dismantled.
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.destroyed_generators -= 1

	has_crystal = FALSE
	deconstruct(TRUE)
	return TRUE


/obj/machinery/swarm_powered/bluespace_catapult/get_replicator_material_amount()
	return -1


/obj/item/get_unit_disintegration_time()
	. = ..()
	if(contaminated)
		. *= REPLICATOR_PUNISH_CONTAMINATION_MODIFIER

/obj/item/get_replicator_material_amount()
	return w_class

/obj/item/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	deconstruct(TRUE)
	return TRUE

/obj/item/stack/get_replicator_material_amount()
	return amount

// Raw materials are eaten much faster.
/obj/item/stack/get_unit_disintegration_time()
	return ..() * REPLICATOR_REWARD_STACKS_TICK_MODIFIER


/obj/item/mine/replicator/can_be_auto_disintegrated()
	return FALSE

/obj/item/mine/replicator/get_replicator_material_amount()
	return REPLICATOR_COST_MINE * get_integrity() / max_integrity

/obj/item/mine/replicator/get_unit_disintegration_time()
	return ..() * REPLICATOR_RECLAIM_OWN_STRUCTURES_TICK_MODIFIER


/obj/mecha/get_replicator_material_amount()
	return w_class

/obj/mecha/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	destroy()
	return TRUE


/obj/effect/decal/mecha_wreckage/get_replicator_material_amount()
	return 1

/obj/effect/decal/mecha_wreckage/replicator_act(mob/living/simple_animal/hostile/replicator/R)
	if(salvage_num > 0)
		var/list/pos_tools = list("welder", "wirecutter", "crowbar")
		while(length(pos_tools) > 0)
			var/tool = pick(pos_tools)
			pos_tools -= tool

			if(detach_part(tool))
				return TRUE

	qdel(src)
	return TRUE
