/client/proc/regisration_panic_bunker()
	set category = "Server"
	set name = "Toggle Registration Panic Bunker"

	if (config.registration_panic_bunker_age)
		config.registration_panic_bunker_age = null
		fdel("data/regisration_panic_bunker.sav")
		log_admin("[key_name(src)] disable regisration panic bunker")
		message_admins("[key_name_admin(src)] disable regisration panic bunker")
		return

	var/year = sanitize_integer(input("Registration year", "Minimal registration year (min: 2000, max: [game_year])", game_year) as num, 2000, game_year, game_year)
	var/month = sanitize_integer(input("Registration month", "Minimal registration month (min: 1, max: 12)", 1) as num, 1, 12, 1)
	var/day = sanitize_integer(input("Registration day", "Minimal registration day (min: 1, max: 31)", 1) as num, 1, 31, 1)
	var/active_hours = input("Hours from current moment to keep panic bunker active (-1 to enable for current round only)", "Active hours (min: -1 or 1, max: 24)", -1) as num
	var/panic_age = "[year]-[month]-[day]"

	if (tgui_alert(usr, "Apply registration bunker, age:[panic_age] active hours: [active_hours]", "Are you sure about that?", list("Yes!", "No")) != "Yes!")
		return

	config.registration_panic_bunker_age = panic_age

	if (active_hours != -1)
		var/savefile/S = new /savefile("data/regisration_panic_bunker.sav")
		S["enabled_by"] = ckey
		S["active_until"] = world.realtime + active_hours * 36000
		S["panic_age"] = panic_age

	var/msg = "enables registration panic bunker for [active_hours != -1 ? "[active_hours] hours" : "current round"] with value: [panic_age]"
	log_admin("[key_name(src)] [msg]")
	message_admins("[key_name_admin(src)] [msg]")
	world.send2bridge(
		type = list(BRIDGE_ADMINALERT, BRIDGE_ADMINIMPORTANT),
		attachment_title = "Panic Bunker",
		attachment_msg = "**[key_name(src)]** [msg]",
		attachment_color = BRIDGE_COLOR_ADMINALERT,
	)

/client/proc/is_blocked_by_regisration_panic_bunker()
	var/regex/bunker_date_regex = regex("(\\d+)-(\\d+)-(\\d+)")

	var/list/byond_date = get_byond_registration()

	if (!length(byond_date))
		return

	bunker_date_regex.Find(config.registration_panic_bunker_age)

	var/user_year = byond_date[1]
	var/user_month = byond_date[2]
	var/user_day = byond_date[3]

	var/bunker_year = text2num(bunker_date_regex.group[1])
	var/bunker_month = text2num(bunker_date_regex.group[2])
	var/bunker_day = text2num(bunker_date_regex.group[3])

	var/is_invalid_year = user_year > bunker_year
	var/is_invalid_month = user_year == bunker_year && user_month > bunker_month
	var/is_invalid_day = user_year == bunker_year && user_month == bunker_month && user_day > bunker_day

	var/is_invalid_date = is_invalid_year || is_invalid_month || is_invalid_day
	var/is_invalid_ingame_age = isnum(player_ingame_age) && player_ingame_age < config.allowed_by_bunker_player_age

	return is_invalid_date && is_invalid_ingame_age

/proc/is_blocked_by_regisration_panic_bunker_ban_mode(key)
	if(!establish_db_connection("erro_player"))
		world.log << "Ban database connection failure. Key [key] not checked"
		log_debug("Ban database connection failure. Key [key] not checked")
		return TRUE

	key = ckey(key)

	if(!key)
		return TRUE

	var/DBQuery/query = dbcon.NewQuery("SELECT ingameage FROM erro_player WHERE ckey = '[key]'")

	if(!query.Execute()) // can't check player because some problems
		return TRUE

	if(!query.RowCount()) // no record in db, new player
		return TRUE

	if(query.NextRow())
		var/sql_player_ingame_age = text2num(query.item[1])

		if(sql_player_ingame_age < config.allowed_by_bunker_player_age) // player in db but doesn't have minutes to pass bunker
			return TRUE

	return FALSE
