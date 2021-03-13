
var/datum/stat_collector/stat_collection = new

// To ensure that if output file syntax is changed, we will still be able to process
// new and old files
// please increment this version whenever making changes
#define STAT_OUTPUT_VERSION "1.4.0"

/datum/stat_collector
	var/const/data_revision = STAT_OUTPUT_VERSION

	var/list/survivors = list()
	var/list/uplink_purchases = list()
	var/list/badass_bundles = list()
	var/list/antag_objectives = list()
	var/list/manifest_entries = list()
	var/list/datum/stat/role/roles = list()
	var/list/datum/stat/faction/factions = list()

	// Blood spilled in c.liters
	var/blood_spilled = 0
	var/crates_ordered = 0
	var/artifacts_discovered = 0
	var/narsie_corpses_fed = 0
	var/crew_score = 0
	var/nuked = FALSE
	var/borgs_at_round_end = 0
	var/heads_at_round_end = 0


	// GAMEMODE-SPECIFIC STATS START HERE
	var/datum/stat/dynamic_mode/dynamic_stats = null

	// THESE MUST BE SET IN POSTROUNDCHECKS OR SOMEWHERE ELSE BEFORE THAT IS CALLED
	var/round_start_time = null
	var/round_end_time = null
	var/map_name = null
	var/station_name = null

// the main file for statistics is statcollection.dm, look there first

// functions related to handling/collecting data, and not writing data specifically
// so I can't get timestamp info so unfortunately I can't do anything like ISO standards
// at least I can keep the format consistent though
#define STAT_TIMESTAMP_FORMAT "YYYY-MM-DD hh:mm:ss"

/datum/stat_collector/proc/uplink_purchase(datum/uplink_item/bundle, obj/resulting_item, mob/user )
	var/was_traitor = TRUE
	if(SSticker.current_state != GAME_STATE_PLAYING)
		return

	if(istype(bundle, /datum/uplink_item/badass/bundle))
		var/datum/stat/uplink_badass_bundle_stat/BAD = new
		var/obj/item/weapon/storage/box/B = resulting_item
		for(var/obj/O in B.contents)
			BAD.contains.Add(O.type)
		BAD.purchaser_key = ckey(user.mind.key)
		BAD.purchaser_name = STRIP_NEWLINE(user.mind.name)
		BAD.purchaser_is_traitor = was_traitor
		badass_bundles.Add(BAD)
	else
		var/datum/stat/uplink_purchase_stat/PUR = new
		if(istype(bundle, /datum/uplink_item/badass/random))
			PUR.itemtype = resulting_item.type
		else
			PUR.itemtype = bundle.item
		PUR.bundle = bundle.type
		PUR.purchaser_key = ckey(user.mind.key)
		PUR.purchaser_name = STRIP_NEWLINE(user.mind.name)
		PUR.purchaser_is_traitor = was_traitor
		uplink_purchases.Add(PUR)

/datum/stat_collector/proc/add_role(datum/role/R)
	//R.stat_datum.generate_statistics(R)
	//roles.Add(R.stat_datum)

/datum/stat_collector/proc/add_faction(datum/faction/F)
	//F.stat_datum.generate_statistics(F)
	//factions.Add(F.stat_datum)

/datum/stat_collector/proc/do_post_round_checks()
	// grab some variables
	round_start_time = time2text(round_start_time, STAT_TIMESTAMP_FORMAT)
	round_end_time   = time2text(world.realtime,   STAT_TIMESTAMP_FORMAT)
	map_name = SSmapping.config.map_name
	nuked = SSticker.station_was_nuked
	station_name = station_name()

/datum/stat_collector/proc/get_valid_file(extension = "json")
	var/filename_date = time2text(round_start_time, "YYYY-MM-DD")
	var/uniquefilename = time2text(round_start_time, "hhmmss")
	// Iterate until we have an unused file.
	while(fexists(file(("[global.log_directory]statistics-[filename_date].[uniquefilename].[extension]"))))
		uniquefilename = "[uniquefilename].dupe"
	return file("[global.log_directory]statistics-[filename_date].[uniquefilename].[extension]")

/datum/stat_collector/proc/Process()
	var/statfile = get_valid_file("json")

	do_post_round_checks()

	to_chat(world, "Writing statistics to file")
	var/start_time = world.realtime
	var/jsonout = datum2json(src)
	statfile << jsonout
	world.log << "Statistics written to file in [(start_time - world.realtime)/10] seconds."

#undef STAT_TIMESTAMP_FORMAT

/datum/stat
	// Hello. Nothing to see here.

// General role-related stats
/datum/stat/role
	var/name = null
	var/faction_id = null
	var/mind_name = null
	var/mind_key = null
	var/list/objectives = list()
	var/victory = FALSE

/datum/stat/role/proc/generate_statistics(datum/role/R)
	name = R.name
	if(R.faction)
		faction_id = R.faction.ID
	else
		faction_id = 0
	mind_name = STRIP_NEWLINE(R.antag.name)
	mind_key = ckey(R.antag.key)
	victory = R.IsSuccessful()

	for(var/datum/objective/O in R.objectives.GetObjectives())
		objectives.Add(new /datum/stat/role_objective(O))

/datum/stat/role_objective
	var/obj_type = null
	var/name = null
	var/desc = null
	var/owner_key = null // used when factionless antags happen (vampires)
	var/belongs_to_faction = null
	var/target = null
	var/target_amount = null
	var/list/protected_jobs = null
	var/is_fulfilled = FALSE

/datum/stat/role_objective/New(datum/objective/O)
	obj_type = O.type
	target_amount = O.target_amount
	protected_jobs = O.protected_jobs
	desc = O.explanation_text
	belongs_to_faction = O.faction?.ID
	is_fulfilled = O.check_completion()
	target = O.target.name
	if(O.owner)
		owner_key = ckey(O.owner.key)

// Faction related stats
/datum/stat/faction
	var/id = null
	var/name = null
	var/desc = null
	var/faction_type = null // typepath
	var/stage = null
	var/victory = FALSE
	var/minor_victory = FALSE

/datum/stat/faction/proc/generate_statistics(datum/faction/F)
	id = F.ID
	name = capitalize(F.name)
	desc = F.desc
	faction_type = F.type
	stage = F.stage
	// I could combine these victory values, but I'd rather have future-proofing
	minor_victory = F.minor_victory
	victory = F.IsSuccessful()

/datum/stat/uplink_purchase_stat
	var/itemtype = null
	var/bundle = null
	var/purchaser_key = null
	var/purchaser_name = null
	var/purchaser_is_traitor = TRUE

/datum/stat/uplink_badass_bundle_stat
	var/list/contains = list()
	var/purchaser_key = null
	var/purchaser_name = null
	var/purchaser_is_traitor = TRUE

/datum/stat/manifest_entry
	var/key = null
	var/name = null
	var/assignment = null

// redo using mind list instead so we can get non-human players in its output
/datum/stat/manifest_entry/New(var/datum/mind/M)
	key = ckey(M.key)
	name = STRIP_NEWLINE(M.name)
	assignment = STRIP_NEWLINE(M.assigned_job)

/datum/stat/faction/blob
	// count of all blob tiles grown, includes structures built on top of blob tiles
	var/blobs_grown_total = 0
	// same as above, but only living blob tiles
	var/blobs_round_end = 0
	// count of all built structures
	var/datum/stat/faction_data/blob/structure_counts/built_structures = new

/datum/stat/faction/blob/generate_statistics(var/datum/faction/blob_conglomerate/BF)
	..(BF)
	//we're using global pre-existing global vars here: structure counts are collected
	//throughout the round elsewhere
	blobs_grown_total = blob_tiles_grown_total
	blobs_round_end = blobs.len

/datum/stat/faction_data/blob/structure_counts
	var/factories = 0
	var/nodes = 0
	var/resgens = 0
	var/shields = 0
	var/cores = 0
