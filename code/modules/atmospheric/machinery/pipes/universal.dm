
/obj/machinery/atmospherics/pipe/simple/visible/universal
	name = "Universal pipe adapter"
	desc = "An adapter for regular, supply and scrubbers pipes."
	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_SUPPLY|CONNECT_TYPE_SCRUBBER
	icon_state = "map_universal"

/obj/machinery/atmospherics/pipe/simple/visible/universal/update_icon(safety = FALSE)
	if(!check_icon_cache())
		return

	alpha = 255

	cut_overlays()
	add_overlay(icon_manager.get_atmos_icon("pipe", , pipe_color, "universal"))
	underlays.Cut()

	var/obj/machinery/atmospherics/node1 = NODE1
	var/obj/machinery/atmospherics/node2 = NODE2

	if (node1)
		universal_underlays(node1)
		if(node2)
			universal_underlays(node2)
		else
			var/node1_dir = get_dir(node1, src)
			universal_underlays(, node1_dir)
	else if (node2)
		universal_underlays(node2)
	else
		universal_underlays(, dir)
		universal_underlays(dir, -180)

/obj/machinery/atmospherics/pipe/simple/visible/universal/update_underlays()
	..()
	update_icon()



/obj/machinery/atmospherics/pipe/simple/hidden/universal
	name = "Universal pipe adapter"
	desc = "An adapter for regular, supply and scrubbers pipes."
	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_SUPPLY|CONNECT_TYPE_SCRUBBER
	icon_state = "map_universal"

/obj/machinery/atmospherics/pipe/simple/hidden/universal/update_icon(safety = FALSE)
	if(!check_icon_cache())
		return

	alpha = 255

	cut_overlays()
	add_overlay(icon_manager.get_atmos_icon("pipe", , pipe_color, "universal"))
	underlays.Cut()

	var/obj/machinery/atmospherics/node1 = NODE1
	var/obj/machinery/atmospherics/node2 = NODE2

	if (node1)
		universal_underlays(node1)
		if(node2)
			universal_underlays(node2)
		else
			var/node2_dir = turn(get_dir(src, node1), -180)
			universal_underlays(, node2_dir)
	else if (node2)
		universal_underlays(node2)
		var/node1_dir = turn(get_dir(src, node2), -180)
		universal_underlays(, node1_dir)
	else
		universal_underlays(, dir)
		universal_underlays(, turn(dir, -180))

/obj/machinery/atmospherics/pipe/simple/hidden/universal/update_underlays()
	..()
	update_icon()

/obj/machinery/atmospherics/proc/universal_underlays(obj/machinery/atmospherics/node, direction)
	var/turf/T = loc
	if(istype(node))
		var/node_dir = get_dir(src,node)
		if(node.icon_connect_type == "-supply")
			add_underlay_adapter(T, , node_dir, "")
			add_underlay_adapter(T, node, node_dir, "-supply")
			add_underlay_adapter(T, , node_dir, "-scrubbers")
		else if (node.icon_connect_type == "-scrubbers")
			add_underlay_adapter(T, , node_dir, "")
			add_underlay_adapter(T, , node_dir, "-supply")
			add_underlay_adapter(T, node, node_dir, "-scrubbers")
		else
			add_underlay_adapter(T, node, node_dir, "")
			add_underlay_adapter(T, , node_dir, "-supply")
			add_underlay_adapter(T, , node_dir, "-scrubbers")
	else
		add_underlay_adapter(T, , direction, "-supply")
		add_underlay_adapter(T, , direction, "-scrubbers")
		add_underlay_adapter(T, , direction, "")

/obj/machinery/atmospherics/proc/add_underlay_adapter(turf/T, obj/machinery/atmospherics/node, direction, icon_connect_type) // modified from add_underlay, does not make exposed underlays
	if(node)
		if(!T.is_plating() && node.level == PIPE_HIDDEN_LEVEL && istype(node, /obj/machinery/atmospherics/pipe))
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "down" + icon_connect_type)
		else
			underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "intact" + icon_connect_type)
	else
		underlays += icon_manager.get_atmos_icon("underlay", direction, color_cache_name(node), "retracted" + icon_connect_type)
