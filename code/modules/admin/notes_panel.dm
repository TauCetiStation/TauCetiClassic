/proc/notes_panel(ckey) // change to proc player_access = FALSE
	if(!(check_rights(R_LOG) && check_rights(R_BAN)))
		return

	if(!establish_db_connection("erro_messages", "erro_player"))
		return

	var/sql_ckey = ckey(ckey)

	if(!sql_ckey)
		return

	var/html = ""

	var/player_ingame_age
	var/player_age
	var/offline = TRUE

	if(global.directory[ckey])
		var/client/C = global.directory[ckey]
		player_ingame_age = C.player_ingame_age
		player_age = C.player_age
		offline = FALSE
	else
		var/DBQuery/player_query = dbcon.NewQuery("SELECT datediff(Now(), firstseen) as age, ingameage FROM erro_player WHERE ckey = '[sql_ckey]'")
		player_query.Execute()

		while(player_query.NextRow())
			player_age = text2num(player_query.item[1])
			player_ingame_age = text2num(player_query.item[2])
			break

	html += {"
		<div style='color: #000; font-weight: bold;'>
			<a style='float: right;' href='?_src_=holder;notes_add=[sql_ckey]'>Add new message</a>
			[offline ? "<span style='color: red;'>Offline</span>" : "<span style='color: green;'>Online</span>"] /
			Player age: [player_age] / In-game age: [player_ingame_age]
			<br/><hr>
		</div>
	"}

	// todo: use mysql DATE_FORMAT(timestamp, '%d.%m.%Y %H:%i:%s') after bans table rework (consistent column names, also need to allow job as null)
	var/DBQuery/query = dbcon.NewQuery({"
		SELECT id as message_id, type AS message_type, text AS message, timestamp, ingameage, adminckey AS author, round_id FROM erro_messages WHERE targetckey = '[sql_ckey]' AND deleted != 1
		UNION ALL
		SELECT NULL as message_id, bantype AS message_type, CONCAT_WS(' | Job: ', reason, NULLIF(job,'')) AS message, bantime AS timestamp, ingameage, a_ckey AS author, round_id FROM erro_ban WHERE ckey = '[sql_ckey]'
		ORDER by timestamp DESC
		LIMIT 50;
	"}) // todo: pager

	if(!query.Execute())
		return

	var/message_id
	var/message_type
	var/message
	var/timestamp
	var/ingameage
	var/author
	var/round_id

	var/age_temperature
	var/border_color
	var/static/list/type_hex_colors = list(
		"note" = "#00ffff",
		lowertext(BANTYPE_PERMA) = "#b00000",
		lowertext(BANTYPE_TEMP) = "#ff0000",
		lowertext(BANTYPE_JOB_PERMA) = "#ff8c00",
		lowertext(BANTYPE_JOB_TEMP) = "#ffa500",
	)

	var/buttons

	while(query.NextRow())
		message_id = query.item[1]
		message_type = lowertext(query.item[2])
		message = query.item[3]
		timestamp = query.item[4]
		ingameage = text2num(query.item[5])
		author = query.item[6]
		round_id = query.item[7] ? "#"+query.item[7] : ""

		// heat color for recent messages
		if(player_ingame_age && ingameage)
			// if diff 5000 minutes or more - green
			// if diff close to 0 - red
			age_temperature = clamp(floor(((player_ingame_age - ingameage) * 100) / 5000), 0, 100)
		else
			age_temperature = 100

		if(type_hex_colors[message_type])
			border_color = type_hex_colors[message_type]
		else
			border_color = null

		if(message_type == "note" && message_id)
			buttons = {"
				<div style='float: right'>
					<a title='Edit' href='?_src_=holder;notes_edit=[sql_ckey];index=[message_id]'>E</a> <a title='Remove' href='?_src_=holder;notes_delete=[sql_ckey];index=[message_id]'>R</a>
				</div>
			"}
		else // bans
			buttons = {"
				<div style='float: right'>
					<a title='View bans' href='?_src_=holder;dbsearchckey=[sql_ckey];index=[message_id]'>V</a>
				</div>
			"}

		// todo: move styles to own css
		html += {"
			<div style='padding: 8px; margin-top: 8px; background: #d1d1d1; border: 2px solid #444; [border_color ? "border-left: 6px solid [border_color]" : ""]'>
				[buttons]
				<span style='font-style: italic; color: #008800; font-size: 140%;'>[message]</span><br/>
				<hr>
				<b>Type:</b> [message_type]; <b>Date:</b> [timestamp] [round_id];<br/> <b>Minutes:</b> <span style='font-weight: bold; background: black; color:hsl([age_temperature], 100%, 50%);'>[ingameage]</span>; <b>By:</b> [author]
			</div>
		"}

	var/datum/browser/popup = new(usr, "[sql_ckey]_notes_history", "[ckey] notes history", 700, 700, ntheme = CSS_THEME_LIGHT)
	popup.set_content(html)
	popup.open()
