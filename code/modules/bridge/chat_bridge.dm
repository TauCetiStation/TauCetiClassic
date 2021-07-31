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

// Topic format: bridge&bridge_secret=secret&bridge_type=type&bridge_from_user=ckey&bridge_from_uid=DiscordID&bridge_from_suffix=Discord&bridge_*=*
/world/proc/bridge2game(list/packet_data)
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
	world.log << "Req type [packet_data["bridge_type"]]"
	if(command)
		world.log << "Command [command.name]"
		command.execute(packet_data)

#define BRIDGE_FROM_HTML_SNIPPET "[params["bridge_from_user"]]<span class=\"bridge_[params["bridge_from_suffix"]]\">([params["bridge_from_suffix"]])</span>"
#define BRIDGE_FROM_SNIPPET "[params["bridge_from_user"]]([params["bridge_from_suffix"]]:[params["bridge_from_uid"]])"

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
	desc = "List of commands"
	format = "@Bot help"
	example = "@Bot help"

/datum/bridge_command/help/execute(list/params)
	var/message = ""

	for(var/C in bridge_commands)
		var/datum/bridge_command/command = bridge_commands[C]
		message += {"**[command.name]**
		[command.desc]
		*Format*: ``[command.format]``
		*Example*: ``[command.example]``
		"}
	
	var/footer = {"Where:
``%message%`` or ``%reason%`` - Just text. New line is allowed.
``%ckey%`` - Player key in ckey format: without spaces and \\_-
``%duration%`` - Number for minutes or ``perma``
``%banid%`` - ban ID, look in ``banlist`` command"}

	world.send2bridge(
		type = list(BRIDGE_ADMINIMPORTANT),
		attachment_title = "Bridge: help",
		attachment_msg = message,
		attachment_footer = footer,
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/announce
	name = "announce"
	desc = "Admin announment message to server"
	format = "@Bot announce %message%"
	example = "@Bot announce Hello! How are you?"

/datum/bridge_command/announce/execute(list/params)
	var/message = sanitize(params["bridge_message"], MAX_PAPER_MESSAGE_LEN, extra = 0)
	
	if(!message)
		return

	do_admin_announce(message, BRIDGE_FROM_HTML_SNIPPET)
	log_admin("Announce: [BRIDGE_FROM_SNIPPET] : [message]")

	world.send2bridge(
		type = list(BRIDGE_ADMINIMPORTANT),
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
	var/message = sanitize(params["bridge_message"], MAX_PAPER_MESSAGE_LEN, extra = 0)

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
	var/message = sanitize(params["bridge_message"], MAX_PAPER_MESSAGE_LEN, extra = 0)

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

/datum/bridge_command/pm //todo: ticked command from tg bot
	name = "pm"
	desc = "Send private message to player"
	format = "@Bot pm %ckey% %message%"
	example = "@Bot pm taukitty Hello! How are you?"

/datum/bridge_command/ooc //todo: enable ooc channel for bridge
	name = "ooc"
	desc = "Send OOC message"
	format = "@Bot ooc %message%"
	example = "@Bot ooc Hello! How are you?"

/datum/bridge_command/ooc/execute(list/params)
	var/message = sanitize(params["bridge_message"])

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
	var/ckey = ckey(params["bridge_ckey"])
	var/reason = sanitize(params["bridge_reason"])

	if(!ckey || !reason)
		return

	var/client/target
	for(var/client/C in clients)
		if(C.ckey == ckey)
			target = C
			break

	if(!target || target.holder)
		world.send2bridge(
			type = list(BRIDGE_ADMINIMPORTANT),
			attachment_title = "Bridge: Kick",
			attachment_msg = "Kick command from <@![params["bridge_from_uid"]]> could not be executed: [target ? "admin can not be kicked" : "client not found"]",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	if(!reason)
		to_chat(target, "<span class='warning'>You have been kicked from the server by admin</span>")
	else
		to_chat(target, "<span class='warning'>You have been kicked from the server by admin: [reason]</span>")

	log_admin("[BRIDGE_FROM_SNIPPET] booted [key_name(target)].")
	message_admins("<span class='notice'>[BRIDGE_FROM_HTML_SNIPPET] booted [key_name_admin(target)].</span>")
	QDEL_IN(target, 2 SECONDS)

	world.send2bridge(
		type = list(BRIDGE_ADMINIMPORTANT),
		attachment_title = "Bridge: Kick",
		attachment_msg = "Client **[target.ckey]** has been kicked by <@![params["bridge_from_uid"]]>",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/banlist
	name = "banlist"
	desc = "Show active player bans."
	format = "@Bot banlist %ckey%"
	example = "@Bot banlist taukitty"

/datum/bridge_command/banlist/execute(list/params)
	var/ckey = ckey(params["bridge_ckey"])

	if(!ckey || !establish_db_connection("erro_ban"))
		return

	var/DBQuery/select_query = dbcon.NewQuery({"SELECT id, bantype, a_ckey, bantime, round_id, job, reason
		FROM erro_ban 
		WHERE ckey='[ckey]' 
			AND (bantype = 'PERMABAN' OR bantype = 'JOB_PERMABAN' OR (bantype = 'TEMPBAN' AND expiration_time > Now()) OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now()))
			AND isnull(unbanned)
		ORDER BY bantime DESC LIMIT 10"})
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
			attachment_msg = "Client **[ckey]** has no bans, <@![params["bridge_from_uid"]]>",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	world.send2bridge(
		type = list(BRIDGE_ADMINIMPORTANT),
		attachment_title = "Bridge: Ban List",
		attachment_msg = "Last 10 active bans of **[ckey]**, requested by <@![params["bridge_from_uid"]]>\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/ban
	name = "ban"
	desc = "Ban player."
	format = "@Bot ban ckey %duration% %reason%"
	example = "@Bot ban taukitty 1440 For no reason"

/datum/bridge_command/ban/execute(list/params)
	var/ckey = ckey(params["bridge_ckey"])
	var/reason = sanitize(params["bridge_reason"])
	var/duration = text2num(params["bridge_duration"])

	if(!ckey || !reason || !establish_db_connection("erro_ban"))
		return

	reason = "[BRIDGE_FROM_SNIPPET]: [reason]" // todo: after HoP bot BD we can use trusted admin name as actual ban author

	if(lowertext(params["bridge_duration"]) == "perma" && DB_ban_record_2(bantype = BANTYPE_PERMA, duration = -1, reason = reason, banckey = ckey))
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
	var/ckey = ckey(params["bridge_ckey"])
	var/id = text2num(params["bridge_banid"])

	if(!ckey || !id || !establish_db_connection("erro_ban"))
		return

	var/DBQuery/select_query = dbcon.NewQuery({"SELECT bantype, a_ckey, job, reason
		FROM erro_ban 
		WHERE id='[id]' AND isnull(unbanned)"})
	select_query.Execute()

	if(!select_query.NextRow())
		world.send2bridge(
			type = list(BRIDGE_ADMINBAN),
			attachment_title = "Bridge: Unban",
			attachment_msg = "<@![params["bridge_from_uid"]]> wrong ban ID or ban already unbanned",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	var/bantype  = select_query.item[1]
	var/admin = select_query.item[2]
	var/job = select_query.item[3]
	var/reason = select_query.item[4]


	var/DBQuery/update_query = dbcon.NewQuery({"UPDATE erro_ban 
		SET unbanned = 1, unbanned_datetime = Now(), unbanned_ckey = '[BRIDGE_FROM_SNIPPET]', unbanned_computerid = '0000000000', unbanned_ip = '127.0.0.1' 
		WHERE id = [id]"})
	update_query.Execute()

	world.send2bridge(
		type = list(BRIDGE_ADMINBAN),
		attachment_title = "UNBAN",
		attachment_msg = "**<@![params["bridge_from_uid"]]> has lifted **[ckey]**'s ban:\n[bantype][job ? "([job])" : ""] by [admin] with reason:\n*[reason]*",
		attachment_color = BRIDGE_COLOR_ADMINBAN,
	)

	ban_unban_log_save("[BRIDGE_FROM_SNIPPET] has lifted [ckey] ban.")
	log_admin("[BRIDGE_FROM_SNIPPET] has lifted [ckey] ban.")
	message_admins("[BRIDGE_FROM_HTML_SNIPPET] has lifted [ckey] ban.")

/datum/bridge_command/pp
	name = "pp"
	desc = "Player panel (info on player)"
	format = "@Bot pp %ckey%"
	example = "@Bot pp taukitty"

/datum/bridge_command/pp/execute(list/params)
	var/ckey = ckey(params["bridge_ckey"])

	if(!ckey || !establish_db_connection("erro_ban", "erro_player"))
		return

/*	for(var/client/C in clients)
		if(C.ckey == ckey)
			message = "[ckey] is currenlty online!"
			return

	if(!message && (ckey in joined_player_list))
		message = "Client was in round, but currenlty offline."*/
	// player offline, last seen date

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
