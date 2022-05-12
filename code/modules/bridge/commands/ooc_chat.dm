// todo:
// /datum/bridge_command/muteooc (need to rewrite cmd_admin_mute(tg))

/datum/bridge_command/ooc
	name = "ooc"
	desc = "Send OOC message"
	format = "@Bot ooc %message%"
	example = "@Bot ooc Hello! How are you?"
	position = 30

/datum/bridge_command/ooc/execute(list/params)
	var/message = sanitize(params["bridge_arg_1"])

	if(!message)
		return

	send2ooc(message, BRIDGE_FROM_SNIPPET_TEXT, BRIDGE_COLOR_BRIDGE, null, BRIDGE_FROM_SNIPPET_HTML)

	world.send2bridge(
		type = list(BRIDGE_OOC),
		attachment_msg = "OOC: <@![params["bridge_from_uid"]]>: [message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/toggleooc
	name = "toggleooc"
	desc = "Toggle OOC globally"
	format = "@Bot toggleooc"
	example = "@Bot toggleooc"
	position = 31

/datum/bridge_command/toggleooc/execute(list/params)
	ooc_allowed = !ooc_allowed

	world.send2bridge(
		type = list(BRIDGE_OOC, BRIDGE_ADMINCOM),
		attachment_msg = "<@![params["bridge_from_uid"]]> toggled OOC [ooc_allowed ? "on" : "off"]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

	to_chat(world, "<B>The OOC channel has been globally [ooc_allowed ? "enabled" : "disabled"]!</B>")

	log_admin("[BRIDGE_FROM_SNIPPET_TEXT] toggled OOC [ooc_allowed ? "on" : "off"].")
	message_admins("[BRIDGE_FROM_SNIPPET_HTML] toggled OOC [ooc_allowed ? "on" : "off"].")
