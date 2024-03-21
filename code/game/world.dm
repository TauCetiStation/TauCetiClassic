var/global/round_id = 0
var/global/base_commit_sha = 0

var/global/it_is_a_snow_day = FALSE

/world/New()
#ifdef DEBUG
	enable_debugger()
#endif

#ifdef EARLY_PROFILE
	Profile(PROFILE_RESTART)
	Profile(PROFILE_RESTART, type = "sendmaps")
#endif

	it_is_a_snow_day = prob(50)

	if(byond_version < RECOMMENDED_VERSION)
		world.log << "Your server's byond version does not meet the recommended requirements for this server. Please update BYOND"

	global.bridge_secret = world.params["bridge_secret"]
	world.params = null

	make_datum_references_lists() //initialises global lists for referencing frequently used datums (so that we only ever do it once)

	timezoneOffset = text2num(time2text(0, "hh")) HOURS
	load_configuration()

	if(!setup_database_connection())
		log_sql("Your server failed to establish a connection with the SQL database.")
	else
		log_sql("SQL database connection established.")

	load_regisration_panic_bunker()
	load_stealth_keys()
	load_mode()
	load_last_mode()
	load_motd()
	load_host_announcements()
	load_test_merges()
	load_admins()
	load_mentors()
	load_supporters()
	if(config.usewhitelist)
		load_whitelist()
	if(config.usealienwhitelist)
		load_whitelistSQL()
	LoadBans()
	load_guard_blacklist()

	spawn
		changelog_hash = trim(get_webpage(config.changelog_hash_link))

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	world.send2bridge(
		type = list(BRIDGE_ROUNDSTAT),
		attachment_title = "Server starting up, new round will start soon",
		attachment_msg = "Join now: <[BYOND_JOIN_LINK]>",
		attachment_color = BRIDGE_COLOR_ANNOUNCE,
		mention = BRIDGE_MENTION_ROUNDSTART,
	)

	radio_controller = new /datum/controller/radio()
	data_core = new /obj/effect/datacore()
	paiController = new /datum/paiController()
	ahelp_tickets = new

	SetRoundID()
	base_commit_sha = GetGitMasterCommit(1)
	SetupLogs() // depends on round id

	spawn(10)
		Master.Initialize()

	update_status()

	. = ..()

#ifdef UNIT_TEST
	log_unit_test("Unit Tests Enabled. This will destroy the world when testing is complete.")
#endif

	if(config.kick_inactive)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(KickInactiveClients)), 15 MINUTES)

#undef RECOMMENDED_VERSION

/world/proc/SetupLogs()
	var/log_suffix = global.round_id ? global.round_id : replacetext(time_stamp(), ":", ".")
	var/log_date = time2text(world.realtime, "YYYY/MM/DD")

	global.log_directory = "data/logs/[log_date]/round-[log_suffix]"
	global.log_investigate_directory = "[log_directory]/investigate"
	global.log_debug_directory = "[log_directory]/debug"
	global.log_debug_js_directory = "[log_debug_directory]/js_errors"

	global.game_log = file("[log_directory]/game.log")
	global.hrefs_log = file("[log_directory]/href.log")
	global.access_log = file("[log_directory]/access.log")
	global.asset_log = file("[log_debug_directory]/asset.log")
	global.tgui_log = file("[log_debug_directory]/tgui.log")

	global.initialization_log = file("[log_debug_directory]/initialization.log")
	global.runtime_log = file("[log_debug_directory]/runtime.log")
	global.qdel_log  = file("[log_debug_directory]/qdel.log")
	global.sql_error_log = file("[log_debug_directory]/sql.log")

	#ifdef REFERENCE_TRACKING
	global.gc_log  = file("[log_debug_directory]/gc_debug.log")
	#endif

	round_log("Server '[config.server_name]' starting up on [BYOND_SERVER_ADDRESS]")

	var/debug_rev_message = ""
	if(base_commit_sha)
		debug_rev_message += "Base SHA: [base_commit_sha][log_end]\n"

	if(fexists("test_merge.txt"))
		debug_rev_message += "TM: [trim(file2text("test_merge.txt"))][log_end]\n"

	if(length(debug_rev_message))
		info(debug_rev_message)
		log_runtime(debug_rev_message)

var/global/world_topic_spam_protect_ip = "0.0.0.0"
var/global/world_topic_spam_protect_time = world.timeofday

/world/Topic(T, addr, master, key)

	if (T == "ping")
		log_href("WTOPIC: \"[T]\", from:[addr], master:[master], key:[key]")

		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		log_href("WTOPIC: \"[T]\", from:[addr], master:[master], key:[key]")

		var/n = 0
		for(var/mob/M in player_list)
			if(M.client)
				n++
		return n

	else if (T == "status")
		log_href("WTOPIC: \"[T]\", from:[addr], master:[master], key:[key]")

		var/list/s = list()
		s["version"] = game_version
		s["mode"] = SSevents.custom_event_mode ? SSevents.custom_event_mode : master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = !LAZYACCESS(SSlag_switch.measures, DISABLE_NON_OBSJOBS)
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["players"] = list()
		s["stationtime"] = worldtime2text()
		s["gamestate"] = SSticker.current_state
		s["roundduration"] = global.roundduration2text()
		s["map_name"] = SSmapping.config?.map_name || "Loading..."
		s["popcap"] = config.client_limit_panic_bunker_count ? config.client_limit_panic_bunker_count : 0
		s["round_id"] = global.round_id
		s["revision"] = base_commit_sha
		var/n = 0
		var/admins = 0

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				admins++
			s["player[n]"] = C.key
			n++
		s["players"] = n

		s["admins"] = admins

		return list2params(s)

	else if (length(T) && istext(T))
		var/list/packet_data = params2list(T)
		if (packet_data)
			if(packet_data["announce"] == "")
				return receive_net_announce(packet_data, addr)
			if(packet_data["bridge"] == "" && addr == "127.0.0.1") // 
				bridge2game(packet_data)
				return "bridge=1" // no return data in topic, feedback should be send only through bridge

	else
		log_href("WTOPIC: \"[T]\", from:[addr], master:[master], key:[key]")

/world/proc/PreShutdown(end_state)

	if(establish_db_connection("erro_round"))
		end_state = end_state ? end_state : "undefined"
		var/DBQuery/query_round_shutdown = dbcon.NewQuery("UPDATE erro_round SET shutdown_datetime = Now(), end_state = '[sanitize_sql(end_state)]' WHERE id = [global.round_id]")
		query_round_shutdown.Execute()

		dbcon.Disconnect()

	world.log << "Runtimes count: [total_runtimes]. Runtimes skip count: [total_runtimes_skipped]."

	// Bad initializations log.
	var/initlog = SSatoms.InitLog()
	if(initlog)
		log_initialization(initlog)

	// Adds the del() log to world.log in a format condensable by the runtime condenser found in tools
	var/list/dellog = list()

	//sort by how long it's wasted hard deleting
	sortTim(SSgarbage.items, cmp=GLOBAL_PROC_REF(cmp_qdel_item_time), associative = TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		dellog += "Path: [path]"
		if (I.failures)
			dellog += "\tFailures: [I.failures]"
		dellog += "\tqdel() Count: [I.qdels]"
		dellog += "\tDestroy() Cost: [I.destroy_time]ms"
		if (I.hard_deletes)
			dellog += "\tTotal Hard Deletes [I.hard_deletes]"
			dellog += "\tTime Spent Hard Deleting: [I.hard_delete_time]ms"
		if (I.slept_destroy)
			dellog += "\tSleeps: [I.slept_destroy]"
		if (I.no_respect_force)
			dellog += "\tIgnored force: [I.no_respect_force] times"
		if (I.no_hint)
			dellog += "\tNo hint: [I.no_hint] times"
	if(dellog.len)
		log_qdel(dellog.Join("\n"))



var/global/shutdown_processed = FALSE

/world/Reboot(reason = 0, end_state)
	PreShutdown(end_state)

	for(var/client/C in clients)
		//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
		C.tgui_panel?.send_roundrestart()
		C << link(BYOND_JOIN_LINK)

	round_log("Reboot [end_state ? ", [end_state]" : ""]")
	shutdown_processed = TRUE

	if(fexists("scripts/hooks/round_reboot.sh")) //nevermind, we drop windows support for this things a little
		var/list/O = world.shelleo("scripts/hooks/round_reboot.sh")
		if(O[SHELLEO_ERRORLEVEL])
			world.log << O[SHELLEO_STDERR]
		else
			world.log << O[SHELLEO_STDOUT]

	..()

/world/Del()
#ifdef DEBUG
	disable_debugger()
#endif

	if(!shutdown_processed) //if SIGTERM signal, not restart/reboot
		PreShutdown("Graceful shutdown")
		round_log("Graceful shutdown")

	..()

/proc/KickInactiveClients()
	for (var/client/C in clients)
		if (!(C.holder || C.supporter) && C.is_afk())
			log_access("AFK: [key_name(C)]")
			to_chat(C, "<span class='userdanger'>You have been inactive for more than [config.afk_time_bracket / 600] minutes and have been disconnected.</span>")
			QDEL_IN(C, 2 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(KickInactiveClients)), 5 MINUTES)

/world/proc/load_stealth_keys()
	var/list/keys_list = file2list("config/stealth_keys.txt")
	if(keys_list.len)
		for(var/X in keys_list)
			stealth_keys += lowertext(X)

/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			log_misc("Saved mode is '[master_mode]'")

/world/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/world/proc/load_last_mode()
	var/list/Lines = file2list("data/last_mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_last_mode = Lines[1]
			log_misc("Previous round played mode was '[master_last_mode]'")

/world/proc/save_last_mode(the_last_mode)
	var/F = file("data/last_mode.txt")
	fdel(F)
	F << the_last_mode

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")

/world/proc/load_host_announcements()
	var/list/files = flist("data/announcements/")

	host_announcements = "" // reset in case of reload

	if(files.len)

		for(var/file in files)

			if(length(host_announcements))
				host_announcements += "<hr>"

			host_announcements += trim(file2text("data/announcements/[file]"))

		host_announcements = "<h2>Important Admin Announcements:</h2><br>[host_announcements]"

/world/proc/load_test_merges()
	if(!fexists("test_merge.txt"))
		return

	test_merges = splittext(trim(file2text("test_merge.txt")), " ")

	var/list/to_fetch = list()

	for(var/pr in test_merges)
		var/path = "[PERSISTENT_CACHE_FOLDER]/github/[pr]"
		if(fexists(path))
			test_merges[pr] = sanitize(file2text(path))
		else
			test_merges[pr] = TEST_MERGE_DEFAULT_TEXT
			to_fetch += pr

	if(length(to_fetch))
		fetch_new_test_merges(to_fetch)

/world/proc/fetch_new_test_merges(list/to_fetch)
	set waitfor = FALSE

	if(!to_fetch)
		return

	var/arguments = to_fetch.Join(" ")
	if(config.github_token)
		arguments += " -t '[config.github_token]'"
	if(config.repository_link)
		arguments += " -r '[config.github_repository_owner]/[config.github_repository_name]'"

	var/json_content = world.ext_python("fetch_test_merges.py", arguments)
	if(!json_content)
		return

	var/list/fetch = json_decode(json_content) // {"number": {"title": title, "success": TRUE|FALSE}}
	for(var/pr in fetch)
		test_merges[pr] = sanitize(fetch[pr]["title"])
		if(fetch[pr]["success"])
			var/path = "[PERSISTENT_CACHE_FOLDER]/github/[pr]"
			text2file(fetch[pr]["title"], path)

/world/proc/load_regisration_panic_bunker()
	if(config.registration_panic_bunker_age)
		log_game("Round with registration panic bunker! Panic age: [config.registration_panic_bunker_age]. Enabled by configuration. No active hours limit")
		return

	if(fexists("data/regisration_panic_bunker.sav"))
		var/savefile/S = new /savefile("data/regisration_panic_bunker.sav")
		var/active_until = text2num(S["active_until"])

		if(active_until <= world.realtime)
			fdel("data/regisration_panic_bunker.sav")
		else
			config.registration_panic_bunker_age = S["panic_age"]
			var/enabled_by = S["enabled_by"]
			var/active_hours_left = num2text((active_until - world.realtime) / 36000, 1)
			log_game("Round with registration panic bunker! Panic age: [config.registration_panic_bunker_age]. Enabled by [enabled_by]. Active hours left: [active_hours_left]")

/world/proc/load_guard_blacklist()
	if(!config.guard_enabled || !fexists("config/guard_blacklist.txt"))
		return

	var/L = file2list("config/guard_blacklist.txt")

	for(var/line in L)
		line = trim(line)

		if(!length(line) || line[1] == "#")
			continue

		var/pos = findtext(line," ")
		var/code = trim(copytext(line, 1, pos))
		var/value = trim(copytext(line, pos))

		if(!length(value)) // don't fuck up
			continue

		switch(code)
			if("IP")
				guard_blacklist["IP"] += value
			if("ISP")
				guard_blacklist["ISP"] += value

/world/proc/load_supporters()
	if(config.allow_donators && fexists("config/donators.txt"))
		var/L = file2list("config/donators.txt")

		var/current_DD = text2num(time2text(world.timeofday, "DD"))
		var/current_MM = text2num(time2text(world.timeofday, "MM"))
		var/current_YY = text2num(time2text(world.timeofday, "YY"))

		for(var/line in L)

			line = trim(line)

			if(!length(line))
				continue

			if(line[1] == "#")
				continue

			var/list/params = splittext(line, " ")
			var/ckey = ckey(params[1])
			var/list/until_date = length(params) > 1 ? splittext(params[2], ".") : 0  // DD.MM.YY

			if(until_date)

				var/DD = text2num(until_date[1])
				var/MM = text2num(until_date[2])
				var/YY = text2num(until_date[3])

				if(YY < current_YY)
					continue
				else if (YY == current_YY)
					if(MM < current_MM)
						continue
					else if (MM == current_MM)
						if(DD < current_DD)
							continue

			donators.Add(ckey)

	// just some tau ceti specific stuff
	if(config.allow_tauceti_patrons)
		var/w = get_webpage("https://taucetistation.org/patreon/json")
		if(!w)
			warning("Failed to load taucetistation.org patreon list")
			message_admins("Failed to load taucetistation.org patreon list, please inform responsible persons")
		else
			var/list/l = json_decode(w)
			for(var/i in l)
				if(l[i]["reward_price"] == "5.00")
					donators.Add(ckey(l[i]["name"]))

	for(var/client/C in clients)
		C.update_supporter_status()

/client/proc/update_supporter_status()
	if((ckey in donators) || config.allow_byond_membership && IsByondMember())
		supporter = 1

/world/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	config.loadmaplist("config/maps.txt")
	config.load_announcer_config("config/announcer")
	// apply some settings from config..
	abandon_allowed = config.respawn


/world/proc/update_status()
	var/s = ""

	if (config && config.server_name)
		s += "<b>[config.server_name]</b> &#8212; "

	s += "<b>[station_name()]</b>";

	if (config && config.siteurl)
		s += " ("
		s += "<a href=\"[config.siteurl]\">" //Change this to wherever you want the hub to link to.
		s += "site"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
		s += "</a>"
		s += ")"

	var/list/features = list()

	if(SSticker)
		if(master_mode)
			features += master_mode
	else
		features += "<b>STARTING</b>"

	if (LAZYACCESS(SSlag_switch.measures, DISABLE_NON_OBSJOBS))
		features += "closed"

	features += abandon_allowed ? "respawn" : "no respawn"

	if (config && config.allow_ai)
		features += "AI allowed"

	var/n = 0
	for (var/mob/M in player_list)
		if (M.client)
			n++

	if (n > 1)
		features += "~[n] players"
	else if (n > 0)
		features += "~[n] player"

	/*
	is there a reason for this? the byond site shows 'hosted by X' when there is a proper host already.
	if (host)
		features += "hosted by <b>[host]</b>"
	*/

	if (!host && config && config.hostedby)
		features += "hosted by <b>[config.hostedby]</b>"

	if (features)
		s += ": [jointext(features, ", ")]"

	/* does this help? I do not know */
	if (src.status != s)
		src.status = s

/proc/SetRoundID()
	if(!establish_db_connection("erro_round"))
		return
	var/DBQuery/query_round_initialize = dbcon.NewQuery("INSERT INTO erro_round (initialize_datetime, server_ip, server_port) VALUES (Now(), INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[sanitize_sql(world.internet_address)]')), '[sanitize_sql(world.port)]')")
	if(query_round_initialize.Execute())
		var/DBQuery/query_round_last_id = dbcon.NewQuery("SELECT LAST_INSERT_ID()")
		query_round_last_id.Execute()
		if(query_round_last_id.NextRow())
			global.round_id = text2num(query_round_last_id.item[1])
			log_game("New round: #[global.round_id]\n-------------------------")
			world.log << "New round: #[global.round_id]\n-------------------------"

#define FAILED_DB_CONNECTION_CUTOFF 5
var/global/failed_db_connections = 0

/proc/setup_database_connection()

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0
	if(!dbcon)
		dbcon = new()

	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		world.log << dbcon.ErrorMsg()

	return .

//This proc ensures that the connection to the database (global variable dbcon) is established
//optionally you can pass table names as args to check that they exist
/proc/establish_db_connection(...)
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon || !dbcon.IsConnected())
		if(!setup_database_connection())
			return 0

	if(length(args))
		for(var/tablename in args)
			if(!dbcon.TableExists(tablename))
				return 0

	return 1

#undef FAILED_DB_CONNECTION_CUTOFF

/world/proc/incrementMaxZ()
	maxz++

// This proc reads the current git commit number of a master branch
/proc/GetGitMasterCommit(no_head = 0)
	var/commitFile = ".git/refs/remotes/origin/master"
	if(fexists(commitFile) == 0)
		info("GetMasterGitCommit() File not found ([commitFile]), using HEAD as a current commit")
		return no_head ? 0 : "HEAD"

	var/text = trim(file2text(commitFile))
	if(!text)
		info("GetMasterGitCommit() File is empty ([commitFile]), using HEAD as a current commit")
		return no_head ? 0 : "HEAD"

	return text

// Net announce
#define NET_ANNOUNCE_BAN "ban"

/world/proc/send_net_announce(type, list/msg)
	// get associated list for message
	// return associated list with key as server url when receive somthing
	var/list/response = list()
	if (length(global.net_announcer_secret) < 2 || !length(msg) || !istext(type) || !length(type))
		return response
	var/cargo = list2params(msg)
	if (!length(cargo))
		return response
	for(var/i in 2 to length(global.net_announcer_secret))
		var/server = global.net_announcer_secret[i]
		response[server] = world.Export(text("[]?announce&secret=[]&type=[]&[]", server, global.net_announcer_secret[server], type, cargo))
	return response

/world/proc/send_ban_announce(ckey = null, ip = null, cid = null)
	if (!config.net_announcers["ban_send"])
		return FALSE
	var/list/data = list()
	if (ckey)
		data["ckey"] = ckey
	if (ip)
		data["ip"] = ip
	if (cid)
		data["cid"] = cid
	if (length(data))
		var/list/received_data = send_net_announce(NET_ANNOUNCE_BAN, data)
		for(var/R in received_data)
			var/number_kicked = text2num(received_data[R])
			if (number_kicked)
				message_admins("Kicked [number_kicked] player(s) on [R]")
		return TRUE
	return FALSE

/world/proc/receive_net_announce(list/packet_data, sender)
	// validate message from /world/Topic
	// actions in proccess_net_announce
	if (
		!length(global.net_announcer_secret) || \
		!islist(packet_data) || \
		packet_data["announce"] != "" || \
		!istext(packet_data["secret"]) || !length(packet_data["secret"]) || \
		!istext(packet_data["type"]) || !length(packet_data["type"])
	)
		return
	var/self = global.net_announcer_secret[1]
	if (!self || packet_data["secret"] != global.net_announcer_secret[self])
		// log_misc("Unauthorized connection for net_announce [sender]")
		return

	packet_data["secret"] = "SECRET"
	log_href("WTOPIC: NET ANNOUNCE: \"[list2params(packet_data)]\", from:[sender]")
	
	return proccess_net_announce(packet_data["type"], packet_data, sender)

/world/proc/proccess_net_announce(type, list/data, sender)
	var/self_flag = FALSE
	if (sender == ("127.0.0.1:[world.port]"))
		self_flag = TRUE
	switch(type)
		if (NET_ANNOUNCE_BAN)
			// legacy system use files, we need DB for ban check
			if (config.net_announcers["ban_receive"] && !self_flag && config && !config.ban_legacy_system)
				return proccess_ban_announce(data, sender)
	return

/world/proc/proccess_ban_announce(list/data, sender, self)
	var/list/to_kick = list()
	for (var/mob/M in global.player_list)
		var/list/ban_key = list()
		if (data["ckey"] && M.ckey && M.ckey == data["ckey"])
			ban_key += "ckey([data["ckey"]])"
		if (data["cid"] && M.computer_id && M.computer_id == data["cid"])
			ban_key += "cid([data["cid"]])"
		if (data["ip"] && M.client && M.client.address && M.client.address == data["ip"])
			ban_key += "ip([data["ip"]])"
		if (length(ban_key))
			var/banned = world.IsBanned(data["ckey"], data["ip"],  data["cid"], real_bans_only = TRUE)
			if (banned && banned["reason"] && banned["desc"])
				to_kick[M] = banned["desc"]
				var/notify = text("Player [] kicked by ban announce from []. Reason: []. Matched [].", M.ckey, sender, banned["reason"], ban_key.Join(", "))
				// message_admins(notify)
				log_admin(notify)
	for (var/mob/K in to_kick)
		if (K.client)
			// Message queue sometimes slow, setup 2 seconds delay
			to_chat(K, "<span class='warning'><BIG><B>You kicked from the server.</B></BIG></span>")
			to_chat(K, "<span class='warning'>[to_kick[K]]</span>")
			QDEL_IN(K.client, 20)
	return length(to_kick)

#undef NET_ANNOUNCE_BAN
