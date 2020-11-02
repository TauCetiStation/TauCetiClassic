/proc/notes_add(key, note, client/admin, secret = 1)
	key = ckey(key)
	note = sanitize(note)

	if (!key || !note)
		return

	if(!(check_rights(R_LOG) && check_rights(R_BAN)))
		return

	establish_db_connection()
	if(!dbcon.IsConnected())
		return

	var/admin_key = admin ? ckey(admin.ckey) : "Adminbot"
	secret = !!secret

	var/sql = {"INSERT INTO erro_messages (type, targetckey, adminckey, text, timestamp, server_ip, server_port, round_id, secret) 
	VALUES ('note', '[key]', '[admin_key]', '[sanitize_sql(note)]', Now(), INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[world.internet_address]')), '[world.port]', '[global.round_id]', '[secret]')"}
	var/DBQuery/new_notes = dbcon.NewQuery(sql)
	new_notes.Execute()

	message_admins("[admin ? key_name_admin(admin) : "Adminbot"] has edited [key]'s notes.")
	log_admin("[admin ? key_name(admin) : "Adminbot"] has edited [key]'s notes.")
	admin_ticket_log(key, "<font color='green'>[admin ? key_name(admin) : "Adminbot"] has edited [key]'s notes: [note]</font>")
