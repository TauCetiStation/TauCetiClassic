//used for holding information about unique properties of maps

/datum/map_config
	// Metadata
	var/config_filename = "maps/boxstation.json"
	var/defaulted = TRUE  // set to FALSE by LoadConfig() succeeding

	// Config actually from the JSON - should default to Box
	var/map_name = "Box Station"
	var/map_path = "boxstation"
	var/map_file = "boxstation.dmm"
	var/station_name = "NSS Exodus"
	var/system_name = "Tau Ceti"
	var/station_image = "exodus"

	// Config from maps.txt
	var/config_max_users = 0
	var/config_min_users = 0

	var/traits = null
	var/space_ruin_levels = 2
	var/space_empty_levels = 1
	var/load_junkyard = TRUE

	var/minetype = "asteroid"

/proc/load_map_config(filename = "data/next_map.json", default_to_box, delete_after, error_if_missing = TRUE)
	var/datum/map_config/config = new
	if (global.config.load_testmap)
		filename = "maps/testmap.json"
	if (default_to_box)
		return config
	if (!config.LoadConfig(filename, error_if_missing))
		qdel(config)
		config = new /datum/map_config  // Fall back to Box
	if (delete_after)
		fdel(filename)
	return config

#define CHECK_EXISTS(X) if(!istext(json[X])) { error("[##X] missing from json!"); return; }
/datum/map_config/proc/LoadConfig(filename, error_if_missing)
	if(!fexists(filename))
		if(error_if_missing)
			error("map_config not found: [filename]")
		return

	var/json = file(filename)
	if(!json)
		error("Could not open map_config: [filename]")
		return

	json = file2text(json)
	if(!json)
		error("map_config is not text: [filename]")
		return

	json = json_decode(json)
	if(!json)
		error("map_config is not json: [filename]")
		return

	config_filename = filename

	CHECK_EXISTS("map_name")
	map_name = json["map_name"]
	CHECK_EXISTS("map_path")
	map_path = json["map_path"]

	map_file = json["map_file"]
	// "map_file": "BoxStation.dmm"
	if (istext(map_file))
		if (!fexists("maps/[map_path]/[map_file]"))
			error("Map file ([map_path]/[map_file]) does not exist!")
			return
	// "map_file": ["Lower.dmm", "Upper.dmm"]
	else if (islist(map_file))
		for (var/file in map_file)
			if (!fexists("maps/[map_path]/[file]"))
				error("Map file ([map_path]/[file]) does not exist!")
				return
	else
		error("map_file missing from json!")
		return

	traits = json["traits"]
	// "traits": [{"Linkage": "Cross"}, {"Space Ruins": true}]
	if (islist(traits))
		// "Station" is set by default, but it's assumed if you're setting
		// traits you want to customize which level is cross-linked
		for (var/level in traits)
			if (!(ZTRAIT_STATION in level))
				level[ZTRAIT_STATION] = TRUE
	// "traits": null or absent -> default
	else if (!isnull(traits))
		error("map_config traits is not a list!")
		return

	var/temp = json["space_ruin_levels"]
	if (isnum(temp))
		space_ruin_levels = temp
	else if (!isnull(temp))
		error("map_config space_ruin_levels is not a number!")
		return

	temp = json["space_empty_levels"]
	if (isnum(temp))
		space_empty_levels = temp
	else if (!isnull(temp))
		error("map_config space_empty_levels is not a number!")
		return

	temp = json["load_junkyard"]
	if (isnum(temp))
		load_junkyard = temp
	else if (!isnull(temp))
		error("map_config load_junkyard is not a number!")
		return

	if ("minetype" in json)
		minetype = json["minetype"]

	if ("station_name" in json)
		station_name = json["station_name"]

	if ("system_name" in json)
		system_name = json["system_name"]

	if("station_image" in json)
		station_image = json["station_image"]

	defaulted = FALSE
	return TRUE
#undef CHECK_EXISTS

/datum/map_config/proc/GetFullMapPaths()
	if (istext(map_file))
		return list("maps/[map_path]/[map_file]")
	. = list()
	for (var/file in map_file)
		. += "maps/[map_path]/[file]"

/datum/map_config/proc/MakeNextMap()
	return config_filename == "data/next_map.json" || fcopy(config_filename, "data/next_map.json")
