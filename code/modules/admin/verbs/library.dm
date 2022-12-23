/client/proc/library_debug_remove()
	set category = "Debug"
	set name = "Library: Remove by id"
	if(!check_rights(R_DEBUG))	return

	if(!establish_db_connection("erro_library"))
		to_chat(usr, "BD POTRACHENO")
		return

	var/id = input("Book ID:") as num|null

	if(!id)
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT author, title FROM erro_library WHERE id='[id]'")
	if(!query.Execute())
		to_chat(usr, "SQL ERROR")

	var/author
	var/title
	while(query.NextRow())
		author = query.item[1]
		title = query.item[2]
		break

	var/input = tgui_alert(src, "You want to remove [title], authored [author]", "Confirm", list("Confirm", "Cancel"))
	if(input != "Confirm")
		return

	log_admin("[key_name(usr)] removed '[title]' from the library database")
	message_admins("[key_name_admin(usr)] removed '[title]' from the library database")

	query = dbcon.NewQuery("DELETE FROM erro_library WHERE id='[id]'")
	if(!query.Execute())
		to_chat(usr, "SQL ERROR")

/client/proc/library_debug_read()
	set category = "Debug"
	set name = "Library: Read by id"
	if(!check_rights(R_DEBUG))	return

	if(!establish_db_connection("erro_library"))
		to_chat(usr, "BD POTRACHENO")
		return

	var/id = input("Book ID:") as num|null

	if(!id)
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT * FROM erro_library WHERE id='[id]'")
	query.Execute()

	var/author
	var/title
	var/content
	while(query.NextRow())
		author = query.item[2]
		title = query.item[3]
		content = query.item[4]
		break

	var/datum/browser/popup = new(usr, "window=content", "[title], [author]", ntheme = CSS_THEME_LIGHT)
	popup.set_content(content)
	popup.open()

/datum/admins/proc/library_recycle_bin()
	set category = "Admin"
	set name = "Library: Recycle bin"

	if(!establish_db_connection("erro_library"))
		to_chat(usr, "Database is not connected.")
		return

	if (!istype(src,/datum/admins))
		src = usr.client.holder
	if (!istype(src,/datum/admins))
		to_chat(usr, "Error: you are not an admin!")
		return

	var/DBQuery/query = dbcon.NewQuery("SELECT id, title, author, ckey, deletereason FROM erro_library WHERE deletereason IS NOT NULL")
	if(!query.Execute())
		return

	var/catalog = ""
	catalog += "<table border=1 rules=all frame=void cellspacing=0 cellpadding=3><HR><tr><td>ID</td><td>TITLE</td><td>AUTHOR</td><td>CKEY</td><td>REASON</td><td>OPTIONS</td></tr></HR>"
	var/permitted = check_rights(R_PERMISSIONS,0)
	while(query.NextRow())
		var/id = query.item[1]
		var/title = query.item[2]
		var/author = query.item[3]
		var/ckey = query.item[4]
		var/reason = query.item[5]
		catalog += "<tr><td>[id]</td><td>[title]</td><td>[author]</td><td>[ckey]</td><td>[reason]</td><td><a href='?src=\ref[src];readbook=[id]'>Read</a>[permitted ? "<BR><a href='?src=\ref[src];restorebook=[id]'>Restore</a><BR>" : null][permitted ? "<a href='?src=\ref[src];deletebook=[id]'>Delete</a><BR>" : null]</td></tr>"
	catalog += "</table>"

	var/datum/browser/popup = new(usr, "window=librecyclebin", "Book Inventory Management", 500, 500, ntheme = CSS_THEME_LIGHT)
	popup.set_content(catalog)
	popup.open()

/proc/library_needs_rewiew()
	. = 0

	var/DBQuery/select_query = dbcon.NewQuery({"SELECT COUNT(*)
		FROM erro_library
		WHERE deletereason IS NOT NULL"})
	select_query.Execute()

	if(select_query.NextRow())
		. = text2num(select_query.item[1])
