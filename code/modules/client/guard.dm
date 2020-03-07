var/global/geoip_exports = 0 // debug, remove me

/datum/guard/
	var/client/holder
	var/total_alert_weight = 0

	var/list/geoip_data
	var/list/geoip_processed = FALSE

	var/list/chat_data = list("cookie_match", "charset")
	var/list/chat_processed = FALSE
	
	var/list/tests_processed = FALSE
	var/report = ""

	var/bridge_reported = FALSE

/datum/guard/New(client/C)
	holder = C

	if(!config.guard_enabled || !config.guard_email)
		return

	addtimer(CALLBACK(src, .proc/trigger_init), 10 SECONDS) // time for other systems to collect data


/datum/guard/proc/trigger_init()
	if(holder && isnum(holder.player_ingame_age) && holder.player_ingame_age < 60)
		load_geoip() // this may takes a few minutes in bad case
		do_announce()

/datum/guard/proc/do_announce()
	if(!tests_processed)
		do_tests()
	if(!total_alert_weight)
		return
	message_admins("GUARD: new player [key_name_admin(holder)] is suspicious with [total_alert_weight] weight (<a href='?_src_=holder;guard=\ref[holder.mob]'>report</a>)", R_LOG)
	log_admin("GUARD: new player [key_name(holder)] is suspicious with [total_alert_weight] weight")
	log_admin("GUARD: DEBUG: [report]") // debug, remove me

	if(!bridge_reported && total_alert_weight > 1)
		send2bridge_adminless_only("GUARD: new player [key_name(holder)] (<http://byond.com/members/[holder.ckey]>) is suspicious with **[total_alert_weight]** weight", type = list(BRIDGE_ADMINIMPORTANT))
		bridge_reported = TRUE

/datum/guard/proc/print_report()
	if(!geoip_processed)
		load_geoip()

	do_tests()

	var/datum/browser/popup = new(usr, "guard_report_[holder.ckey]", "Guard report on [holder.key]", 350)
	popup.set_content(src.report)
	popup.open()

/datum/guard/proc/do_tests()
	report = ""
	total_alert_weight = 0

	/* geoip */
	if(geoip_processed)
		var/geoip_weight = 0
		geoip_weight += geoip_data["proxy"]   ? 0.4 : 0 // low weight because false-positives
		geoip_weight += geoip_data["mobile"]  ? 0.2 : 0
		geoip_weight += geoip_data["hosting"] ? 1 : 0

		geoip_weight += geoip_data["ipintel"]>0 ? geoip_data["ipintel"] : 0

		report += {"<div class='block'><h3>GeoIP ([holder.address]): [geoip_weight]</h3>
		Connected from ([geoip_data["country"]], [geoip_data["regionName"]], [geoip_data["city"]]) using ISP: ([geoip_data["isp"]])<br>
		Remember: next flags may be false-positives!<br>
		Proxy: [geoip_data["proxy"]];<br> Mobile: [geoip_data["mobile"]];<br> Hosting: [geoip_data["hosting"]];<br> Ipintel: [geoip_data["ipintel"]];</div>"}

		total_alert_weight += geoip_weight

	/* country */
	if(geoip_processed && geoip_data["countryCode"] && length(config.guard_whitelisted_country_codes))
		var/country_weight = 0
		if(!(geoip_data["countryCode"] in config.guard_whitelisted_country_codes))
			country_weight += 0.5

			report += {"<div class='block'><h3>Country ([geoip_data["countryCode"]]/[geoip_data["country"]]): [country_weight]</h3></div>"}

		total_alert_weight += country_weight

	/* browser & cookie */
	if(chat_processed)
		var/cookie_weight = 0
		if(chat_data["cookie_match"])
			cookie_weight += 2

			report += {"<div class='block'><h3>Cookie: [cookie_weight]</h3>
			Matched: [chat_data["cookie_match"]["ckey"]], [chat_data["cookie_match"]["ip"]], [chat_data["cookie_match"]["compid"]].<br>
			There may be other accounts, we show only first.</div>"}

		total_alert_weight += cookie_weight

	/* ru-specific, not sure about it. 513/post-IE should be removed */
	if(length(config.guard_whitelisted_country_codes) && chat_processed)
		var/charset_weight = 0
		if(!(geoip_data["countryCode"] in config.guard_whitelisted_country_codes) && chat_data["charset"] == "windows1251")
			charset_weight += 1
			
			report += {"<div class='block'><h3>Charset: [charset_weight]</h3>
			Charset not ordinary for country.</div>"}

		total_alert_weight += charset_weight

	/* database related accounts */
	if((length(holder.related_accounts_cid) && holder.related_accounts_cid != "Requires database") || (length(holder.related_accounts_ip) && holder.related_accounts_ip != "Requires database"))
		var/related_db_weight = 0
		related_db_weight += holder.related_accounts_ip ? 0.2 : 0
		related_db_weight += holder.related_accounts_cid ? 0.5 : 0

		report += {"<div class='block'><h3>Related accounts: [related_db_weight]</h3>
		By CID: [holder.related_accounts_cid ? holder.related_accounts_cid : "none"];<br>
		By IP:  [holder.related_accounts_ip ? holder.related_accounts_ip : "none"];</div>"}

		total_alert_weight += related_db_weight

	if(holder.prefs.cid_list.len > 1)
		var/multicid_weight = 0
		
		multicid_weight += (holder.prefs.cid_list.len - 1) * 0.1// new account, should not be many

		report += {"<div class='block'><h3>Differents CID's: [multicid_weight]</h3>
		Has [holder.prefs.cid_list.len] different computer_id.</div>"}

		total_alert_weight += multicid_weight

	//age & byond profile tests (useless)

	report += "<div class='block'>Total Weight: [total_alert_weight]</div>"
	
	tests_processed = TRUE

/datum/guard/proc/load_geoip(var/force_reload = FALSE)
	if(!config.guard_enabled || !config.guard_email)
		return

	if(geoip_processed && !force_reload)
		return

	var/cache_path = ("data/player_saves/[copytext(holder.ckey,1,2)]/[holder.ckey]/geoip.sav")
	
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

	if(!ipintel)
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
		geoip_exports++

		if(response && text2num(response["STATUS"]) == 200)
			return json_decode(file2text(response["CONTENT"]))

		geoip_failed_attempts++
		sleep(10 SECONDS)

	return