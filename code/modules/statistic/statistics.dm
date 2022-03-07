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

// You can find migration of statistics here
// https://github.com/TauCetiStation/TauCetiClassic/commits/master/code/modules/statistic/statistics.dm

// To ensure that if output file syntax is changed, we will still be able to process
// new and old files
// please increment this version whenever making changes
#define STAT_OUTPUT_VERSION 3
#define STAT_FILE_NAME "stat.json"

// Documentation rules:
//  * First write the type of data
//  * Then write the format of data in square brackets or data pool in square brackets or comments
//  * At the end, write any comment about the variable
/datum/stat_collector
	// int, [2...]
	var/const/version = STAT_OUTPUT_VERSION
	// int, [1...]
	var/round_id
	// string, [hh:mm:ss]
	var/start_time
	// string, [hh:mm:ss]
	var/end_time
	// string, [hh:mm]
	var/duration
	// string, pool in ./code/game/gamemodes/modes_declares/ in var name
	var/mode
	// string, ["win", "lose"], shows whether all objectives of all antagonists' are completed
	var/mode_result
	// string, pool in ./maps/ directory in json files in var map_name
	var/map
	// You can get the nanoui map using
	// "https://cdn.jsdelivr.net/gh/TauCetiStation/TauCetiClassic@" + base_commit_sha + "/" + minimap_image
	// string, pool in ./maps/ directory in json files in var station_image
	var/minimap_image
	// string, ["byond://game.taucetistation.org:[2506, 2507, 2508]"]
	var/server_address
	// string, sha
	var/base_commit_sha
	// string, ["#pr_id #pr_id..."]
	var/test_merges

	// string, html page
	var/completion_html

	// object
	var/datum/stat/score/score = new /datum/stat/score
	// array of objects
	var/list/datum/stat/achievement/achievements = list()
	// array of objects
	var/list/datum/stat/communication_log/communication_logs = list()

	// New data
	// array of objects
	var/list/datum/stat/death_stat/deaths = list()
	// array of objects
	var/list/datum/stat/explosion_stat/explosions = list()
	// array of objects
	var/list/datum/stat/manifest_entry/manifest_entries = list()
	// array of objects
	var/list/datum/stat/leave_stat/leave_stats = list()
	// array of objects
	var/list/datum/stat/role/orphaned_roles = list()
	// array of objects
	var/list/datum/stat/faction/factions = list()

/datum/stat_collector/New()
	var/datum/default_datum = new
	ROOT_DATUM_VARS = default_datum.vars.Copy()
	qdel(default_datum)

/datum/stat_collector/proc/drop_round_stats(stealth = FALSE)
	var/statfile = file("[global.log_directory]/[STAT_FILE_NAME]")
	if(length(statfile))
		fdel(statfile)
		statfile = file("[global.log_directory]/[STAT_FILE_NAME]")

	do_post_round_checks()

	var/start_time = world.realtime
	statfile << datum2json(src)
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
	minimap_image = "nano/images/nanomap_[SSmapping.station_image]_1.png"
	server_address = BYOND_SERVER_ADDRESS
	base_commit_sha = global.base_commit_sha
	test_merges = global.test_merges
	completion_html = SSticker.mode.completition_text

	for(var/datum/mind/M in SSticker.minds)
		add_manifest_entry(M.key, M.name, M.assigned_role, M.special_role, M.antag_roles)

	for(var/ckey in global.disconnected_ckey_by_stat)
		leave_stats += global.disconnected_ckey_by_stat[ckey]
