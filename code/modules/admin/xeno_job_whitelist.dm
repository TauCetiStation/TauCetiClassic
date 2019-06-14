/datum/admins/proc/xeno_job_whitelist_panel()
	set category = "Server"
	set name = "Xeno Job Whitelist"
	set desc = "Allows you to view whitelist and maybe add or edit users."

	src = usr.client.holder
	if(!check_rights(R_ADMIN|R_WHITELIST))
		return

	var/output = {"<!DOCTYPE html>
<html>
<head>
<title>Xeno Job Whitelist Panel</title>
<script type='text/javascript' src='search.js'></script>
<link rel='stylesheet' type='text/css' href='panels.css'>
</head>
<body onload='selectTextField();updateSearch();'>
<div id='main'><table id='searchable' cellspacing='0'>
<tr class='title'>
<th text-align:center;'>CKEY <a class='small' href='?src=\ref[src];xeno_job_whitelist=add_user'>\[+\]</a></th>
</tr>
"}

	for(var/user_ckey in xeno_job_whitelist)
		output += "<tr>"
		output += "<td style='text-align:center;'><a class='small' href='?src=\ref[src];xeno_job_whitelist=showroles;ckey=[user_ckey]'>[user_ckey]</a></td>"
		output += "</tr>"

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(entity_ja(output),"window=whitelist;size=600x500")

/datum/admins/proc/xeno_job_whitelist_view(user_ckey)
	src = usr.client.holder
	if(!check_rights(R_ADMIN|R_WHITELIST))
		return
	if(!user_ckey)
		to_chat(usr, "<span class='alert'>Error: Topic 'whitelist': No valid ckey</span>")
		return

	var/output = {"<!DOCTYPE html>
<html>
<head>
<title>Xeno Job Whitelist Panel for [user_ckey]</title>
<script type='text/javascript' src='search.js'></script>
<link rel='stylesheet' type='text/css' href='panels.css'>
</head>
<body onload='selectTextField();updateSearch();'>
<div id='main'><table id='searchable' cellspacing='0'>
<tr class='title'>
<th style='width:125px;text-align:center;'>[uppertext(user_ckey)]</th>
<th style='width:125px;'>ROLE <a class='small' href='?src=\ref[src];xeno_job_whitelist=add_role;ckey=[user_ckey]'>\[+\]</a></th><th style='width:125px;'>JOB</th><th style='width:100%;'>REASON</th><th style='width:125px;'>ADDED BY</th><th style='width:125px;'>EDITED BY</th>
</tr>
"}

	for(var/role in xeno_job_whitelist[user_ckey])
		var/list/jobs = xeno_job_whitelist[user_ckey][role]
		for(var/job in jobs)
			output += "<tr>"

			var/ban = jobs[job]["ban"] ? "Banned" : "Available"
			output += "<td><a class='small' href='?src=\ref[src];xeno_job_whitelist=edit_ban;ckey=[user_ckey];role=[role];job=[job]'>[ban]</a></td>"
			output += "<td>[role]</td>"
			output += "<td>[job]</td>"

			var/reason = sanitize(jobs[job]["reason"])
			output += "<td><a class='small' href='?src=\ref[src];xeno_job_whitelist=edit_reason;ckey=[user_ckey];role=[role];job=[job]'>(E)</a> [reason]</td>"
			var/addby = jobs[job]["addby"]
			var/addtm = jobs[job]["addtm"]
			output += "<td>[addby]<br>[addtm]</td>"
			var/editby = jobs[job]["editby"]
			var/edittm = jobs[job]["edittm"]
			output += "<td>[editby]<br>[edittm]</td>"

			output += "</tr>"

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(entity_ja(output),"window=whitelist_user;size=750x500")

/datum/admins/proc/xeno_job_whitelist_add(target_ckey = "")
	if(!check_rights(R_WHITELIST))
		return

	if(!target_ckey)
		target_ckey = input(usr,"type in ckey:","Add User", null) as null|text
		if(!target_ckey)
			return

	var/role = input(usr, "select role for [target_ckey]:", "Role") as null|anything in (whitelisted_roles - "ian")
	if(!role)
		return

	var/list/jobs = list()
	for(var/datum/job/job in SSjob.occupations)
		jobs[job.title] = job
	var/job = input(usr, "select job to whitelist for [target_ckey] as [role]:", "Job") as null|anything in jobs
	if(!job)
		return

	var/reason = input(usr, "([target_ckey] [role] [job]) type in reason:", "Reason") as null|text
	if(!reason)
		return

	xeno_job_whitelist_DB_add(target_ckey, role, job, reason, usr.ckey)

/datum/admins/proc/xeno_job_whitelist_edit(target_ckey, role, job, ban_edit)
	if(!check_rights(R_WHITELIST))
		return

	if(!target_ckey || !role || !job)
		return

	var/ban = xeno_job_whitelist[target_ckey][role][job]["ban"]

	if(ban_edit)
		ban_edit = alert(usr, ban ? "Do you want to UNBAN [job] job for [role] for [target_ckey]?" : "Do you want to BAN [job] job for [role] for [target_ckey]?",,ban ? "Unban" : "Ban", "Cancel")
		switch(ban_edit)
			if("Cancel")
				return
			if("Unban")
				ban = FALSE
			if("Ban")
				ban = TRUE

	var/reason = input(usr, "([target_ckey] [job] [role][ban_edit ? (ban ? " BAN" : " UNBAN") : ""]) type in reason:", "Reason") as null|text
	if(!reason)
		return

	xeno_job_whitelist_DB_edit(target_ckey, role, job, ban, ban_edit, reason, usr.ckey)

/proc/xeno_job_whitelist_DB_add(target_ckey, role, job, reason, adm_ckey, added_by_bot = FALSE)
	if(!config.use_alien_job_restriction)
		if(!added_by_bot)
			to_chat(usr, "<span class='warning'>Whitelist disabled.</span>")
		return FALSE

	target_ckey = ckey(target_ckey)
	role = lowertext(role)
	job = lowertext(job)
	reason = sanitize_sql(reason)
	adm_ckey = ckey(adm_ckey)

	if(!target_ckey || !role || !job || !reason || !adm_ckey)
		return FALSE

	if(!added_by_bot && !check_rights(R_WHITELIST))
		return FALSE

	if(!(role in whitelisted_roles))
		if(!added_by_bot)
			to_chat(usr, "<span class='warning'>Role [role] does not exist in whitelisted roles.</span>")
		return FALSE

	if(xeno_job_whitelist && xeno_job_whitelist[target_ckey] && xeno_job_whitelist[target_ckey][role] && xeno_job_whitelist[target_ckey][role][job])
		if(!added_by_bot)
			to_chat(usr, "<span class='warning'>[job] job for [role] for [target_ckey] already exists in whitelist.</span>")
		return FALSE

	establish_db_connection()
	if(!dbcon.IsConnected())
		if(!added_by_bot)
			to_chat(usr, "<span class='warning'>Failed to establish database connection.</span>")
		return FALSE

	var/DBQuery/insert_query = dbcon.NewQuery("INSERT INTO `xeno_job_whitelist` (`ckey`, `role`, `job`, `ban`, `reason`, `addby`, `addtm`, `editby`, `edittm`) VALUES ('[target_ckey]', '[role]', '[job]', '0', '[reason]', '[adm_ckey]', NOW(), '[adm_ckey]', NOW());")
	if(!insert_query.Execute())
		var/fail_msg = insert_query.ErrorMsg()
		world.log << "SQL ERROR (I): [fail_msg]"
		message_admins("SQL ERROR (I): [fail_msg]")
		return FALSE

	if(!xeno_job_whitelist[target_ckey])
		xeno_job_whitelist[target_ckey] = list()
	if(!xeno_job_whitelist[target_ckey][role])
		xeno_job_whitelist[target_ckey][role] = list()
	xeno_job_whitelist[target_ckey][role][job] = list("ban" = 0, "reason" = reason, "addby" = adm_ckey, "addtm" = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss"), "editby" = adm_ckey)

	var/msg = "whitelisted [job] job for [role] for [target_ckey] with reason: [sanitize(reason)]"
	if(!added_by_bot)
		message_admins("[key_name_admin(usr)] [msg]")
		log_admin("[key_name(usr)] [msg]")
		world.send2bridge(
			type = list(BRIDGE_ADMINWL),
			attachment_title = "WHITELIST",
			attachment_msg = "**[key_name(usr)]** [msg]",
			attachment_color = BRIDGE_COLOR_ADMINWL,
		)
		usr.client.holder.xeno_job_whitelist_panel()
		usr.client.holder.xeno_job_whitelist_view(target_ckey)
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

/datum/admins/proc/xeno_job_whitelist_DB_edit(target_ckey, role, job, ban, ban_edit, reason, adm_ckey)
	if(!config.use_alien_job_restriction)
		to_chat(usr, "<span class='notice'>Whitelist disabled.</span>")
		return

	target_ckey = ckey(target_ckey)
	role = lowertext(role)
	job = lowertext(job)
	reason = sanitize_sql(reason)
	adm_ckey = ckey(adm_ckey)

	if(!target_ckey || !role || !job || !reason || !adm_ckey)
		return

	if(!check_rights(R_WHITELIST))
		return

	if(!(role in whitelisted_roles))
		to_chat(usr, "<span class='warning'>Role [role] does not exist in whitelisted roles.</span>")
		return

	if(!xeno_job_whitelist[target_ckey])
		to_chat(usr, "<span class='warning'>[target_ckey] does not exist in whitelist.</span>")
		return

	if(!xeno_job_whitelist[target_ckey][role])
		to_chat(usr, "<span class='warning'>[role] for [target_ckey] does not exist in whitelist.</span>")
		return

	if(!xeno_job_whitelist[target_ckey][role][job])
		to_chat(usr, "<span class='warning'>[job] job for [role] for [target_ckey] does not exist in whitelist.</span>")
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "<span class='warning'>Failed to establish database connection.</span>")
		return

	var/sql_update
	if(ban_edit)
		sql_update = "UPDATE `xeno_job_whitelist` SET ban = '[ban]', reason = '[reason]', editby = '[adm_ckey]', edittm = Now() WHERE ckey = '[target_ckey]' AND role = '[role]' AND job = '[job]'"
	else
		sql_update = "UPDATE `xeno_job_whitelist` SET reason = '[reason]', editby = '[adm_ckey]', edittm = Now() WHERE ckey = '[target_ckey]' AND role = '[role]' AND job = '[job]'"
	var/DBQuery/query_update = dbcon.NewQuery(sql_update)
	if(!query_update.Execute())
		var/fail_msg = query_update.ErrorMsg()
		world.log << "SQL ERROR (U): [fail_msg]"
		message_admins("SQL ERROR (U): [fail_msg]")
		return

	var/msg = "changed reason in xeno job whitelist from [sanitize(xeno_job_whitelist[target_ckey][role][job]["reason"])] to [sanitize(reason)] for [target_ckey] as [role] for [job] job."
	if(ban_edit)
		xeno_job_whitelist[target_ckey][role][job]["ban"] = ban
		msg = "[ban ? "banned" : "unbanned"] [job] job for [role] from xeno job whitelist for [target_ckey] with reason [sanitize(reason)]."

	xeno_job_whitelist[target_ckey][role][job]["reason"] = reason
	xeno_job_whitelist[target_ckey][role][job]["editby"] = adm_ckey
	xeno_job_whitelist[target_ckey][role][job]["edittm"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

	message_admins("[key_name_admin(usr)] [msg]")

	world.send2bridge(
		type = list(BRIDGE_ADMINWL),
		attachment_title = "WHITELIST",
		attachment_msg = "**[key_name(usr)]** [msg]",
		attachment_color = BRIDGE_COLOR_ADMINWL,
	)

	xeno_job_whitelist_view(target_ckey)

/proc/load_xeno_job_whitelistSQL()
	if(!config.use_alien_job_restriction)
		return

	xeno_job_whitelist = list()

	establish_db_connection()
	if(!dbcon.IsConnected())
		world.log << "SQL ERROR (L): whitelist: connection failed to SQL database."
		return

	var/DBQuery/select_query = dbcon.NewQuery("SELECT * FROM xeno_job_whitelist")

	if(!select_query.Execute())
		world.log << "SQL ERROR (L): whitelist: [select_query.ErrorMsg()]."
		return FALSE
	else
		while(select_query.NextRow())
			var/list/row = select_query.GetRowData()

			if(!xeno_job_whitelist[row["ckey"]])
				xeno_job_whitelist[row["ckey"]] = list()
			if(!xeno_job_whitelist[row["ckey"]][row["role"]])
				xeno_job_whitelist[row["ckey"]][row["role"]] = list()

			xeno_job_whitelist[row["ckey"]][row["role"]][row["job"]] = list("ban" = text2num(row["ban"]), "reason" = row["reason"], "addby" = row["addby"], "addtm" = row["addtm"], "editby" = row["editby"], "edittm" = row["edittm"])
	return TRUE

/proc/is_alien_job_whitelisted(client/M, role, job)
	if(!config.use_alien_job_restriction)
		return TRUE
	if(!M || !role || !job || !xeno_job_whitelist)
		return FALSE

	if(!xeno_job_whitelist[M.ckey])
		return FALSE

	role = lowertext(role)
	job = lowertext(job)

	if(xeno_job_whitelist[M.ckey][role] && xeno_job_whitelist[M.ckey][role][job])
		if(xeno_job_whitelist[M.ckey][role][job]["ban"])
			return FALSE
		return TRUE

	return FALSE