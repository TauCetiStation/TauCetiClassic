/datum/bridge_command/pp
	name = "pp"
	desc = "Player panel (info on player)"
	format = "@Bot pp %ckey%"
	example = "@Bot pp taukitty"
	position = 80

/datum/bridge_command/pp/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])

	if(!ckey || !establish_db_connection("erro_ban", "erro_messages", "erro_player"))
		return

	var/DBQuery/select_query_player = dbcon.NewQuery({"SELECT DATE_FORMAT(firstseen, '%d.%m.%Y %H:%i:%s'), DATE_FORMAT(lastseen, '%d.%m.%Y %H:%i:%s'), ingameage
		FROM erro_player 
		WHERE ckey='[ckey]'"})
	select_query_player.Execute()

	if(!select_query_player.NextRow())
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM),
			attachment_title = "Bridge: Player Panel",
			attachment_msg = "<@![params["bridge_from_uid"]]> player **[ckey]** not found",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	var/message = ""
	var/client/online_client

	for(var/client/C in clients)
		if(C.ckey == ckey)
			online_client = C
			break

	// age
	var/firstseen = select_query_player.item[1]
	var/lastseen = select_query_player.item[2]
	var/ingameage = select_query_player.item[3]
	var/list/byond_date = online_client ? online_client.get_byond_registration() : get_byond_registration_from_pager(ckey)

	message += "**First seen**: [firstseen]; **Last seen**: [lastseen];\n **Ingame age**: [ingameage];"

	if(length(byond_date))
		message += " **Byond registration**: [byond_date[3]].[byond_date[2]].[byond_date[1]]"

	message += "\n"

	// online status
	if(online_client)
		message += "**Currenlty on server!**"
	else if(ckey in joined_player_list)
		message += "Was on server this round."
	else
		message += "Not on this server."

	message += "\n"

	if(online_client)
		var/mob/M = online_client.mob
		message += "Playing as [M.real_name]"
		if(M.mind && M.mind.assigned_job)
			message += " ([M.mind.assigned_job.title] - spawn job)"
		switch(M.stat)
			if(UNCONSCIOUS)
				message += " (unconscious)"
			if(DEAD)
				message += " (dead)"
		message += "\n"

		if(isanyantag(M))
			message += "**Antag roles:**\n"
			for(var/id in M.mind.antag_roles)
				var/datum/role/role = M.mind.antag_roles[id]
				message += "[role.name]\n"

	// guard
	if(online_client)
		if(!length(online_client.guard.short_report))
			online_client.guard.prepare()

		message += "**Guard report**: [online_client.guard.short_report]"

	else
		message += "**Guard report**: not available for offline player"

	message += "\n"

	// bans
	var/DBQuery/select_query_bans = dbcon.NewQuery({"SELECT bantype, job
		FROM erro_ban 
		WHERE ckey='[ckey]' 
			AND (bantype = 'PERMABAN' OR bantype = 'JOB_PERMABAN' OR (bantype = 'TEMPBAN' AND expiration_time > Now()) OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now()))
			AND isnull(unbanned)"})
	select_query_bans.Execute()

	var/flag_currently_banned = FALSE
	var/jobbans_total = 0
	var/jobbans_text = ""

	while(select_query_bans.NextRow())
		//var/bantype  = select_query_bans.item[1]
		var/job = select_query_bans.item[2]
		
		if(job)
			jobbans_total++
			jobbans_text += "[job]; "
		else
			flag_currently_banned = TRUE

	if(flag_currently_banned)
		message += "Currently **banned** and can't play on server;"
	else
		message += "Has no active server bans;"

	message += " Has **[jobbans_total]** jobbans[length(jobbans_text) ? " \[[trim(jobbans_text)]\]" : ""]"
	message += "\n"

	// notes
	// todo: need different type for warnings in DB so we can show different types here
	var/notes_count = 0

	var/DBQuery/select_query_notes =  dbcon.NewQuery({"SELECT COUNT(*)
		FROM erro_messages
		WHERE targetckey='[ckey]' AND deleted=0"})
	select_query_notes.Execute()

	if(select_query_notes.NextRow())
		notes_count = select_query_notes.item[1]
	
	message += "Has **[notes_count]** notes"

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: Player Panel",
		attachment_msg = "<@![params["bridge_from_uid"]]> player **[ckey]**:\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)
