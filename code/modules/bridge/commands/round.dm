/datum/bridge_command/round
	name = "round"
	desc = "Show round information by ID"
	format = "@Bot round %roundid%"
	example = "@Bot round 123"
	position = 90

/datum/bridge_command/round/execute(list/params)
	var/target_round = text2num(params["bridge_arg_1"])

	if(!target_round || !establish_db_connection("erro_round"))
		return

	var/DBQuery/select_query = dbcon.NewQuery({"SELECT DATE_FORMAT(start_datetime, '%d.%m.%Y %H:%i:%s'), DATE_FORMAT(end_datetime, '%d.%m.%Y %H:%i:%s'), server_port, game_mode, game_mode_result, end_state, map_name, DATE_FORMAT(initialize_datetime, '%Y/%m/%d')
		FROM erro_round
		WHERE id = '[target_round]'
		ORDER BY initialize_datetime"})
	select_query.Execute()

	if(!select_query.NextRow())
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM),
			attachment_title = "Bridge: Round",
			attachment_msg = "<@![params["bridge_from_uid"]]> wrong round ID",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	var/start = select_query.item[1]
	var/end = select_query.item[2]
	var/port = select_query.item[3]
	var/mode = select_query.item[4]
	var/result = select_query.item[5]
	var/end_state = select_query.item[6]
	var/map = select_query.item[7]

	var/init_date = select_query.item[8]

	var/message = {"**Time**: [start] (start) - [end] (end)
**Server**: [port]
**Map**: [map]
**Mode**: [mode]
**Result**: [result]
**End state**: [end_state]

**Stat link**: <https://stat.taucetistation.org/html/[init_date]/round-[target_round]/>"}

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: Round",
		attachment_msg = "<@![params["bridge_from_uid"]]> information about #[target_round]\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)

/datum/bridge_command/roundfinder
	name = "roundfinder"
	desc = "Show rounds by date"
	format = "@Bot round %day% %mounth% %year%"
	example = "@Bot round 30 12 2020"
	position = 91

/datum/bridge_command/roundfinder/execute(list/params)
	var/day = text2num(params["bridge_arg_1"])
	var/mounth = text2num(params["bridge_arg_2"])
	var/year = text2num(params["bridge_arg_3"])

	if(!day || !mounth || !year || !establish_db_connection("erro_round"))
		return

	var/day_str = "[year]-[mounth]-[day]"

	var/DBQuery/select_query = dbcon.NewQuery({"SELECT id, DATE_FORMAT(start_datetime, '%H:%i:%s'), DATE_FORMAT(end_datetime, '%H:%i:%s'), server_port, game_mode, game_mode_result, end_state, map_name
		FROM erro_round
		WHERE DATE(initialize_datetime) = '[day_str]'
		ORDER BY initialize_datetime"})
	select_query.Execute()

	var/message = ""
	while(select_query.NextRow())
		var/id = select_query.item[1]
		var/start = select_query.item[2]
		var/end = select_query.item[3]
		var/port = select_query.item[4]
		//var/mode = select_query.item[5]
		//var/result = select_query.item[6]
		//var/end_state = select_query.item[7]
		//var/map = select_query.item[8]

		message += "**ID**: [id]; **Time**: [start] - [end]; **Port**: [port];\n"

	if(!length(message))
		world.send2bridge(
			type = list(BRIDGE_ADMINCOM),
			attachment_title = "Bridge: Round Finder",
			attachment_msg = "<@![params["bridge_from_uid"]]> wrong date or no rounds during this date",
			attachment_color = BRIDGE_COLOR_BRIDGE,
		)
		return

	world.send2bridge(
		type = list(BRIDGE_ADMINCOM),
		attachment_title = "Bridge: Round Finder",
		attachment_msg = "<@![params["bridge_from_uid"]]> rounds during [day].[mounth].[year]:\n-----\n[message]",
		attachment_color = BRIDGE_COLOR_BRIDGE,
	)
