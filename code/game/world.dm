var/round_id = 0
var/base_commit_sha = 0
var/logs_folder

#define RECOMMENDED_VERSION 512
/world/New()
#ifdef DEBUG
	enable_debugger()
#endif

	//logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")
	href_logfile = file("data/logs/[date_string] hrefs.htm")
	diary = file("data/logs/[date_string].log")
	diary << "[log_end]\n[log_end]\nStarting up. [time2text(world.timeofday, "hh:mm.ss")][log_end]\n---------------------[log_end]"

	if(byond_version < RECOMMENDED_VERSION)
		world.log << "Your server's byond version does not meet the recommended requirements for this server. Please update BYOND"

	make_datum_references_lists() //initialises global lists for referencing frequently used datums (so that we only ever do it once)

	load_configuration()
	load_regisration_panic_bunker()
	load_stealth_keys()
	load_mode()
	load_last_mode()
	load_motd()
	load_host_announcements()
	load_test_merge()
	load_admins()
	load_mentors()
	load_supporters()
	if(config.usewhitelist)
		load_whitelist()
	if(config.usealienwhitelist)
		load_whitelistSQL()
	load_proxy_whitelist()
	LoadBans()
	investigate_reset()

	spawn
		changelog_hash = trim(get_webpage(config.changelog_hash_link))

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	if(config && config.log_runtime)
		log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD-(hh-mm-ss)")]-runtime.log")

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

	spawn(10)
		Master.Setup()

	if(!setup_old_database_connection())
		log_sql("Your server failed to establish a connection with the SQL database.")
	else
		log_sql("SQL database connection established.")

	if(!setup_database_connection())
		log_sql("Your server failed to establish a connection with the feedback database.")
	else
		log_sql("Feedback database connection established.")

	SetRoundID()
	base_commit_sha = GetGitMasterCommit(1)

	var/date = time2text(world.realtime, "YYYY/MM/DD")
	logs_folder = "data/stat_logs/[date]/round-"

	if(round_id)
		logs_folder += round_id
	else
		var/timestamp = replacetext(time_stamp(), ":", ".")
		logs_folder += "[timestamp]"

	Get_Holiday()

	src.update_status()

	round_log("Server starting up")

	if(base_commit_sha)
		info("Base SHA: [base_commit_sha]")

	if(fexists("test_merge.txt"))
		info("TM: [trim(file2text("test_merge.txt"))]")

	. = ..()

#ifdef UNIT_TEST
	log_unit_test("Unit Tests Enabled. This will destroy the world when testing is complete.")
#endif

	spawn(3000)		//so we aren't adding to the round-start lag
		if(config.kick_inactive)
			KickInactiveClients()

#undef RECOMMENDED_VERSION

	return

//world/Topic(href, href_list[])
//		world << "Received a Topic() call!"
//		world << "[href]"
//		for(var/a in href_list)
//			world << "[a]"
//		if(href_list["hello"])
//			world << "Hello world!"
//			return "Hello world!"
//		world << "End of Topic() call."
//		..()

var/world_topic_spam_protect_ip = "0.0.0.0"
var/world_topic_spam_protect_time = world.timeofday

/world/Topic(T, addr, master, key)
	diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key][log_end]"

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		var/n = 0
		for(var/mob/M in player_list)
			if(M.client)
				n++
		return n

	else if (T == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = custom_event_msg ? "event" : master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
		s["host"] = host ? host : null
		s["players"] = list()
		s["stationtime"] = worldtime2text()
		s["gamestate"] = ticker.current_state
		s["roundduration"] = roundduration2text()
		s["map_name"] = SSmapping.config?.map_name || "Loading..."
		s["popcap"] = config.client_limit_panic_bunker_count ? config.client_limit_panic_bunker_count : 0
		s["round_id"] = round_id
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

	else if(copytext(T,1,9) == "adminmsg")
		/*
			We got an adminmsg from IRC bot lets split the input then validate the input.
			expected output:
				1. adminmsg = ckey of person the message is to
				2. msg = contents of message, parems2list requires
				3. validatationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
				4. sender = the ircnick that send the message.
		*/


		var/input[] = params2list(T)
		if(input["key"] != config.comms_password)
			if(world_topic_spam_protect_ip == addr && abs(world_topic_spam_protect_time - world.time) < 50)

				spawn(50)
					world_topic_spam_protect_time = world.time
					return "Bad Key (Throttled)"

			world_topic_spam_protect_time = world.time
			world_topic_spam_protect_ip = addr

			return "Bad Key"

		var/client/C

		for(var/client/K in clients)
			if(K.ckey == input["adminmsg"])
				C = K
				break
		if(!C)
			return "No client with that name on server"

		var/message =	"<font color='red'>IRC-Admin PM from <b><a href='?irc_msg=1'>[C.holder ? "IRC-" + input["sender"] : "Administrator"]</a></b>: [input["msg"]]</font>"
		var/amessage =  "<font color='blue'>IRC-Admin PM from <a href='?irc_msg=1'>IRC-[input["sender"]]</a> to <b>[key_name(C)]</b> : [input["msg"]]</font>"

		C.received_irc_pm = world.time
		C.irc_admin = input["sender"]

		C.mob.playsound_local(null, 'sound/effects/adminhelp.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)
		to_chat(C, message)


		for(var/client/A in admins)
			if(A != C)
				to_chat(A, amessage)

		return "Message Successful"

	else if(copytext(T,1,6) == "notes")
		/*
			We got a request for notes from the IRC Bot
			expected output:
				1. notes = ckey of person the notes lookup is for
				2. validationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
		*/
		var/input[] = params2list(T)
		if(input["key"] != config.comms_password)
			if(world_topic_spam_protect_ip == addr && abs(world_topic_spam_protect_time - world.time) < 50)

				spawn(50)
					world_topic_spam_protect_time = world.time
					return "Bad Key (Throttled)"

			world_topic_spam_protect_time = world.time
			world_topic_spam_protect_ip = addr
			return "Bad Key"

		return show_player_info_irc(input["notes"])



/world/proc/PreShutdown(end_state)

	if(dbcon.IsConnected())
		end_state = end_state ? end_state : "undefined"
		var/DBQuery/query_round_shutdown = dbcon.NewQuery("UPDATE erro_round SET shutdown_datetime = Now(), end_state = '[sanitize_sql(end_state)]' WHERE id = [round_id]")
		query_round_shutdown.Execute()

		dbcon.Disconnect()

	if(dbcon_old.IsConnected())
		dbcon_old.Disconnect()

	world.log << "Runtimes count: [total_runtimes]. Runtimes skip count: [total_runtimes_skipped]."

/* ToDo: these logs are too spamming, we should create different log for this. Also we have Debug buttons for this.

	// Bad initializations log.
	var/initlog = SSatoms.InitLog()
	if(initlog)
		world.log << initlog

	// Adds the del() log to world.log in a format condensable by the runtime condenser found in tools
	var/list/dellog = list()

	//sort by how long it's wasted hard deleting
	sortTim(SSgarbage.items, cmp=/proc/cmp_qdel_item_time, associative = TRUE)
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
	world.log << dellog.Join("\n")

*/

var/shutdown_processed = FALSE

/world/Reboot(reason = 0, end_state)
	PreShutdown(end_state)

	for(var/client/C in clients)
		//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
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
	if(!shutdown_processed) //if SIGTERM signal, not restart/reboot
		PreShutdown("Graceful shutdown")
		round_log("Graceful shutdown")

	..()

#define INACTIVITY_KICK	6000	//10 minutes in ticks (approx.)
/world/proc/KickInactiveClients()
	spawn(-1)
		//set background = 1
		while(1)
			sleep(INACTIVITY_KICK)
			for(var/client/C in clients)
				if(C.is_afk(INACTIVITY_KICK))
					if(!istype(C.mob, /mob/dead))
						log_access("AFK: [key_name(C)]")
						to_chat(C, "<span class='userdanger'>You have been inactive for more than 10 minutes and have been disconnected.</span>")
						del(C)
#undef INACTIVITY_KICK

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

/world/proc/load_test_merge()
	if(fexists("test_merge.txt"))
		join_test_merge = "<strong>Test merged PRs:</strong> "
		var/list/prs = splittext(trim(file2text("test_merge.txt")), " ")
		for(var/pr in prs)
			join_test_merge += "<a href='[config.repository_link]/pull/[pr]'>#[pr]</a> "

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

/world/proc/load_supporters()
	if(config.allow_donators && fexists("config/donators.txt"))
		var/L = file2list("config/donators.txt")
		for(var/line in L)
			if(!length(line))
				continue
			if(copytext(line,1,2) == "#")
				continue
			donators.Add(ckey(line))

	// just some tau ceti specific stuff
	if(config.allow_tauceti_patrons)
		var/w = get_webpage("https://taucetistation.org/patreon/json")
		if(!w)
			warning("Failed to load taucetistation.org patreon list")
			message_admins("Failed to load taucetistation.org patreon list, please inform responsible persons")
		else
			var/list/l = json2list(w)
			for(var/i in l)
				if(l[i]["reward_price"] == "5.00")
					donators.Add(ckey(l[i]["name"]))

	for(var/client/C in clients)
		C.update_supporter_status()

/client/proc/update_supporter_status()
	if(ckey in donators || config.allow_byond_membership && IsByondMember())
		supporter = 1


/world/proc/load_proxy_whitelist()
	if(!fexists("config/proxy_whitelist.txt"))
		return
	var/L = file2list("config/proxy_whitelist.txt")
	for(var/line in L)
		if(!length(line))
			continue
		if(copytext(line,1,2) == "#")
			continue
		proxy_whitelist.Add(ckey(line))


/world/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.loadsql("config/dbconfig.txt")
	config.loadmaplist("config/maps.txt")
	// apply some settings from config..
	abandon_allowed = config.respawn


/world/proc/update_status()
	var/s = ""

	if (config && config.server_name)
		s += "<b>[config.server_name]</b> &#8212; "

	s += "<b>[station_name()]</b>";
	s += " ("
	s += "<a href=\"http://tauceti.ru\">" //Change this to wherever you want the hub to link to.
//	s += "[game_version]"
	s += "site"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
	s += "</a>"
	s += ")"

	var/list/features = list()

	if(ticker)
		if(master_mode)
			features += master_mode
	else
		features += "<b>STARTING</b>"

	if (!enter_allowed)
		features += "closed"

	features += abandon_allowed ? "respawn" : "no respawn"

	if (config && config.allow_vote_mode)
		features += "vote"

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
	if(!dbcon.IsConnected())
		return
	var/DBQuery/query_round_initialize = dbcon.NewQuery("INSERT INTO erro_round (initialize_datetime, server_ip, server_port) VALUES (Now(), INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]')")
	query_round_initialize.Execute()
	var/DBQuery/query_round_last_id = dbcon.NewQuery("SELECT LAST_INSERT_ID()")
	query_round_last_id.Execute()
	if(query_round_last_id.NextRow())
		round_id = query_round_last_id.item[1]
		log_game("New round: #[round_id]\n-------------------------")
		world.log << "New round: #[round_id]\n-------------------------"

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0
var/failed_old_db_connections = 0

/proc/setup_database_connection()

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
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

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
/proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1

//These two procs are for the old database, while it's being phased out. See the tgstation.sql file in the SQL folder for more information.
/proc/setup_old_database_connection()

	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon_old)
		dbcon_old = new()

	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon_old.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon_old.IsConnected()
	if ( . )
		failed_old_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_old_db_connections++		//If it failed, increase the failed connections counter.
		world.log << dbcon.ErrorMsg()

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
/proc/establish_old_db_connection()
	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon_old || !dbcon_old.IsConnected())
		return setup_old_database_connection()
	else
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

#ifdef DEBUG
/world/proc/enable_debugger()
	var/dll = world.GetConfig("env", "EXTOOLS_DLL")
	if (dll)
		call(dll, "debug_initialize")()
#endif
