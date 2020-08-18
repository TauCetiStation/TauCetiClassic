/obj/machinery/atmospherics/pipe
	can_unwrench = TRUE
	use_power = NO_POWER_USE
	can_buckle = 1
	buckle_require_restraints = 1
	buckle_lying = -1

	var/datum/gas_mixture/air_temporary // used when reconstructing a pipeline that broke
	var/datum/pipeline/parent
	var/volume = 0
	//var/leaking = FALSE until someone will make this as proper feature, because currently it only leaks from simple pipes and nothing else, not even manifolds.

	var/alert_pressure = 170 * ONE_ATMOSPHERE

/obj/machinery/atmospherics/pipe/atom_init()
	if(istype(get_turf(src), /turf/simulated/wall) || istype(get_turf(src), /turf/simulated/shuttle/wall) || istype(get_turf(src), /turf/unsimulated/wall))
		level = PIPE_HIDDEN_LEVEL
	. = ..()

/obj/machinery/atmospherics/pipe/Destroy()
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
	var/turf/T = loc
	hide(!T.is_plating())
	..()

/obj/machinery/atmospherics/pipe/nullifyNode(I)
	var/obj/machinery/atmospherics/oldN = NODE_I
	..()
	if(oldN)
		oldN.build_network()

/obj/machinery/atmospherics/pipe/hides_under_flooring()
	return level != PIPE_VISIBLE_LEVEL

/obj/machinery/atmospherics/pipe/hide(i)
	if(level == PIPE_HIDDEN_LEVEL && istype(loc, /turf/simulated))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon()

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
/obj/machinery/atmospherics/pipe/add_underlay(var/obj/machinery/atmospherics/node, var/direction)
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
