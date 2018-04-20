/client/proc/library_debug_cat()
	set category = "Debug"
	set name = "Library: Catalog"
	if(!check_rights(R_PERMISSIONS))	return

	establish_old_db_connection()
	if(!dbcon_old.IsConnected())
		to_chat(usr, "BD POTRACHENO")
		return

	var/catalog = "<HEAD><TITLE>Book Inventory Management</TITLE></HEAD><BODY>\n"
	catalog += "<table><tr><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td>ID</td></tr>"

	var/DBQuery/query = dbcon_old.NewQuery("SELECT id, author, title, category FROM library")
	query.Execute()

	while(query.NextRow())
		var/id = query.item[1]
		var/author = query.item[2]
		var/title = query.item[3]
		var/category = query.item[4]
		catalog += "<tr><td>[author]</td><td>[title]</td><td>[category]</td><td>[id]</td></tr>"
	catalog += "</table>"

	usr << browse(entity_ja(catalog), "window=admlibrarycatalog")
	onclose(usr, "admlibrarycatalog")

/client/proc/library_debug_remove()
	set category = "Debug"
	set name = "Library: Remove by id"
	if(!check_rights(R_PERMISSIONS))	return

	establish_old_db_connection()
	if(!dbcon_old.IsConnected())
		to_chat(usr, "BD POTRACHENO")
		return

	var/id = input("Book ID:") as num

	var/DBQuery/query = dbcon_old.NewQuery("SELECT author, title FROM library WHERE id='[id]'")
	if(!query.Execute())
		to_chat(usr, query.ErrorMsg())

	var/author
	var/title
	while(query.NextRow())
		author = query.item[1]
		title = query.item[2]
		break

	var/input = alert(src, "You want to remove [title], authored [author]", "Confirm", "Confirm", "Cancel")
	if(input != "Confirm")
		return

	query = dbcon_old.NewQuery("DELETE FROM library WHERE id='[id]'")
	if(!query.Execute())
		to_chat(usr, query.ErrorMsg())

/client/proc/library_debug_read()
	set category = "Debug"
	set name = "Library: Read by id"
	if(!check_rights(R_PERMISSIONS))	return

	establish_old_db_connection()
	if(!dbcon_old.IsConnected())
		to_chat(usr, "BD POTRACHENO")
		return

	var/id = input("Book ID:") as num

	var/DBQuery/query = dbcon_old.NewQuery("SELECT * FROM library WHERE id='[id]'")
	query.Execute()

	var/author
	var/title
	var/content
	while(query.NextRow())
		author = query.item[2]
		title = query.item[3]
		content = query.item[4]
		break

	var/book = "<HEAD><TITLE>[title], [author]</TITLE></HEAD><BODY>\n"
	book += content

	usr << browse(entity_ja(content), "window=content")



/datum/admins/proc/library_recycle_bin()
	set category = "Admin"
	set name = "Library recycle bin"

	establish_old_db_connection()
	if(!dbcon_old.IsConnected())
		to_chat(usr, "Database is not connected.")
		return

	var/DBQuery/query = dbcon_old.NewQuery("SELECT id, author, title, category, ckey, deletereason FROM library WHERE deletereason != 'NULL'")
	if(!query.Execute())
		return

	var/catalog = "<HEAD><TITLE>Book Inventory Management</TITLE></HEAD><BODY>\n"
	catalog += "<table><tr><td>ID</td><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td>CKEY</td><td>REASON</td></tr>"

	while(query.NextRow())
		var/id = query.item[1]
		var/author = query.item[2]
		var/title = query.item[3]
		var/category = query.item[4]
		var/ckey = query.item[5]
		var/reason = query.item[6]
		catalog += "<tr><td>[id]</td><td>[author]</td><td>[title]</td><td>[category]</td><td>[ckey]</td><td>[reason]</td><td><a href='?src=\ref[src];readbook=[id]'>Read</a></td>[(check_rights(R_PERMISSIONS,0)) ? "<td><a href='?src=\ref[src];restorebook=[id]'>Restore</a></td>" : null][(check_rights(R_PERMISSIONS,0)) ? "<td><a href='?src=\ref[src];deletebook=[id]'>Delete</a></td>" : null]</tr>"
	catalog += "</table>"


	usr << browse(entity_ja(catalog), "window=librecyclebin")
	onclose(usr, "librecyclebin")