/obj/machinery/atmospherics/pipe
	can_unwrench = TRUE
	use_power = NO_POWER_USE
	can_buckle = 1
	buckle_require_restraints = 1
	buckle_lying = TRUE

	var/datum/gas_mixture/air_temporary // used when reconstructing a pipeline that broke
	var/datum/pipeline/parent
	var/volume = 0
	//var/leaking = FALSE until someone will make this as proper feature, because currently it only leaks from simple pipes and nothing else, not even manifolds.

	var/alert_pressure = 170 * ONE_ATMOSPHERE

	undertile = TRUE

/* todo: need to add turf signals and make them work
/obj/machinery/atmospherics/pipe/atom_init()
	..()

	check_force_hide()
	RegisterSignal(loc, COMSIG_TURF_CHANGED, PROC_REF(check_force_hide))

// this shitty part exists only for /visible pipes, when unexpectedly we need to make them invisible under walls
// it has nothing to do with the component, and should be rewritten in the future
/obj/machinery/atmospherics/pipe/proc/check_force_hide()
	SIGNAL_HANDLER
	world.log << "[src] turf changed to [loc]"
	if(!undertile) // for undertile it is already resolved by component
		var/turf/T = get_turf(src)
		if(T.density)
			ADD_TRAIT(src, TRAIT_T_RAY_VISIBLE, REF(src))
			alpha = 128
			invisibility = INVISIBILITY_MAXIMUM
		else
			REMOVE_TRAIT(src, TRAIT_T_RAY_VISIBLE, REF(src))
			alpha = initial(alpha)
			invisibility = initial(invisibility)*/

/obj/machinery/atmospherics/pipe/Destroy()
	if(SSair.stop_airnet_processing)
		return ..()

	releaseAirToTurf()
	qdel(air_temporary)
	air_temporary = null

	var/turf/T = loc
	for(var/obj/machinery/meter/meter in T)
		if(meter.target == src)
			var/obj/item/pipe_meter/PM = new (T)
			meter.transfer_fingerprints_to(PM)
			qdel(meter)

	. = ..()

	if(parent && !QDELETED(parent))
		qdel(parent)
	parent = null

/obj/machinery/atmospherics/pipe/atmos_init()
	update_icon()
	..()

/obj/machinery/atmospherics/pipe/nullifyNode(I)
	var/obj/machinery/atmospherics/oldN = NODE_I
	..()
	if(oldN)
		oldN.build_network()

/obj/machinery/atmospherics/pipe/proc/check_pressure(pressure)
	//Return TRUE if parent should continue checking other pipes
	//Return null if parent should stop checking other pipes. Recall: qdel(src) will by default return null

	return TRUE

/obj/machinery/atmospherics/pipe/proc/releaseAirToTurf()
	if(air_temporary)
		var/turf/T = loc
		T.assume_air(air_temporary)

/obj/machinery/atmospherics/pipe/return_air()
	return parent.air

/obj/machinery/atmospherics/pipe/build_network()
	if(!parent)
		parent = new /datum/pipeline()
		parent.build_pipeline(src)

/obj/machinery/atmospherics/pipe/returnPipenet()
	return parent

/obj/machinery/atmospherics/pipe/returnPipenets()
	. = list(parent)

/obj/machinery/atmospherics/pipe/setPipenet(datum/pipeline/P)
	parent = P

/*
/obj/machinery/atmospherics/pipe/add_underlay(obj/machinery/atmospherics/node, direction)
	if(istype(src, /obj/machinery/atmospherics/components/unary/tank))	//todo: move tanks to unary devices
		return ..()

	if(node)
		var/temp_dir = get_dir(src, node)
		underlays += icon_manager.get_atmos_icon("pipe_underlay_intact", temp_dir, color_cache_name(node))
		return temp_dir
	else if(direction)
		underlays += icon_manager.get_atmos_icon("pipe_underlay_exposed", direction, pipe_color)
	else
		return null
*/

/obj/machinery/atmospherics/pipe/color_cache_name(obj/machinery/atmospherics/node)
	if(istype(src, /obj/machinery/atmospherics/components/unary/tank))
		return ..()

	if(istype(node, /obj/machinery/atmospherics/pipe/manifold) || istype(node, /obj/machinery/atmospherics/pipe/manifold4w))
		if(pipe_color == node.pipe_color)
			return node.pipe_color
		else
			return null
	else if(istype(node, /obj/machinery/atmospherics/pipe/simple))
		return node.pipe_color
	else
		return pipe_color

/obj/machinery/atmospherics/pipe/attack_hand(mob/living/carbon/human/H)
	if(can_buckle && buckled_mob && istype(H))
		user_unbuckle_mob(H)
	else
		..()
