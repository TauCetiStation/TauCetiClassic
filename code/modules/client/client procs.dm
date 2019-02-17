	////////////
	//SECURITY//
	////////////
#define TOPIC_SPAM_DELAY	2		//2 ticks is about 2/10ths of a second; it was 4 ticks, but that caused too many clicks to be lost due to lag
#define UPLOAD_LIMIT		10485760	//Restricts client uploads to the server to 10MB //Boosted this thing. What's the worst that can happen?

var/list/blacklisted_builds = list(
	"1407" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1408" = "bug preventing client display overrides from working leads to clients being able to see things/mobs they shouldn't be able to see",
	"1428" = "bug causing right-click menus to show too many verbs that's been fixed in version 1429",
	"1434" = "bug turf images weren't reapplied properly when moving around the map",
	)

	/*
	When somebody clicks a link in game, this Topic is called first.
	It does the stuff in this proc and  then is redirected to the Topic() proc for the src=[0xWhatever]
	(if specified in the link). ie locate(hsrc).Topic()

	Such links can be spoofed.

	Because of this certain things MUST be considered whenever adding a Topic() for something:
		- Can it be fed harmful values which could cause runtimes?
		- Is the Topic call an admin-only thing?
		- If so, does it have checks to see if the person who called it (usr.client) is an admin?
		- Are the processes being called by Topic() particularly laggy?
		- If so, is there any protection against somebody spam-clicking a link?
	If you have any  questions about this stuff feel free to ask. ~Carn
	*/
/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	if(href_list["_src_"] == "chat")
		return chatOutput.Topic(href, href_list)

	//Reduces spamming of links by dropping calls that happen during the delay period
	if(next_allowed_topic_time > world.time)
		return
	next_allowed_topic_time = world.time + TOPIC_SPAM_DELAY

	//search the href for script injection
	if( findtext(href,"<script",1,0) )
		world.log << "Attempted use of scripts within a topic call, by [src]"
		message_admins("Attempted use of scripts within a topic call, by [src]")
		//del(usr)
		return

	if(href_list["asset_cache_confirm_arrival"])
		//to_chat(src, "ASSET JOB [href_list["asset_cache_confirm_arrival"]] ARRIVED.")
		var/job = text2num(href_list["asset_cache_confirm_arrival"])
		completed_asset_jobs += job
		return

	if (href_list["action"] && href_list["action"] == "debugFileOutput" && href_list["file"] && href_list["message"])
		var/file = href_list["file"]
		var/message = href_list["message"]
		debugFileOutput.error(file, message, src)
		return

	//Admin PM
	if(href_list["priv_msg"])
		var/client/C = locate(href_list["priv_msg"])
		if(ismob(C)) 		//Old stuff can feed-in mobs instead of clients
			var/mob/M = C
			C = M.client
		if(href_list["ahelp_reply"])
			cmd_ahelp_reply(C)
			return
		cmd_admin_pm(C,null)
		return

	if(href_list["irc_msg"])
		if(!holder && received_irc_pm < world.time - 6000) //Worse they can do is spam IRC for 10 minutes
			to_chat(usr, "<span class='warning'>You are no longer able to use this, it's been more then 10 minutes since an admin on IRC has responded to you</span>")
			return
		if(mute_irc)
			to_chat(usr, "<span class='warning'You cannot use this as your client has been muted from sending messages to the admins on IRC</span>")
			return
		cmd_admin_irc_pm()
		return

	//Logs all hrefs
	if(config && config.log_hrefs && href_logfile)
		href_logfile << "<small>[time2text(world.timeofday,"hh:mm")] [src] (usr:[usr])</small> || [hsrc ? "[hsrc] " : ""][href]<br>"

	switch(href_list["_src_"])
		if("holder")	hsrc = holder
		if("usr")		hsrc = mob
		if("prefs")		return prefs.process_link(usr,href_list)
		if("vars")		return view_var_Topic(href,href_list,hsrc)

	switch(href_list["action"])
		if ("openLink")
			src << link(href_list["link"])

	..()	//redirect to hsrc.Topic()

/client/proc/handle_spam_prevention(message, mute_type)
	if(global_message_cooldown && (world.time < last_message_time + 5))
		return 1
	if(config.automute_on && !holder && src.last_message == message)
		src.last_message_count++
		if(src.last_message_count >= SPAM_TRIGGER_AUTOMUTE)
			to_chat(src, "\red You have exceeded the spam filter limit for identical messages. An auto-mute was applied.")
			cmd_admin_mute(src.mob, mute_type, 1)
			return 1
		if(src.last_message_count >= SPAM_TRIGGER_WARNING)
			to_chat(src, "\red You are nearing the spam filter limit for identical messages.")
			return 0
	else
		last_message_time = world.time
		last_message = message
		src.last_message_count = 0
		return 0

//This stops files larger than UPLOAD_LIMIT being sent from client to server via input(), client.Import() etc.
/client/AllowUpload(filename, filelength)
	if(filelength > UPLOAD_LIMIT)
		to_chat(src, "<font color='red'>Error: AllowUpload(): File Upload too large. Upload Limit: [UPLOAD_LIMIT/1024]KiB.</font>")
		return 0
/*	//Don't need this at the moment. But it's here if it's needed later.
	//Helps prevent multiple files being uploaded at once. Or right after eachother.
	var/time_to_wait = fileaccess_timer - world.time
	if(time_to_wait > 0)
		to_chat(src, "<font color='red'>Error: AllowUpload(): Spam prevention. Please wait [round(time_to_wait/10)] seconds.</font>")
		return 0
	fileaccess_timer = world.time + FTPDELAY	*/
	return 1


	///////////
	//CONNECT//
	///////////
/client/New(TopicData)
	chatOutput = new /datum/chatOutput(src) // Right off the bat.
	var/tdata = TopicData //save this for later use
	TopicData = null							//Prevent calls to client.Topic from connect

	if(connection != "seeker")					//Invalid connection type.
		return null

	if(IsGuestKey(key))
		alert(src,"This server doesn't allow guest accounts to play. Please go to http://www.byond.com/ and register for a key.","Guest","OK")
		qdel(src)
		return

	// Change the way they should download resources.
	if(config.resource_urls)
		src.preload_rsc = pick(config.resource_urls)
	else src.preload_rsc = 1 // If config.resource_urls is not set, preload like normal.

	to_chat(src, "\red If the title screen is black, resources are still downloading. Please be patient until the title screen appears.")


	clients += src
	directory[ckey] = src

	//Admin Authorisation
	holder = admin_datums[ckey]
	if(holder)
		holder.owner = src
		admins += src
		if(holder.deadminned)
			holder.disassociate()
			verbs += /client/proc/readmin_self

	if(ckey in mentor_ckeys)
		mentors += src

	//preferences datum - also holds some persistant data for the client (because we may as well keep these datums to a minimum)
	prefs = preferences_datums[ckey]
	if(prefs)
		prefs.parent = src
	else
		prefs = new /datum/preferences(src)
		preferences_datums[ckey] = prefs
	prefs.last_ip = address				//these are gonna be used for banning
	prefs.last_id = computer_id			//these are gonna be used for banning

	var/cur_date = time2text(world.realtime, "YYYY/MM/DD hh:mm:ss")
	if("[computer_id]" in prefs.cid_list)
		prefs.cid_list["[computer_id]"]["last_seen"] = cur_date
	else
		prefs.cid_list["[computer_id]"] = list("first_seen"=cur_date, "last_seen"=cur_date)

	if(prefs.cid_list.len > 2)
		log_admin("[ckey] has [prefs.cid_list.len] different computer_id.")
		message_admins("[ckey] has <span class='red'>[prefs.cid_list.len]</span> different computer_id.")

	prefs.save_preferences()

	. = ..()	//calls mob.Login()
	spawn() // Goonchat does some non-instant checks in start()
		chatOutput.start()


	spawn(50)//should wait for goonchat initialization
		if(config.byond_version_min && byond_version < config.byond_version_min)
			to_chat(src, "<span class='warning bold'>Your version of Byond is too old. Update to the [config.byond_version_min] or later for playing on our server.</span>")
			log_access("Failed Login: [key] [computer_id] [address] - byond version less that minimal required: [byond_version].[byond_build])")
			if(!holder)
				qdel(src)
				return

		if(config.byond_version_recommend && byond_version < config.byond_version_recommend)
			to_chat(src, "<span class='warning bold'>Your version of Byond is less that recommended. Update to the [config.byond_version_recommend] for better experiense.</span>")

		if((byond_version >= 512 && (!byond_build || byond_build < 1421)) || num2text(byond_build) in blacklisted_builds)
			to_chat(src, "<span class='warning bold'>You are using the inappropriate Byond version. Update to the latest Byond version or install another from http://www.byond.com/download/build/ for playing on our server.</span>")
			message_admins("<span class='adminnotice'>[key_name(src)] has been detected as using a inappropriate byond version: [byond_version].[byond_build]. Connection rejected.</span>")
			log_access("Failed Login: [key] [computer_id] [address] - inappropriate byond version: [byond_version].[byond_build])")
			if(!holder)
				qdel(src)
				return

	if(custom_event_msg && custom_event_msg != "")
		to_chat(src, "<h1 class='alert'>Custom Event</h1>")
		to_chat(src, "<h2 class='alert'>A custom event is taking place. OOC Info:</h2>")
		to_chat(src, "<span class='alert'>[custom_event_msg]</span>")
		to_chat(src, "<br>")

	if( (world.address == address || !address) && !host )
		host = key
		world.update_status()

	if(holder)
		add_admin_verbs()
		admin_memo_show()

	if (config.allow_donators && (ckey in donators) || config.allow_byond_membership && IsByondMember())
		supporter = 1
		to_chat(src, "<span class='info bold'>Hello [key]! Thanks for supporting [(ckey in donators) ? "us" : "Byond"]! You are awesome! You have access to all the additional supporters-only features this month.</span>")

	log_client_to_db(tdata)

	send_resources()

	generate_clickcatcher()

	if(prefs.lastchangelog != changelog_hash) // Bolds the changelog button on the interface so we know there are updates.
		to_chat(src, "<span class='info'>You have unread updates in the changelog.</span>")
		winset(src, "rpane.changelog", "font-style=bold;background-color=#B1E477")

	if(!geoip)
		geoip = new(src, address)

		//This is down here because of the browse() calls in tooltip/New()
	if(!tooltips)
		tooltips = new /datum/tooltip(src)

	if(!cob)
		cob = new()

	if(!winexists(src, "asset_cache_browser")) // The client is using a custom skin, tell them.
		to_chat(src, "<span class='warning'>Unable to access asset cache browser, \
		if you are using a custom skin file, please allow DS to download the updated version, if you are not, then make a bug report. \
		This is not a critical issue but can cause issues with resource downloading, as it is impossible to know when extra resources arrived to you.</span>")


	//////////////
	//DISCONNECT//
	//////////////
/client/Del()
	log_client_ingame_age_to_db()
	if(cob && cob.in_building_mode)
		cob.remove_build_overlay(src)
	if(holder)
		holder.owner = null
		admins -= src
	directory -= ckey
	mentors -= src
	clients -= src
	QDEL_LIST_ASSOC_VAL(char_render_holders)
	if(movingmob != null)
		movingmob.client_mobs_in_contents -= mob
		UNSETEMPTY(movingmob.client_mobs_in_contents)
	return ..()



/client/proc/log_client_to_db(connectiontopic)

	if ( IsGuestKey(src.key) )
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/sql_ckey = sql_sanitize_text(src.ckey)

	var/DBQuery/query = dbcon.NewQuery("SELECT id, datediff(Now(),firstseen) as age, ingameage FROM erro_player WHERE ckey = '[sql_ckey]'")
	query.Execute()
	var/sql_id = 0
	player_age = 0	// New players won't have an entry so knowing we have a connection we set this to zero to be updated if their is a record.
	player_ingame_age = 0
	while(query.NextRow())
		sql_id = query.item[1]
		player_age = text2num(query.item[2])
		player_ingame_age = text2num(query.item[3])
		break

	var/DBQuery/query_ip = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE ip = '[address]'")
	query_ip.Execute()
	related_accounts_ip = ""
	while(query_ip.NextRow())
		related_accounts_ip += "[query_ip.item[1]], "
		break

	var/DBQuery/query_cid = dbcon.NewQuery("SELECT ckey FROM erro_player WHERE computerid = '[computer_id]'")
	query_cid.Execute()
	related_accounts_cid = ""
	while(query_cid.NextRow())
		related_accounts_cid += "[query_cid.item[1]], "
		break

	var/admin_rank = "Player"
	if (src.holder)
		admin_rank = src.holder.rank
	else if (config.check_randomizer && check_randomizer(connectiontopic))
		return

	//Just the standard check to see if it's actually a number
	if(sql_id)
		if(istext(sql_id))
			sql_id = text2num(sql_id)
		if(!isnum(sql_id))
			return

	var/sql_ip = sql_sanitize_text(src.address)
	var/sql_computerid = sql_sanitize_text(src.computer_id)
	var/sql_admin_rank = sql_sanitize_text(admin_rank)


	if(sql_id)
		//Player already identified previously, we need to just update the 'lastseen', 'ip' and 'computer_id' variables
		var/DBQuery/query_update = dbcon.NewQuery("UPDATE erro_player SET lastseen = Now(), ip = '[sql_ip]', computerid = '[sql_computerid]', lastadminrank = '[sql_admin_rank]' WHERE id = [sql_id]")
		query_update.Execute()
	else if(!config.serverwhitelist)
		//New player!! Need to insert all the stuff
		var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO erro_player (id, ckey, firstseen, lastseen, ip, computerid, lastadminrank, ingameage) VALUES (null, '[sql_ckey]', Now(), Now(), '[sql_ip]', '[sql_computerid]', '[sql_admin_rank]', '[player_ingame_age]')")
		query_insert.Execute()

	//Logging player access
	var/serverip = "[world.internet_address]:[world.port]"
	var/DBQuery/query_accesslog = dbcon.NewQuery("INSERT INTO `erro_connection_log`(`id`,`datetime`,`serverip`,`ckey`,`ip`,`computerid`) VALUES(null,Now(),'[serverip]','[sql_ckey]','[sql_ip]','[sql_computerid]');")
	query_accesslog.Execute()

/client/proc/check_randomizer(topic)
	. = FALSE
	if (connection != "seeker")
		return
	topic = params2list(topic)
	var/static/cidcheck = list()
	var/static/tokens = list()
	var/static/cidcheck_failedckeys = list() //to avoid spamming the admins if the same guy keeps trying.
	var/static/cidcheck_spoofckeys = list()

	var/oldcid = cidcheck[ckey]

	if (oldcid)
		if (!topic || !topic["token"] || !tokens[ckey] || topic["token"] != tokens[ckey])
			if (!cidcheck_spoofckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name(src)] appears to have attempted to spoof a cid randomizer check.</span>")
				cidcheck_spoofckeys[ckey] = TRUE
			cidcheck[ckey] = computer_id
			tokens[ckey] = cid_check_reconnect()

			sleep(10) //browse is queued, we don't want them to disconnect before getting the browse() command.
			del(src)
			return TRUE

		if (oldcid != computer_id) //IT CHANGED!!!
			cidcheck -= ckey //so they can try again after removing the cid randomizer.

			to_chat(src, "<span class='userdanger'>Connection Error:</span>")
			to_chat(src, "<span class='danger'>Invalid ComputerID(spoofed). Please remove the ComputerID spoofer from your byond installation and try again.</span>")

			if (!cidcheck_failedckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name(src)] has been detected as using a cid randomizer. Connection rejected.</span>")
				send2slack_logs(key_name(src), "has been detected as using a cid randomizer. Connection rejected.", "(CidRandomizer)")
				cidcheck_failedckeys[ckey] = TRUE
				notes_add(ckey, "Detected as using a cid randomizer.")

			log_access("Failed Login: [key] [computer_id] [address] - CID randomizer confirmed (oldcid: [oldcid])")

			del(src)
			return TRUE
		else
			if (cidcheck_failedckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name_admin(src)] has been allowed to connect after showing they removed their cid randomizer</span>")
				send2slack_logs(key_name(src), "has been allowed to connect after showing they removed their cid randomizer.", "(CidRandomizer)")
				cidcheck_failedckeys -= ckey
			if (cidcheck_spoofckeys[ckey])
				message_admins("<span class='adminnotice'>[key_name_admin(src)] has been allowed to connect after appearing to have attempted to spoof a cid randomizer check because it <i>appears</i> they aren't spoofing one this time</span>")
				cidcheck_spoofckeys -= ckey
			cidcheck -= ckey
	else
		var/sql_ckey = sanitize_sql(ckey)
		var/DBQuery/query_cidcheck = dbcon.NewQuery("SELECT computerid FROM erro_player WHERE ckey = '[sql_ckey]'")
		query_cidcheck.Execute()

		var/lastcid
		if (query_cidcheck.NextRow())
			lastcid = query_cidcheck.item[1]

		if (computer_id != lastcid)
			cidcheck[ckey] = computer_id
			tokens[ckey] = cid_check_reconnect()

			sleep(10) //browse is queued, we don't want them to disconnect before getting the browse() command.
			del(src)
			return TRUE

/client/proc/cid_check_reconnect()
	var/token = md5("[rand(0,9999)][world.time][rand(0,9999)][ckey][rand(0,9999)][address][rand(0,9999)][computer_id][rand(0,9999)]")
	. = token
	log_access("Failed Login: [key] [computer_id] [address] - CID randomizer check")
	var/url = winget(src, null, "url")
	//special javascript to make them reconnect under a new window.
	src << browse("<a id='link' href='byond://[url]?token=[token]'>byond://[url]?token=[token]</a><script type='text/javascript'>document.getElementById(\"link\").click();window.location=\"byond://winset?command=.quit\"</script>", "border=0;titlebar=0;size=1x1")
	to_chat(src, "<a href='byond://[url]?token=[token]'>You will be automatically taken to the game, if not, click here to be taken manually</a>")

/client/proc/log_client_ingame_age_to_db()
	if ( IsGuestKey(src.key) )
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	if(!isnum(player_ingame_age))
		return

	if(player_ingame_age <= 0)
		return

	var/sql_ckey = sql_sanitize_text(src.ckey)
	var/DBQuery/query_update = dbcon.NewQuery("UPDATE erro_player SET ingameage = '[player_ingame_age]' WHERE ckey = '[sql_ckey]'")
	query_update.Execute()

#undef TOPIC_SPAM_DELAY
#undef UPLOAD_LIMIT

/client/Click(atom/object, atom/location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers["drag"])
		return
	..()

//checks if a client is afk
//3000 frames = 5 minutes
/client/proc/is_afk(duration = 3000)
	if(inactivity > duration)
		return inactivity
	return 0

// Byond seemingly calls stat, each tick.
// Calling things each tick can get expensive real quick.
// So we slow this down a little.
// See: http://www.byond.com/docs/ref/info.html#/client/proc/Stat
/client/Stat()
	. = ..()
	if (holder)
		sleep(1)
	else
		sleep(5)
		stoplag()

// Send resources to the client.
/client/proc/send_resources()
	// Most assets are now handled through asset_cache.dm
	getFiles(
		'html/search.js', // Used in various non-NanoUI HTML windows for search functionality
		'html/panels.css' // Used for styling certain panels, such as in the new player panel
	)

	spawn (10) //removing this spawn causes all clients to not get verbs.
		//Precache the client with all other assets slowly, so as to not block other browse() calls
		getFilesSlow(src, SSasset.cache, register_asset = FALSE)

/client/proc/generate_clickcatcher()
	if(!void)
		void = new()
		screen += void

//This may help with UI's that were stuck and don't want to open anymore.
/client/verb/close_nanouis()
	set name = "Fix NanoUI (Close All)"
	set category = "OOC"
	set desc = "Closes all opened NanoUI."

	to_chat(src, "<span class='notice'>You forcibly close any opened NanoUI interfaces.")
	nanomanager.close_user_uis(usr)

/client/proc/show_character_previews(mutable_appearance/MA)
	var/pos = 0
	for(var/D in cardinal)
		pos++
		var/obj/screen/O = LAZYACCESS(char_render_holders, "[D]")
		if(!O)
			O = new
			LAZYSET(char_render_holders, "[D]", O)
			screen |= O
		O.appearance = MA
		O.dir = D
		O.underlays += image('icons/turf/floors.dmi', "floor")
		O.screen_loc = "character_preview_map:0,[pos]"

/client/proc/clear_character_previews()
	for(var/index in char_render_holders)
		var/obj/screen/S = char_render_holders[index]
		screen -= S
		qdel(S)
	char_render_holders = null
