/datum/map_template
	var/name = "Default Template Name"
	var/width = 0
	var/height = 0
	var/mappath = null
	var/mapfile = null
	var/loaded = 0 // Times loaded this round
	var/list/loaded_stuff = list()

/datum/map_template/New(path = null, map = null, rename = null)
	if(path)
		mappath = path
	if(mappath)
		preload_size(mappath)
	if(map)
		mapfile = map
	if(rename)
		name = rename

/datum/map_template/proc/preload_size(path)
	loaded_stuff = maploader.load_map(file(path), 1, 1, 1, cropMap=FALSE, measureOnly=TRUE)
	if(loaded_stuff && loaded_stuff.len)
		var/list/bounds = loaded_stuff["bounds"]
		if(bounds && bounds.len)
			width = bounds[MAP_MAXX] // Assumes all templates are rectangular, have a single Z level, and begin at 1,1,1
			height = bounds[MAP_MAXY]
			. = bounds
			loaded_stuff.Cut()
		else
			. = null
	else
		. = null

/proc/initTemplateBounds(list/bounds)
	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/atoms = list()

	for(var/L in block(locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
	                   locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])))
		var/turf/B = L
		for(var/A in B)
			atoms += A
			if(istype(A,/obj/structure/cable))
				cables += A
				continue
			if(istype(A,/obj/machinery/atmospherics))
				atmos_machines += A
				continue

	SSobj.setup_template_objects(atoms)
	SSmachine.setup_template_powernets(cables)
	SSair.setup_template_machinery(atmos_machines)

/datum/map_template/proc/load(turf/T, centered = FALSE)
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
	if(!T)
		return
	if(T.x+width > world.maxx)
		return
	if(T.y+height > world.maxy)
		return

	loaded_stuff = maploader.load_map(get_file(), T.x, T.y, T.z, cropMap=TRUE)
	if(!loaded_stuff || !loaded_stuff.len)
		return 0

	var/list/bounds = loaded_stuff["bounds"]
	if(!bounds || !bounds.len)
		return 0

	var/list/stuff = loaded_stuff["stuff"]
	. = stuff
	//initialize things that are normally initialized after map load
	initTemplateBounds(bounds)

	log_game("[name] loaded at at [T.x],[T.y],[T.z]")
	loaded_stuff.Cut()

/datum/map_template/proc/get_file()
	if(mapfile)
		. = mapfile
	else if(mappath)
		. = file(mappath)

	if(!.)
		world.log << "The file of [src] appears to be empty/non-existent."

/datum/map_template/proc/get_affected_turfs(turf/T, centered = FALSE)
	var/turf/placement = T
	if(centered)
		var/turf/corner = locate(placement.x - round(width/2), placement.y - round(height/2), placement.z)
		if(corner)
			placement = corner
	return block(placement, locate(placement.x+width-1, placement.y+height-1, placement.z))


/proc/preloadTemplates(path = "maps/templates/") //see master controller setup
	var/list/filelist = flist(path)
	for(var/map in filelist)
		var/datum/map_template/T = new /datum/map_template(path = "[path][map]", rename = "[map]")
		map_templates[T.name] = T

	preloadShelterTemplates()
	preloadHolodeckTemplates()
	//preloadRuinTemplates()		//This all can be usefull, but not now
	//preloadShuttleTemplates()

/*
/proc/preloadRuinTemplates()
	// Still supporting bans by filename
	var/list/banned = list()
//	generateMapList("config/lavaRuinBlacklist.txt")
//	banned += generateMapList("config/spaceRuinBlacklist.txt")

	for(var/item in subtypesof(/datum/map_template/ruin))
		var/datum/map_template/ruin/ruin_type = item
		// screen out the abstract subtypes
		if(!initial(ruin_type.id))
			continue
		var/datum/map_template/ruin/R = new ruin_type()

		if(banned.Find(R.mappath))
			continue

		map_templates[R.name] = R
		ruins_templates[R.name] = R

		if(istype(R, /datum/map_template/ruin/lavaland))
			lava_ruins_templates[R.name] = R
		else if(istype(R, /datum/map_template/ruin/space))
			space_ruins_templates[R.name] = R


/proc/preloadShuttleTemplates()
	for(var/item in subtypesof(/datum/map_template/shuttle))
		var/datum/map_template/shuttle/shuttle_type = item
		if(!(initial(shuttle_type.suffix)))
			continue

		var/datum/map_template/shuttle/S = new shuttle_type()

		shuttle_templates[S.shuttle_id] = S
		map_templates[S.shuttle_id] = S
*/

/proc/preloadHolodeckTemplates()
	for(var/item in subtypesof(/datum/map_template/holoscene))
		var/datum/map_template/holoscene/holoscene_type = item
		if(!(initial(holoscene_type.mappath)))
			continue
		var/datum/map_template/holoscene/S = new holoscene_type()
		holoscene_templates[S.id()] = S
		map_templates[S.id()] = S


/proc/preloadShelterTemplates()
	for(var/item in subtypesof(/datum/map_template/shelter))
		var/datum/map_template/shelter/shelter_type = item
		if(!(initial(shelter_type.mappath)))
			continue
		var/datum/map_template/shelter/S = new shelter_type()
		shelter_templates[S.id()] = S
		map_templates[S.id()] = S
