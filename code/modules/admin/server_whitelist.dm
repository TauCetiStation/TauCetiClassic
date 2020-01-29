//see also config.serverwhitelist

//return 1, if player in server db, or 0
/proc/check_if_a_new_player(key)
	if(!establish_db_connection())
		world.log << "Ban database connection failure. Key [key] not checked"
		log_debug("Ban database connection failure. Key [key] not checked")
		return 1

	key = ckey(key)
	if(!key)
		return 0

	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM erro_player WHERE ckey = '[key]'")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR, WHITELIST. Error : \[[err]\]\n")
		return 0

	if(query.RowCount())
		return 1

	return 0

/client/proc/gsw_add()
	set category = "Server"
	set name = "Server whitelist"
	if(!check_rights(R_PERMISSIONS))	return

	if(!config.serverwhitelist)
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		to_chat(usr, "<span class='warning'>Failed to establish database connection</span>")
		return

	var/ckey = ckey(copytext(input(usr, "", "Player ckey") as text, 1, MAX_MESSAGE_LEN))

	if(check_if_a_new_player(ckey))
		to_chat(src, "<span class='warning'>Player already in whitelist</span>")
		return

	var/DBQuery/query_insert = dbcon.NewQuery("INSERT INTO erro_player (ckey, firstseen) VALUES ('[ckey], Now()')")
	if(!query_insert.Execute())
		var/err = query_insert.ErrorMsg()
		log_game("SQL ERROR, WHITELIST. Error : \[[err]\]\n")
		return

	message_admins("[key_name_admin(src)] add [ckey] to server whitelist")
	log_admin("[key_name(src)] add [ckey] to server whitelist")
