/* Sood's Statistics Collection Project
	If you feel that there is some data that aught to be collected, feel free to make a PR to change
	this code. Be aware, however, that if the web server is not updated to handle new data formats,
	it will not properly use this information, or may cause the data to be discarded as invalid.
	In short, please ensure the web server is updated before merging changes to these files.

	When making additions, changes or removals to any of the data that is exported here, please change
	STAT_OUTPUT_VERSION. This allows me to easily handle new versions of data on the web server side.
*/

// Space Station Statistics
var/global/datum/stat_collector/SSStatistics = new /datum/stat_collector

// To ensure that if output file syntax is changed, we will still be able to process
// new and old files
// please increment this version whenever making changes
#define STAT_OUTPUT_VERSION 2
#define STAT_FILE_NAME "stat.json"

/datum/stat_collector
	var/round_id
	var/start_time
	var/end_time
	var/duration
	var/mode
	var/mode_result
	var/map

	var/completion_html
	// Deprecated
	var/list/datum/stat/antagonists_completion/completion_antagonists = list()

	var/datum/stat/score/score = new /datum/stat/score
	var/list/datum/stat/achievement/achievements = list()
	var/list/datum/stat/centcomm_communication/centcomm_communications = list()






	var/const/data_revision = STAT_OUTPUT_VERSION
	// UNUSED
	// var/enabled = 1
	//var/list/datum/stat/death_stat/deaths = list()
	//var/list/datum/stat/explosion_stat/explosions = list()
	//var/list/survivors = list()
	//var/list/uplink_purchases = list()
	//var/list/badass_bundles = list()
	//var/list/antag_objectives = list()
	//var/list/manifest_entries = list()
	//var/list/datum/stat/role/roles = list()
	//var/list/datum/stat/faction/factions = list()
//
	//// Blood spilled in c.liters
	//var/blood_spilled = 0
	//var/crates_ordered = 0
	//var/artifacts_discovered = 0
	//var/narsie_corpses_fed = 0
	//var/crew_score = 0
	//var/nuked = FALSE
	//var/borgs_at_round_end = 0
	//var/heads_at_round_end = 0
//
//
	//// GAMEMODE-SPECIFIC STATS START HERE
	//var/datum/stat/dynamic_mode/dynamic_stats = null
//
	//// THESE MUST BE SET IN POSTROUNDCHECKS OR SOMEWHERE ELSE BEFORE THAT IS CALLED
	//var/round_start_time = null
	//var/round_end_time = null
	//var/map_name = null
	//var/tech_total = 0
	//var/station_name = null

/datum/stat_collector/proc/drop_round_stats(stealth = FALSE)
	var/statfile = file("[global.log_directory]/[STAT_FILE_NAME]")
	if(length(statfile))
		fdel(statfile)
		statfile = file("[global.log_directory]/[STAT_FILE_NAME]")

	do_post_round_checks()

	var/start_time = world.realtime
	WRITE_FILE(statfile, datum2json(src))
	to_chat(stealth ? usr : world, "<span class='info'>Статистика была записана в файл за [(start_time - world.realtime)/10] секунд. </span>")

	to_chat(stealth ? usr : world, "<span class='info'>Статистика по этому раунду вскоре будет доступа по ссылке [generate_url()]</span>")

/datum/stat_collector/proc/generate_url()
	var/root = "https://stat.taucetistation.org/html"
	var/list/date = splittext(time2text(world.realtime, "YYYY-MM-DD"), "-")
	return "[root]/[date[1]]/[date[2]]/[date[3]]/round-[global.round_id]/[STAT_FILE_NAME]"

/datum/stat_collector/proc/do_post_round_checks()
	round_id = global.round_id
	start_time = time2text(round_start_realtime, "hh:mm:ss")
	end_time = time2text(world.realtime, "hh:mm:ss")
	duration = roundduration2text()
	mode = SSticker.mode.name
	mode_result = SSticker.mode.get_mode_result()
	map = SSmapping.config.map_name
	completion_html = SSticker.mode.completition_text

/datum/stat
	// Hello. Nothing to see here.

// Deprecated
/datum/stat/antagonists_completion
	var/faction
	var/role
	var/html

/datum/stat/centcomm_communication
	var/__type
	var/title
	var/author
	var/time
	var/content

/datum/stat/achievement
	var/key
	var/name
	var/title
	var/desc

/datum/stat/score
	var/crewscore      = 0 // this is the overall var/score for the whole round
	var/rating         = "Nothing of Value" // crewscore but string
	var/stuffshipped   = 0 // how many useful items have cargo shipped out?
	var/stuffharvested = 0 // how many harvests have hydroponics done?
	var/oremined       = 0 // obvious
	var/researchdone   = 0
	var/eventsendured  = 0 // how many random events did the station survive?
	var/powerloss      = 0 // how many APCs have poor charge?
	var/mess           = 0 // how much poo, puke, gibs, etc went uncleaned
	var/meals          = 0
	var/disease        = 0 // how many rampant, uncured diseases are on board the station
	var/deadcommand    = 0 // used during rev, how many command staff perished
	var/arrested       = 0 // how many traitors/revs/whatever are alive in the brig
	var/traitorswon    = 0 // how many traitors were successful?
	var/roleswon       = 0 // how many roles were successful?
	var/allarrested    = 0 // did the crew catch all the enemies alive?
	var/opkilled       = 0 // used during nuke mode, how many operatives died?
	var/disc           = 0 // is the disc safe and secure?
	var/nuked          = 0 // was the station blown into little bits?
	var/destranomaly   = 0 // anomaly of cult
	var/rec_antags     = 0 // How many antags did we reconvert

	//crew
	var/crew_escaped   = 0      // how many people got out alive?
	var/crew_dead      = 0      // dead bodies on the station, oh no
	var/crew_total     = 0      // how many people was registred as crew
	var/crew_survived  = 0      // how many people was registred as crew
	var/captain        = list() // who was captain of the shift (or captains?...)

	// these ones are mainly for the stat panel
	var/powerbonus    = 0 // if all APCs on the station are running optimally, big bonus
	var/messbonus     = 0 // if there are no messes on the station anywhere, huge bonus
	var/deadaipenalty = 0 // is the AI dead? if so, big penalty
	var/foodeaten     = 0 // nom nom nom
	var/clownabuse    = 0 // how many times a clown was punched, struck or otherwise maligned
	var/richestname   = 0 // this is all stuff to show who was the richest alive on the shuttle
	var/richestjob    = 0 // kinda pointless if you dont have a money system i guess
	var/richestcash   = 0
	var/richestkey    = 0
	var/dmgestname    = 0 // who had the most damage on the shuttle (but was still alive)
	var/dmgestjob     = 0
	var/dmgestdamage  = 0
	var/dmgestkey     = 0


/datum/stat/death_stat
	var/mob_typepath = null
	var/death_x = 0
	var/death_y = 0
	var/death_z = 0
	var/time_of_death = 0
	var/special_role = null
	var/assigned_role = null
	var/key = null
	var/mind_name = null
	var/from_suicide = 0
	var/list/damage = list(
		"BRUTE" = 0,
		"FIRE" = 0,
		"TOXIN" = 0,
		"OXY" = 0,
		"CLONE" = 0,
		"BRAIN" = 0)

// this literally only exists because it's easier for me to serialize this way
/datum/stat/survivor
	var/mob_typepath = null
	var/special_role = null
	var/assigned_role = null
	var/key = null
	var/mind_name = null
	var/escaped = FALSE
	var/list/damage = list(
		"BRUTE" = 0,
		"FIRE" = 0,
		"TOXIN" = 0,
		"OXY" = 0,
		"CLONE" = 0,
		"BRAIN" = 0)
	var/loc_x = 0
	var/loc_y = 0
	var/loc_z = 0

/datum/stat/antag_objective
	var/mind_name = null
	var/key = null
	var/special_role = null
	var/objective_type = null
	var/objective_desc = null
	var/objective_succeeded = FALSE
	var/target_name = null
	var/target_role = null

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

/datum/stat/explosion_stat
	var/epicenter_x = 0
	var/epicenter_y = 0
	var/epicenter_z = 0
	var/devastation_range = 0
	var/heavy_impact_range = 0
	var/light_impact_range = 0

/datum/stat/manifest_entry
	var/key = null
	var/name = null
	var/assignment = null

// redo using mind list instead so we can get non-human players in its output
/datum/stat/manifest_entry/New(datum/mind/M)
	key = ckey(M.key)
	name = STRIP_NEWLINE(M.name)
	assignment = STRIP_NEWLINE(M.assigned_role)
