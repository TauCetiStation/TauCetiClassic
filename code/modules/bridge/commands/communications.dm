/datum/bridge_command/announce
	name = "announce"
	desc = "Admin announment message to the server"
	format = "@Bot announce %message%"
	example = "@Bot announce Hello! How are you?"
	position = 20

/datum/bridge_command/announce/execute(list/params)
	var/message = sanitize(params["bridge_arg_1"], MAX_PAPER_MESSAGE_LEN, extra = 0)
	
	if(!message)
		return

	do_admin_announce(message, BRIDGE_FROM_SNIPPET_HTML)
	log_admin("Announce: [BRIDGE_FROM_SNIPPET_TEXT] : [message]")

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: announce",
		attachment_msg = "Admin announcment by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/fax
	name = "fax"
	desc = "Send fax from CentComm to all faxes, bb-codes allowed"
	format = "@Bot fax %message%"
	example = "@Bot fax You are all fired!"
	position = 21

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

	send_fax(BRIDGE_FROM_SNIPPET_TEXT, P, department)

	SSStatistics.add_communication_log(type = "fax-centcomm", title = P.name, author = "Centcomm Officer", content = P.info + "\n" + P.stamp_text)
	message_admins("Fax message was created by [BRIDGE_FROM_SNIPPET_HTML] and sent to [department]")
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
	position = 22

/datum/bridge_command/centcomm/execute(list/params)
	var/message = sanitize(params["bridge_arg_1"], MAX_PAPER_MESSAGE_LEN, extra = 0)

	if(!message)
		return

	var/datum/announcement/centcomm/announce = new
	announce.message = message
	announce.play()

	log_admin("[BRIDGE_FROM_SNIPPET_TEXT] has created a command report with sound [announce.sound]. [announce.title] - [announce.subtitle]: [announce.message].")
	message_admins("[BRIDGE_FROM_SNIPPET_HTML] has created a command report.")

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: CentComm message",
		attachment_msg = "CentComm announcment by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)
