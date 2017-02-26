#define SSAIR_PIPENETS   1
#define SSAIR_TILES_CUR  2
#define SSAIR_TILES_DEF  3
#define SSAIR_EDGES      4
#define SSAIR_FIRE       5
#define SSAIR_ZONES      6
var/datum/subsystem/air/SSair

/datum/subsystem/air
	name = "Air"

	init_order    = SS_INIT_AIR
	priority      = SS_PRIORITY_AIR
	wait          = SS_WAIT_AIR
	display_order = SS_DISPLAY_AIR

	flags = SS_BACKGROUND

	var/current_cycle = 0
	var/next_id       = 1 //Used to keep track of zone UIDs.

	var/cost_pipenets   = 0
	var/cost_tiles_curr = 0
	var/cost_tiles_def  = 0
	var/cost_edges      = 0
	var/cost_hotspots   = 0
	var/cost_zones      = 0

	var/list/zones = list()
	var/list/edges = list()
	var/list/tiles_to_update = list()
	var/list/deferred_tiles  = list()
	var/list/zones_to_update = list()
	var/list/active_hotspots = list()

	var/list/currentrun = list()
	var/currentpart = SSAIR_PIPENETS

/datum/subsystem/air/New()
	NEW_SS_GLOBAL(SSair)

/datum/subsystem/air/stat_entry(msg)
	msg += "\nC:{"
	msg += "TC:[round(cost_tiles_curr)]|"
	msg += "TD:[round(cost_tiles_def)]|"
	msg += "E:[round(cost_edges)]|"
	msg += "HS:[round(cost_hotspots)]|"
	msg += "PN:[round(cost_pipenets)]|"
	msg += "Z:[round(cost_zones)]|"
	msg += "} "
	msg += "E:[edges.len]|"
	msg += "TTU:[tiles_to_update.len]|"
	msg += "AHS:[active_hotspots.len]|"
	msg += "Z:[zones.len]|"
	msg += "ZTU:[zones_to_update.len]|"
	..(msg)


/datum/subsystem/air/Initialize(timeofday)
	setup_allturfs()
	setup_atmos_machinery()
	setup_pipenets()
	..()

/datum/subsystem/air/fire(resumed = 0)
	current_cycle++
	var/timer = world.tick_usage

	if (currentpart == SSAIR_PIPENETS || !resumed)
		process_pipenets(resumed)
		cost_pipenets = MC_AVERAGE(cost_pipenets, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_TILES_CUR

	if (currentpart == SSAIR_TILES_CUR)
		timer = world.tick_usage
		process_tiles_current(resumed)
		cost_tiles_curr = MC_AVERAGE(cost_tiles_curr, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_TILES_DEF

	if (currentpart == SSAIR_TILES_DEF)
		timer = world.tick_usage
		process_tiles_deferred(resumed)
		cost_tiles_def = MC_AVERAGE(cost_tiles_def, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_EDGES

	if (currentpart == SSAIR_EDGES)
		timer = world.tick_usage
		process_edges(resumed)
		cost_edges = MC_AVERAGE(cost_edges, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_FIRE

	if (currentpart == SSAIR_FIRE)
		timer = world.tick_usage
		process_fire(resumed)
		cost_hotspots = MC_AVERAGE(cost_hotspots, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_ZONES

	if (currentpart == SSAIR_ZONES)
		timer = world.tick_usage
		process_zones(resumed)
		cost_zones = MC_AVERAGE(cost_zones, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_PIPENETS


/*********** Processing procs ***********/

/datum/subsystem/air/proc/process_pipenets(resumed = 0)
	if (!resumed)
		src.currentrun = pipe_networks.Copy()
	// Cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(thing)
			thing.process()
		else
			pipe_networks -= thing
		if (MC_TICK_CHECK)
			return

/datum/subsystem/air/proc/process_tiles_current(resumed = 0)
	while (tiles_to_update.len)
		var/turf/T = tiles_to_update[tiles_to_update.len]
		tiles_to_update.len--
		// Check if the turf is self-zone-blocked
		if(T.c_airblock(T) & ZONE_BLOCKED)
			deferred_tiles += T
			if (MC_TICK_CHECK)
				return
			continue
		T.update_air_properties()
		T.post_update_air_properties()
		T.needs_air_update = FALSE
		if (MC_TICK_CHECK)
			return

/datum/subsystem/air/proc/process_tiles_deferred(resumed = 0)
	while (deferred_tiles.len)
		var/turf/T = deferred_tiles[deferred_tiles.len]
		deferred_tiles.len--
		T.update_air_properties()
		T.post_update_air_properties()
		T.needs_air_update = FALSE
		if (MC_TICK_CHECK)
			return

/datum/subsystem/air/proc/process_edges(resumed = 0)
	if (!resumed)
		src.currentrun = edges.Copy()
	// Cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while (currentrun.len)
		var/connection_edge/E = currentrun[currentrun.len]
		currentrun.len--
		E.tick()
		if (MC_TICK_CHECK)
			return

/datum/subsystem/air/proc/process_fire(resumed = 0)
	if (!resumed)
		src.currentrun = active_hotspots.Copy()
	// Cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while (currentrun.len)
		var/obj/fire/F = currentrun[currentrun.len]
		currentrun.len--
		F.process()
		if (MC_TICK_CHECK)
			return

/datum/subsystem/air/proc/process_zones(resumed = 0)
	while (zones_to_update.len)
		var/zone/Z = zones_to_update[zones_to_update.len]
		zones_to_update.len--
		Z.tick()
		Z.needs_update = FALSE
		if (MC_TICK_CHECK)
			return


/*********** Setup procs ***********/

/datum/subsystem/air/proc/setup_allturfs()
	var/list/turfs_to_init = block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz))

	for(var/turf/simulated/T in turfs_to_init)
		T.update_air_properties()
		CHECK_TICK

/datum/subsystem/air/proc/setup_pipenets()
	for(var/obj/machinery/atmospherics/AM in machines)
		AM.build_network()
		CHECK_TICK

/datum/subsystem/air/proc/setup_atmos_machinery()
	for(var/obj/machinery/atmospherics/unary/AM in machines)
		if(istype(AM, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = AM
			T.broadcast_status()
		else if(istype(AM, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = AM
			T.broadcast_status()
		CHECK_TICK

/datum/subsystem/air/proc/setup_template_machinery(list/atmos_machines)
	for(var/A in atmos_machines)
		if(!istype(A, /obj/machinery/atmospherics/unary))
			continue
		if(istype(A, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = A
			T.broadcast_status()
		else if(istype(A, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = A
			T.broadcast_status()
		CHECK_TICK

	for(var/A in atmos_machines)
		var/obj/machinery/atmospherics/AM = A
		AM.build_network()
		CHECK_TICK


/*********** Procs, which doesn't get involved in processing directly ***********/

/datum/subsystem/air/proc/add_zone(zone/z)
	zones += z
	z.name = "Zone [next_id++]"
	mark_zone_update(z)

/datum/subsystem/air/proc/remove_zone(zone/z)
	zones -= z

/datum/subsystem/air/proc/air_blocked(turf/A, turf/B)
	var/ablock = A.c_airblock(B)
	if(ablock == BLOCKED)
		return BLOCKED
	return ablock | B.c_airblock(A)

/datum/subsystem/air/proc/has_valid_zone(turf/simulated/T)
	return istype(T) && T.zone && !T.zone.invalid

/datum/subsystem/air/proc/merge(zone/A, zone/B)
	if(A.contents.len < B.contents.len)
		A.c_merge(B)
		mark_zone_update(B)
	else
		B.c_merge(A)
		mark_zone_update(A)

/datum/subsystem/air/proc/connect(turf/simulated/A, turf/simulated/B)
	var/block = SSair.air_blocked(A, B)

	if(block & AIR_BLOCKED)
		return

	var/direct = !(block & ZONE_BLOCKED)
	var/space = !istype(B)

	if(!space)
		if(min(A.zone.contents.len, B.zone.contents.len) < 14 || (direct && (equivalent_pressure(A.zone,B.zone) || current_cycle == 0)))
			merge(A.zone,B.zone)
			return

	var/a_to_b = get_dir(A, B)
	var/b_to_a = get_dir(B, A)

	if(!A.connections)
		A.connections = new
	if(!B.connections)
		B.connections = new

	if(A.connections.get(a_to_b))
		return
	if(B.connections.get(b_to_a))
		return
	if(!space)
		if(A.zone == B.zone)
			return

	var/connection/c = new /connection(A,B)

	A.connections.place(c, a_to_b)
	B.connections.place(c, b_to_a)

	if(direct)
		c.mark_direct()


/datum/subsystem/air/proc/mark_for_update(turf/T)
	if(!T || T.needs_air_update)
		return
	tiles_to_update |= T
	T.needs_air_update = TRUE

/datum/subsystem/air/proc/mark_zone_update(zone/Z)
	if(!Z || Z.needs_update)
		return
	zones_to_update += Z
	Z.needs_update = TRUE

/datum/subsystem/air/proc/equivalent_pressure(zone/A, zone/B)
	return A.air.compare(B.air)

/datum/subsystem/air/proc/remove_edge(connection/c)
	edges -= c

/datum/subsystem/air/proc/get_edge(zone/A, zone/B)

	if(istype(B))
		for(var/connection_edge/zone/edge in A.edges)
			if(edge.contains_zone(B))
				return edge
		var/connection_edge/edge = new/connection_edge/zone(A,B)
		edges += edge
		return edge
	else
		for(var/connection_edge/unsimulated/edge in A.edges)
			if(has_same_air(edge.B, B))
				return edge
		var/connection_edge/edge = new/connection_edge/unsimulated(A,B)
		edges += edge
		return edge

/datum/subsystem/air/proc/has_same_air(turf/A, turf/B)
	if(A.oxygen != B.oxygen)
		return FALSE
	if(A.nitrogen != B.nitrogen)
		return FALSE
	if(A.phoron != B.phoron)
		return FALSE
	if(A.carbon_dioxide != B.carbon_dioxide)
		return FALSE
	if(A.temperature != B.temperature)
		return FALSE
	return TRUE

#undef SSAIR_PIPENETS
#undef SSAIR_TILES
#undef SSAIR_EDGES
#undef SSAIR_FIRE
#undef SSAIR_ZONES