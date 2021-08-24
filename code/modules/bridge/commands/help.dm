/datum/bridge_command/help
	name = "help"
	desc = "List of commands or help for a specific command"
	format = "@Bot help %command%"
	example = "@Bot help"
	position = 1

/datum/bridge_command/help/execute(list/params)
	var/command_specified = sanitize(params["bridge_arg_1"])

	var/message = ""

	for(var/C in bridge_commands)
		var/datum/bridge_command/command = bridge_commands[C]
		if(command_specified && !(findtext(command.name, command_specified))) // so we can see all bans commands with "ban" world
			continue
		message += {"**[command.name]**
		[command.desc]
		*Format*: ``[command.format]``
		*Example*: ``[command.example]``
		"}

	if(!length(message))
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM),
			attachment_title = "Bridge: help",
			attachment_msg = "No commands found for your request <@![params["bridge_from_uid"]]>",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return
	
	var/footer = {"Where:
%message%, %reason%, %objective% - Just text. New line is allowed.
%ckey% - Player key in ckey format: without spaces and \\_-
%duration% - Number for minutes or perma
%banid%, %noteid% - ID number, look in banslist/noteslist command
%offset% - optional offset for lists, default 0"}

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: help",
		attachment_msg = "Help for <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_footer = footer,
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)
