/datum/guard
	var/client/holder
	var/total_alert_weight = 0
	var/bridge_reported = FALSE

	var/tests_processed = FALSE
	var/report = ""
	var/short_report = ""

	var/list/geoip_data
	var/geoip_processed = FALSE

	var/list/chat_data = list("cookie_match", "charset")
	var/chat_processed = FALSE
	
	var/first_entry = FALSE

	var/time_velocity_spawn
	var/time_velocity_shuttle
	var/velocity_console = FALSE
	var/velocity_console_dock = FALSE

/datum/guard/New(client/C)
	holder = C

	if(!config.guard_enabled)
		return

	addtimer(CALLBACK(src, .proc/trigger_init), 20 SECONDS) // time for other systems to collect data

/datum/guard/proc/trigger_init()
	if(holder && isnum(holder.player_ingame_age) && holder.player_ingame_age < GUARD_CHECK_AGE)
		load_geoip() // this may takes a few minutes in bad case
		
		if(!tests_processed)
			do_tests()

		do_announce()

		if(isnum(config.guard_autoban_treshhold) && total_alert_weight >= config.guard_autoban_treshhold)
			process_autoban()

/datum/guard/proc/do_announce()
	if(!total_alert_weight || total_alert_weight < 1)
		return

	message_admins("GUARD: new player [key_name_admin(holder)] is suspicious with [total_alert_weight] weight (<a href='?_src_=holder;guard=\ref[holder.mob]'>report</a>)", R_LOG)
	log_admin("GUARD: new player [key_name(holder)] is suspicious with [total_alert_weight] weight[log_end]\nGUARD: [short_report]")

	if(!bridge_reported)
		bridge_reported = TRUE
		send2bridge_adminless_only("GUARD: [key_name(holder)]", short_report, type = list(BRIDGE_ADMINIMPORTANT))

/datum/guard/proc/print_report()
	if(!geoip_processed)
		load_geoip()

	do_tests()

	var/datum/browser/popup = new(usr, "guard_report_[holder.ckey]", "Guard report on [holder.key]", 350)
	popup.set_content(src.report)
	popup.open()

//todo: pending tests
/datum/guard/proc/do_tests()
	var/new_report = ""
	var/new_short_report = ""
	total_alert_weight = 0

	/* geoip */
	if(!config.guard_email)
		new_report += "<span color='red'>Please configure guard_email for geoip</span>"

	if(geoip_processed)
		var/geoip_weight = 0

		// country cross-factor
		if(geoip_data["countryCode"] && length(config.guard_whitelisted_country_codes) && !(geoip_data["countryCode"] in config.guard_whitelisted_country_codes))
			geoip_weight += geoip_data["proxy"]   ? 1 : 0
			geoip_weight += geoip_data["hosting"] ? 1 : 0
		else
			geoip_weight += geoip_data["proxy"]   ? 0.5 : 0 // low weight because false-positives
			geoip_weight += geoip_data["hosting"] ? 0.5 : 0 // same


		geoip_weight += geoip_data["mobile"]  ? 0.2 : 0

		geoip_weight += geoip_data["ipintel"]>=0.9 ? geoip_data["ipintel"] : 0

		// todo: button to force new geoip
		new_report += {"<div class='block'><h3>GeoIP ([geoip_weight]):</h3>
		[first_entry ? "" : "Cached geoip from [time2text(geoip_data["date"], "DD.MM.YYYY")] for address: [holder.address]<br>"]
		Connected from ([geoip_data["country"]], [geoip_data["regionName"]], [geoip_data["city"]]) using ISP: ([geoip_data["isp"]])<br>
		Remember: next flags may be false-positives!<br>
		Proxy: [geoip_data["proxy"]];<br> Mobile: [geoip_data["mobile"]];<br> Hosting: [geoip_data["hosting"]];<br> Ipintel: [geoip_data["ipintel"]];</div>"}

		new_short_report += "Geoip:[geoip_data["proxy"]],[geoip_data["mobile"]],[geoip_data["hosting"]],[geoip_data["ipintel"]]; "

		total_alert_weight += geoip_weight

	/* country */
	if(geoip_processed && geoip_data["countryCode"] && length(config.guard_whitelisted_country_codes))
		var/country_weight = 0
		if(!(geoip_data["countryCode"] in config.guard_whitelisted_country_codes))
			country_weight += 0.5

			new_report += {"<div class='block'><h3>Country ([geoip_data["countryCode"]]/[geoip_data["country"]]): [country_weight]</h3></div>"}

			new_short_report += "[geoip_data["country"]]; "

		total_alert_weight += country_weight

	/* browser & cookie */
	if(chat_processed)
		var/cookie_weight = 0
		if(chat_data["cookie_match"])
			cookie_weight += 2

			new_report += {"<div class='block'><h3>Cookie ([cookie_weight]):</h3>
			Matched: [chat_data["cookie_match"]["ckey"]], [chat_data["cookie_match"]["ip"]], [chat_data["cookie_match"]["compid"]].<br>
			There may be other accounts, we show only first.</div>"}

			new_short_report += "Has cookie; "

		total_alert_weight += cookie_weight

	/* ru-specific, not sure about it. 513/post-IE should be removed */
	/*
	if(length(config.guard_whitelisted_country_codes) && chat_processed)
		var/charset_weight = 0
		if(!(geoip_data["countryCode"] in config.guard_whitelisted_country_codes) && chat_data["charset"] == "windows1251")
			charset_weight += 1

			if(first_entry)
				charset_weight += 0.5 // how he know
			
			new_report += {"<div class='block'><h3>Charset ([charset_weight]):</h3>
			Charset not ordinary for country[first_entry ? " <b>in the first entry</b>" : ""].</div>"}

			new_short_report += "Charset test failed(tw: [charset_weight]); "

		total_alert_weight += charset_weight
	*/

	/* database related accounts */
	if((length(holder.related_accounts_cid) && holder.related_accounts_cid != "Requires database") || (length(holder.related_accounts_ip) && holder.related_accounts_ip != "Requires database"))
		var/related_db_weight = 0
		// todo: check jobs/bans on related
		if(!(geoip_processed && geoip_data["mobile"])) // geoip cross-factor
			related_db_weight += holder.related_accounts_ip ? 0.2 : 0

		related_db_weight += holder.related_accounts_cid ? 0.5 : 0

		new_report += {"<div class='block'><h3>Related accounts ([related_db_weight]):</h3>
		By CID: [holder.related_accounts_cid ? holder.related_accounts_cid : "none"];<br>
		By IP:  [holder.related_accounts_ip ? holder.related_accounts_ip : "none"];</div>"}

		new_short_report += "Has related accounts in DB (tw: [related_db_weight]); "

		total_alert_weight += related_db_weight

	if(holder.prefs.cid_list.len > 1)
		var/multicid_weight = 0
		var/allowed_amount = 1

		if(isnum(holder.player_age) && holder.player_age > 60)
			allowed_amount++
		
		multicid_weight += min(((holder.prefs.cid_list.len - allowed_amount) * 0.35), 2) // new account, should not be many. 4 cids in the first hour -> +1 weight

		new_report += {"<div class='block'><h3>Differents CID's ([multicid_weight]):</h3>
		Has [holder.prefs.cid_list.len] different computer_id.</div>"}

		new_short_report += "Has [holder.prefs.cid_list.len] CID's (tw: [multicid_weight]); "

		total_alert_weight += multicid_weight

	// todo:
	// age & byond profile tests (useless)
	// timezone tests
	// speedrun tests

	/* No more tests, prepare reports (todo: some cleanup needet) */

	var/velocity_text
	if(time_velocity_spawn && time_velocity_shuttle)
		var/num_console = 0
		if(velocity_console)
			num_console++
		if(velocity_console_dock)
			num_console++
		velocity_text = "<b>Velocity run:</b> [round((time_velocity_shuttle - time_velocity_spawn)/10)] seconds[num_console ? "; Triggered [num_console] console(s)" : "" ]"


	var/byond_date_text
	var/list/byond_date = holder.get_byond_registration()
	if(length(byond_date))
		byond_date_text = "[byond_date[3]].[byond_date[2]].[byond_date[1]]"

	var/seen_text
	if(first_entry || isnum(holder.player_age))
		seen_text = "[first_entry ? "this round" : "[holder.player_age] days ago"]"

	new_report = {"<b>Total Weight:</b> [total_alert_weight]<br>
	[byond_date_text ? "<b>Byond registration:</b> [byond_date_text]<br>" : ""]
	[seen_text ? "<b>First seen:</b> [seen_text]<br>" : ""]
	[isnum(holder.player_ingame_age) ? "<b>Player ingame age:</b> [holder.player_ingame_age] minutes<br>" : ""]
	[velocity_text ? "---<br>[velocity_text]<br>": ""]
	[new_report]"}

	new_short_report = "TW: [total_alert_weight];[byond_date_text ? " Byond reg: [byond_date_text];" : ""][seen_text ? " First seen: [seen_text];" : ""][isnum(holder.player_ingame_age) ? " Ingame: [holder.player_ingame_age] min.;" : ""] [new_short_report]"

	report = new_report
	short_report = new_short_report
	tests_processed = TRUE

/datum/guard/proc/load_geoip(var/force_reload = FALSE)
	if(!config.guard_enabled || !config.guard_email)
		return

	if(geoip_processed && !force_reload)
		return

	var/cache_path = ("data/player_saves/[holder.ckey[1]]/[holder.ckey]/geoip.sav")
	
	if(fexists(cache_path) && !force_reload)
		var/savefile/S = new /savefile(cache_path)
		S["geoip"] >> geoip_data
		/* for updates:
			geoip_data["version"] < N
			... do something ...
		*/
		geoip_processed = TRUE
		return

	geoip_data = get_geoip_data("http://ip-api.com/json/[holder.address]?fields=country,countryCode,regionName,city,isp,mobile,proxy,hosting")

	if(!geoip_data)
		return

	var/list/ipintel = get_geoip_data("http://check.getipintel.net/check.php?ip=[holder.address]&format=json&flags=f&contact=[config.guard_email]")

	if(!length(ipintel))
		return

	geoip_data["ipintel"] = text2num(ipintel["result"])
	geoip_data["date"] = world.realtime

	var/savefile/S = new /savefile(cache_path)
	S["geoip"] << geoip_data

	geoip_processed = TRUE

/datum/guard/proc/get_geoip_data(url)
	var/attempts = 3
	var/static/geoip_failed_attempts = 0
	
	if(geoip_failed_attempts > 15)
		log_debug("GUARD: multiple get_geoip fails, geoip disabled for round")
		message_admins("GUARD: multiple get_geoip fails, geoip disabled for round", R_DEBUG)
		return

	while(attempts--)
		var/list/response = world.Export(url)

		if(response && text2num(response["STATUS"]) == 200)
			return json_decode(file2text(response["CONTENT"]))

		geoip_failed_attempts++
		sleep(10 SECONDS)

	return

/datum/guard/proc/process_autoban()

	if(!dbcon.IsConnected())
		message_admins("GUARD: autoban for [holder.ckey] not processed due to database connection problem.")
		return

	var/reason = config.guard_autoban_reason

	AddBan(holder.ckey, holder.computer_id, reason, "taukitty", 0, 0, holder.mob.lastKnownIP) // legacy bans base

	DB_ban_record_2(BANTYPE_PERMA, holder.mob, -1, reason) // copypaste, bans refactoring needed
	feedback_inc("ban_perma",1)

	ban_unban_log_save("Tau Kitty has permabanned [holder.ckey]. - Reason: [reason] - This is a permanent ban.")


	to_chat(holder, "<span class='danger'><BIG><B>You have been banned by Tau Kitty.\nReason: [reason].</B></BIG></span>")
	to_chat(holder, "<span class='red'>This is a permanent ban.</span>")
	if(config.banappeals)
		to_chat(holder, "<span class='red'>To try to resolve this matter head to [config.banappeals]</span>")

	log_admin("Tau Kitty has banned [holder.ckey].\nReason: [reason]\nThis is a permanent ban.")
	message_admins("Tau Kitty has banned [holder.ckey].\nReason: [reason]\nThis is a permanent ban.")

	if(config.guard_autoban_sticky)
		var/list/ban = list()
		ban[BANKEY_ADMIN] = "Tau Kitty"
		ban[BANKEY_TYPE] = list("sticky")
		ban[BANKEY_REASON] = "(AutoBan)(GUARD)"
		ban[BANKEY_CKEY] = holder.ckey
		ban[BANKEY_MSG] = "[reason]"
		
		if(!get_stickyban_from_ckey(holder.ckey))
			SSstickyban.add(holder.ckey, ban)

	QDEL_IN(holder, 2 SECONDS)
