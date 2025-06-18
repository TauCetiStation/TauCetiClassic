/datum/bridge_command/banslist
	name = "banslist"
	desc = "Show active player bans"
	format = "@Bot banslist %ckey% %offset%"
	example = "@Bot banslist taukitty"
	position = 50

/datum/bridge_command/banslist/execute(list/params)
	return bridge_command_banslist_handler(params, TRUE)

/datum/bridge_command/bansarchive
	name = "bansarchive"
	desc = "Show all (active, expired and unbanned) player bans."
	format = "@Bot bansarchive %ckey% %offset%"
	example = "@Bot bansarchive taukitty"
	position = 51

/datum/bridge_command/bansarchive/execute(list/params)
	return bridge_command_banslist_handler(params)

/datum/bridge_command/ban
	name = "ban"
	desc = "Ban player"
	format = "@Bot ban ckey %duration% %reason%"
	example = "@Bot ban taukitty 1440 For no reason"
	position = 52

/datum/bridge_command/ban/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])
	var/duration = (lowertext(params["bridge_arg_2"]) == "perma" ? "perma" : text2num(params["bridge_arg_2"]))
	var/reason = sanitize(params["bridge_arg_3"])

	if(!ckey || !reason || !duration || !establish_db_connection("erro_ban"))
		return

	var/mob/target_mob

	for(var/client/C in clients)
		if(C.ckey == ckey)
			target_mob = C.mob
			break

	reason = "[BRIDGE_FROM_SNIPPET_TEXT]: [reason]" // todo: after HoP bot BD we can use trusted admin name as actual ban author

	if(duration == "perma" && DB_ban_record_2(bantype = BANTYPE_PERMA, banned_mob = target_mob, duration = -1, reason = reason, banckey = ckey))
		world.send2bridge(
			type = list(BRIDGE_ADMINBAN),
			attachment_title = "Bridge: Ban",
			attachment_msg = "<@![params["bridge_from_uid"]]> permabanned **[ckey]** with reason:\n*[reason]*",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		ban_unban_log_save("[BRIDGE_FROM_SNIPPET_TEXT] has permabanned [ckey]. - Reason: [reason] - This is a permanent ban.")
		log_admin("[BRIDGE_FROM_SNIPPET_TEXT] has banned [ckey].\nReason: [reason]\nThis is a permanent ban.")
		message_admins("[BRIDGE_FROM_SNIPPET_HTML] has banned [ckey].\nReason: [reason]\nThis is a permanent ban.")


	else if (duration && DB_ban_record_2(bantype = BANTYPE_TEMP, banned_mob = target_mob, duration = duration, reason = reason, banckey = ckey))
		world.send2bridge(
			type = list(BRIDGE_ADMINBAN),
			attachment_title = "Bridge: Ban",
			attachment_msg = "<@![params["bridge_from_uid"]]> banned **[ckey]** for [duration] minutes with reason:\n*[reason]*",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		ban_unban_log_save("[BRIDGE_FROM_SNIPPET_TEXT] has banned [ckey]. - Reason: [reason]")
		log_admin("[BRIDGE_FROM_SNIPPET_TEXT] has banned [ckey].\nReason: [reason]")
		message_admins("[BRIDGE_FROM_SNIPPET_HTML] has banned [ckey].\nReason: [reason]")

	else
		world.send2bridge(
			type = list(BRIDGE_ADMINBAN),
			attachment_title = "Bridge: Ban",
			attachment_msg = "<@![params["bridge_from_uid"]]> was unable to ban **[ckey]**: wrong duration OR player has not been seen on server",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)

/*
// not today... can someone refactor ban/jobban system first?
// /code/game/jobs/jobs.dm (need one world ID or job ID)
/datum/bridge_command/jobban
	name = "jobban"
	desc = "Job ban player. You can find job ID with ``somecommand``"
	format = "@Bot jobban ckey %jobid%"
	example = "@Bot jobban taukitty 4" or "@Bot jobban taukitty CAPTAIN" or something */

/datum/bridge_command/unban
	name = "unban"
	desc = "Unban player ban by ID. You can find ID with ``banslist``"
	format = "@Bot unban ckey %banid%"
	example = "@Bot unban taukitty 123"
	position = 53

/datum/bridge_command/unban/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])
	var/id = text2num(params["bridge_arg_2"])

	if(!ckey || !id || !establish_db_connection("erro_ban"))
		return

	var/DBQuery/select_query = dbcon.NewQuery({"SELECT bantype, a_ckey, job, reason
		FROM erro_ban 
		WHERE id='[id]' AND ckey='[ckey]' AND isnull(unbanned)"})
	select_query.Execute()

	if(!select_query.NextRow())
		world.send2bridge(
			type = list(BRIDGE_ADMINBAN),
			attachment_title = "Bridge: Unban",
			attachment_msg = "<@![params["bridge_from_uid"]]> wrong ban ID, client, or ban already unbanned",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	var/bantype  = select_query.item[1]
	var/admin = select_query.item[2]
	var/job = select_query.item[3]
	var/reason = select_query.item[4]


	var/DBQuery/update_query = dbcon.NewQuery({"UPDATE erro_ban 
		SET unbanned = 1, unbanned_datetime = Now(), unbanned_ckey = '[BRIDGE_FROM_SNIPPET_DB]', unbanned_computerid = '0000000000', unbanned_ip = '127.0.0.1' 
		WHERE id = [id]"})
	update_query.Execute()

	world.send2bridge(
		type = list(BRIDGE_ADMINBAN),
		attachment_title = "Bridge: Unban",
		attachment_msg = "<@![params["bridge_from_uid"]]> has lifted **[ckey]**\'s ban:\n[bantype][job ? "([job])" : ""] by [admin] with reason:\n*[reason]*",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

	ban_unban_log_save("[BRIDGE_FROM_SNIPPET_TEXT] has lifted [ckey] ban.")
	log_admin("[BRIDGE_FROM_SNIPPET_TEXT] has lifted [ckey] ban.")
	message_admins("[BRIDGE_FROM_SNIPPET_HTML] has lifted [ckey] ban.")

/proc/bridge_command_banslist_handler(list/params, active_only = FALSE)
	var/ckey = ckey(params["bridge_arg_1"])
	var/offset = text2num(params["bridge_arg_2"]) // offset

	if(!isnum(offset) || offset < 0)
		offset = 0

	if(!ckey || !establish_db_connection("erro_ban"))
		return

	var/DBQuery/select_query 
	if(active_only)
		select_query = dbcon.NewQuery({"SELECT id, bantype, a_ckey, bantime, duration, round_id, job, reason, ingameage
			FROM erro_ban 
			WHERE ckey='[ckey]' 
				AND (bantype = 'PERMABAN' OR bantype = 'JOB_PERMABAN' OR (bantype = 'TEMPBAN' AND expiration_time > Now()) OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now()))
				AND isnull(unbanned)
			ORDER BY bantime DESC 
			LIMIT 10 OFFSET [offset]"})
	else
		select_query = dbcon.NewQuery({"SELECT id, bantype, a_ckey, bantime, duration, round_id, job, reason, ingameage
			FROM erro_ban 
			WHERE ckey='[ckey]'
			ORDER BY bantime DESC 
			LIMIT 10 OFFSET [offset]"})

	select_query.Execute()

	var/message = ""

	while(select_query.NextRow())
		var/banid = select_query.item[1]
		var/bantype  = select_query.item[2]
		var/admin = select_query.item[3]
		var/bantime  = select_query.item[4]
		var/duration  = select_query.item[5]
		var/roundid  = select_query.item[6]
		var/job = select_query.item[7]
		var/reason = select_query.item[8]
		var/ingameage = select_query.item[9]

		if(duration == -1)
			duration = null // permaban

		message += "**ID**: [banid];  **Type**: [bantype]; **Admin**: [admin]; **Ban time**: [bantime] ([ingameage]); [duration ? "**Duration**: [duration]; " : ""]**Round**: [roundid]; [job ? "**Job**: [job]; ": ""]\n**Reason**: *[reason]*\n\n"

	if(!length(message))
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM),
			attachment_title = "Bridge: Ban List",
			attachment_msg = "Client **[ckey]** has no more[active_only ? "**active**" : ""] bans, <@![params["bridge_from_uid"]]>",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: Ban List",
		attachment_msg = "[active_only ? "**Active**" : "**All**"] bans of **[ckey]**, offset **[offset]**, requested by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)
