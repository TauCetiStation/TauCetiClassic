// just common methods to work with messages
// can be called from bots so does not check permissions/etc.
// you should do it yourself

/proc/notes_add(key, note, admin_key, secret = 1)
	if(!establish_db_connection("erro_messages"))
		return

	key = ckey(key)
	note = sanitize(note)
	admin_key = ckey(admin_key)

	if (!key || !note)
		return

	if(!admin_key)
		admin_key = "Adminbot"

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

	admin_ticket_log(key, "<font color='green'>[admin_key] has edited [key]'s notes: [note]</font>")

/proc/notes_delete(id, admin_key)
	if(!establish_db_connection("erro_messages"))
		return

	id = text2num(id)
	admin_key = ckey(admin_key)

	if(!id || !admin_key)
		return

	var/DBQuery/query = dbcon.NewQuery({"UPDATE erro_messages 
		SET deleted = 1, deleted_ckey = '[admin_key]'
		WHERE id = [id]"})
	query.Execute()

/proc/notes_edit(id, new_note)
	if(!establish_db_connection("erro_messages"))
		return

	id = text2num(id)
	new_note = sanitize(new_note)

	if(!id || !new_note)
		return

	var/DBQuery/query = dbcon.NewQuery({"UPDATE erro_messages 
		SET text = '[sanitize_sql(new_note)]'
		WHERE id = [id]"})
	query.Execute()
