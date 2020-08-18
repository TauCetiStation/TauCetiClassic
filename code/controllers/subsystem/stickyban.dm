#define STICKYBAN_TABLENAME "erro_stickyban"
#define STICKYBAN_CKEY_MATCHED_TABLENAME "erro_stickyban_matched_ckey"
#define STICKYBAN_CID_MATCHED_TABLENAME "erro_stickyban_matched_cid"
#define STICKYBAN_IP_MATCHED_TABLENAME "erro_stickyban_matched_ip"

SUBSYSTEM_DEF(stickyban)
	name = "PRISM"

	init_order = SS_INIT_STICKY_BAN
	flags = SS_NO_FIRE

	// List on bans on start of round
	// Update record after admin any modifications
	var/list/cache = list()
	// List of bans loaded from DB.
	// Updated every STICKYBAN_DB_CACHE_TIME or fail to found dbcache
	var/list/dbcache = list()
	// Next world.time to update DB cache
	var/dbcache_expire = 0

/datum/controller/subsystem/stickyban/Initialize(start_timeofday)
	if (length(global.stickyban_admin_exemptions))
		// if admin login turn on Config stickybans
		restore_stickybans()
	var/list/bannedkeys = sticky_banned_ckeys()
	sync_db(bannedkeys)
	sync_config(bannedkeys)
	return ..()

/datum/controller/subsystem/stickyban/stat_entry(msg)
	..("I:[initialized] D:[length(dbcache)] C:[length(cache)]")

/datum/controller/subsystem/stickyban/proc/sync_db(list/current_bannedkeys)
	// Private procedure for subsystem init
	// Delete bans that no longer exist in the database
	// and add new bans to the database
	// Config => DB && remove expired DB stickyban from Config
	if (global.dbcon.Connect() || length(dbcache))
		if (length(global.stickyban_admin_exemptions))
			restore_stickybans()
		// Checking new bans from Config
		for (var/oldban in (world.GetConfig("ban") - current_bannedkeys))
			var/ckey = ckey(oldban)
			if (ckey != oldban && (ckey in current_bannedkeys))
				continue

			// Add new bans to DB, legacy bans too
			var/list/ban = params2list(world.GetConfig("ban", oldban))
			if (ban && !ban[BANKEY_FROMDB])
				if (!import_raw_stickyban_to_db(ckey, ban))
					log_game("Could not import stickyban on [oldban] into the database. Ignoring")
					continue
				dbcache_expire = 0
				current_bannedkeys += ckey
			// Remove bans not in DB anymore
			world.SetConfig("ban", oldban, null)
	if (length(global.stickyban_admin_exemptions)) //the previous loop can sleep
		restore_stickybans()

/datum/controller/subsystem/stickyban/proc/sync_config(bannedkeys)
	// Private procedure for subsystem init
	// Init cache and sync from DBcache/Config
	// DB/Config => Config, memory cache
	for (var/bannedkey in bannedkeys)
		var/ckey = ckey(bannedkey)
		var/list/ban = get_stickyban_from_ckey(bannedkey)

		//byond stores sticky bans by key, that's lame
		if (ckey != bannedkey)
			world.SetConfig("ban", bannedkey, null)

		if (!ban[BANKEY_CKEY])
			ban[BANKEY_CKEY] = ckey
		cache[ckey] = ban
		world.SetConfig("ban", ckey, list2stickyban(ban))

/datum/controller/subsystem/stickyban/proc/get_cached_sticky_banned_ckeys()
	// Return list of stickybaned ckeys form DBcache or null. Update dbcache on timer
	if (establish_db_connection() || length(dbcache))
		populate_expired_dbcache()
		// Is dbcache initilized?
		if (dbcache_expire)
			return dbcache.Copy()

/datum/controller/subsystem/stickyban/proc/get_dbcached_stickyban(ckey)
	// Return stickyban, if have it in DB or DBcache. Update dbcache on timer
	var/list/stickyban_record = list()
	if ((establish_db_connection()) || length(dbcache))
		populate_expired_dbcache()
		// Is dbcache initilized?
		if (dbcache_expire)
			stickyban_record = dbcache[ckey]
			// For null dbcache record load db. Exepct same tick already reloaded
			if (!stickyban_record && dbcache_expire != world.time + STICKYBAN_DB_CACHE_TIME)
				// Force reload dbcache and reset expire
				dbcache_expire = 1 // if populate have db errors try next time again
				populate_dbcache()
				stickyban_record = dbcache[ckey]
			if (stickyban_record)
				var/list/cache_ban = cache["[ckey]"]
				if (cache_ban)
					stickyban_record[BANKEY_TIMEOUT] = cache_ban[BANKEY_TIMEOUT]
				stickyban_record[BANKEY_FROMDB] = TRUE
	return stickyban_record

/datum/controller/subsystem/stickyban/proc/populate_expired_dbcache()
	// Update DBcache if need
	if (dbcache_expire < world.time)
		populate_dbcache()

/datum/controller/subsystem/stickyban/proc/populate_dbcache()
	// Load DBcache from DB

	var/list/new_dbcache = list() //so if we runtime or the db connection dies we don't kill the existing cache
	if (!establish_db_connection())
		return

	var/DBQuery/query_stickybans = dbcon.NewQuery("SELECT ckey, reason, banning_admin, datetime FROM [STICKYBAN_TABLENAME] ORDER BY ckey")
	var/DBQuery/query_ckey_matches = dbcon.NewQuery("SELECT stickyban, matched_ckey, first_matched, last_matched, exempt FROM [STICKYBAN_CKEY_MATCHED_TABLENAME] ORDER BY first_matched")
	var/query_ckey_matches_executed = FALSE
	var/DBQuery/query_cid_matches = dbcon.NewQuery("SELECT stickyban, matched_cid, first_matched, last_matched FROM [STICKYBAN_CID_MATCHED_TABLENAME] ORDER BY first_matched")
	var/query_cid_matches_executed = FALSE
	var/DBQuery/query_ip_matches = dbcon.NewQuery("SELECT stickyban, INET_NTOA(matched_ip), first_matched, last_matched FROM [STICKYBAN_IP_MATCHED_TABLENAME] ORDER BY first_matched")
	var/query_ip_matches_executed = FALSE

	// stickyban query must requested
	if (!query_stickybans || !query_stickybans.Execute())
		return
	if (query_ckey_matches && query_ckey_matches.Execute())
		query_ckey_matches_executed = TRUE
	if (query_cid_matches && query_cid_matches.Execute())
		query_cid_matches_executed = TRUE
	if (query_ip_matches && query_ip_matches.Execute())
		query_ip_matches_executed = TRUE

	while (query_stickybans.NextRow())
		var/list/ban = list()

		ban[BANKEY_CKEY] = query_stickybans.item[1]
		ban[BANKEY_MSG] = query_stickybans.item[2]
		ban[BANKEY_REASON] = "(InGameBan)([query_stickybans.item[3]])"
		ban[BANKEY_ADMIN] = query_stickybans.item[3]
		ban["datetime"] = query_stickybans.item[4]
		ban[BANKEY_TYPE] = list("sticky")

		new_dbcache["[query_stickybans.item[1]]"] = ban

	// stickyban_matched_ckey table
	if (query_ckey_matches_executed)
		while (query_ckey_matches.NextRow())
			var/list/match = list()

			match["stickyban"] = query_ckey_matches.item[1]
			match["matched_ckey"] = query_ckey_matches.item[2]
			match["first_matched"] = query_ckey_matches.item[3]
			match["last_matched"] = query_ckey_matches.item[4]
			match["exempt"] = text2num(query_ckey_matches.item[5])

			var/ban = new_dbcache[query_ckey_matches.item[1]]
			if (!ban)
				continue
			var/keys = ban[text2num(query_ckey_matches.item[5]) ? BANKEY_WHITELIST : BANKEY_KEYS]
			if (!keys)
				keys = ban[text2num(query_ckey_matches.item[5]) ? BANKEY_WHITELIST : BANKEY_KEYS] = list()
			keys[query_ckey_matches.item[2]] = match

	// stickyban_matched_cid table
	if (query_cid_matches_executed)
		while (query_cid_matches.NextRow())
			var/list/match = list()

			match["stickyban"] = query_cid_matches.item[1]
			match["matched_cid"] = query_cid_matches.item[2]
			match["first_matched"] = query_cid_matches.item[3]
			match["last_matched"] = query_cid_matches.item[4]

			var/ban = new_dbcache[query_cid_matches.item[1]]
			if (!ban)
				continue
			var/computer_ids = ban[BANKEY_CID]
			if (!computer_ids)
				computer_ids = ban[BANKEY_CID] = list()
			computer_ids[query_cid_matches.item[2]] = match

	// stickyban_matched_ip table
	if (query_ip_matches_executed)
		while (query_ip_matches.NextRow())
			var/list/match = list()

			match["stickyban"] = query_ip_matches.item[1]
			match["matched_ip"] = query_ip_matches.item[2]
			match["first_matched"] = query_ip_matches.item[3]
			match["last_matched"] = query_ip_matches.item[4]

			var/ban = new_dbcache[query_ip_matches.item[1]]
			if (!ban)
				continue
			var/IPs = ban[BANKEY_IP]
			if (!IPs)
				IPs = ban[BANKEY_IP] = list()
			IPs[query_ip_matches.item[2]] = match

	dbcache = new_dbcache
	dbcache_expire = world.time + STICKYBAN_DB_CACHE_TIME


/datum/controller/subsystem/stickyban/proc/add(ckey, list/ban)
	// Add new stickyban, no cheks input arguments!
	if (import_raw_stickyban_to_db(ckey, ban))
		ban[BANKEY_FROMDB] = TRUE
	world.SetConfig("ban", ckey, list2stickyban(ban))
	// Update memory cache
	ban = stickyban2list(list2stickyban(ban))
	cache[ckey] = ban

/datum/controller/subsystem/stickyban/proc/import_raw_stickyban_to_db(ckey, list/ban)
	. = FALSE
	if (!ban[BANKEY_ADMIN])
		ban[BANKEY_ADMIN] = "LEGACY"
	if (!ban[BANKEY_MSG])
		ban[BANKEY_MSG] = "Evasion"

	if (!establish_db_connection())
		return
	var/DBQuery/query_create_stickyban = dbcon.NewQuery({"INSERT IGNORE INTO [STICKYBAN_TABLENAME]
		(ckey, reason, banning_admin)
		VALUES ('[sanitize_sql(ckey)]', '[sanitize_sql(ban[BANKEY_MSG])]', '[sanitize_sql(ban[BANKEY_ADMIN])]')"})
	if (!query_create_stickyban.Execute())
		return

	// Prepare mass insert
	var/list/sqlckeys = list()
	var/list/sqlcids = list()
	var/list/sqlips = list()

	if (ban[BANKEY_KEYS])
		var/list/keys = splittext(ban[BANKEY_KEYS], ",")
		for (var/key in keys)
			var/list/sqlckey = list()
			sqlckey["stickyban"] = "'[sanitize_sql(ckey)]'"
			sqlckey["matched_ckey"] = "'[sanitize_sql(ckey(key))]'"
			sqlckey["exempt"] = FALSE
			sqlckeys[++sqlckeys.len] = sqlckey

	if (ban[BANKEY_WHITELIST])
		var/list/keys = splittext(ban[BANKEY_WHITELIST], ",")
		for (var/key in keys)
			var/list/sqlckey = list()
			sqlckey["stickyban"] = "'[sanitize_sql(ckey)]'"
			sqlckey["matched_ckey"] = "'[sanitize_sql(ckey(key))]'"
			sqlckey["exempt"] = TRUE
			sqlckeys[++sqlckeys.len] = sqlckey

	if (ban[BANKEY_CID])
		var/list/cids = splittext(ban[BANKEY_CID], ",")
		for (var/cid in cids)
			var/list/sqlcid = list()
			sqlcid["stickyban"] = "'[sanitize_sql(ckey)]'"
			sqlcid["matched_cid"] = "'[sanitize_sql(cid)]'"
			sqlcids[++sqlcids.len] = sqlcid

	if (ban[BANKEY_IP])
		var/list/ips = splittext(ban[BANKEY_IP], ",")
		for (var/ip in ips)
			var/list/sqlip = list()
			sqlip["stickyban"] = "'[sanitize_sql(ckey)]'"
			sqlip["matched_ip"] = "'[sanitize_sql(ip)]'"
			sqlips[++sqlips.len] = sqlip

	// Execute prepared mass insert
	if (length(sqlckeys) && establish_db_connection())
		var/DBQuery/matched_ckey_query = dbcon.NewMassInsertQuery(STICKYBAN_CKEY_MATCHED_TABLENAME, sqlckeys, FALSE, TRUE)
		if (matched_ckey_query)
			matched_ckey_query.Execute()

	if (length(sqlcids) && establish_db_connection())
		var/DBQuery/matched_cid_query = dbcon.NewMassInsertQuery(STICKYBAN_CID_MATCHED_TABLENAME, sqlcids, FALSE, TRUE)
		if (matched_cid_query)
			matched_cid_query.Execute()

	if (length(sqlips) && establish_db_connection())
		var/DBQuery/matched_ip_query = dbcon.NewMassInsertQuery(STICKYBAN_IP_MATCHED_TABLENAME, sqlips, FALSE, TRUE)
		if (matched_ip_query)
			matched_ip_query.Execute()

	return TRUE

/datum/controller/subsystem/stickyban/proc/remove(ckey)
	// Drop stickyban record from all
	if (ckey)
		if (establish_db_connection())
			var/sanitized_ckey = sanitize_sql(ckey)
			if (length(sanitized_ckey))
				var/list/sql_q = list(
					"DELETE FROM [STICKYBAN_TABLENAME] WHERE ckey = '[sanitized_ckey]'",
					"DELETE FROM [STICKYBAN_CKEY_MATCHED_TABLENAME] WHERE stickyban = '[sanitized_ckey]",
					"DELETE FROM [STICKYBAN_CID_MATCHED_TABLENAME] stickyban = '[sanitized_ckey]'",
					"DELETE FROM [STICKYBAN_IP_MATCHED_TABLENAME] WHERE stickyban = '[sanitized_ckey]'"
				)
				for (var/Q in sql_q)
					var/DBQuery/query = dbcon.NewQuery(Q)
					if (query)
						query.Execute()
		world.SetConfig("ban", ckey, null)
		cache -= ckey

/datum/controller/subsystem/stickyban/proc/remove_altkey(ckey, altckey, list/ban = null)
	// Remove connected other ckey from stickyban
	// If ban argument passed don't searching it again
	if (ckey && altckey)
		if (!ban) // For optimize passthrough ban optional
			ban = get_stickyban_from_ckey(ckey)
		if (length(ban))
			LAZYREMOVE(ban[BANKEY_KEYS], altckey)
			world.SetConfig("ban", ckey, list2stickyban(ban))
			cache[ckey] = ban
			var/sanitized_ckey = sanitize_sql(ckey)
			var/sanitized_alt_ckey = sanitize_sql(altckey)
			if (length(sanitized_ckey) && length(sanitized_alt_ckey) && establish_db_connection())
				var/DBQuery/query = dbcon.NewQuery("DELETE FROM [STICKYBAN_CKEY_MATCHED_TABLENAME] WHERE stickyban = '[sanitized_ckey]' AND matched_ckey = '[sanitized_alt_ckey]'")
				if (query)
					query.Execute()

/datum/controller/subsystem/stickyban/proc/update_reason(ckey, reason, list/ban = null)
	// Update message in stickyban
	// If ban argument passed don't searching it again
	if (ckey && reason)
		if (!ban)
			ban = get_stickyban_from_ckey(ckey)
		if (length(ban))
			ban[BANKEY_MSG] = "[reason]"
			var/santinized_ckey = sanitize_sql(ckey)
			if (santinized_ckey && establish_db_connection())
				var/DBQuery/query_update = dbcon.NewQuery("UPDATE [STICKYBAN_TABLENAME] SET reason = '[sanitize_sql(reason)]' WHERE ckey = '[santinized_ckey]'")
				if (query_update)
					query_update.Execute()
			world.SetConfig("ban", ckey, list2stickyban(ban))
			cache[ckey] = ban

/datum/controller/subsystem/stickyban/proc/exempt_alt_ckey(ckey, altckey, list/ban = null)
	// Remove *altckey* connection with *ckey*.
	// If ban argument passed don't searching it again
	if (!ban)
		ban = get_stickyban_from_ckey(ckey)
	if (length(ban) && altckey)
		var/key = LAZYACCESS(ban[BANKEY_KEYS], altckey)
		if (key)
			// Rewrite cache and Config
			LAZYREMOVE(ban[BANKEY_KEYS], altckey)
			key["exempt"] = TRUE
			LAZYSET(ban[BANKEY_WHITELIST], altckey, key)
			world.SetConfig("ban", ckey, list2stickyban(ban))
			cache[ckey] = ban
			// Update DB if can
			if (establish_db_connection())
				var/sanitized_ckey = sanitize_sql(ckey)
				var/sanitized_alt_ckey = sanitize_sql(altckey)
				if (sanitized_ckey && sanitized_alt_ckey)
					var/DBQuery/query_exempt_stickyban_alt = dbcon.NewQuery("UPDATE [STICKYBAN_CKEY_MATCHED_TABLENAME] SET exempt = 1 WHERE stickyban = '[sanitized_ckey]' AND matched_ckey = '[sanitized_alt_ckey]'")
					if (query_exempt_stickyban_alt)
						query_exempt_stickyban_alt.Execute()

/datum/controller/subsystem/stickyban/proc/unexempt_alt_ckey(ckey, altckey, list/ban = null)
	// Return connection altkey ban for ckey
	// If ban argument passed don't searching it again
	if (!ban)
		ban = get_stickyban_from_ckey(ckey)
	if (length(ban))
		var/key = LAZYACCESS(ban[BANKEY_WHITELIST], altckey)
		if (key)
			// Rewrite cache and Config
			LAZYREMOVE(ban[BANKEY_WHITELIST], altckey)
			key["exempt"] = FALSE
			LAZYSET(ban[BANKEY_KEYS], altckey, key)
			world.SetConfig("ban", ckey, list2stickyban(ban))
			cache[ckey] = ban
			// Update DB if can
			if (establish_db_connection())
				var/sanitized_ckey = sanitize_sql(ckey)
				var/sanitized_alt_ckey = sanitize_sql(altckey)
				if (sanitized_ckey && sanitized_alt_ckey)
					var/DBQuery/query_unexmpt_stickyban_alt = dbcon.NewQuery("UPDATE [STICKYBAN_CKEY_MATCHED_TABLENAME] SET exempt = 0 WHERE stickyban = '[sanitized_ckey]' AND matched_ckey = '[sanitized_alt_ckey]'")
					if (query_unexmpt_stickyban_alt)
						query_unexmpt_stickyban_alt.Execute()

/datum/controller/subsystem/stickyban/proc/timeout_before_restart(ckey, list/ban = null)
	// Exclude stickyban before droping cache(restart)
	// On timeout on all connection from ckey allowed
	if (!ban)
		ban = get_stickyban_from_ckey(ckey)
	if (length(ban))
		ban[BANKEY_TIMEOUT] = TRUE
		world.SetConfig("ban", ckey, null)
		var/cache_ban = cache[ckey]
		if (cache_ban)
			cache_ban[BANKEY_TIMEOUT] = TRUE

/datum/controller/subsystem/stickyban/proc/untimeout(ckey)
	// Restore blocking connection for ckey
	if (!ckey)
		return
	var/ban = get_stickyban_from_ckey(ckey)
	var/cache_ban = cache[ckey]
	if (cache_ban)
		cache_ban[BANKEY_TIMEOUT] = FALSE
	if (!ban)
		if (!cache_ban)
			return
		ban = cache_ban
	ban[BANKEY_TIMEOUT] = FALSE
	world.SetConfig("ban", ckey, list2stickyban(ban))

/datum/controller/subsystem/stickyban/proc/reload_from_cache(ckey)
	// Just reset Config ban storage from cache
	if (ckey)
		var/cached_ban = cache[ckey]
		world.SetConfig("ban", ckey, null)
		// Revert is mostly used when shit goes rouge, so we have to set it to null
		//	and wait a byond tick before assigning it to ensure byond clears its shit.
		stoplag()
		world.SetConfig("ban", ckey, list2stickyban(cached_ban))

/datum/controller/subsystem/stickyban/proc/update_matches(ckey, matched_ckey, matched_address, matched_computer_id)
	// Updates matches tables
	// If matched address, ckey or cid found, update last_matched column in DB

	if(establish_db_connection())
		var/list/ckey_match_row = list(
			"stickyban" = "'[sanitize_sql(ckey)]'",
			"matched_ckey" = "'[sanitize_sql(matched_ckey)]'")
		var/list/address_match_row = list(
			"stickyban" = "'[sanitize_sql(ckey)]'",
			"matched_ip" = "INET_ATON('[sanitize_sql(matched_address)]')")
		var/list/cid_match_row = list(
			"stickyban" = "'[sanitize_sql(ckey)]'",
			"matched_cid" = "'[sanitize_sql(matched_computer_id)]'")
		// Generate sql
		var/on_duplicate = "ON DUPLICATE KEY UPDATE last_matched = now()"
		var/DBQuery/ckey_query = dbcon.NewMassInsertQuery(STICKYBAN_CKEY_MATCHED_TABLENAME, list(ckey_match_row), on_duplicate)
		var/DBQuery/address_query = dbcon.NewMassInsertQuery(STICKYBAN_IP_MATCHED_TABLENAME, list(address_match_row), on_duplicate)
		var/DBQuery/cid_query = dbcon.NewMassInsertQuery(STICKYBAN_CID_MATCHED_TABLENAME, list(cid_match_row), on_duplicate)
		// Execute query
		if (ckey_query)
			ckey_query.Execute()
		if (address_query)
			address_query.Execute()
		if (cid_query)
			cid_query.Execute()


/proc/is_stickyban_from_game(ban)
	// returns true if and only if the game added the sticky ban.
	return (ban && islist(ban) && ("sticky" in ban[BANKEY_TYPE]) && copytext(ban[BANKEY_REASON], 1, 12) == "(InGameBan)")

/proc/sticky_banned_ckeys()
	// Return list of stickybaned ckeys
	// Update cache on timer
	var/list/ckeys_list = SSstickyban.get_cached_sticky_banned_ckeys()
	return ckeys_list ? ckeys_list : sortList(world.GetConfig("ban"))

/proc/get_stickyban_from_ckey(var/ckey)
	// Return list of stickybans for client with by ckey
	// If nothig found or error return null
	// Update cache on timer

	if (!ckey)
		return null
	// Looking in cache
	var/list/stickyban_record = SSstickyban.get_dbcached_stickyban(ckey)
	if (length(stickyban_record))
		return stickyban_record
	// Looking in Config
	else
		stickyban_record = stickyban2list(world.GetConfig("ban", ckey))
	if (!length(stickyban_record))
		stickyban_record = stickyban2list(world.GetConfig("ban", ckey(ckey)))
	if(!length(stickyban_record))
		return null
	return stickyban_record

/proc/stickyban2list(ban_params)
	// Convert text(params) to list of stickybans
	// Return list. Empty on errors

	if (!ban_params)
		return list()
	. = params2list(ban_params)
	if (.[BANKEY_KEYS])
		var/keys = splittext(.[BANKEY_KEYS], ",")
		var/ckeys = list()
		for (var/key in keys)
			var/ckey = ckey(key)
			ckeys[ckey] = ckey //to make searching faster.
		.[BANKEY_KEYS] = ckeys
	if (.[BANKEY_WHITELIST])
		var/keys = splittext(.[BANKEY_WHITELIST], ",")
		var/ckeys = list()
		for (var/key in keys)
			var/ckey = ckey(key)
			ckeys[ckey] = ckey //to make searching faster.
		.[BANKEY_WHITELIST] = ckeys
	.[BANKEY_TYPE] = splittext(.[BANKEY_TYPE], ",")
	.[BANKEY_IP] = splittext(.[BANKEY_IP], ",")
	.[BANKEY_CID] = splittext(.[BANKEY_CID], ",")
	. -= BANKEY_FROMDB

/proc/list2stickyban(list/ban_list)
	// list2params with formating
	// Convert list of bans to sticky format
	// Ready to save in SetConfig.
	// Return null on empty list or errors
	// Otherwise return text(params)

	if (!ban_list || !islist(ban_list))
		return null
	//Formating list to stickyban
	var/list/buffer = ban_list.Copy()
	if (buffer[BANKEY_KEYS])
		buffer[BANKEY_KEYS] = jointext(buffer[BANKEY_KEYS], ",")
	if (buffer[BANKEY_IP])
		buffer[BANKEY_IP] = jointext(buffer[BANKEY_IP], ",")
	if (buffer[BANKEY_CID])
		buffer[BANKEY_CID] = jointext(buffer[BANKEY_CID], ",")
	if (buffer[BANKEY_WHITELIST])
		buffer[BANKEY_WHITELIST] = jointext(buffer[BANKEY_WHITELIST], ",")
	if (buffer[BANKEY_TYPE])
		buffer[BANKEY_TYPE] = jointext(buffer[BANKEY_TYPE], ",")
	// Remove IsBanned matches data from cache
	buffer -= BANKEY_REVERT
	buffer -= BANKEY_MATCHES_THIS_ROUND
	buffer -= BANKEY_EXISTING_USER_MATCHES
	buffer -= BANKEY_ADMIN_MATCHES_THIS_ROUND
	buffer -= BANKEY_PENDING_MATCHES
	return list2params(buffer)

#undef STICKYBAN_TABLENAME
#undef STICKYBAN_CKEY_MATCHED_TABLENAME
#undef STICKYBAN_CID_MATCHED_TABLENAME
#undef STICKYBAN_IP_MATCHED_TABLENAME
