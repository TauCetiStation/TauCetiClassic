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
#define STAT_OUTPUT_VERSION 2
#define STAT_FILE_NAME "stat.json"

/datum/stat_collector
	var/const/version = STAT_OUTPUT_VERSION
	var/round_id
	var/start_time
	var/end_time
	var/duration
	var/mode
	var/mode_result
	var/map
	// You can get the nanoui map using
	// "https://cdn.jsdelivr.net/gh/TauCetiStation/TauCetiClassic@" + base_commit_sha + "/" + minimap_image
	var/minimap_image
	var/server_address
	var/base_commit_sha
	var/test_merges

	var/completion_html

	var/datum/stat/score/score = new /datum/stat/score
	var/list/datum/stat/achievement/achievements = list()
	var/list/datum/stat/communication_log/communication_logs = list()

	// New data
	var/list/datum/stat/death_stat/deaths = list()
	var/list/datum/stat/explosion_stat/explosions = list()
	var/list/datum/stat/manifest_entry/manifest_entries = list()
	var/list/datum/stat/leave_stat/leave_stats = list()
	var/list/datum/stat/role/orphaned_roles = list()
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
