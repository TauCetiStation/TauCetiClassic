//вернет 1, если key в вайтлисте, иначе(или в случае ошибки) 0
proc/global_whitelist_check(var/key)
	if(!establish_db_connection())
		world.log << "Ban database connection failure. Key [key] not checked"
		diary << "Ban database connection failure. Key [key] not checked"
		return 0

	key = ckey(key)
	if(!key)
		return 0

	var/DBQuery/query = dbcon.NewQuery("SELECT ckey FROM global_whitelist WHERE ckey = '[key]'")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR, WHITELIST. Error : \[[err]\]\n")
		return 0

	if(query.RowCount())
		return 1

	return 0

client/verb/global_whitelist_info()
	set name = "Check ckey"
	set category = "Whitelist"

	var/key = ckey(input("Enter ckey:") as text)

	if(!key)
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT inviter FROM global_whitelist WHERE ckey = '[key]'")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR, WHITELIST. Error : \[[err]\]\n")
		return

	if(!query.RowCount())
		usr << "\red [key] isn't in the whitelist"
		return

	var/inviter
	while(query.NextRow())
		inviter = query.item[1]

	var/output = "<HEAD><TITLE>Info</TITLE></HEAD><BODY>\n"
	output += "<b>Ckey:</b> [key]<br>"
	output += "<b>Was invited:</b> [inviter]<br>"
	output += "<b>Invited:</b><br>"

	var/DBQuery/stat_query = dbcon.NewQuery("SELECT ckey FROM global_whitelist WHERE inviter = '[key]'")
	if(!stat_query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR, WHITELIST. Error : \[[err]\]\n")
		return

	var/first = 1	//ради отсутствия лишних запятых
	while(stat_query.NextRow())
		if(!first)
			output += ", "

		first = 0
		output += stat_query.item[1]

	output += "</table>"

	usr << browse(output, "window=globalwhitelistinfo")

client/verb/global_whitelist_invite()
	set name = "Invite"
	set category = "Whitelist"

	var/key = ckey(input("Enter ckey:") as text)
	var/inviter = ckey(usr.ckey)

	if(!key || !inviter) return

	establish_db_connection()
	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return

	if(global_whitelist_check(key))
		usr << "\red [key] is already in the whitelist"
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT rank, invites FROM global_whitelist WHERE ckey = '[inviter]'")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR, WHITELIST. Error : \[[err]\]\n")
		return

	if(!query.RowCount()) return

	var/usr_rank
	var/usr_invites
	while(query.NextRow())
		usr_rank = text2num(query.item[1])
		usr_invites = text2num(query.item[2])

	if(!usr_invites)
		usr << "\red For now you can't invite more players."
		return

	var/inv_rank
	var/inv_invites

	if(usr_rank == 0)
		inv_rank = input("Select rank:", , 1) in list(1,2,3,4,5)
	else
		inv_rank = usr_rank - 1

	switch(inv_rank)
		if(1) inv_invites = 4
		if(2) inv_invites = 3
		if(3) inv_invites = 2
		if(4) inv_invites = 1
		else inv_invites = 0

	var/DBQuery/insert_query = dbcon.NewQuery("INSERT IGNORE INTO global_whitelist (ckey, inviter, rank, invites) VALUES ('[key]', '[inviter]', '[inv_rank]', '[inv_invites]')")
	if(!insert_query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR, WHITELIST. Error : \[[err]\]\n")
		return

	usr_invites -= 1

	var/DBQuery/update_query = dbcon.NewQuery("UPDATE global_whitelist SET invites = '[usr_invites]' WHERE ckey = '[inviter]'")
	if(!update_query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR, WHITELIST. Error : \[[err]\]\n")
		return

	world << "<font size='3' color='purple'>OOC-Info: <b>[key]</b> was invited by <b>[inviter]</b></font>"

client/verb/global_whitelist_status()
	set name = "Status"
	set category = "Whitelist"

	if(!dbcon.IsConnected())
		usr << "\red Failed to establish database connection"
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT invites FROM global_whitelist WHERE ckey = '[ckey(usr.ckey)]'")
	if(!query.Execute())
		var/err = query.ErrorMsg()
		log_game("SQL ERROR, WHITELIST. Error : \[[err]\]\n")
		return

	var/invites
	while(query.NextRow())
		invites = query.item[1]

	alert("You have <b>[invites]</b> invitations")