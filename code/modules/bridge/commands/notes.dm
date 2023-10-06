// todo:
// /datum/bridge_command/noteadd
// /datum/bridge_command/notewarn
// maybe need to do #7744 and #6658 first

/datum/bridge_command/noteslist
	name = "noteslist"
	desc = "Show player notes."
	format = "@Bot notes %ckey% %offset%"
	example = "@Bot notes taukitty"
	position = 70

/datum/bridge_command/noteslist/execute(list/params)
	var/ckey = ckey(params["bridge_arg_1"])
	var/offset = text2num(params["bridge_arg_2"])

	if(!isnum(offset) || offset < 0)
		offset = 0

	if(!ckey || !establish_db_connection("erro_messages"))
		return

	var/DBQuery/select_query = dbcon.NewQuery({"SELECT id, type, adminckey, timestamp, round_id, text, ingameage
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
		var/ingameage = select_query.item[7]

		message += "**ID**: [noteid];  **Type**: [notetype]; **Admin**: [admin]; **Note time**: [notetime] ([ingameage]); **Round**: [roundid];\n**Text**: *[text]*\n\n"

	if(!length(message))
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM),
			attachment_title = "Bridge: Notes",
			attachment_msg = "Client **[ckey]** has no more notes, <@![params["bridge_from_uid"]]>",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: Notes",
		attachment_msg = "Notes of **[ckey]**, offset **[offset]**, requested by <@![params["bridge_from_uid"]]>\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/notedel
	name = "notedel"
	desc = "Delete player note by ID. You can find ID with ``noteslist``"
	format = "@Bot notedel %ckey% %noteid%"
	example = "@Bot notedel taukitty 123"
	position = 71

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
			type = list(BRIDGE_ADMINCOM),
			attachment_title = "Bridge: Notedel",
			attachment_msg = "<@![params["bridge_from_uid"]]> wrong note ID or note already deleted",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	var/notetype = select_query.item[1]
	var/admin = select_query.item[2]
	var/text = select_query.item[3]

	var/DBQuery/update_query = dbcon.NewQuery({"UPDATE erro_messages 
		SET deleted = 1, deleted_ckey = '[BRIDGE_FROM_SNIPPET_DB]'
		WHERE id = [id]"})
	update_query.Execute()

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: Notedel",
		attachment_msg = "<@![params["bridge_from_uid"]]> has deleted **[ckey]**'s note:\n[notetype] by [admin] with text:\n*[text]*",
		attachment_color = BRIDGE_COLOR_ADMINBAN,
	)

	log_admin("[BRIDGE_FROM_SNIPPET_TEXT] has deleted [ckey] note [notetype] by [admin] with text: [text].")
	message_admins("[BRIDGE_FROM_SNIPPET_HTML] has deleted [ckey] note [notetype] by [admin] with text: [text].")
