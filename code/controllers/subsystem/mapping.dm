var/datum/subsystem/mapping/SSmapping

// How many structures will be spawned
#define SPACE_STRUCTURES_AMMOUNT 7
// Structures will spawn on zlevels 3 and 4
#define SPACE_STRUCTURES_ZLEVELS list(ZLEVEL_TELECOMMS, ZLEVEL_DERELICT)
// Uncomment to enable debug output of structure coords
//#define SPACE_STRUCTURES_DEBUG 1

/datum/subsystem/mapping
	name = "Mapping"
	init_order = SS_INIT_MAPPING
	flags = SS_NO_FIRE

	var/const/max_secret_rooms = 3
	var/list/spawned_structures = list()

/datum/subsystem/mapping/New()
	NEW_SS_GLOBAL(SSmapping)

/datum/subsystem/mapping/Initialize(timeofday)
	// Generate mining.
	make_mining_asteroid_secrets()
	populate_distribution_map()
	// Load templates
	preloadTemplates()
	// Space structures
	spawn_space_structures()
	..()

/datum/subsystem/mapping/proc/make_mining_asteroid_secrets()
	for(var/i in 1 to max_secret_rooms)
		make_mining_asteroid_secret()

/datum/subsystem/mapping/proc/populate_distribution_map()
	var/datum/ore_distribution/distro = new
	distro.populate_distribution_map()

/datum/subsystem/mapping/proc/spawn_space_structures()
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

/datum/subsystem/mapping/proc/find_spot(datum/map_template/space_structure/structure)
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

/datum/subsystem/mapping/Recover()
	flags |= SS_NO_INIT

#undef SPACE_STRUCTURES_AMMOUNT
#undef SPACE_STRUCTURES_ZLEVELS
