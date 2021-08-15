/world/proc/send2bridge(msg, list/type = list(BRIDGE_SERVICE), attachment_msg, attachment_title, attachment_color, attachment_footer, mention)

	if(!config.chat_bridge || !islist(type) || !type.len || !(msg || attachment_msg || attachment_title))
		return 0

	var/list/json = list()

	json["type"] = type

	if(msg)
		json["message"] = msg

	if(attachment_msg)
		json["attachment_msg"] = attachment_msg

	if(attachment_title)
		json["attachment_title"] = attachment_title

	if(attachment_color)
		json["attachment_color"] = attachment_color

	if(attachment_footer)
		json["attachment_footer"] = attachment_footer

	if(mention)
		json["mention"] = mention

	var/encoded_json = replacetext(json_encode(json), "'", @"\\`")
	//world.log << "send2bridge json: [encoded_json]"

	spawn()
		var/ext = world.ext_python("get.py", "[shelleo_url_scrub(config.chat_bridge)] --json='[encoded_json]'")

		if(!ext) // ext_python error
			return

		var/list/result = json_decode(ext)
		if(result["success"] != 1)
			if(result["error"])
				ERROR("Unsuccessful send2bridge, json:\n \t[encoded_json]\n \tbridge error:\n \t[result["error"]]")
			else
				ERROR("Unsuccessful send2bridge, json:\n \t[encoded_json]")

	return 1

// Topic format: bridge&bridge_secret=secret&bridge_type=type&bridge_from_user=username&bridge_from_uid=DiscordID&bridge_from_suffix=Discord&bridge_arg_1=...
/world/proc/bridge2game(list/packet_data)
	if(!config.chat_bridge)
		return

	if(global.bridge_secret == null || !istext(packet_data["bridge_secret"]) || global.bridge_secret != packet_data["bridge_secret"])
		return

	packet_data["bridge_secret"] = "SECRET"
	log_href("WTOPIC: BRIDGE: \"[list2params(packet_data)]\"")

	packet_data["bridge_from_user"] = ckey(packet_data["bridge_from_user"])
	packet_data["bridge_from_suffix"] = ckey(packet_data["bridge_from_suffix"])
	packet_data["bridge_from_uid"] = sanitize_numbers(packet_data["bridge_from_uid"])

	if(!packet_data["bridge_from_user"] || !packet_data["bridge_from_uid"] || !packet_data["bridge_from_suffix"])
		return

	var/datum/bridge_command/command = bridge_commands[packet_data["bridge_type"]]
	//world.log << "Req type [packet_data["bridge_type"]]"
	if(command)
		//world.log << "Command [command.name]"
		command.execute(packet_data)

#define BRIDGE_FROM_HTML_SNIPPET "[params["bridge_from_user"]](<span class=\"bridge_[params["bridge_from_suffix"]]\">[params["bridge_from_suffix"]]</span>)"
#define BRIDGE_FROM_SNIPPET "[params["bridge_from_user"]]([params["bridge_from_suffix"]]:[params["bridge_from_uid"]])"

// because of varchar(32) in database we need short version
// todo: temporery before HoP bot will give us trusted associations ckey<->discordID
#define BRIDGE_FROM_DB_SNIPPET "[params["bridge_from_suffix"]]:[params["bridge_from_uid"]]"

var/global/list/bridge_commands

/datum/bridge_command
	var/name
	var/desc
	var/format
	var/example

/datum/bridge_command/proc/execute(list/params)
	return

/datum/bridge_command/help
	name = "help"
	desc = "List of commands or help for a specific command"
	format = "@Bot help %command%"
	example = "@Bot help"

/datum/bridge_command/help/execute(list/params)
	var/message = ""
	var/command_scpecified = params["bridge_arg_1"]

	if(bridge_commands[command_scpecified])
		var/datum/bridge_command/command = bridge_commands[command_scpecified]
		message += {"**[command.name]**
		[command.desc]
		*Format*: ``[command.format]``
		*Example*: ``[command.example]``
		"}
	else
		for(var/C in bridge_commands)
			var/datum/bridge_command/command = bridge_commands[C]
			message += {"**[command.name]**
			[command.desc]
			*Format*: ``[command.format]``
			*Example*: ``[command.example]``
			"}
	
	var/footer = {"Where:
%message% or %reason% - Just text. New line is allowed.
%ckey% - Player key in ckey format: without spaces and \\_-
%duration% - Number for minutes or perma
%banid% or %noteid% - ID number, look in banlist/noteslist command
%offset% - optional offset for lists, default 0"}

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: help",
		attachment_msg = "Help for <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_footer = footer,
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/announce
	name = "announce"
	desc = "Admin announment message to the server"
	format = "@Bot announce %message%"
	example = "@Bot announce Hello! How are you?"

/datum/bridge_command/announce/execute(list/params)
	var/message = sanitize(params["bridge_arg_1"], MAX_PAPER_MESSAGE_LEN, extra = 0)
	
	if(!message)
		return

	do_admin_announce(message, BRIDGE_FROM_HTML_SNIPPET)
	log_admin("Announce: [BRIDGE_FROM_SNIPPET] : [message]")

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM, BRIDGE_ADMINIMPORTANT),
		attachment_title = "Bridge: announce",
		attachment_msg = "Admin announcment by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/fax
	name = "fax"
	desc = "Send fax from CentComm to all faxes, bb-codes allowed"
	format = "@Bot fax %message%"
	example = "@Bot fax You are all fired!"

/datum/bridge_command/fax/execute(list/params)
	var/message = sanitize(params["bridge_arg_1"], MAX_PAPER_MESSAGE_LEN, extra = 0)

	if(!message)
		return

	var/department = "All"

	var/obj/item/weapon/paper/P = new
	P.name = "NanoTrasen Update"
	var/parsed_text = parsebbcode(message)
	parsed_text = replacetext(parsed_text, "\[nt\]", "<img src = bluentlogo.png />")
	P.info = parsed_text
	P.update_icon()

	var/obj/item/weapon/stamp/S = new /obj/item/weapon/stamp/centcomm
	S.stamp_paper(P)

	send_fax(BRIDGE_FROM_SNIPPET, P, department)

	add_communication_log(type = "fax-centcomm", title = P.name, author = "Centcomm Officer", content = P.info + "\n" + P.stamp_text)
	message_admins("Fax message was created by [BRIDGE_FROM_HTML_SNIPPET] and sent to [department]")
	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: fax message",
		attachment_msg = "Fax message was created by <@![params["bridge_from_uid"]]> and sent to ***[department]***\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/centcomm
	name = "centcomm"
	desc = "Send centcomm message to crew" // todo: pub | priv
	format = "@Bot centcomm %message%"
	example = "@Bot centcomm You are all fired!"

/datum/bridge_command/centcomm/execute(list/params)
	var/message = sanitize(params["bridge_arg_1"], MAX_PAPER_MESSAGE_LEN, extra = 0)

	if(!message)
		return

	var/datum/announcement/centcomm/announce = new
	announce.message = message
	announce.play()

	log_admin("[BRIDGE_FROM_SNIPPET] has created a command report with sound [announce.sound]. [announce.title] - [announce.subtitle]: [announce.message].")
	message_admins("[BRIDGE_FROM_HTML_SNIPPET] has created a command report.")

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: CentComm message",
		attachment_msg = "CentComm announcment by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/pm
	name = "pm"
	desc = "(WiP)Send private message to player"
	format = "@Bot pm %ckey% %message%"
	example = "@Bot pm taukitty Hello! How are you?"

/datum/bridge_command/pm/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])
	var/message = sanitize(params["bridge_arg_2"])

	if(!ckey || !message)
		return

	var/client/target
	for(var/client/C in clients)
		if(C.ckey == ckey)
			target = C
			break

	if(!target)
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM, BRIDGE_ADMINLOG),
			attachment_title = "Bridge: PM",
			attachment_msg = "<@![params["bridge_from_uid"]]> client [ckey] is offline!",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	if(!target.holder && !target.current_ticket)
		new /datum/admin_help(message, target, TRUE)

	if(!target.holder)
		to_chat(target, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")

	//todo: reply (priv_msg) currently works only with client
	//to_chat(target, "<font color='red'>Admin PM from-<b><a href='?priv_msg=[BRIDGE_FROM_SNIPPET]'>[BRIDGE_FROM_HTML_SNIPPET]</a></b>: <span class='emojify linkify'>[message]</span></font>")
	to_chat(target, "<font color='red'>Remote admin PM from-<b>[BRIDGE_FROM_HTML_SNIPPET]</b>: <span class='emojify linkify'>[message]</span></font>")

	if(!target.holder)
		 // workaround because tickets needs clients to reply and it's not easy to change
		to_chat(target, "<font color='red'><i>Это удаленный ответ администратора, используйте F1 для ответа.</i></font>")
		giveadminhelpverb(target.ckey)

	admin_ticket_log(target, "<font color='blue'>PM From [BRIDGE_FROM_SNIPPET]: [message]</font>")
	
	if(!target.holder)
		target.mob.playsound_local(null, 'sound/effects/adminhelp.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)

	log_admin_private("[BRIDGE_FROM_SNIPPET]->[key_name(target)]: [message]")
	to_chat((global.admins-target), "<font color='blue'><B>PM: [BRIDGE_FROM_SNIPPET]-&gt;[key_name(target, 1, 0)]:</B> <span class='emojify linkify'>[message]</span></font>" )

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM, BRIDGE_ADMINLOG),
		attachment_title = "Bridge: PM",
		attachment_msg = "**<@![params["bridge_from_uid"]]>->[key_name(target)]:** [message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

///datum/bridge_command/ticketlist
///datum/bridge_command/ticketaction

/datum/bridge_command/ooc
	name = "ooc"
	desc = "Send OOC message"
	format = "@Bot ooc %message%"
	example = "@Bot ooc Hello! How are you?"

/datum/bridge_command/ooc/execute(list/params)
	var/message = sanitize(params["bridge_arg_1"])

	if(!message)
		return

	send2ooc(message, BRIDGE_FROM_SNIPPET, BRIDGE_COLOR_BRIDGE, null, BRIDGE_FROM_HTML_SNIPPET)

	world.send2bridge(
		type = list(BRIDGE_OOC),
		attachment_msg = "OOC: <@![params["bridge_from_uid"]]>: [message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/kick
	name = "kick"
	desc = "Kick player"
	format = "@Bot kick %ckey% %reason%"
	example = "@Bot kick taukitty For no reason"

/datum/bridge_command/kick/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])
	var/reason = sanitize(params["bridge_arg_2"])

	if(!ckey || !reason)
		return

	var/client/target
	for(var/client/C in clients)
		if(C.ckey == ckey)
			target = C
			break

	if(!target || target.holder)
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM, BRIDGE_ADMINLOG),
			attachment_title = "Bridge: Kick",
			attachment_msg = "Kick command from <@![params["bridge_from_uid"]]> could not be executed: [target ? "admin can not be kicked" : "client not found"]",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	to_chat(target, "<span class='warning'>You have been kicked from the server by admin: [reason]</span>")

	log_admin("[BRIDGE_FROM_SNIPPET] booted [key_name(target)] with reason: [reason].")
	message_admins("<span class='notice'>[BRIDGE_FROM_HTML_SNIPPET] booted [key_name_admin(target)] with reason: [reason].</span>")
	QDEL_IN(target, 2 SECONDS)

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM, BRIDGE_ADMINLOG),
		attachment_title = "Bridge: Kick",
		attachment_msg = "Client **[target.ckey]** has been kicked by <@![params["bridge_from_uid"]]>",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/banlist
	name = "banlist"
	desc = "Show active player bans."
	format = "@Bot banlist %ckey% %offset%"
	example = "@Bot banlist taukitty"

/datum/bridge_command/banlist/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])
	var/offset = text2num(params["bridge_arg_2"]) // offset

	if(!isnum(offset) || offset < 0)
		offset = 0

	if(!ckey || !establish_db_connection("erro_ban"))
		return

	var/DBQuery/select_query = dbcon.NewQuery({"SELECT id, bantype, a_ckey, bantime, round_id, job, reason
		FROM erro_ban 
		WHERE ckey='[ckey]' 
			AND (bantype = 'PERMABAN' OR bantype = 'JOB_PERMABAN' OR (bantype = 'TEMPBAN' AND expiration_time > Now()) OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now()))
			AND isnull(unbanned)
		ORDER BY bantime DESC 
		LIMIT 10 OFFSET [offset]"})
	select_query.Execute()

	var/message = ""

	while(select_query.NextRow())
		var/banid = select_query.item[1]
		var/bantype  = select_query.item[2]
		var/admin = select_query.item[3]
		var/bantime  = select_query.item[4]
		var/roundid  = select_query.item[5]
		var/job = select_query.item[6]
		var/reason = select_query.item[7]

		message += "**ID**: [banid];  **Type**: [bantype]; **Admin**: [admin]; **Ban time**: [bantime]; **Round**: [roundid]; [job ? "**Job**: [job]; ": ""]\n**Reason**: *[reason]*\n\n"

	if(!length(message))
		world.send2bridge(
			type = list(BRIDGE_ADMINIMPORTANT),
			attachment_title = "Bridge: Ban List",
			attachment_msg = "Client **[ckey]** has no more active bans, <@![params["bridge_from_uid"]]>",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	world.send2bridge(
		type = list(BRIDGE_ADMINIMPORTANT),
		attachment_title = "Bridge: Ban List",
		attachment_msg = "Active bans of **[ckey]**, offset **[offset]**, requested by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/ban
	name = "ban"
	desc = "Ban player."
	format = "@Bot ban ckey %duration% %reason%"
	example = "@Bot ban taukitty 1440 For no reason"

/datum/bridge_command/ban/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])
	var/duration = (lowertext(params["bridge_arg_2"]) == "perma" ? "perma" : text2num(params["bridge_arg_2"]))
	var/reason = sanitize(params["bridge_arg_3"])

	if(!ckey || !reason || !duration || !establish_db_connection("erro_ban"))
		return

	reason = "[BRIDGE_FROM_SNIPPET]: [reason]" // todo: after HoP bot BD we can use trusted admin name as actual ban author

	if(duration == "perma" && DB_ban_record_2(bantype = BANTYPE_PERMA, duration = -1, reason = reason, banckey = ckey))
		world.send2bridge(
			type = list(BRIDGE_ADMINBAN),
			attachment_title = "Bridge: Ban",
			attachment_msg = "<@![params["bridge_from_uid"]]> permabanned **[ckey]** with reason:\n*[reason]*",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		ban_unban_log_save("[BRIDGE_FROM_SNIPPET] has permabanned [ckey]. - Reason: [reason] - This is a permanent ban.")
		log_admin("[BRIDGE_FROM_SNIPPET] has banned [ckey].\nReason: [reason]\nThis is a permanent ban.")
		message_admins("[BRIDGE_FROM_HTML_SNIPPET] has banned [ckey].\nReason: [reason]\nThis is a permanent ban.")


	else if (duration && DB_ban_record_2(bantype = BANTYPE_TEMP, duration = duration, reason = reason, banckey = ckey))
		world.send2bridge(
			type = list(BRIDGE_ADMINBAN),
			attachment_title = "Bridge: Ban",
			attachment_msg = "<@![params["bridge_from_uid"]]> banned **[ckey]** for [duration] minutes with reason:\n*[reason]*",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		ban_unban_log_save("[BRIDGE_FROM_SNIPPET] has banned [ckey]. - Reason: [reason]")
		log_admin("[BRIDGE_FROM_SNIPPET] has banned [ckey].\nReason: [reason]")
		message_admins("[BRIDGE_FROM_HTML_SNIPPET] has banned [ckey].\nReason: [reason]")
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
	desc = "Unban player ban by ID. You can find ID with ``banlist``"
	format = "@Bot unban ckey %banid%"
	example = "@Bot unban taukitty 123"

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
		SET unbanned = 1, unbanned_datetime = Now(), unbanned_ckey = '[BRIDGE_FROM_DB_SNIPPET]', unbanned_computerid = '0000000000', unbanned_ip = '127.0.0.1' 
		WHERE id = [id]"})
	update_query.Execute()

	world.send2bridge(
		type = list(BRIDGE_ADMINBAN),
		attachment_title = "Bridge: Unban",
		attachment_msg = "**<@![params["bridge_from_uid"]]> has lifted **[ckey]**\'s ban:\n[bantype][job ? "([job])" : ""] by [admin] with reason:\n*[reason]*",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

	ban_unban_log_save("[BRIDGE_FROM_SNIPPET] has lifted [ckey] ban.")
	log_admin("[BRIDGE_FROM_SNIPPET] has lifted [ckey] ban.")
	message_admins("[BRIDGE_FROM_HTML_SNIPPET] has lifted [ckey] ban.")

/datum/bridge_command/noteslist
	name = "noteslist"
	desc = "Show player notes."
	format = "@Bot notes %ckey% %offset%"
	example = "@Bot notes taukitty"

/datum/bridge_command/noteslist/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])
	var/offset = text2num(params["bridge_arg_2"])

	if(!isnum(offset) || offset < 0)
		offset = 0

	if(!ckey || !establish_db_connection("erro_messages"))
		return

	var/DBQuery/select_query = dbcon.NewQuery({"SELECT id, type, adminckey, timestamp, round_id, text
		FROM erro_messages 
		WHERE targetckey='[ckey]' AND deleted=0
		ORDER BY timestamp DESC
		LIMIT 10 OFFSET [offset]"})
	select_query.Execute()

	var/message = ""

	while(select_query.NextRow())
		var/noteid = select_query.item[1]
		var/notetype  = select_query.item[2]
		var/admin = select_query.item[3]
		var/notetime  = select_query.item[4]
		var/roundid  = select_query.item[5]
		var/text = select_query.item[6]

		message += "**ID**: [noteid];  **Type**: [notetype]; **Admin**: [admin]; **Note time**: [notetime]; **Round**: [roundid];\n**Text**: *[text]*\n\n"

	if(!length(message))
		world.send2bridge(
			type = list(BRIDGE_ADMINIMPORTANT),
			attachment_title = "Bridge: Notes",
			attachment_msg = "Client **[ckey]** has no more notes, <@![params["bridge_from_uid"]]>",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	world.send2bridge(
		type = list(BRIDGE_ADMINIMPORTANT),
		attachment_title = "Bridge: Notes",
		attachment_msg = "Notes of **[ckey]**, offset **[offset]**, requested by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/notedel
	name = "notedel"
	desc = "Delete player note by ID. You can find ID with ``noteslist``"
	format = "@Bot notedel %ckey% %noteid%"
	example = "@Bot notedel taukitty 123"

/datum/bridge_command/notedel/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])
	var/id = text2num(params["bridge_arg_2"])

	if(!ckey || !id || !establish_db_connection("erro_messages"))
		return

	var/DBQuery/select_query = dbcon.NewQuery({"SELECT type, adminckey, text
		FROM erro_messages 
		WHERE id='[id]' AND deleted=0"})
	select_query.Execute()

	if(!select_query.NextRow())
		world.send2bridge(
			type = list(BRIDGE_ADMINIMPORTANT),
			attachment_title = "Bridge: Notedel",
			attachment_msg = "<@![params["bridge_from_uid"]]> wrong note ID or note already deleted",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	var/notetype = select_query.item[1]
	var/admin = select_query.item[2]
	var/text = select_query.item[3]

	var/DBQuery/update_query = dbcon.NewQuery({"UPDATE erro_messages 
		SET deleted = 1, deleted_ckey = '[BRIDGE_FROM_DB_SNIPPET]'
		WHERE id = [id]"})
	update_query.Execute()

	world.send2bridge(
		type = list(BRIDGE_ADMINIMPORTANT),
		attachment_title = "Bridge: Notedel",
		attachment_msg = "**<@![params["bridge_from_uid"]]> has deleted **[ckey]**'s note:\n[notetype] by [admin] with text:\n*[text]*",
		attachment_color = BRIDGE_COLOR_ADMINBAN,
	)

	log_admin("[BRIDGE_FROM_SNIPPET] has deleted [ckey] note [notetype] by [admin] with text: [text].")
	message_admins("[BRIDGE_FROM_HTML_SNIPPET] has deleted [ckey] note [notetype] by [admin] with text: [text].")

/datum/bridge_command/pp
	name = "pp"
	desc = "Player panel (info on player)"
	format = "@Bot pp %ckey%"
	example = "@Bot pp taukitty"

/datum/bridge_command/pp/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])

	if(!ckey || !establish_db_connection("erro_ban", "erro_messages", "erro_player"))
		return

	var/DBQuery/select_query_player = dbcon.NewQuery({"SELECT firstseen, lastseen, ingameage
		FROM erro_player 
		WHERE ckey='[ckey]'"})
	select_query_player.Execute()

	if(!select_query_player.NextRow())
		world.send2bridge(
			type = list(BRIDGE_ADMINIMPORTANT),
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

	// todo: if online - show IC info (character, antag)

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
		type = list(BRIDGE_ADMINIMPORTANT),
		attachment_title = "Bridge: Player Panel",
		attachment_msg = "<@![params["bridge_from_uid"]]> player **[ckey]**:\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

///datum/bridge_command/noteadd
///datum/bridge_command/notewarn

/datum/bridge_command/status
	name = "status"
	desc = "Get server status"
	format = "@Bot status"
	example = "@Bot status"

/datum/bridge_command/status/execute(list/params)
	var/message = ""

	// round stat
	message += "**Status:**: #[global.round_id]"

	if(SSticker.mode && SSticker.mode.name)
		message += ", [SSticker.mode.name] ([master_mode])"
	else
		message += ", Lobby ([master_mode])"


	if(SSmapping.config && SSmapping.config.map_name)
		message += ", [SSmapping.config.map_name]"

	message += ", [roundduration2text()]"

	if(SSshuttle.online && SSshuttle.location < 2)
		message += ", Shuttle ETA [shuttleeta2text()] [SSshuttle.location == 0 ? "(transit)" : "(station)"]"

	message += "\n"

	// todo: code, antags
	
	// admins
	var/list/adm = get_admin_counts()
	var/admins_online_flag = FALSE

	message += "**Admins**: "

	if(!length(adm["afk"]) && !length(adm["stealth"]) && !length(adm["noflags"]) && !length(adm["present"]))
		message += "No admins online"
	else
		admins_online_flag = TRUE
		if(length(adm["present"]))
			message += "\[[get_english_list(adm["present"])]\]; "

		if(length(adm["stealth"]))
			message += "Stealthed\[[get_english_list(adm["stealth"])]\]; "

		if(length(adm["afk"]))
			message += "AFK\[[get_english_list(adm["afk"])]\]; "

		if(length(adm["noflags"]))
			message += "without +BAN\[[get_english_list(adm["noflags"])]\]; "

	message += "\n"

	// mentors
	message += "**Mentors**: [length(mentors)] mentors online\n"

	// players
	message += "**Players**: [length(clients)] clients and [length(player_list)] active players\n"

	// tickets
	if(!length(global.ahelp_tickets.active_tickets))
		message += "**Tickets**: No active tickets"
	else
		message += "**Tickets**: [global.ahelp_tickets.active_tickets] active tickets" + (admins_online_flag ? "" : " and no admins online! :warning:")

	world.send2bridge(
		type = list(BRIDGE_ADMINIMPORTANT),
		attachment_title = "Bridge: status",
		attachment_msg = "Server status requested by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

#undef BRIDGE_FROM_HTML_SNIPPET
#undef BRIDGE_FROM_SNIPPET
