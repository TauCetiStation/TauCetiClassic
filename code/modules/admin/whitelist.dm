/datum/admins/proc/whitelist_panel()
	set category = "Server"
	set name = "Whitelist Panel"
	set desc = "Allows you to view whitelist and maybe add or edit users."

	src = usr.client.holder
	if(!check_rights(R_ADMIN|R_WHITELIST))
		return

	var/output = {"<!DOCTYPE html>
<html>
<head>
<title>Whitelist Panel</title>
<script type='text/javascript' src='search.js'></script>
<link rel='stylesheet' type='text/css' href='panels.css'>
</head>
<body onload='selectTextField();updateSearch();'>
<div id='main'><table id='searchable' cellspacing='0'>
<tr class='title'>
<th text-align:center;'>CKEY <a class='small' href='?src=\ref[src];whitelist=add_user'>\[+\]</a></th>
</tr>
"}

	for(var/user_ckey in role_whitelist)
		output += "<tr>"
		output += "<td style='text-align:center;'><a class='small' href='?src=\ref[src];whitelist=showroles;ckey=[user_ckey]'>[user_ckey]</a></td>"
		output += "</tr>"

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(output,"window=whitelist;size=600x500")

/datum/admins/proc/whitelist_view(user_ckey)
	src = usr.client.holder
	if(!check_rights(R_ADMIN|R_WHITELIST))
		return
	if(!user_ckey)
		to_chat(usr, "<span class='alert'>Error: Topic 'whitelist': No valid ckey</span>")
		return

	var/output = {"<!DOCTYPE html>
<html>
<head>
<title>Whitelist Panel for [user_ckey]</title>
<script type='text/javascript' src='search.js'></script>
<link rel='stylesheet' type='text/css' href='panels.css'>
</head>
<body onload='selectTextField();updateSearch();'>
<div id='main'><table id='searchable' cellspacing='0'>
<tr class='title'>
<th style='width:125px;text-align:center;'>[uppertext(user_ckey)]</th>
<th style='width:125px;'>ROLE <a class='small' href='?src=\ref[src];whitelist=add_role;ckey=[user_ckey]'>\[+\]</a></th><th style='width:100%;'>REASON</th><th style='width:125px;'>ADDED BY</th><th style='width:125px;'>EDITED BY</th>
</tr>
"}

	for(var/role in role_whitelist[user_ckey])
		output += "<tr>"

		var/ban = role_whitelist[user_ckey][role]["ban"] ? "Banned" : "Available"
		output += "<td><a class='small' href='?src=\ref[src];whitelist=edit_ban;ckey=[user_ckey];role=[role]'>[ban]</a></td>"
		output += "<td>[role]</td>"

		var/reason = sanitize(role_whitelist[user_ckey][role]["reason"])
		output += "<td><a class='small' href='?src=\ref[src];whitelist=edit_reason;ckey=[user_ckey];role=[role]'>(E)</a> [reason]</td>"
		var/addby = role_whitelist[user_ckey][role]["addby"]
		var/addtm = role_whitelist[user_ckey][role]["addtm"]
		output += "<td>[addby]<br>[addtm]</td>"
		var/editby = role_whitelist[user_ckey][role]["editby"]
		var/edittm = role_whitelist[user_ckey][role]["edittm"]
		output += "<td>[editby]<br>[edittm]</td>"

		output += "</tr>"

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(output,"window=whitelist_user;size=750x500")

/datum/admins/proc/whitelist_add_user()
	if(!check_rights(R_WHITELIST))
		return

	var/target_ckey = input(usr,"type in ckey:","Add User", null) as null|text
	if(!target_ckey)
		return

	var/role = input(usr, "select role for [target_ckey]:", "Role") as null|anything in whitelisted_roles
	if(!role)
		return

	var/reason = input(usr, "([target_ckey] [role]) type in reason:", "Reason") as null|text
	if(!reason)
		return

	whitelist_DB_add(target_ckey, role, reason, usr.ckey)

/datum/admins/proc/whitelist_add_role(target_ckey)
	if(!check_rights(R_WHITELIST))
		return

	if(!target_ckey)
		return

	var/role = input(usr, "select role for [target_ckey]:", "Role") as null|anything in whitelisted_roles
	if(!role)
		return

	var/reason = input(usr, "([target_ckey] [role]) type in reason:", "Reason") as null|text
	if(!reason)
		return

	whitelist_DB_add(target_ckey, role, reason, usr.ckey)

/datum/admins/proc/whitelist_edit(target_ckey, role, ban_edit)
	if(!check_rights(R_WHITELIST))
		return

	if(!target_ckey || !role)
		return

	var/ban = role_whitelist[target_ckey][role]["ban"]

	if(ban_edit)
		ban_edit = alert(usr, ban ? "Do you want to UNBAN [role] for [target_ckey]?" : "Do you want to BAN [role] for [target_ckey]?",,ban ? "Unban" : "Ban", "Cancel")
		switch(ban_edit)
			if("Cancel")
				return
			if("Unban")
				ban = FALSE
			if("Ban")
				ban = TRUE

	var/reason = input(usr, "([target_ckey] [role][ban_edit ? (ban ? " BAN" : " UNBAN") : ""]) type in reason:", "Reason") as null|text
	if(!reason)
		return

	whitelist_DB_edit(target_ckey, role, ban, ban_edit, reason, usr.ckey)

/proc/whitelist_DB_add(target_ckey, role, reason, adm_ckey, added_by_bot = FALSE)
	if(!config.usealienwhitelist)
		if(!added_by_bot)
			to_chat(usr, "<span class='warning'>Whitelist disabled.</span>")
		return FALSE

	target_ckey = ckey(target_ckey)
	role = lowertext(role)
	reason = sanitize_sql(reason)
	adm_ckey = ckey(adm_ckey)

	if(!target_ckey || !role || !reason || !adm_ckey)
		return FALSE

	if(!added_by_bot && !check_rights(R_WHITELIST))
		return FALSE

	if(!(role in whitelisted_roles))
		if(!added_by_bot)
			to_chat(usr, "<span class='warning'>Role [role] does not exist in whitelisted roles.</span>")
		return FALSE

	if(role_whitelist[target_ckey] && role_whitelist[target_ckey][role])
		if(!added_by_bot)
			to_chat(usr, "<span class='warning'>[role] for [target_ckey] already exists in whitelist.</span>")
		return FALSE

	establish_db_connection()
	if(!dbcon.IsConnected())
		if(!added_by_bot)
			to_chat(usr, "<span class='warning'>Failed to establish database connection.</span>")
		return FALSE

	var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO `whitelist` (`ckey`, `role`, `ban`, `reason`, `addby`, `addtm`, `editby`, `edittm`) VALUES ('[target_ckey]', '[role]', '0', '[reason]', '[adm_ckey]', NOW(), '[adm_ckey]', NOW());")
	if(!insert_query.Execute())
		var/fail_msg = insert_query.ErrorMsg()
		world.log << "SQL ERROR (I): [fail_msg]"
		message_admins("SQL ERROR (I): [fail_msg]")
		return FALSE

	if(!role_whitelist[target_ckey])
		role_whitelist[target_ckey] = list()
	role_whitelist[target_ckey][role] = list("ban" = 0, "reason" = reason, "addby" = adm_ckey, "addtm" = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss"), "editby" = adm_ckey)

	var/msg = "whitelisted [role] for [target_ckey] with reason: [sanitize(reason)]"
	if(!added_by_bot)
		message_admins("[key_name_admin(usr)] [msg]")
		log_admin("[key_name(usr)] [msg]")
		world.send2bridge(
			type = list(BRIDGE_ADMINWL),
			attachment_title = "WHITELIST",
			attachment_msg = "**[key_name(usr)]** [msg]",
			attachment_color = BRIDGE_COLOR_ADMINWL,
		)
		usr.client.holder.whitelist_panel()
		usr.client.holder.whitelist_view(target_ckey)
	else
		message_admins("[adm_ckey] [msg]")
		log_admin("[adm_ckey] [msg]")
		world.send2bridge(
			type = list(BRIDGE_ADMINWL),
			attachment_title = "WHITELIST BOT",
			attachment_msg = "**[adm_ckey]** [msg]",
			attachment_color = BRIDGE_COLOR_ADMINWL,
		)
	return TRUE

/datum/admins/proc/whitelist_DB_edit(target_ckey, role, ban, ban_edit, reason, adm_ckey)
	if(!config.usealienwhitelist)
		to_chat(usr, "<span class='notice'>Whitelist disabled.</span>")
		return

	target_ckey = ckey(target_ckey)
	role = lowertext(role)
	reason = sanitize_sql(reason)
	adm_ckey = ckey(adm_ckey)

	if(!target_ckey || !role || !reason || !adm_ckey)
		return

	if(!check_rights(R_WHITELIST))
		return

	if(!(role in whitelisted_roles))
		to_chat(usr, "<span class='warning'>Role [role] does not exist in whitelisted roles.</span>")
		return

	if(!role_whitelist[target_ckey])
		to_chat(usr, "<span class='warning'>[target_ckey] does not exist in whitelist.</span>")
		return

	if(!role_whitelist[target_ckey][role])
		to_chat(usr, "<span class='warning'>[role] for [target_ckey] does not exist in whitelist.</span>")
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "<span class='warning'>Failed to establish database connection.</span>")
		return

	var/sql_update
	if(ban_edit)
		sql_update = "UPDATE `whitelist` SET ban = '[ban]', reason = '[reason]', editby = '[adm_ckey]', edittm = Now() WHERE ckey = '[target_ckey]' AND role = '[role]'"
	else
		sql_update = "UPDATE `whitelist` SET reason = '[reason]', editby = '[adm_ckey]', edittm = Now() WHERE ckey = '[target_ckey]' AND role = '[role]'"
	var/DBQuery/query_update = dbcon.NewQuery(sql_update)
	if(!query_update.Execute())
		var/fail_msg = query_update.ErrorMsg()
		world.log << "SQL ERROR (U): [fail_msg]"
		message_admins("SQL ERROR (U): [fail_msg]")
		return

	var/msg = "changed reason in whitelist from [sanitize(role_whitelist[target_ckey][role]["reason"])] to [sanitize(reason)] for [target_ckey] as [role]."
	if(ban_edit)
		role_whitelist[target_ckey][role]["ban"] = ban
		msg = "[ban ? "banned" : "unbanned"] [role] from whitelist for [target_ckey] with reason [sanitize(reason)]."

	role_whitelist[target_ckey][role]["reason"] = reason
	role_whitelist[target_ckey][role]["editby"] = adm_ckey
	role_whitelist[target_ckey][role]["edittm"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

	message_admins("[key_name_admin(usr)] [msg]")

	world.send2bridge(
		type = list(BRIDGE_ADMINWL),
		attachment_title = "WHITELIST",
		attachment_msg = "**[key_name(usr)]** [msg]",
		attachment_color = BRIDGE_COLOR_ADMINWL,
	)

	whitelist_view(target_ckey)

/proc/load_whitelistSQL()
	if(!config.usealienwhitelist)
		return

	role_whitelist = list()

	establish_db_connection()
	if(!dbcon.IsConnected())
		world.log << "SQL ERROR (L): whitelist: connection failed to SQL database."
		return

	var/DBQuery/select_query = dbcon.NewQuery("SELECT * FROM whitelist")

	if(!select_query.Execute())
		world.log << "SQL ERROR (L): whitelist: [select_query.ErrorMsg()]."
		return FALSE
	else
		while(select_query.NextRow())
			var/list/row = select_query.GetRowData()
			if(role_whitelist[row["ckey"]])
				var/list/A = role_whitelist[row["ckey"]]
				A.Add(list(row["role"] = list("ban" = text2num(row["ban"]), "reason" = row["reason"], "addby" = row["addby"], "addtm" = row["addtm"], "editby" = row["editby"], "edittm" = row["edittm"])))
			else
				role_whitelist[row["ckey"]] = list(row["role"] = list("ban" = text2num(row["ban"]), "reason" = row["reason"], "addby" = row["addby"], "addtm" = row["addtm"], "editby" = row["editby"], "edittm" = row["edittm"]))
	return TRUE

/proc/is_alien_whitelisted(mob/M, role)
	if(!config.usealienwhitelist)
		return TRUE
	if(!M || !role || !role_whitelist)
		return FALSE

	role = lowertext(role)

	if(role == "human")
		return TRUE

	switch(role) //We don't use separate whitelist for languages, lets transform lang name to their race name.
		if("sinta'unathi")
			role = "unathi"
		if("siik'maas","siik'tajr")
			role = "tajaran"
		if("skrellian")
			role = "skrell"

	if(role_whitelist[M.ckey] && role_whitelist[M.ckey][role])
		if(role_whitelist[M.ckey][role]["ban"])
			return FALSE
		return TRUE

	if(M.client && config.whitelisted_species_by_time[role] && (isnum(M.client.player_ingame_age) && M.client.player_ingame_age >= config.whitelisted_species_by_time[role]))
		return TRUE

	return FALSE

//true if whitelist enabled & mob in it & has ban, false othervise
//temporary solution, because we don't have separate bans currently
/proc/is_alien_whitelisted_banned(mob/M, role)
	if(!config.usealienwhitelist || !M || !role || !role_whitelist)
		return FALSE

	if(role == "human")
		return FALSE

	switch(role) //We don't use separate whitelist for languages, lets transform lang name to their race name.
		if("sinta'unathi")
			role = "unathi"
		if("siik'maas","siik'tajr")
			role = "tajaran"
		if("skrellian")
			role = "skrell"

	if(role_whitelist[M.ckey] && role_whitelist[M.ckey][role])
		if(role_whitelist[M.ckey][role]["ban"])
			return TRUE
		return FALSE
