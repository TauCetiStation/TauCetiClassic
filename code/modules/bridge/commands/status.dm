/datum/bridge_command/status
	name = "status"
	desc = "Get server status"
	format = "@Bot status"
	example = "@Bot status"
	position = 2

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
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: status",
		attachment_msg = "Server status requested by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)
