var/datum/subsystem/air/SSair

/datum/subsystem/air
	name = "Air"
	priority = -1
	wait = 5
	dynamic_wait = 1
	dwait_upper = 300
	dwait_delta = 7
	display = 1

	var/active_zones = 0
	var/current_cycle = 0
	var/next_id = 1 //Used to keep track of zone UIDs.

	var/cost_turfs = 0
	var/cost_edges = 0
	var/cost_zones = 0
	var/cost_hotspots = 0
	var/cost_pipenets = 0
	//var/cost_atmos_machinery = 0

	var/list/zones = list()
	var/list/edges = list()
	var/list/tiles_to_update = list()
	var/list/zones_to_update = list()
	var/list/active_hotspots = list()
	//var/list/obj/machinery/atmos_machinery = list()


/datum/subsystem/air/New()
	NEW_SS_GLOBAL(SSair)

/datum/subsystem/air/stat_entry(msg)
	msg += "C:{"
	msg += "AT:[round(cost_turfs,0.01)]|"
	msg += "E:[round(cost_edges,0.01)]|"
	msg += "HS:[round(cost_hotspots,0.01)]|"
	msg += "PN:[round(cost_pipenets,0.01)]|"
	//msg += "AM:[round(cost_atmos_machinery,0.01)]"
	msg += "Z:[round(cost_zones,0.01)]|"
	msg += "} "
	msg +=  "E:[edges.len]|"
	msg +=  "TTU:[tiles_to_update.len]|"
	msg +=  "AHS:[active_hotspots.len]|"
	msg +=  "Z:[zones.len]|"
	msg +=  "AZ:[active_zones]"
	msg +=  "ZTU:[zones_to_update.len]|"
	..(msg)


/datum/subsystem/air/Initialize(timeofday, zlevel)
	setup_allturfs(zlevel)
	setup_atmos_machinery(zlevel)
	setup_pipenets(zlevel)
	..()

#define AIR_BLOCKED 1
#define ZONE_BLOCKED 2
#define BLOCKED 3

#define MC_AVERAGE(average, current) (0.8*(average) + 0.2*(current))
/datum/subsystem/air/fire(resumed = 0)
	current_cycle++

	var/timer = world.timeofday

	process_pipenets()
	cost_pipenets = MC_AVERAGE(cost_pipenets, (world.timeofday - timer))

	timer = world.timeofday

	//If there are tiles to update, do so.
	var/list/updating
	if(tiles_to_update.len)
		updating = tiles_to_update
		tiles_to_update = list()

		//defer updating of self-zone-blocked turfs until after all other turfs have been updated.
		//this hopefully ensures that non-self-zone-blocked turfs adjacent to self-zone-blocked ones
		//have valid zones when the self-zone-blocked turfs update.
		var/list/deferred = list()

		for(var/turf/T in updating)
			//check if the turf is self-zone-blocked
			if(T.c_airblock(T) & ZONE_BLOCKED)
				deferred += T
				continue

			T.update_air_properties()
			T.post_update_air_properties()
			T.needs_air_update = 0
			CHECK_TICK

		for(var/turf/T in deferred)
			T.update_air_properties()
			T.post_update_air_properties()
			T.needs_air_update = 0
			CHECK_TICK

		timer = world.timeofday

	cost_turfs = MC_AVERAGE(cost_turfs, (world.timeofday - timer))

	//Where gas exchange happens.
	timer = world.timeofday
	for(var/connection_edge/edge in edges)
		edge.tick()
		CHECK_TICK
	cost_edges = MC_AVERAGE(cost_edges, (world.timeofday - timer))

	//Process fires.
	timer = world.timeofday
	for(var/obj/fire/fire in active_hotspots)
		fire.process()
		CHECK_TICK
	cost_hotspots = MC_AVERAGE(cost_hotspots, (world.timeofday - timer))

	//Process zones.
	timer = world.timeofday
	active_zones = zones_to_update.len
	if(zones_to_update.len)
		updating = zones_to_update
		zones_to_update = list()
		for(var/zone/zone in updating)
			zone.tick()
			zone.needs_update = 0
			CHECK_TICK
	cost_zones = MC_AVERAGE(cost_zones, (world.timeofday - timer))

#undef MC_AVERAGE

/datum/subsystem/air/proc/process_pipenets()
	for(var/thing in pipe_networks)
		if(thing)
			thing:process()
			continue
		pipe_networks.Remove(thing)

/datum/subsystem/air/proc/add_zone(zone/z)
	zones.Add(z)
	z.name = "Zone [next_id++]"
	mark_zone_update(z)

/datum/subsystem/air/proc/remove_zone(zone/z)
	zones.Remove(z)

/datum/subsystem/air/proc/air_blocked(turf/A, turf/B)
	var/ablock = A.c_airblock(B)
	if(ablock == BLOCKED) return BLOCKED
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
	var/block = SSair.air_blocked(A,B)
	if(block & AIR_BLOCKED) return

	var/direct = !(block & ZONE_BLOCKED)
	var/space = !istype(B)

	if(!space)
		if(min(A.zone.contents.len, B.zone.contents.len) < 14 || (direct && (equivalent_pressure(A.zone,B.zone) || current_cycle == 0)))
			merge(A.zone,B.zone)
			return

	var
		a_to_b = get_dir(A,B)
		b_to_a = get_dir(B,A)

	if(!A.connections) A.connections = new
	if(!B.connections) B.connections = new

	if(A.connections.get(a_to_b)) return
	if(B.connections.get(b_to_a)) return
	if(!space)
		if(A.zone == B.zone) return


	var/connection/c = new /connection(A,B)

	A.connections.place(c, a_to_b)
	B.connections.place(c, b_to_a)

	if(direct) c.mark_direct()

/datum/subsystem/air/proc/mark_for_update(turf/T)
	if(!T) return
	if(T.needs_air_update) return
	tiles_to_update |= T
	T.needs_air_update = 1

/datum/subsystem/air/proc/mark_zone_update(zone/Z)
	if(!Z) return
	if(Z.needs_update) return
	zones_to_update.Add(Z)
	Z.needs_update = 1

/datum/subsystem/air/proc/equivalent_pressure(zone/A, zone/B)
	return A.air.compare(B.air)

/datum/subsystem/air/proc/get_edge(zone/A, zone/B)

	if(istype(B))
		for(var/connection_edge/zone/edge in A.edges)
			if(edge.contains_zone(B)) return edge
		var/connection_edge/edge = new/connection_edge/zone(A,B)
		edges.Add(edge)
		return edge
	else
		for(var/connection_edge/unsimulated/edge in A.edges)
			if(has_same_air(edge.B,B)) return edge
		var/connection_edge/edge = new/connection_edge/unsimulated(A,B)
		edges.Add(edge)
		return edge

/datum/subsystem/air/proc/has_same_air(turf/A, turf/B)
	if(A.oxygen != B.oxygen) return 0
	if(A.nitrogen != B.nitrogen) return 0
	if(A.phoron != B.phoron) return 0
	if(A.carbon_dioxide != B.carbon_dioxide) return 0
	if(A.temperature != B.temperature) return 0
	return 1

/datum/subsystem/air/proc/remove_edge(connection/c)
	edges.Remove(c)

/datum/subsystem/air/proc/setup_allturfs(z_level)
	var/z_start = 1
	var/z_finish = world.maxz

	if(1 <= z_level && z_level <= world.maxz)
		z_level = round(z_level)
		z_start = z_level
		z_finish = z_level

	var/list/turfs_to_init = block(locate(1, 1, z_start), locate(world.maxx, world.maxy, z_finish))

	for(var/turf/simulated/T in turfs_to_init)
		T.update_air_properties()
		CHECK_TICK

/datum/subsystem/air/proc/setup_pipenets(z_level)
	for(var/obj/machinery/atmospherics/AM in machines)
		if (z_level && AM.z != z_level)
			continue
		AM.build_network()
		CHECK_TICK

/datum/subsystem/air/proc/setup_atmos_machinery(z_level)
	for(var/obj/machinery/atmospherics/unary/AM in machines)
		if (z_level && AM.z != z_level)
			continue
		if(istype(AM, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = AM
			T.broadcast_status()
		else if(istype(AM, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = AM
			T.broadcast_status()
		CHECK_TICK

//from /tg/ SSair for templates
/datum/subsystem/air/proc/setup_template_machinery(list/atmos_machines)
	for(var/A in atmos_machines)
		if(!istype(A,/obj/machinery/atmospherics/unary))
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
