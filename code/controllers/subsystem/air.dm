#define SSAIR_PIPENETS         1
#define SSAIR_ATMOSMACHINERY   2
#define SSAIR_TILES_CUR        3
#define SSAIR_TILES_DEF        4
#define SSAIR_EDGES            5
#define SSAIR_FIRE_ZONES       6
#define SSAIR_HOTSPOTS         7
#define SSAIR_ZONES            8

#define SSAIR_TICK_MULTIPLIER 2

SUBSYSTEM_DEF(air)
	name = "Air"

	init_order    = SS_INIT_AIR
	priority      = SS_PRIORITY_AIR
	wait          = SS_WAIT_AIR
	display_order = SS_DISPLAY_AIR

	flags = SS_BACKGROUND

	var/next_id       = 1 // Used to keep track of zone UIDs.

	var/cost_pipenets        = 0
	var/cost_atmos_machinery = 0
	var/cost_tiles_curr      = 0
	var/cost_tiles_def       = 0
	var/cost_edges           = 0
	var/cost_fire_zones      = 0
	var/cost_hotspots        = 0
	var/cost_zones           = 0

	// Geometry lists
	var/list/zones = list()
	var/list/edges = list()

	// Geometry updates lists
	var/list/tiles_to_update = list()
	var/list/deferred_tiles  = list()
	var/list/active_edges = list()
	var/list/active_fire_zones = list()
	var/list/active_hotspots = list()
	var/list/zones_to_update = list()

	var/list/networks = list()
	var/list/obj/machinery/atmos_machinery = list()

	var/list/currentrun = list()
	var/currentpart = SSAIR_PIPENETS

	var/map_loading = TRUE
	var/map_init_levels = 0 // number of z-levels initialized under this type of SS.
	var/list/queued_for_update

/datum/controller/subsystem/air/stat_entry(msg)
	msg += "\nC:{"
	msg += "PN:[round(cost_pipenets,1)]|"
	msg += "AM:[round(cost_atmos_machinery,1)]"
	msg += "TC:[round(cost_tiles_curr,1)]|"
	msg += "TD:[round(cost_tiles_def,1)]|"
	msg += "E:[round(cost_edges,1)]|"
	msg += "FZ:[round(cost_fire_zones,1)]|"
	msg += "HS:[round(cost_hotspots,1)]|"
	msg += "Z:[round(cost_zones,1)]|"
	msg += "} "
	msg += "PN:[networks.len]|"
	msg += "AM:[atmos_machinery.len]|"
	msg += "TTU:[tiles_to_update.len]|"
	msg += "DT:[deferred_tiles.len]|"
	msg += "E:[active_edges.len]|"
	msg += "FZ:[active_fire_zones.len]"
	msg += "HS:[active_hotspots.len]|"
	msg += "ZTU:[zones_to_update.len]|"
	msg += "E:[edges.len]|"
	msg += "Z:[zones.len]|"
	..(msg)


/datum/controller/subsystem/air/Initialize(timeofday)
	map_loading = FALSE
	setup_allturfs()
	setup_atmos_machinery()
	setup_pipenets()
	..()

/datum/controller/subsystem/air/fire(resumed = 0)
	var/timer = world.tick_usage

	if (currentpart == SSAIR_PIPENETS || !resumed)
		process_pipenets(resumed)
		cost_pipenets = MC_AVERAGE(cost_pipenets, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_ATMOSMACHINERY

	if(currentpart == SSAIR_ATMOSMACHINERY)
		timer = world.tick_usage
		process_atmos_machinery(resumed)
		cost_atmos_machinery = MC_AVERAGE(cost_atmos_machinery, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_TILES_CUR

	// defer updating of self-zone-blocked turfs until after all other turfs have been updated.
	// this hopefully ensures that non-self-zone-blocked turfs adjacent to self-zone-blocked ones
	// have valid zones when the self-zone-blocked turfs update.

	// This ensures that doorways don't form their own single-turf zones, since doorways are self-zone-blocked and
	// can merge with an adjacent zone, whereas zones that are formed on adjacent turfs cannot merge with the doorway.
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

	// Where gas exchange happens.
	if (currentpart == SSAIR_EDGES)
		timer = world.tick_usage
		process_edges(resumed)
		cost_edges = MC_AVERAGE(cost_edges, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_FIRE_ZONES

	// Process fire zones.
	if (currentpart == SSAIR_FIRE_ZONES)
		timer = world.tick_usage
		process_fire_zones(resumed)
		cost_fire_zones = MC_AVERAGE(cost_fire_zones, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_HOTSPOTS

	// Process hotspots.
	if (currentpart == SSAIR_HOTSPOTS)
		timer = world.tick_usage
		process_hotspots(resumed)
		cost_hotspots = MC_AVERAGE(cost_hotspots, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_ZONES

	// Process zones.
	if (currentpart == SSAIR_ZONES)
		timer = world.tick_usage
		process_zones(resumed)
		cost_zones = MC_AVERAGE(cost_zones, TICK_DELTA_TO_MS(world.tick_usage - timer))
		if(state != SS_RUNNING)
			return
		resumed = 0
		currentpart = SSAIR_PIPENETS

/*********** Processing procs ***********/

/datum/controller/subsystem/air/proc/process_pipenets(resumed = 0)
	if (!resumed)
		src.currentrun = networks.Copy()
	// Cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--
		if(!QDELETED(thing))
			thing.process()
		else
			networks -= thing
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_atmos_machinery(resumed = 0)
	var/seconds = wait * 0.1
	if (!resumed)
		src.currentrun = atmos_machinery.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/obj/machinery/M = currentrun[currentrun.len]
		currentrun.len--
		if(QDELETED(M) || (M.process_atmos(seconds) == PROCESS_KILL))
			atmos_machinery.Remove(M)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_tiles_current(resumed = 0)
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

		#ifdef ZASDBG
		T.cut_overlay(mark)
		#endif

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_tiles_deferred(resumed = 0)
	while (deferred_tiles.len)
		var/turf/T = deferred_tiles[deferred_tiles.len]
		deferred_tiles.len--

		T.update_air_properties()
		T.post_update_air_properties()
		T.needs_air_update = FALSE

		#ifdef ZASDBG
		T.cut_overlay(mark)
		#endif

		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_edges(resumed = 0)
	if (!resumed)
		src.currentrun = active_edges.Copy()
	// Cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while (currentrun.len)
		var/connection_edge/E = currentrun[currentrun.len]
		currentrun.len--
		E.tick()
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_fire_zones(resumed = 0)
	if (!resumed)
		src.currentrun = active_fire_zones.Copy()
	// Cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while (currentrun.len)
		var/zone/Z = currentrun[currentrun.len]
		currentrun.len--
		Z.process_fire()
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/air/proc/process_hotspots(resumed = 0)
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

/datum/controller/subsystem/air/proc/process_zones(resumed = 0)
	while (zones_to_update.len)
		var/zone/Z = zones_to_update[zones_to_update.len]
		zones_to_update.len--
		Z.tick()
		Z.needs_update = FALSE
		if (MC_TICK_CHECK)
			return

/*********** Setup procs ***********/

/datum/controller/subsystem/air/proc/setup_allturfs()
	var/list/turfs_to_init = block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz))

	map_init_levels = world.maxz // we simply set current max Z level (later on this value will be increased by maploading process).

	for(var/turf/simulated/T in turfs_to_init)
		T.update_air_properties()
		CHECK_TICK

/datum/controller/subsystem/air/proc/setup_atmos_machinery()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.atmos_init()
		CHECK_TICK

//this can't be done with setup_atmos_machinery() because
//	all atmos machinery has to initalize before the first
//	pipenet can be built.
/datum/controller/subsystem/air/proc/setup_pipenets()
	for (var/obj/machinery/atmospherics/AM in atmos_machinery)
		AM.build_network()
		CHECK_TICK

/datum/controller/subsystem/air/proc/setup_template_machinery(list/atmos_machines)
	for(var/A in atmos_machines)
		var/obj/machinery/atmospherics/AM = A
		AM.atmos_init()
		CHECK_TICK

	for(var/A in atmos_machines)
		var/obj/machinery/atmospherics/AM = A
		AM.build_network()
		CHECK_TICK

/*********** Procs, which doesn't get involved in processing directly ***********/

/datum/controller/subsystem/air/proc/add_zone(zone/z)
	zones += z
	z.name = "Zone [next_id++]"
	mark_zone_update(z)

/datum/controller/subsystem/air/proc/remove_zone(zone/z)
	zones -= z
	zones_to_update.Remove(z)

/datum/controller/subsystem/air/proc/air_blocked(turf/A, turf/B)
	#ifdef ZASDBG
	ASSERT(isturf(A))
	ASSERT(isturf(B))
	#endif

	var/ablock = A.c_airblock(B)
	if(ablock == BLOCKED)
		return BLOCKED
	return ablock | B.c_airblock(A)

/datum/controller/subsystem/air/proc/has_valid_zone(turf/simulated/T)
	#ifdef ZASDBG
	ASSERT(istype(T))
	#endif

	return istype(T) && T.zone && !T.zone.invalid

/datum/controller/subsystem/air/proc/merge(zone/A, zone/B)
	#ifdef ZASDBG
	ASSERT(istype(A))
	ASSERT(istype(B))
	ASSERT(!A.invalid)
	ASSERT(!B.invalid)
	ASSERT(A != B)
	#endif

	if(A.contents.len < B.contents.len)
		A.c_merge(B)
		mark_zone_update(B)
	else
		B.c_merge(A)
		mark_zone_update(A)

/datum/controller/subsystem/air/proc/connect(turf/simulated/A, turf/simulated/B)
	#ifdef ZASDBG
	ASSERT(istype(A))
	ASSERT(isturf(B))
	ASSERT(A.zone)
	ASSERT(!A.zone.invalid)
	//ASSERT(B.zone)
	ASSERT(A != B)
	#endif

	var/block = SSair.air_blocked(A, B)
	if(block & AIR_BLOCKED)
		return

	var/direct = !(block & ZONE_BLOCKED)
	var/space = !istype(B)

	if(!space)
		if(min(A.zone.contents.len, B.zone.contents.len) < ZONE_MIN_SIZE || (direct && (equivalent_pressure(A.zone, B.zone) || times_fired == 0)))
			merge(A.zone, B.zone)
			return

	var/a_to_b = get_dir(A,B)
	var/b_to_a = get_dir(B,A)

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

/datum/controller/subsystem/air/proc/mark_for_update(turf/simulated/T)
	#ifdef ZASDBG
	ASSERT(isturf(T))
	#endif

	if(T.needs_air_update)
		return

	if(map_loading && T.z > map_init_levels) // we don't want to interupt SS process on other levels
		if(queued_for_update)
			queued_for_update[T] = T
	else
		tiles_to_update += T
		#ifdef ZASDBG
		T.add_overlay(mark)
		#endif

		T.needs_air_update = TRUE

/datum/controller/subsystem/air/StartLoadingMap()
	LAZYINITLIST(queued_for_update)
	map_loading = TRUE

/datum/controller/subsystem/air/StopLoadingMap()
	map_loading = FALSE
	map_init_levels = world.maxz // update z level counting, so air start to work on added levels.

	for(var/T in queued_for_update)
		mark_for_update(T)

	queued_for_update.Cut()

/datum/controller/subsystem/air/proc/mark_zone_update(zone/Z)
	#ifdef ZASDBG
	ASSERT(istype(Z))
	#endif

	if(Z.needs_update)
		return

	zones_to_update.Add(Z)
	Z.needs_update = TRUE

/datum/controller/subsystem/air/proc/mark_edge_sleeping(connection_edge/E)
	#ifdef ZASDBG
	ASSERT(istype(E))
	#endif

	if(E.sleeping)
		return

	active_edges.Remove(E)
	E.sleeping = TRUE

/datum/controller/subsystem/air/proc/mark_edge_active(connection_edge/E)
	#ifdef ZASDBG
	ASSERT(istype(E))
	#endif

	if(!E.sleeping)
		return

	active_edges.Add(E)
	E.sleeping = FALSE

	#ifdef ZASDBG
	if(istype(E, /connection_edge/zone))
		var/connection_edge/zone/ZE = E
		log_debug("ZASDBG: Active edge! Areas: [get_area(pick(ZE.A.contents))] / [get_area(pick(ZE.B.contents))]")
	else
		log_debug("ZASDBG: Active edge! Area: [get_area(pick(E.A.contents))]")
	#endif

/datum/controller/subsystem/air/proc/equivalent_pressure(zone/A, zone/B)
	return A.air.compare(B.air)

/datum/controller/subsystem/air/proc/get_edge(zone/A, zone/B)

	if(istype(B))
		for(var/connection_edge/zone/edge in A.edges)
			if(edge.contains_zone(B))
				return edge
		var/connection_edge/edge = new/connection_edge/zone(A, B)
		edges.Add(edge)
		edge.recheck()
		return edge
	else
		for(var/connection_edge/unsimulated/edge in A.edges)
			if(has_same_air(edge.B, B))
				return edge
		var/connection_edge/edge = new/connection_edge/unsimulated(A, B)
		edges.Add(edge)
		edge.recheck()
		return edge

/datum/controller/subsystem/air/proc/remove_edge(connection_edge/E)
	edges -= E
	if(!E.sleeping)
		active_edges.Remove(E)

/datum/controller/subsystem/air/proc/has_same_air(turf/A, turf/B)
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
#undef SSAIR_ATMOSMACHINERY
#undef SSAIR_TILES_CUR
#undef SSAIR_TILES_DEF
#undef SSAIR_EDGES
#undef SSAIR_FIRE_ZONES
#undef SSAIR_HOTSPOTS
#undef SSAIR_ZONES
