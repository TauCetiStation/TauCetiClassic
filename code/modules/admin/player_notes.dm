/proc/notes_add(key, note, client/admin, secret = 1, note_type = PLAYER_INFO_TYPE_ADMIN)
	key = ckey(key)
	note = sanitize(note)

	if (!key || !note)
		return

	if(!(note_type in global.player_info_type_rights))
		return

	if(!check_rights(R_LOG))
		return

	for(var/flag in global.player_info_type_rights[note_type])
		if(!check_rights(flag))
			return

	if(!establish_db_connection("erro_messages"))
		return

	var/admin_key = admin ? ckey(admin.ckey) : "Adminbot"
	secret = !!secret

	var/sql = {"INSERT INTO erro_messages (type, targetckey, adminckey, text, timestamp, server_ip, server_port, round_id, secret)
	VALUES ('[note_type]', '[key]', '[admin_key]', '[sanitize_sql(note)]', Now(), INET_ATON(IF('[world.internet_address]' LIKE '', '0', '[sanitize_sql(world.internet_address)]')), '[sanitize_sql(world.port)]', '[global.round_id]', '[secret]')"}
	var/DBQuery/new_notes = dbcon.NewQuery(sql)
	new_notes.Execute()

	message_admins("[admin ? key_name_admin(admin) : "Adminbot"] has edited [key]'s notes.")
	log_admin("[admin ? key_name(admin) : "Adminbot"] has edited [key]'s notes.")
	admin_ticket_log(key, "<font color='green'>[admin ? key_name(admin) : "Adminbot"] has edited [key]'s notes: [note]</font>")
