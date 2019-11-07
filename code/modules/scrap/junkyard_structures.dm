/datum/map_template/junkyard_structure
	var/structure_id
	var/blacklisted_turfs
	var/banned_areas

/datum/map_template/junkyard_structure/New()
	. = ..()
	blacklisted_turfs = typecacheof(/turf/unsimulated)
	blacklisted_turfs += typecacheof(/turf/simulated/mineral)
	blacklisted_turfs += typecacheof(/turf/simulated/shuttle)
	blacklisted_turfs += typecacheof(/turf/simulated/wall)
	banned_areas = typecacheof(/area/shuttle)
	banned_areas += typecacheof(/area/holodeck)
	banned_areas += typecacheof(/area/vox_station)
	banned_areas += typecacheof(/area/syndicate_station)
	banned_areas += typecacheof(/area/supply)

/datum/map_template/junkyard_structure/proc/check_deploy(turf/deploy_location)
	var/affected = get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/T in affected)
		var/area/A = get_area(T)
		if(is_type_in_typecache(A, banned_areas))
			return FALSE

		var/banned = is_type_in_typecache(T, blacklisted_turfs)
		if(banned)
			return FALSE

		for(var/obj/O in T)
			if(O.density && O.anchored)
				return FALSE
	return TRUE

/datum/map_template/junkyard_structure/broken_teleporter
	structure_id = "broken_teleporter_junkyard"
	mappath = "maps/templates/junkyard_structures/broken_teleporter.dmm"

/datum/map_template/junkyard_structure/broken_cloning_lab
	structure_id = "broken_cloning_lab_junkyard"
	mappath = "maps/templates/junkyard_structures/cloning_lab.dmm"

/datum/map_template/junkyard_structure/garden
	structure_id = "garden_junkyard"
	mappath = "maps/templates/junkyard_structures/garden.dmm"

/datum/map_template/junkyard_structure/old_ship
	structure_id = "old_ship_junkyard"
	mappath = "maps/templates/junkyard_structures/old_ship.dmm"

/datum/map_template/junkyard_structure/planetarium
	structure_id = "planetarium_junkyard"
	mappath = "maps/templates/junkyard_structures/planetarium.dmm"

/datum/map_template/junkyard_structure/smelter
	structure_id = "smelter_junkyard"
	mappath = "maps/templates/junkyard_structures/smelter.dmm"

/obj/effect/junkyard_structure_generator
	name = "junkyard structure generator"
	var/datum/map_template/junkyard_structure/template

/obj/effect/junkyard_structure_generator/atom_init(mapload, heap_size = 1)
	. = ..()
	template = pick(structures_junkyard_templates)
	var/turf/T = get_turf(src)
	T = get_turf(src)
	var/status = template.check_deploy(T)
	if(status)
		template.load(T, centered = TRUE)
	qdel(src)

/obj/effect/junkyard_structure_generator/Destroy()
	template = null
	. = ..()
