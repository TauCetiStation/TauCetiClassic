/proc/notes_add(key, note, client/admin, secret = 1)
	key = ckey(key)
	note = sanitize(note)

	if (!key || !note)
		return

	if(!(check_rights(R_LOG) && check_rights(R_BAN)))
		return

	
	if(!establish_db_connection("erro_messages"))
		return

	var/admin_key = admin ? ckey(admin.ckey) : "Adminbot"
	secret = !!secret

	var/ingameage = 0

	var/DBQuery/player_query = dbcon.NewQuery("SELECT ingameage FROM erro_player WHERE ckey = '[key]'")
	if(!player_query.Execute())
		return
	while(player_query.NextRow())
		ingameage = text2num(player_query.item[1])

	var/sql = {"INSERT INTO erro_messages (type, targetckey, adminckey, text, timestamp, server_ip, server_port, round_id, secret, ingameage)
	VALUES ('note', '[key]', '[admin_key]', '[sanitize_sql(note)]', Now(), INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[sanitize_sql(world.internet_address)]')), '[sanitize_sql(world.port)]', '[global.round_id]', '[secret]', [ingameage])"}
	var/DBQuery/new_notes = dbcon.NewQuery(sql)
	new_notes.Execute()

	message_admins("[admin ? key_name_admin(admin) : "Adminbot"] has edited [key]'s notes.")
	log_admin("[admin ? key_name(admin) : "Adminbot"] has edited [key]'s notes.")
	admin_ticket_log(key, "<font color='green'>[admin ? key_name(admin) : "Adminbot"] has edited [key]'s notes: [note]</font>")
