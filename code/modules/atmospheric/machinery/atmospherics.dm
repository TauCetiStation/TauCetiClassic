/*
Quick overview:

Pipes combine to form pipelines
Pipelines and other atmospheric objects combine to form pipe_networks
	Note: A single pipe_network represents a completely open space

Pipes -> Pipelines
Pipelines + Other Objects -> Pipe network

*/

#define PIPE_VISIBLE_LEVEL   2
#define PIPE_HIDDEN_LEVEL    1

/obj/machinery/atmospherics
	anchored = TRUE
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = STATIC_ENVIRON
	layer = GAS_PIPE_HIDDEN_LAYER // under wires

	var/nodealert = FALSE
	var/can_unwrench = FALSE
	var/initialize_directions = 0
	var/power_rating // the maximum amount of power the machine can use to do work, affects how powerful the machine is, in Watts

	var/connect_types = CONNECT_TYPE_REGULAR
	var/icon_connect_type = "" //"-supply" or "-scrubbers"

	var/pipe_color
	var/static/datum/pipe_icon_manager/icon_manager

	var/device_type = 0
	var/list/obj/machinery/atmospherics/nodes

	var/atmos_initalized = FALSE

/obj/machinery/atmospherics/atom_init(mapload, process = TRUE)
	nodes = new(device_type)

	if(!icon_manager)
		icon_manager = new()

	if(!pipe_color)
		pipe_color = color
	color = null

	if(!pipe_color_check(pipe_color))
		pipe_color = null

	. = ..()

	if(process)
		SSair.atmos_machinery += src

	SetInitDirections()

/obj/machinery/atmospherics/Destroy()
	for(DEVICE_TYPE_LOOP)
		nullifyNode(I)

	SSair.atmos_machinery -= src

	return ..()

/obj/machinery/atmospherics/proc/nullifyNode(I)
	if(NODE_I)
		var/obj/machinery/atmospherics/N = NODE_I
		N.disconnect(src)
		NODE_I = null

/obj/machinery/atmospherics/proc/getNodeConnects()
	var/list/node_connects = list()
	node_connects.len = device_type

	for(DEVICE_TYPE_LOOP)
		for(var/D in cardinal)
			if(D & GetInitDirections())
				if(D in node_connects)
					continue
				node_connects[I] = D
				break
	return node_connects

//this is called just after the air controller sets up turfs
/obj/machinery/atmospherics/proc/atmos_init(list/node_connects)
	atmos_initalized = TRUE

	if(!node_connects) //for pipes where order of nodes doesn't matter
		node_connects = getNodeConnects()

	for(DEVICE_TYPE_LOOP)
		for(var/obj/machinery/atmospherics/target in get_step(src, node_connects[I]))
			if(can_be_node(target, I))
				if(check_connect_types(target, src))
					NODE_I = target
					break

	update_icon()
	update_underlays()

/obj/machinery/atmospherics/proc/can_be_node(obj/machinery/atmospherics/target)
	if(target.initialize_directions & get_dir(target,src))
		return 1

/obj/machinery/atmospherics/proc/has_free_nodes()
	var/connections_count = 0
	for(DEVICE_TYPE_LOOP)
		if(NODE_I)
			connections_count++
	return (connections_count != device_type)

/obj/machinery/atmospherics/proc/pipeline_expansion()
	return nodes

/obj/machinery/atmospherics/proc/SetInitDirections()
	return

/obj/machinery/atmospherics/proc/GetInitDirections()
	return initialize_directions

/obj/machinery/atmospherics/proc/returnPipenet()
	return

/obj/machinery/atmospherics/proc/returnPipenetAir()
	return

/obj/machinery/atmospherics/proc/setPipenet()
	return

/obj/machinery/atmospherics/proc/replacePipenet()
	return

/obj/machinery/atmospherics/proc/build_network()
	// Called to build a network from this node
	return

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		qdel(P.parent)
	var/I = nodes.Find(reference)
	NODE_I = null
	update_icon()
	update_underlays()

/obj/machinery/atmospherics/update_icon()
	return null

/obj/machinery/atmospherics/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/analyzer))
		return
	else if(iswrench(W))
		if(user.is_busy()) return
		if(can_unwrench(user))
			var/turf/T = get_turf(src)
			if (level == 1 && isturf(T) && T.intact)
				to_chat(user, "<span class='warning'>You must remove the plating first!</span>")
				return 1

			var/datum/gas_mixture/int_air = return_air()
			var/datum/gas_mixture/env_air = loc.return_air()

			var/unsafe_wrenching = FALSE
			var/internal_pressure = int_air.return_pressure()-env_air.return_pressure()

			add_fingerprint(user)
			to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")

			if (internal_pressure > 2 * ONE_ATMOSPHERE)
				to_chat(user, "<span class='warning'>As you begin unwrenching \the [src] a gush of air blows in your face... maybe you should reconsider?</span>")
				unsafe_wrenching = TRUE //Oh dear oh dear

			if (W.use_tool(src, user, 20, volume = 50))
				user.visible_message(
					"[user] unfastens \the [src].", \
					"<span class='notice'>You unfasten \the [src].</span>",
					"<span class='italics'>You hear ratchet.</span>")
				log_investigate("was <span class='warning'>REMOVED</span> by [key_name(usr)]", INVESTIGATE_ATMOS)

				//You unwrenched a pipe full of pressure? Let's splat you into the wall, silly.
				if(unsafe_wrenching)
					unsafe_pressure_release(user, internal_pressure)
				deconstruct(TRUE)
	else
		return ..()

/obj/machinery/atmospherics/proc/can_unwrench(mob/user)
	return can_unwrench

// Throws the user when they unwrench a pipe with a major difference between the internal and environmental pressure.
/obj/machinery/atmospherics/proc/unsafe_pressure_release(mob/user, pressures = null)
	if(!user)
		return
	if(!pressures)
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		pressures = int_air.return_pressure() - env_air.return_pressure()

	var/fuck_you_dir = get_dir(src, user) // Because fuck you...
	if(!fuck_you_dir)
		fuck_you_dir = pick(cardinal)
	var/turf/target = get_edge_target_turf(user, fuck_you_dir)
	var/range = pressures/250
	var/speed = range/5

	user.visible_message("<span class='danger'>[user] is sent flying by pressure!</span>","<span class='userdanger'>The pressure sends you flying!</span>")
	user.throw_at(target, range, speed)

/obj/machinery/atmospherics/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(can_unwrench)
			var/obj/item/pipe/stored = new(loc, null, null, src)
			transfer_fingerprints_to(stored)
	..()

/obj/machinery/atmospherics/construction(pipe_type, obj_color)
	var/turf/T = get_turf(src)
	if(level == PIPE_HIDDEN_LEVEL) // so we only hide ones that are hideable.
		level = !T.is_plating() ? PIPE_VISIBLE_LEVEL : PIPE_HIDDEN_LEVEL
	atmos_init()
	var/list/nodes = pipeline_expansion()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.atmos_init()
		A.addMember(src)
	build_network()

/obj/machinery/atmospherics/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/machinery/atmospherics/proc/returnPipenets()
	return list()

/obj/machinery/atmospherics/proc/add_underlay(turf/T, obj/machinery/atmospherics/node, direction, icon_connect_type)
	if(node)
		if(!T.is_plating() && node.level == PIPE_HIDDEN_LEVEL && istype(node, /obj/machinery/atmospherics/pipe))
			//underlays += icon_manager.get_atmos_icon("underlay_down", direction, color_cache_name(node))
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "down" + icon_connect_type)
		else
			//underlays += icon_manager.get_atmos_icon("underlay_intact", direction, color_cache_name(node))
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
	else
		//underlays += icon_manager.get_atmos_icon("underlay_exposed", direction, pipe_color)
		underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "exposed" + icon_connect_type)

/obj/machinery/atmospherics/proc/update_underlays()
	if(check_icon_cache())
		return TRUE
	else
		return FALSE

/obj/machinery/atmospherics/proc/check_connect_types(obj/machinery/atmospherics/atmos1, obj/machinery/atmospherics/atmos2)
	return (atmos1.connect_types & atmos2.connect_types)

/obj/machinery/atmospherics/proc/check_connect_types_construction(obj/machinery/atmospherics/atmos1, obj/item/pipe/pipe2)
	return (atmos1.connect_types & pipe2.connect_types)

/obj/machinery/atmospherics/proc/check_icon_cache(safety = FALSE)
	if(!istype(icon_manager))
		if(!safety) //to prevent infinite loops
			icon_manager = new()
			check_icon_cache(1)
		return FALSE

	return TRUE

/obj/machinery/atmospherics/proc/change_color(new_color)
	//only pass valid pipe colors please ~otherwise your pipe will turn invisible
	if(!pipe_color_check(new_color))
		return

	pipe_color = new_color
	update_icon()

	var/list/nodes = pipeline_expansion()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.update_underlays()

/obj/machinery/atmospherics/proc/color_cache_name(obj/machinery/atmospherics/node)
	//Don't use this for standard pipes
	if(!istype(node))
		return null

	return node.pipe_color
