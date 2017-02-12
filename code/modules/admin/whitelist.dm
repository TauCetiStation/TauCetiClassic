/datum/admins/proc/whitelist_panel()
	set category = "Server"
	set name = "Whitelist Panel"
	set desc = "Allows you to view whitelist and maybe add or edit users."

	src = usr.client.holder
	if(!check_rights(R_ADMIN))
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
	if(!check_rights(R_ADMIN))
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

		var/reason = sanitize_alt(role_whitelist[user_ckey][role]["reason"])
		output += "<td><a class='small' href='?src=\ref[src];whitelist=edit_reason;ckey=[user_ckey];role=[role]'>[reason]</a></td>"
		var/addby = role_whitelist[user_ckey][role]["addby"]
		var/addtm = role_whitelist[user_ckey][role]["addtm"]
		output += "<td>[addby] - [addtm]</td>"
		var/editby = role_whitelist[user_ckey][role]["editby"]
		var/edittm = role_whitelist[user_ckey][role]["edittm"]
		output += "<td>[editby] - [edittm]</td>"

		output += "</tr>"

	output += {"
</table></div>
<div id='top'><b>Search:</b> <input type='text' id='filter' value='' style='width:70%;' onkeyup='updateSearch();'></div>
</body>
</html>"}

	usr << browse(output,"window=whitelist_user;size=750x500")

/datum/admins/proc/whitelist_add_user()
	if(!check_rights(R_ADMIN))
		return

	var/target_ckey = ckey(input(usr,"type in ckey:","Add User", null) as null|text)
	if(!target_ckey)
		return

	if(role_whitelist[target_ckey])
		to_chat(usr, "<span class='warning'>[target_ckey] already exists in whitelist.</span>")
		return

	var/role = input(usr, "select role:", "Role") as null|anything in whitelisted_roles
	if(!role)
		return

	var/reason = input(usr, "type in reason:", "Reason") as null|text
	if(!reason)
		return

	//Yay! Copycheck! Lets do final check before we touch DB.
	if(role_whitelist[target_ckey]) //inputs :(, i wish for multi column inputs with drop down menus... so we can input while we input in one go!
		to_chat(usr, "<span class='warning'>[target_ckey] already exists in whitelist.</span>")
		return

	whitelist_DB_add(target_ckey, role, reason, usr.ckey)

/datum/admins/proc/whitelist_add_role(target_ckey)
	if(!check_rights(R_ADMIN))
		return

	if(!target_ckey)
		return

	var/role = input(usr, "select role:", "Role") as null|anything in whitelisted_roles
	if(!role)
		return

	if(role_whitelist[target_ckey][role])
		to_chat(usr, "<span class='warning'>[role] for [target_ckey] already exists in whitelist.</span>")
		return

	var/reason = input(usr, "type in reason:", "Reason") as null|text
	if(!reason)
		return

	if(!role_whitelist[target_ckey])
		to_chat(usr, "<span class='warning'>[target_ckey] does not exist in whitelist (?_?).</span>")
		return
	if(role_whitelist[target_ckey][role])
		to_chat(usr, "<span class='warning'>[role] for [target_ckey] already exists in whitelist.</span>")
		return

	whitelist_DB_add(target_ckey, role, reason, usr.ckey)

/datum/admins/proc/whitelist_edit(target_ckey, role, ban_edit)
	if(!check_rights(R_ADMIN))
		return

	if(!target_ckey || !role)
		return

	var/ban = role_whitelist[target_ckey][role]["ban"]

	if(ban_edit)
		ban_edit = alert(usr, ban ? "Do you want to UNBAN [role] for [target_ckey]?" : "Do you want to REMOVE [role] for [target_ckey]?",,ban ? "Unban" : "Remove", "Cancel")
		switch(ban_edit)
			if("Cancel")
				return
			if("Unban")
				ban = FALSE
			if("Remove")
				ban = TRUE

	var/reason = input(usr, "type in reason:", "Reason") as null|text
	if(!reason)
		return

	if(!role_whitelist[target_ckey])
		to_chat(usr, "<span class='warning'>[target_ckey] does not exist in whitelist.</span>")
		return

	if(!role_whitelist[target_ckey][role])
		to_chat(usr, "<span class='warning'>[role] for [target_ckey] does not exist in whitelist.</span>")
		return

	whitelist_DB_edit(target_ckey, role, ban, ban_edit, reason, usr.ckey)

/datum/admins/proc/whitelist_DB_add(target_ckey, role, reason, adm_ckey)
	if(!check_rights(R_ADMIN))
		return

	reason = sql_sanitize_text(reason)

	var/database/query/insert_query = new("INSERT INTO whitelist VALUES (?, ?, '0', ?, ?, datetime('now'), ?, datetime('now'));", target_ckey, role, reason, adm_ckey, adm_ckey)
	insert_query.Execute(whitelist_db)
	var/fail_msg = insert_query.ErrorMsg()
	if(fail_msg)
		world.log << "SQL ERROR (I): [fail_msg]"
		message_admins("SQL ERROR (I): [fail_msg]")
		return

	if(!role_whitelist[target_ckey])
		role_whitelist[target_ckey] = list()
	role_whitelist[target_ckey][role] = list("ban" = 0, "reason" = reason, "addby" = adm_ckey, "addtm" = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss"), "editby" = adm_ckey)

	var/msg = "whitelisted [role] for [target_ckey] with reason: [sanitize(reason)]"
	message_admins("[key_name_admin(usr)] [msg]")
	log_admin("[key_name(usr)] [msg]")
	send2slack_logs(key_name(usr), msg, "(WHITELIST)")

	whitelist_panel()
	whitelist_view(target_ckey)

/datum/admins/proc/whitelist_DB_edit(target_ckey, role, ban, ban_edit, reason, adm_ckey)
	if(!check_rights(R_ADMIN))
		return

	reason = sql_sanitize_text(reason)

	var/database/query/update_query
	if(ban_edit)
		update_query = new("UPDATE whitelist SET ban = ?, reason = ?, editby = ?, edittm = datetime('now') WHERE ckey = ? AND role = ?;", ban, reason, adm_ckey, target_ckey, role)
	else
		update_query = new("UPDATE whitelist SET reason = ?, editby = ?, edittm = datetime('now') WHERE ckey = ? AND role = ?;", reason, adm_ckey, target_ckey, role)
	update_query.Execute(whitelist_db)
	var/fail_msg = update_query.ErrorMsg()
	if(fail_msg)
		world.log << "SQL ERROR (U): [fail_msg]"
		message_admins("SQL ERROR (U): [fail_msg]")
		return

	var/msg = "changed reason from [sanitize(role_whitelist[target_ckey][role]["reason"])] to [sanitize(reason)] for [target_ckey] as [role]."
	if(ban_edit)
		role_whitelist[target_ckey][role]["ban"] = ban
		msg = "[ban ? "removed" : "unbanned"] [role] for [target_ckey] with reason [sanitize(reason)]."

	role_whitelist[target_ckey][role]["reason"] = reason
	role_whitelist[target_ckey][role]["editby"] = adm_ckey
	role_whitelist[target_ckey][role]["edittm"] = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")

	message_admins("[key_name_admin(usr)] [msg]")
	log_admin("[key_name(usr)] [msg]")
	send2slack_logs(key_name(usr), msg, "(WHITELIST)")

	whitelist_view(target_ckey)

/proc/load_whitelistSQL()
	if(!whitelist_db)

		// Create or load the DB.
		whitelist_db = new(whitelist_sqlite_path)

		// Whitelist table.
		var/database/query/init_schema = new(
			"CREATE TABLE IF NOT EXISTS whitelist ( \
			ckey TEXT NOT NULL, \
			role TEXT NOT NULL, \
			ban INTEGER NOT NULL, \
			reason TEXT NOT NULL, \
			addby TEXT NOT NULL, \
			addtm INTEGER NOT NULL, \
			editby TEXT NOT NULL, \
			edittm INTEGER NOT NULL \
			);")

		init_schema.Execute(whitelist_db)
		if(init_schema.ErrorMsg())
			world.log << "SQL ERROR (C): whitelist: [init_schema.ErrorMsg()]."
			return FALSE

	role_whitelist = list()
	var/database/query/query = new("SELECT * FROM whitelist")
	query.Execute(whitelist_db)
	if(query.ErrorMsg())
		world.log << "SQL ERROR (L): whitelist: [query.ErrorMsg()]."
		return FALSE
	else
		while(query.NextRow())
			var/list/row = query.GetRowData()
			if(role_whitelist[row["ckey"]])
				var/list/A = role_whitelist[row["ckey"]]
				A.Add(list(row["role"] = list("ban" = row["ban"], "reason" = row["reason"], "addby" = row["addby"], "addtm" = row["addtm"], "editby" = row["editby"], "edittm" = row["edittm"])))
			else
				role_whitelist[row["ckey"]] = list(row["role"] = list("ban" = row["ban"], "reason" = row["reason"], "addby" = row["addby"], "addtm" = row["addtm"], "editby" = row["editby"], "edittm" = row["edittm"]))
	return TRUE

/proc/is_whitelisted(mob/M, role)
	if(!M || !role || !role_whitelist || !role_whitelist[M.ckey] || !check_rights(R_ADMIN, FALSE))
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

	if(role_whitelist[M.ckey][role] && !role_whitelist[M.ckey][role]["ban"])
		return TRUE
	return FALSE
