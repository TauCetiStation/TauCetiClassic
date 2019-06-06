var/datum/subsystem/space_structures/SSspaceStructures

// How many structures will be spawned
#define SPACE_STRUCTURES_AMMOUNT 7
// Structures will spawn on zlevels 3 and 4
#define SPACE_STRUCTURES_ZLEVELS list(ZLEVEL_TELECOMMS, ZLEVEL_DERELICT)
// Uncomment to enable debug output of structure coords
//#define SPACE_STRUCTURES_DEBUG 1

/datum/subsystem/space_structures
	name = "Space Structures"
	init_order = SS_INIT_SPACESTRUCTURES
	flags = SS_NO_FIRE

	var/list/spawned_structures = list()

/datum/subsystem/space_structures/New()
	NEW_SS_GLOBAL(SSspace_structures)

/datum/subsystem/space_structures/Initialize(timeofday)
	// picking structures to spawn
	var/list/possible = list()
	for(var/structure_id in spacestructures_templates)
		possible += structure_id

	var/list/picked_structures = list()
	while(possible.len && picked_structures.len < SPACE_STRUCTURES_AMMOUNT)
		var/structure_id = pick(possible)
		possible -= structure_id
		picked_structures += structure_id

	// structure spawning
	for (var/structure_id in picked_structures)
		var/datum/map_template/space_structure/structure = spacestructures_templates[structure_id]

		var/turf/T = find_spot(structure)
		if(T)
			// coords might point to any turf inside the structure
			var/xcoord = T.x + rand(-structure.width / 2, structure.width / 2)
			var/ycoord = T.y + rand(-structure.height / 2, structure.height / 2)
			spawned_structures += list(list("id" = structure_id, "desc" = structure.desc, "turf" = T, "x" = xcoord, "y" = ycoord, "z" = T.z))
			structure.load(T, centered = TRUE)
#ifdef SPACE_STRUCTURES_DEBUG
			message_admins("[structure_id] was created in [T.x],[T.y],[T.z] [ADMIN_JMP(T)]")
#endif

	// spawning paper with coordinates
	var/paper_text = "<center><img src = bluentlogo.png /><br /><font size = 3><b>NSS Exodus</b> Sensor Readings:</font></center><br /><hr>"
	paper_text += "Scan results show the following points of interest:<br />"
	for(var/list/structure in spawned_structures)
		paper_text += "<li><b>[structure["desc"]]</b>: x = [structure["x"]], y = [structure["y"]], z = [structure["z"]]</li>"
	paper_text += "<hr>"

	for(var/obj/effect/landmark/C in landmarks_list)
		if(C.name == "spacestructures_paper")
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(C.loc)
			P.name = "NSS Exodus Sensor Readings"
			P.info = paper_text
			P.updateinfolinks()
			P.update_icon()

	..()

/datum/subsystem/space_structures/proc/find_spot(datum/map_template/space_structure/structure)
	var/structure_size = ceil(max(structure.width / 2, structure.height / 2))
	for (var/try_count in 1 to 10)
		var/turf/space/T = locate(rand(structure.width, world.maxx - structure.width), rand(structure.height, world.maxy - structure.height), pick(SPACE_STRUCTURES_ZLEVELS))
		if(!istype(T))
			continue

		if(locate(/turf/simulated) in orange(structure_size, T))
			continue
		if(locate(/obj) in orange(structure_size, T))
			continue

		return T
#ifdef SPACE_STRUCTURES_DEBUG
	message_admins("Couldn't find position for [structure.structure_id]")
#endif
	return null



/datum/map_template/space_structure
	var/structure_id
	var/desc // what is displayed on a sensor reading paper

/datum/map_template/space_structure/clown_shuttle
	name = "Clown Shuttle"
	structure_id = "clown_shuttle"
	desc = "Debris of an unknown shuttle"
	mappath = "maps/templates/space_structures/clown_shuttle.dmm"

/datum/map_template/space_structure/derelict_station
	name = "Derelict Station"
	structure_id = "derelict_station"
	desc = "Unknown huge object"
	mappath = "maps/templates/space_structures/derelict_station.dmm"

/datum/map_template/space_structure/dj_station
	name = "DJ Station"
	structure_id = "dj_station"
	desc = "Unknown huge object"
	mappath = "maps/templates/space_structures/dj_station.dmm"

/datum/map_template/space_structure/derelict_teleporter
	name = "Derelict Teleporter"
	structure_id = "derelict_teleporter"
	desc = "Unknown debris"
	mappath = "maps/templates/space_structures/derelict_teleporter.dmm"

/datum/map_template/space_structure/space_toilet
	name = "Space Toilet"
	structure_id = "space_toilet"
	desc = "Unknown debris"
	mappath = "maps/templates/space_structures/toilet.dmm"

/datum/map_template/space_structure/abandoned_ship
	name = "Abandoned Ship"
	structure_id = "abandoned_ship"
	desc = "Debris of an unknown shuttle"
	mappath = "maps/templates/space_structures/abandoned_ship.dmm"

/datum/map_template/space_structure/teleporter
	name = "teleporter"
	structure_id = "teleporter"
	desc = "Unknown debris"
	mappath = "maps/templates/space_structures/teleporter.dmm"

#undef SPACE_STRUCTURES_AMMOUNT
#undef SPACE_STRUCTURES_ZLEVELS
