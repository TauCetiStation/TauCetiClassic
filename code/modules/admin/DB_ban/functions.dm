//Either pass the mob you wish to ban in the 'banned_mob' attribute, or the banckey, banip and bancid variables. If both are passed, the mob takes priority! If a mob is not passed, banckey is the minimum that needs to be passed! banip and bancid are optional.
// todo: job should be renamed as subtype or bansubtype
/datum/admins/proc/DB_ban_record(bantype, mob/banned_mob, duration = -1, reason, job = "", banckey = null, banip = null, bancid = null)

	if(!check_rights(R_BAN))
		return

	if(!establish_db_connection("erro_ban", "erro_player"))
		return

	var/serverip = sanitize_sql("[world.internet_address]:[world.port]")

	if(!(bantype in global.valid_ban_types))
		CRASH("Unknown ban type [bantype]!")

	switch(bantype)
		if(BANTYPE_PERMA)
			duration = -1
		if(BANTYPE_JOB_PERMA)
			duration = -1
		if(BANTYPE_CHAT_PERMA)
			duration = -1

	if( !istext(reason) ) return
	if( !isnum(duration) ) return

	var/ckey
	var/computerid
	var/ip
	var/ingameage = 0

	if(ismob(banned_mob))
		ckey = ckey(banned_mob.ckey)
		if(banned_mob.client)
			computerid = sanitize_sql(banned_mob.client.computer_id)
			ip = sanitize_sql(banned_mob.client.address)
	else if(banckey)
		ckey = ckey(banckey)
		computerid = sanitize_sql(bancid)
		ip = sanitize_sql(banip)

	var/DBQuery/query = dbcon.NewQuery("SELECT ingameage FROM erro_player WHERE ckey = '[ckey]'")
	query.Execute()
	var/validckey = 0
	if(query.NextRow())
		validckey = 1
		ingameage = text2num(query.item[1])
	if(!validckey)
		if(!banned_mob || (banned_mob && !IsGuestKey(banned_mob.key)))
			message_admins("<font color='red'>[key_name_admin(usr)] attempted to ban [ckey], but [ckey] has not been seen yet. Please only ban actual players.</font>")
			return

	var/a_ckey
	var/a_computerid
	var/a_ip

	if(src.owner && isclient(src.owner))
		a_ckey = ckey(src.owner:ckey)
		a_computerid = sanitize_sql(src.owner:computer_id)
		a_ip = sanitize_sql(src.owner:address)

	var/who
	for(var/client/C in clients)
		if(!who)
			who = "[ckey(C)]"
		else
			who += ", [ckey(C)]"

	var/adminwho
	for(var/client/C as anything in admins)
		if(!adminwho)
			adminwho = "[ckey(C)]"
		else
			adminwho += ", [ckey(C)]"

	reason = sanitize_sql(reason)
	job = sanitize_sql(job)

	var/msg = "[key_name_admin(usr)] has added a [bantype] for [ckey] [(job)?"([job])":""] [(duration > 0)?"([duration] minutes)":""] with the reason: \"[sanitize(reason)]\" to the ban database."

	var/datum/admin_help/AH = admin_ticket_log(ckey, msg)
	if((bantype == BANTYPE_PERMA || bantype == BANTYPE_TEMP) && AH) // not sure if only for perma.
		AH.Resolve()

	var/sql = "INSERT INTO erro_ban (`id`,`bantime`,`serverip`,`round_id`,`bantype`,`reason`,`job`,`duration`,`expiration_time`,`ckey`,`computerid`,`ip`,`ingameage`,`a_ckey`,`a_computerid`,`a_ip`,`who`,`adminwho`,`edits`,`unbanned`,`unbanned_datetime`,`unbanned_ckey`,`unbanned_computerid`,`unbanned_ip`) VALUES (null, Now(), '[serverip]', [global.round_id], '[bantype]', '[reason]', '[job]', [(duration)?"[duration]":"0"], Now() + INTERVAL [(duration>0) ? duration : 0] MINUTE, '[ckey]', '[computerid]', '[ip]', [ingameage], '[a_ckey]', '[a_computerid]', '[a_ip]', '[who]', '[adminwho]', '', null, null, null, null, null)"
	var/DBQuery/query_insert = dbcon.NewQuery(sql)
	query_insert.Execute()
	to_chat(usr, "<span class='notice'>Ban saved to database.</span>")
	message_admins(msg)

	world.send2bridge(
		type = list(BRIDGE_ADMINBAN),
		attachment_title = "BAN",
		attachment_msg = "**[key_name(usr)]** [text("has added a **[]** for **[] [] []** with the reason: ***[]*** to the ban database.", bantype, ckey, (job ? "([job])" : ""), (duration > 0 ? "([duration] minutes)" : ""), text("[sanitize(reason)]"))]",
		attachment_color = BRIDGE_COLOR_ADMINBAN,
	)
	if (bantype == BANTYPE_PERMA || bantype == BANTYPE_TEMP)
		// servers use data from DB
		world.send_ban_announce(ckey, ip, computerid)

/datum/admins/proc/DB_ban_unban(ckey, bantype, job = "")

	if(!check_rights(R_BAN))
		return

	if(!(bantype || length(job)))
		CRASH("Should have any of bantype or job!")

	var/bantype_sql
	if(bantype) 
		if(!(bantype in global.valid_ban_types))
			CRASH("Unknown ban type [bantype]!")
		bantype_sql = "bantype = '[bantype]'"
	else // any actual jobban then
		bantype_sql = "(bantype = '[BANTYPE_JOB_PERMA]' OR (bantype = '[BANTYPE_JOB_TEMP]' AND expiration_time > Now()))"

	var/sql = "SELECT id FROM erro_ban WHERE ckey = '[ckey(ckey)]' AND [bantype_sql] AND (unbanned is null OR unbanned = false)"
	if(length(job))
		sql += " AND job = '[sanitize_sql(job)]'"

	if(!establish_db_connection("erro_ban"))
		return

	var/ban_id
	var/ban_number = 0 //failsafe

	var/DBQuery/query = dbcon.NewQuery(sql)
	query.Execute()
	while(query.NextRow())
		ban_id = query.item[1]
		ban_number++;

	if(ban_number == 0)
		to_chat(usr, "<span class='warning'>Database update failed due to no bans fitting the search criteria. If this is not a legacy ban you should contact the database admin.</span>")
		return

	if(ban_number > 1)
		to_chat(usr, "<span class='warning'>Database update failed due to multiple bans fitting the search criteria. Note down the ckey, job and current time and contact the database admin.</span>")
		return

	if(istext(ban_id))
		ban_id = text2num(ban_id)
	if(!isnum(ban_id))
		to_chat(usr, "<span class='warning'>Database update failed due to a ban ID mismatch. Contact the database admin.</span>")
		return

	DB_ban_unban_by_id(ban_id)

/datum/admins/proc/DB_ban_edit(banid = null, param = null)

	if(!check_rights(R_BAN))	return

	if(!isnum(banid) || !istext(param))
		to_chat(usr, "Cancelled")
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT ckey, duration, reason FROM erro_ban WHERE id = [banid]")
	query.Execute()

	var/eckey = ckey(usr.ckey)	//Editing admin ckey
	var/pckey				//(banned) Player ckey
	var/duration			//Old duration
	var/reason				//Old reason

	if(query.NextRow())
		pckey = query.item[1]
		duration = query.item[2]
		reason = query.item[3]
	else
		to_chat(usr, "Invalid ban id. Contact the database admin")
		return

	reason = sanitize_sql(reason)
	var/value

	switch(param)
		if("reason")
			if(!value)
				value = sanitize(input("Insert the new reason for [pckey]'s ban", "New Reason", "[reason]", null) as null|text)
				value = sanitize_sql(value)
				if(!value)
					to_chat(usr, "Cancelled")
					return

			var/DBQuery/update_query = dbcon.NewQuery("UPDATE erro_ban SET reason = '[value]', edits = CONCAT(edits,'- [eckey] changed ban reason from <cite><b>\\\"[reason]\\\"</b></cite> to <cite><b>\\\"[value]\\\"</b></cite><BR>') WHERE id = [banid]")
			update_query.Execute()
			message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s reason from [reason] to [value]")

			world.send2bridge(
				type = list(BRIDGE_ADMINBAN),
				attachment_title = "BANEDIT",
				attachment_msg = "**[key_name(usr)]** has edited a ban for **[pckey]**'s reason from ***[reason]*** to ***[value]***",
				attachment_color = BRIDGE_COLOR_ADMINBAN,
			)

		if("duration")
			if(!value)
				value = input("Insert the new duration (in minutes) for [pckey]'s ban", "New Duration", "[duration]", null) as null|num
				if(!isnum(value) || !value)
					to_chat(usr, "Cancelled")
					return

			var/DBQuery/update_query = dbcon.NewQuery("UPDATE erro_ban SET duration = [value], edits = CONCAT(edits,'- [eckey] changed ban duration from [duration] to [value]<br>'), expiration_time = DATE_ADD(bantime, INTERVAL [value] MINUTE) WHERE id = [banid]")
			message_admins("[key_name_admin(usr)] has edited a ban for [pckey]'s duration from [duration] to [value]")
			world.send2bridge(
				type = list(BRIDGE_ADMINBAN),
				attachment_title = "BANEDIT",
				attachment_msg = "**[key_name(usr)]** has edited a ban for **[pckey]**'s duration from ***[duration]*** to ***[value]***",
				attachment_color = BRIDGE_COLOR_ADMINBAN,
			)

			update_query.Execute()
		if("unban")
			if(tgui_alert(usr, "Unban [pckey]?", "Unban?", list("Yes", "No")) == "Yes")
				DB_ban_unban_by_id(banid)
				return
			else
				to_chat(usr, "Cancelled")
				return
		else
			to_chat(usr, "Cancelled")
			return

/datum/admins/proc/DB_ban_unban_by_id(id)

	if(!check_rights(R_BAN))	return

	if(!isnum(id))
		return

	if(!establish_db_connection("erro_ban"))
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT ckey, bantype, a_ckey, job, reason FROM erro_ban WHERE id = [id]")
	query.Execute()

	if(!query.NextRow())
		to_chat(usr, "<span class='warning'>Database update failed due to a ban id not being present in the database.</span>")
		return

	var/pckey = query.item[1]
	var/pbantype  = query.item[2]
	var/padmin = query.item[3]
	var/pjob = query.item[4]
	var/preason = query.item[5]

	if(!src.owner || !isclient(src.owner))
		return

	var/unban_ckey = ckey(src.owner.ckey)
	var/unban_computerid = sanitize_sql(src.owner.computer_id)
	var/unban_ip = sanitize_sql(src.owner.address)

	var/sql_update = "UPDATE erro_ban SET unbanned = 1, unbanned_datetime = Now(), unbanned_ckey = '[unban_ckey]', unbanned_computerid = '[unban_computerid]', unbanned_ip = '[unban_ip]' WHERE id = [id]"

	ban_unban_log_save("[key_name(usr)] has lifted [pckey] ban.")
	log_admin("[key_name(usr)] has lifted [pckey] ban.")
	message_admins("[key_name_admin(usr)] has lifted [pckey]'s ban.")

	world.send2bridge(
		type = list(BRIDGE_ADMINBAN),
		attachment_title = "UNBAN",
		attachment_msg = "**[key_name(usr)]** has lifted **[pckey]**'s ban:\n[pbantype][pjob ? "([pjob])" : ""] by [padmin] with reason:\n*[preason]*",
		attachment_color = BRIDGE_COLOR_ADMINBAN,
	)


	var/DBQuery/query_update = dbcon.NewQuery(sql_update)
	query_update.Execute()


/datum/admins/proc/DB_ban_panel(playerckey = null, adminckey = null, playerip = null, playercid = null, dbbantype = null, match = null)
	if(!usr.client)
		return

	if(!(check_rights(R_LOG) && check_rights(R_BAN)))
		return

	if(!establish_db_connection("erro_ban"))
		to_chat(usr, "<span class='warning'>Failed to establish database connection</span>")
		return

	var/output = "<div align='center'><table width='90%'><tr>"

	output += "<td width='35%' align='center'>"
	output += "</td>"

	output += "<td width='65%' align='center' bgcolor='#f9f9f9'>"

	output += "<form method='GET' action='?src=\ref[src]'><b>Add custom ban:</b> (ONLY use this if you can't ban through any other method)"
	output += "<input type='hidden' name='src' value='\ref[src]'>"
	output += "<table width='100%'><tr>"
	output += "<td width='50%' align='right'><b>Ban type:</b><select name='dbbanaddtype'>"
	output += "<option value=''>--</option>"
	output += "<option value='[BANTYPE_PERMA]'>PERMABAN</option>"
	output += "<option value='[BANTYPE_TEMP]'>TEMPBAN</option>"
	output += "<option value='[BANTYPE_JOB_PERMA]'>JOB PERMABAN</option>"
	output += "<option value='[BANTYPE_JOB_TEMP]'>JOB TEMPBAN</option>"
	output += "</select></td>"
	output += "<td width='50%' align='right'><b>Ckey:</b> <input type='text' name='dbbanaddckey'></td></tr>"
	output += "<tr><td width='50%' align='right'><b>IP:</b> <input type='text' name='dbbanaddip'></td>"
	output += "<td width='50%' align='right'><b>CID:</b> <input type='text' name='dbbanaddcid'></td></tr>"
	output += "<tr><td width='50%' align='right'><b>Duration:</b> <input type='text' name='dbbaddduration'></td>"
	output += "<td width='50%' align='right'><b>Job:</b><select name='dbbanaddjob'>"
	output += "<option value=''>--</option>"
	for(var/j in SSjob.name_departments)
		output += "<option value='[j]'>[j]</option>"
	for(var/j in list(ROLE_TRAITOR, ROLE_CHANGELING, ROLE_OPERATIVE, ROLE_REV, ROLE_RAIDER, ROLE_CULTIST, ROLE_WIZARD, ROLE_ERT, ROLE_SHADOWLING, ROLE_ABDUCTOR, ROLE_FAMILIES, ROLE_NINJA, ROLE_BLOB, ROLE_MALF, ROLE_DRONE, ROLE_GHOSTLY, ROLE_REPLICATOR))
		output += "<option value='[j]'>[j]</option>"
	output += "</select></td></tr></table>"
	output += "<b>Reason:<br></b><textarea name='dbbanreason' cols='50'></textarea><br>"
	output += "<input type='submit' value='Add ban'>"
	output += "</form>"

	output += "</td>"
	output += "</tr>"
	output += "</table>"

	output += "<form method='GET' action='?src=\ref[src]'><table width='60%'><tr><td colspan='2' align='left'><b>Search:</b>"
	output += "<input type='hidden' name='src' value='\ref[src]'></td></tr>"
	output += "<tr><td width='50%' align='right'><b>Ckey:</b> <input type='text' name='dbsearchckey' value='[playerckey]'></td>"
	output += "<td width='50%' align='right'><b>Admin ckey:</b> <input type='text' name='dbsearchadmin' value='[adminckey]'></td></tr>"
	output += "<tr><td width='50%' align='right'><b>IP:</b> <input type='text' name='dbsearchip' value='[playerip]'></td>"
	output += "<td width='50%' align='right'><b>CID:</b> <input type='text' name='dbsearchcid' value='[playercid]'></td></tr>"
	output += "<tr><td width='50%' align='right' colspan='2'><b>Ban type:</b><select name='dbsearchbantype'>"
	output += "<option value=''>--</option>"
	output += "<option value='[BANTYPE_PERMA]'>PERMABAN</option>"
	output += "<option value='[BANTYPE_TEMP]'>TEMPBAN</option>"
	output += "<option value='[BANTYPE_JOB_PERMA]'>JOB PERMABAN</option>"
	output += "<option value='[BANTYPE_JOB_TEMP]'>JOB TEMPBAN</option>"
	output += "</select></td></tr></table>"
	output += "<br><input type='submit' value='search'><br>"
	output += "<input type='checkbox' value='[match]' name='dbmatch' [match? "checked=\"1\"" : null]> Match(min. 3 characters to search by key or ip, and 7 to search by cid)<br>"
	output += "</form>"
	output += "Please note that all jobban bans or unbans are in-effect the following round.<br>"
	output += "This search shows only last 100 bans."

	if(adminckey || playerckey || playerip || playercid || dbbantype)

		adminckey = ckey(adminckey)
		playerckey = ckey(playerckey)
		playerip = sanitize_sql(playerip)
		playercid = sanitize_sql(playercid)

		if(adminckey || playerckey || playerip || playercid || dbbantype)

			var/blcolor = "#ffeeee" //banned light
			var/bdcolor = "#ffdddd" //banned dark
			var/ulcolor = "#eeffee" //unbanned light
			var/udcolor = "#ddffdd" //unbanned dark

			output += "<table width='90%' bgcolor='#e3e3e3' cellpadding='5' cellspacing='0' align='center'>"
			output += "<tr>"
			output += "<th width='25%'><b>TYPE</b></th>"
			output += "<th width='20%'><b>CKEY</b></th>"
			output += "<th width='20%'><b>TIME APPLIED</b></th>"
			output += "<th width='20%'><b>ADMIN</b></th>"
			output += "<th width='15%'><b>OPTIONS</b></th>"
			output += "</tr>"

			var/adminsearch = ""
			var/playersearch = ""
			var/ipsearch = ""
			var/cidsearch = ""
			var/bantypesearch = ""

			if(!match)
				if(adminckey)
					adminsearch = "AND a_ckey = '[adminckey]' "
				if(playerckey)
					playersearch = "AND ckey = '[playerckey]' "
				if(playerip)
					ipsearch  = "AND ip = '[playerip]' "
				if(playercid)
					cidsearch  = "AND computerid = '[playercid]' "
			else
				if(adminckey && length(adminckey) > 3)
					adminsearch = "AND a_ckey LIKE '[adminckey]%' "
				if(playerckey && length(playerckey) > 3)
					playersearch = "AND ckey LIKE '[playerckey]%' "
				if(playerip && length(playerip) > 3)
					ipsearch  = "AND ip LIKE '[playerip]%' "
				if(playercid && length(playercid) > 7)
					cidsearch  = "AND computerid LIKE '[playercid]%' "

			if(dbbantype)
				if(dbbantype in global.valid_ban_types)
					bantypesearch = "AND bantype = '[dbbantype]' "
				else // idk if it's possible, i'm just updating legacy code
					bantypesearch = "AND bantype = '[BANTYPE_PERMA]' "

			var/DBQuery/select_query = dbcon.NewQuery("SELECT id, bantime, bantype, reason, job, duration, expiration_time, ckey, a_ckey, unbanned, unbanned_ckey, unbanned_datetime, edits, ip, computerid, round_id, ingameage FROM erro_ban WHERE 1 [playersearch] [adminsearch] [ipsearch] [cidsearch] [bantypesearch] ORDER BY bantime DESC LIMIT 100")
			select_query.Execute()

			while(select_query.NextRow())
				var/banid = select_query.item[1]
				var/bantime = select_query.item[2]
				var/bantype  = select_query.item[3]
				var/reason = select_query.item[4]
				var/job = select_query.item[5]
				var/duration = select_query.item[6]
				var/expiration = select_query.item[7]
				var/ckey = select_query.item[8]
				var/ackey = select_query.item[9]
				var/unbanned = select_query.item[10]
				var/unbanckey = select_query.item[11]
				var/unbantime = select_query.item[12]
				var/edits = select_query.item[13]
				var/ip = select_query.item[14]
				var/cid = select_query.item[15]
				var/rid = select_query.item[16]
				var/ingameage = select_query.item[17]

				var/lcolor = blcolor
				var/dcolor = bdcolor
				if(unbanned)
					lcolor = ulcolor
					dcolor = udcolor

				var/typedesc =""
				switch(bantype)
					if(BANTYPE_PERMA)
						typedesc = "<font color='red'><b>PERMABAN</b></font>"
					if(BANTYPE_TEMP)
						typedesc = "<b>TEMPBAN</b><br><font size='2'>([duration] minutes [(unbanned) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=duration;dbbanid=[banid]\">Edit</a>))"]<br>Expires [expiration]</font>"
					if(BANTYPE_JOB_PERMA)
						typedesc = "<b>JOBBAN</b><br><font size='2'>([job])</font>"
					if(BANTYPE_JOB_TEMP)
						typedesc = "<b>TEMP JOBBAN</b><br><font size='2'>([job])<br>([duration] minutes<br>Expires [expiration]</font>"
					if(BANTYPE_CHAT_PERMA)
						typedesc = "<b>CHAT BAN</b><br><font size='2'>([job])</font>"
					if(BANTYPE_CHAT_TEMP)
						typedesc = "<b>TEMP CHAT BAN</b><br><font size='2'>([job])<br>([duration] minutes<br>Expires [expiration]</font>"

				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center'>[typedesc]</td>"
				output += "<td align='center'><b>[ckey]</b></td>"
				output += "<td align='center'>#[rid], [bantime]<br>([ingameage] player minutes)</td>"
				output += "<td align='center'><b>[ackey]</b></td>"
				output += "<td align='center'>[(unbanned) ? "" : "<b><a href=\"byond://?src=\ref[src];dbbanedit=unban;dbbanid=[banid]\">Unban</a></b>"]</td>"
				output += "</tr>"
				output += "<tr bgcolor='[dcolor]'>"
				output += "<td align='center' colspan='2' bgcolor=''><b>IP:</b> [ip]</td>"
				output += "<td align='center' colspan='3' bgcolor=''><b>CID:</b> [cid]</td>"
				output += "</tr>"
				output += "<tr bgcolor='[lcolor]'>"
				output += "<td align='center' colspan='5'><b>Reason: [(unbanned) ? "" : "(<a href=\"byond://?src=\ref[src];dbbanedit=reason;dbbanid=[banid]\">Edit</a>)"]</b> <cite>\"[sanitize(reason)]\"</cite></td>"
				output += "</tr>"
				if(edits)
					output += "<tr bgcolor='[dcolor]'>"
					output += "<td align='center' colspan='5'><b>EDITS</b></td>"
					output += "</tr>"
					output += "<tr bgcolor='[lcolor]'>"
					output += "<td align='center' colspan='5'><font size='2'>[edits]</font></td>"
					output += "</tr>"
				if(unbanned)
					output += "<tr bgcolor='[dcolor]'>"
					output += "<td align='center' colspan='5' bgcolor=''><b>UNBANNED by admin [unbanckey] on [unbantime]</b></td>"
					output += "</tr>"
				output += "<tr>"
				output += "<td colspan='5' bgcolor='white'>&nbsp</td>"
				output += "</tr>"

			output += "</table></div>"

	var/datum/browser/popup = new(usr, "window=lookupbans", "Banning panel", 900, 700, ntheme = CSS_THEME_LIGHT)
	popup.set_content(output)
	popup.open()

//Version of DB_ban_record that can be used without holder (fuck, someone pls rewrite bans)
/proc/DB_ban_record_2(bantype, mob/banned_mob, duration = -1, reason, job = "", banckey = null, banip = null, bancid = null)
	if(!establish_db_connection("erro_player"))
		return 0

	var/serverip = sanitize_sql("[world.internet_address]:[world.port]")


	if(!(bantype in global.valid_ban_types))
		CRASH("Unknown ban type [bantype]!")

	switch(bantype)
		if(BANTYPE_PERMA)
			duration = -1
		if(BANTYPE_JOB_PERMA)
			duration = -1
		if(BANTYPE_CHAT_PERMA)
			duration = -1

	if( !istext(reason) ) return 0
	if( !isnum(duration) ) return 0

	var/ckey
	var/computerid
	var/ip

	if(ismob(banned_mob))
		ckey = ckey(banned_mob.ckey)
		if(banned_mob.client)
			computerid = sanitize_sql(banned_mob.client.computer_id)
			ip = sanitize_sql(banned_mob.client.address)
	else if(banckey)
		ckey = ckey(banckey)
		computerid = sanitize_sql(bancid)
		ip = sanitize_sql(banip)

	var/DBQuery/query = dbcon.NewQuery("SELECT id FROM erro_player WHERE ckey = '[ckey]'")
	query.Execute()
	var/validckey = 0
	if(query.NextRow())
		validckey = 1
	if(!validckey)
		if(!banned_mob || (banned_mob && !IsGuestKey(banned_mob.key)))
			message_admins("<font color='red'>Tau Kitty attempted to ban [ckey], but [ckey] has not been seen yet. Please only ban actual players.</font>")
			return 0

	var/a_ckey = "taukitty"
	var/a_computerid = "0000000000"
	var/a_ip = "127.0.0.1"

	var/who
	for(var/client/C in clients)
		if(!who)
			who = "[ckey(C)]"
		else
			who += ", [ckey(C)]"

	var/adminwho
	for(var/client/C as anything in admins)
		if(!adminwho)
			adminwho = "[ckey(C)]"
		else
			adminwho += ", [ckey(C)]"

	reason = sanitize_sql(reason)
	job = sanitize_sql(job)

	var/sql = "INSERT INTO erro_ban (`id`,`bantime`,`serverip`,`round_id`,`bantype`,`reason`,`job`,`duration`,`expiration_time`,`ckey`,`computerid`,`ip`,`a_ckey`,`a_computerid`,`a_ip`,`who`,`adminwho`,`edits`,`unbanned`,`unbanned_datetime`,`unbanned_ckey`,`unbanned_computerid`,`unbanned_ip`) VALUES (null, Now(), '[serverip]', [global.round_id], '[bantype]', '[reason]', '[job]', [(duration)?"[duration]":"0"], Now() + INTERVAL [(duration>0) ? duration : 0] MINUTE, '[ckey]', '[computerid]', '[ip]', '[a_ckey]', '[a_computerid]', '[a_ip]', '[who]', '[adminwho]', '', null, null, null, null, null)"
	var/DBQuery/query_insert = dbcon.NewQuery(sql)
	query_insert.Execute()
	message_admins("Tau Kitty has added a [bantype] for [ckey] [(job)?"([job])":""] [(duration > 0)?"([duration] minutes)":""] with the reason: \"[reason]\" to the ban database.")
	world.send2bridge(
		type = list(BRIDGE_ADMINBAN),
		attachment_title = "BOTBAN",
		attachment_msg = "**Tau Kitty** has added a **[bantype]** for **[ckey]** **[(job)?"([job])":""] [(duration > 0)?"([duration] minutes)":""]** with the reason: ***\"[reason]\"*** to the ban database.",
		attachment_color = BRIDGE_COLOR_ADMINBAN,
	)
	if (bantype == BANTYPE_PERMA || bantype == BANTYPE_TEMP)
		// servers use data from DB
		world.send_ban_announce(ckey, ip, computerid)

	return 1
