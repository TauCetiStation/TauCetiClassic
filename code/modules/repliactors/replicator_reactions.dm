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
	var/efficency = 1.0
	if(flags & CONDUCT)
		efficency *= 2.0

	return REPLICATOR_TICKS_PER_MATERIAL / efficency

/turf/simulated/floor/get_replicator_material_amount()
	if(type == basetype)
		return -1

	return 1

/turf/simulated/floor/replicator_act(mob/living/simple_animal/replicator/R)
	if(is_plating())
		ChangeTurf(/turf/simulated/floor/plating/airless/catwalk/forcefield)
		return TRUE

	if(broken)
		break_tile_to_plating()
		return TRUE

	break_tile()
	return TRUE

/turf/simulated/floor/engine/replicator_act(mob/living/simple_animal/replicator/R)
	ChangeTurf(basetype)
	return TRUE

/turf/simulated/floor/plating/airless/catwalk/forcefield/get_replicator_material_amount()
	return -1

// wall turns into barrier
/turf/simulated/wall/get_replicator_material_amount()
	return 1

/turf/simulated/wall/replicator_act(mob/living/simple_animal/replicator/R)
	new /obj/structure/inflatable/forcefield(get_turf(src))
	dismantle_wall()
	return TRUE

/mob/living/simple_animal/replicator/can_be_auto_disintegrated()
	return stat == DEAD

/mob/living/simple_animal/replicator/get_replicator_material_amount()
	if(ckey)
		return -1
	return REPLICATOR_COST_REPLICATE

/mob/living/simple_animal/replicator/get_unit_disintegration_time()
	return ..() * 0.5

/mob/living/simple_animal/replicator/replicator_act(mob/living/simple_animal/replicator/R)
	gib()
	return TRUE

/obj/structure/get_replicator_material_amount()
	return w_class

/obj/structure/replicator_act(mob/living/simple_animal/replicator/R)
	deconstruct(TRUE)
	return TRUE

// Power is needed for Transponders!
/obj/structure/cable/can_be_auto_disintegrated()
	return FALSE

/obj/structure/window/replicator_act(mob/living/simple_animal/replicator/R)
	if(is_fulltile())
		new /obj/structure/inflatable/forcefield(get_turf(src))
	deconstruct(TRUE)
	return TRUE

/obj/structure/inflatable/forcefield/get_replicator_material_amount()
	return -1

/obj/structure/forcefield_node/get_replicator_material_amount()
	return -1

/obj/structure/bluespace_corridor/can_be_auto_disintegrated()
	return FALSE

/obj/structure/bluespace_corridor/get_replicator_material_amount()
	return 1

/obj/structure/bluespace_corridor/get_unit_disintegration_time()
	return ..() * 0.5

// Can be used for navigation across the station. Why damage such infrastructure?
/obj/structure/disposalpipe/can_be_auto_disintegrated()
	return FALSE

/obj/machinery/get_replicator_material_amount()
	return w_class

/obj/machinery/replicator_act(mob/living/simple_animal/replicator/R)
	// dismantle and fall into pieces
	deconstruct(TRUE)
	return TRUE

// Vents and pipes are used to transport through the station.
/obj/machinery/atmospherics/can_be_auto_disintegrated()
	return FALSE

/obj/machinery/portable_atmospherics/can_be_auto_disintegrated()
	return FALSE

// Power is needed for the Transponders.
/obj/machinery/power/can_be_auto_disintegrated()
	return FALSE

/obj/machinery/disposal/can_be_auto_disintegrated()
	return FALSE

/obj/machinery/bluespace_transponder/can_be_auto_disintegrated()
	return FALSE

// Refund!
/obj/machinery/bluespace_transponder/get_replicator_material_amount()
	return REPLICATOR_COST_REPLICATE

/obj/machinery/bluespace_transponder/get_unit_disintegration_time()
	return ..() * 0.5

/obj/machinery/power/replicator_generator/can_be_auto_disintegrated()
	return FALSE

/obj/machinery/power/replicator_generator/get_replicator_material_amount()
	return REPLICATOR_COST_REPLICATE

/obj/machinery/replicator_generator/get_unit_disintegration_time()
	return ..() * 0.5

/obj/item/get_replicator_material_amount()
	return w_class

/obj/item/replicator_act(mob/living/simple_animal/replicator/R)
	deconstruct(TRUE)
	return TRUE

/obj/item/stack/get_replicator_material_amount()
	return amount

// Raw materials are eaten much faster.
/obj/item/stack/get_unit_disintegration_time()
	return ..() * 0.5
