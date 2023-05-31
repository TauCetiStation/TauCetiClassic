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
	message += "**Admins**: [get_admin_counts_formatted()]\n"

	// mentors
	message += "**Mentors**: [length(mentors)] mentors online\n"

	// players
	message += "**Players**: [length(clients)] clients and [length(player_list)] active players\n"

	// tickets
	if(!length(global.ahelp_tickets.active_tickets))
		message += "**Tickets**: No active tickets"
	else
		message += "**Tickets**: [length(global.ahelp_tickets.active_tickets)] active tickets"

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: status",
		attachment_msg = "Server status requested by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)
