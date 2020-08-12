/* Library Machines
 *
 * Contains:
 *		Borrowbook datum
 *		Library Public Computer
 *		Library Computer
 *		Library Scanner
 *		Book Binder
 */

#define LIBRETURNLIMIT 15 // how many entries we will display to the user per page.

/*
 * Borrowbook datum
 */
/datum/borrowbook // Datum used to keep track of who has borrowed what when and for how long.
	var/bookname
	var/mobname
	var/getdate
	var/duedate


/*
 * Library Public Computer
 */
/obj/machinery/computer/libraryconsole
	name = "visitor computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer_regular_library"
	circuit = /obj/item/weapon/circuitboard/libraryconsole

	state_broken_preset = "computer_regularb"
	state_nopower_preset = "computer_regular0"

	var/screenstate = 0
	var/title
	var/category = "Any"
	var/author
	var/page = 0

/obj/machinery/computer/libraryconsole/old // an older-looking version, looks fancy
	icon_state = "computer_old"
	state_broken_preset = "computer_oldb"
	state_nopower_preset = "computer_old0"

/obj/machinery/computer/libraryconsole/ui_interact(mob/user)
	var/dat = ""
	switch(screenstate)
		if(0)
			dat += {"<h2>Search Settings</h2><br>
			<A href='?src=\ref[src];settitle=1'>Filter by Title: [title]</A><BR>
			<A href='?src=\ref[src];setcategory=1'>Filter by Category: [category]</A><BR>
			<A href='?src=\ref[src];setauthor=1'>Filter by Author: [author]</A><BR>
			<A href='?src=\ref[src];search=1'>\[Start Search\]</A><BR>"}
		if(1)
			establish_old_db_connection()
			if(!dbcon_old.IsConnected())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font><BR>"
			else
				var/SQLquery = "SELECT author, title, category, id FROM library WHERE "
				if(category == "Any")
					SQLquery += "author LIKE '%[author]%' AND title LIKE '%[title]%' LIMIT [page], [LIBRETURNLIMIT]"
				else
					SQLquery += "author LIKE '%[author]%' AND title LIKE '%[title]%' AND category='[category]' LIMIT [page], [LIBRETURNLIMIT]"
				dat += {"<table>
				<tr><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td>SS<sup>13</sup>BN</td></tr>"}

				var/DBQuery/query = dbcon_old.NewQuery(SQLquery)
				query.Execute()

				while(query.NextRow())
					var/author = query.item[1]
					var/title = query.item[2]
					var/category = query.item[3]
					var/id = query.item[4]
					dat += "<tr><td>[author]</td><td>[title]</td><td>[category]</td><td>[id]</td></tr>"
				dat += "</table><BR>"
			dat += {"
			<A href='?src=\ref[src];back=1'>\[Go Back\]</A>
			 <A href='?src=\ref[src];pageprev=2'>\[<< Page\]</A>
			 <A href='?src=\ref[src];pageprev=1'>\[< Page\]</A>
			 <A href='?src=\ref[src];pagereset=1'>\[Reset\]</A>
			 <A href='?src=\ref[src];pagenext=1'>\[Page >\]</A>
			 <A href='?src=\ref[src];pagenext=2'>\[Page >>\]</A><BR>"}

	var/datum/browser/popup = new(user, "publiclibrary", "Library Visitor", 600, 600)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/libraryconsole/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["settitle"])
		var/newtitle = sanitize_safe(input("Enter a title to search for:") as text|null)
		if(newtitle)
			title = newtitle
		else
			title = null
		title = sanitize_sql(title)
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category to search for:") in list("Any", "Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
		if(newcategory)
			category = newcategory
		else
			category = "Any"
		category = sanitize_sql(category)
	if(href_list["setauthor"])
		var/newauthor = sanitize(input("Enter an author to search for:") as text|null)
		if(newauthor)
			author = newauthor
		else
			author = null
		author = sanitize_sql(author)
	if(href_list["search"])
		screenstate = 1

	if(href_list["back"])
		screenstate = 0

	if(href_list["pageprev"] == "1")
		page = max(0, page - LIBRETURNLIMIT)

	if(href_list["pageprev"] == "2")
		page = max(0, page - (LIBRETURNLIMIT * 5))

	if(href_list["pagereset"])
		page = 0

	if(href_list["pagenext"] == "1")
		page = min(page + LIBRETURNLIMIT, 10000)

	if(href_list["pagenext"] == "2")
		page = min(page + (LIBRETURNLIMIT * 5), 10000)

	src.updateUsrDialog()

/*
 * Library Computer
 * After 860 days, it's finally a buildable computer.
 */
/obj/machinery/computer/libraryconsole/bookmanagement
	name = "Check-In/Out Computer"
	var/arcanecheckout = 0
	screenstate = 0 // 0 - Main Menu, 1 - Inventory, 2 - Checked Out, 3 - Check Out a Book
	var/buffer_book
	var/buffer_mob
	var/upload_category = "Fiction"
	var/list/checkouts = list()
	var/list/inventory = list()
	var/checkoutperiod = 5 // In minutes
	var/obj/machinery/libraryscanner/scanner // Book scanner that will be used when uploading books to the Archive

	var/count_bible = 4
	var/next_print = 0

/obj/machinery/computer/libraryconsole/bookmanagement/old // an older-looking version, looks fancy
	icon_state = "computer_old"
	state_broken_preset = "computer_oldb"
	state_nopower_preset = "computer_old0"

/obj/machinery/computer/libraryconsole/bookmanagement/atom_init()
	. = ..()
	if(circuit)
		circuit.name = "circuit board (Book Inventory Management Console)"
		circuit.build_path = /obj/machinery/computer/libraryconsole/bookmanagement

/obj/machinery/computer/libraryconsole/bookmanagement/interact(mob/user)
	user.set_machine(src)
	var/dat = ""
	switch(screenstate)
		if(0)
			// Main Menu
			dat += {"<A href='?src=\ref[src];switchscreen=1'>1. View General Inventory</A><BR>
			<A href='?src=\ref[src];switchscreen=2'>2. View Checked Out Inventory</A><BR>
			<A href='?src=\ref[src];switchscreen=3'>3. Check out a Book</A><BR>
			<A href='?src=\ref[src];switchscreen=4'>4. Connect to External Archive</A><BR>
			<A href='?src=\ref[src];switchscreen=5'>5. Upload New Title to Archive</A><BR>
			<A href='?src=\ref[src];switchscreen=6'>6. Print a Bible</A><BR>"}
			if(src.emagged)
				dat += "<A href='?src=\ref[src];switchscreen=7'>7. Access the Forbidden Lore Vault</A><BR>"
			if(src.arcanecheckout)
				new /obj/item/weapon/book/tome/old(src.loc)
				to_chat(user, "<span class='warning'>Your sanity barely endures the seconds spent in the vault's browsing window. The only thing to remind you of this when you stop browsing is a dusty old tome sitting on the desk. You don't really remember printing it.</span>")
				user.visible_message("[user] stares at the blank screen for a few moments, his expression frozen in fear. When he finally awakens from it, he looks a lot older.", 2)
				src.arcanecheckout = 0
		if(1)
			// Inventory
			dat += "<H3>Inventory</H3><BR>"
			for(var/obj/item/weapon/book/b in inventory)
				dat += "[b.name] <A href='?src=\ref[src];delbook=\ref[b]'>(Delete)</A><BR>"
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(2)
			// Checked Out
			dat += "<h3>Checked Out Books</h3><BR>"
			for(var/datum/borrowbook/b in checkouts)
				var/timetaken = world.time - b.getdate
				//timetaken *= 10
				timetaken /= 600
				timetaken = round(timetaken)
				var/timedue = b.duedate - world.time
				//timedue *= 10
				timedue /= 600
				if(timedue <= 0)
					timedue = "<font color=red><b>(OVERDUE)</b> [timedue]</font>"
				else
					timedue = round(timedue)
				dat += {"\"[b.bookname]\", Checked out to: [b.mobname]<BR>--- Taken: [timetaken] minutes ago, Due: in [timedue] minutes<BR>
				<A href='?src=\ref[src];checkin=\ref[b]'>(Check In)</A><BR><BR>"}
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(3)
			// Check Out a Book
			dat += {"<h3>Check Out a Book</h3><BR>
			Book: [src.buffer_book]
			<A href='?src=\ref[src];editbook=1'>\[Edit\]</A><BR>
			Recipient: [src.buffer_mob]
			<A href='?src=\ref[src];editmob=1'>\[Edit\]</A><BR>
			Checkout Date : [world.time/600]<BR>
			Due Date: [(world.time + checkoutperiod)/600]<BR>
			(Checkout Period: [checkoutperiod] minutes) (<A href='?src=\ref[src];increasetime=1'>+</A>/<A href='?src=\ref[src];decreasetime=1'>-</A>)
			<A href='?src=\ref[src];checkout=1'>(Commit Entry)</A><BR>
			<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"}
		if(4)
			dat += "<h3>External Archive</h3>"
			establish_old_db_connection()
			if(!dbcon_old.IsConnected())
				dat += "<font color=red><b>ERROR</b>: Unable to contact External Archive. Please contact your system administrator for assistance.</font>"
			else
				var/DBQuery/query = dbcon_old.NewQuery("SELECT id, author, title, category, deletereason FROM library LIMIT [page], [LIBRETURNLIMIT]")
				query.Execute()

				var/first_id = null
				var/last_id = null

				while(query.NextRow())
					last_id = query.item[1]
					if(!first_id)
						first_id = last_id
					var/author = query.item[2]
					var/title = query.item[3]
					var/category = query.item[4]
					var/deletereason = query.item[5]
					dat += "<tr><td>[last_id]</td><td>[author]</td><td>[title]</td><td>[category]</td><td><A href='?src=\ref[src];targetid=[last_id]'>\[Order\]</A></td><td>[(deletereason == null) ? "<A href='?src=\ref[src];deleteid=[last_id]'>\[Send removal request\]</A>" : "<font color=red>MARKED FOR REMOVAL</font>"]</td></tr>"
				dat += "</table>"
				dat = {"<A href='?src=\ref[src];orderbyid=1'>(Order book by SS<sup>13</sup>BN)</A>([first_id] - [last_id])<BR><BR>
				<table>
				<tr><td>ID</td><td>AUTHOR</td><td>TITLE</td><td>CATEGORY</td><td></td><td></td></tr>"} + dat
			dat += {"
			<BR><A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A>
			 <A href='?src=\ref[src];pageprev=2'>\[<< Page\]</A>
			 <A href='?src=\ref[src];pageprev=1'>\[< Page\]</A>
			 <A href='?src=\ref[src];pagereset=1'>\[Reset\]</A>
			 <A href='?src=\ref[src];pagenext=1'>\[Page >\]</A>
			 <A href='?src=\ref[src];pagenext=2'>\[Page >>\]</A><BR>"}
		if(5)
			dat += "<H3>Upload a New Title</H3>"
			if(!scanner)
				for(var/obj/machinery/libraryscanner/S in range(9))
					scanner = S
					break
			if(!scanner)
				dat += "<FONT color=red>No scanner found within wireless network range.</FONT><BR>"
			else if(!scanner.cache)
				dat += "<FONT color=red>No data found in scanner memory.</FONT><BR>"
			else
				dat += {"<TT>Data marked for upload...</TT><BR>
				<TT>Title: </TT>[sanitize(scanner.cache.name)]<BR>"}
				if(!scanner.cache.author)
					scanner.cache.author = "Anonymous"
				dat += {"<TT>Author: </TT><A href='?src=\ref[src];setauthor=1'>[scanner.cache.author]</A><BR>
				<TT>Category: </TT><A href='?src=\ref[src];setcategory=1'>[upload_category]</A><BR>
				<A href='?src=\ref[src];upload=1'>\[Upload\]</A><BR>"}
			dat += "<A href='?src=\ref[src];switchscreen=0'>(Return to main menu)</A><BR>"
		if(7)
			dat += {"<h3>Accessing Forbidden Lore Vault v 1.3</h3>
			Are you absolutely sure you want to proceed? EldritchTomes Inc. takes no responsibilities for loss of sanity resulting from this action.<p>
			<A href='?src=\ref[src];arccheckout=1'>Yes.</A><BR>
			<A href='?src=\ref[src];switchscreen=0'>No.</A><BR>"}

	var/datum/browser/popup = new(user, "library", "Book Inventory Management", 600, 600)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/libraryconsole/bookmanagement/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = W
		scanner.computer = src
		to_chat(user, "[scanner]'s associated machine has been set to [src].")
		audible_message("[src] lets out a low, short blip.")
	else
		..()

/obj/machinery/computer/libraryconsole/bookmanagement/emag_act(mob/user)
	if(emagged)
		return FALSE
	emagged = 1
	return TRUE

/obj/machinery/computer/libraryconsole/bookmanagement/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["switchscreen"])
		switch(href_list["switchscreen"])
			if("0")
				screenstate = 0
			if("1")
				screenstate = 1
			if("2")
				screenstate = 2
			if("3")
				screenstate = 3
			if("4")
				screenstate = 4
			if("5")
				screenstate = 5
			if("6")
				if(count_bible > 0 && world.time > next_print)
					if(global.chaplain_religion)
						global.chaplain_religion.spawn_bible(loc)
						count_bible -= 1
						next_print = world.time + 6 SECONDS
					else
						visible_message("<b>[src]</b>'s monitor flashes,  \"Could not connect to station's religion database at this moment, please try again later.\"")

				else
					visible_message("<b>[src]</b>'s monitor flashes, \"Bible printer currently unavailable, please wait a moment.\"")

			if("7")
				screenstate = 7
	if(href_list["arccheckout"])
		if(src.emagged)
			src.arcanecheckout = 1
		src.screenstate = 0
	if(href_list["increasetime"])
		checkoutperiod += 1
	if(href_list["decreasetime"])
		checkoutperiod -= 1
		if(checkoutperiod < 1)
			checkoutperiod = 1
	if(href_list["editbook"])
		buffer_book = sanitize_safe(input("Enter the book's title:") as text|null, MAX_NAME_LEN)
	if(href_list["editmob"])
		buffer_mob = sanitize(input("Enter the recipient's name:") as text|null, MAX_NAME_LEN)
	if(href_list["checkout"])
		var/datum/borrowbook/b = new /datum/borrowbook
		b.bookname = buffer_book
		b.mobname = buffer_mob
		b.getdate = world.time
		b.duedate = world.time + (checkoutperiod * 600)
		checkouts.Add(b)
	if(href_list["checkin"])
		var/datum/borrowbook/b = locate(href_list["checkin"])
		checkouts.Remove(b)
	if(href_list["delbook"])
		var/obj/item/weapon/book/b = locate(href_list["delbook"])
		inventory.Remove(b)
	if(href_list["setauthor"])
		var/newauthor = sanitize(input("Enter the author's name: ") as text|null, MAX_NAME_LEN)
		if(newauthor)
			scanner.cache.author = newauthor
	if(href_list["setcategory"])
		var/newcategory = input("Choose a category: ") in list("Fiction", "Non-Fiction", "Adult", "Reference", "Religion")
		if(newcategory)
			upload_category = newcategory
	if(href_list["upload"])
		if(scanner)
			if(scanner.cache)
				var/choice = input("Are you certain you wish to upload this title to the Archive?") in list("Confirm", "Abort")
				if(choice == "Confirm")
					if(scanner.cache.unique)
						alert("This book has been rejected from the database. Aborting!")
					else
						establish_old_db_connection()
						if(!dbcon_old.IsConnected())
							alert("Connection to Archive has been severed. Aborting.")
						else
							/*
							var/sqltitle = dbcon.Quote(scanner.cache.name)
							var/sqlauthor = dbcon.Quote(scanner.cache.author)
							var/sqlcontent = dbcon.Quote(scanner.cache.dat)
							var/sqlcategory = dbcon.Quote(upload_category)
							*/
							var/sqltitle = sanitize_sql(scanner.cache.name)
							var/sqlauthor = sanitize_sql(scanner.cache.author)
							var/sqlcontent = sanitize_sql(scanner.cache.dat)
							var/sqlcategory = sanitize_sql(upload_category)
							var/sqlckey = sanitize_sql(usr.ckey)
							var/DBQuery/query = dbcon_old.NewQuery("INSERT INTO library (author, title, content, category, ckey) VALUES ('[sqlauthor]', '[sqltitle]', '[sqlcontent]', '[sqlcategory]', '[sqlckey]')")
							if(!query.Execute())
								to_chat(usr, query.ErrorMsg())
							else
								log_game("[key_name(usr)] has uploaded the book titled [scanner.cache.name], [length(scanner.cache.dat)] signs")
								alert("Upload Complete.")

	if(href_list["targetid"])
		var/sqlid = sanitize_sql(href_list["targetid"])
		if(!sqlid)
			return

		establish_old_db_connection()
		if(!dbcon_old.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
		if(next_print > world.time)
			visible_message("<b>[src]</b>'s monitor flashes, \"Printer unavailable. Please allow a short time before attempting to print.\"")
		else
			next_print = world.time + 6 SECONDS
			var/DBQuery/query = dbcon_old.NewQuery("SELECT * FROM library WHERE id='[sqlid]'")
			query.Execute()

			while(query.NextRow())
				var/author = query.item[2]
				var/title = query.item[3]
				var/content = query.item[4]
				var/obj/item/weapon/book/B = new(src.loc)
				B.name = "Book: [title]"
				B.title = title
				B.author = author
				B.dat = content
				B.icon_state = "book[rand(1,10)]"
				src.visible_message("[src]'s printer hums as it produces a completely bound book. How did it do that?")
				break

	if(href_list["deleteid"])
		var/sqlid = sanitize_sql(href_list["deleteid"])
		if(!sqlid)
			return

		establish_old_db_connection()
		if(!dbcon_old.IsConnected())
			alert("Connection to Archive has been severed. Aborting.")
			return

		var/DBQuery/query = dbcon_old.NewQuery("SELECT title, deletereason FROM library WHERE id='[sqlid]'")
		if(!query.Execute())
			return


		var/title
		if(query.NextRow())
			title = query.item[1]
			if(query.item[2] != null)
				return

		var/reason = sanitize_sql(sanitize(input(usr,"Reason for removal","Enter reason (max 60 characters)") as text))
		if(length(reason) > 60)
			alert("The reason is more than 60 characters long")
			return

		if(!reason)
			return

		query = dbcon_old.NewQuery("UPDATE library SET deletereason = '[reason]' WHERE id = '[sqlid]'")
		query.Execute()

		message_admins("[usr.name]/[usr.ckey] requested removal of [title] from the library database")

		alert("Delete request sent.")

	if(href_list["orderbyid"])
		var/orderid = input("Enter your order:") as num|null
		if(orderid)
			if(isnum(orderid))
				var/nhref = "src=\ref[src];targetid=[orderid]"
				spawn() src.Topic(nhref, params2list(nhref), src)
	src.updateUsrDialog()

/*
 * Library Scanner
 */
/obj/machinery/libraryscanner
	name = "scanner"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	anchored = 1
	density = 1
	var/obj/item/weapon/book/cache		// Last scanned book

/obj/machinery/libraryscanner/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/book))
		user.drop_item()
		O.loc = src

/obj/machinery/libraryscanner/ui_interact(mob/user)
	var/dat = ""
	if(cache)
		dat += "<FONT color=#005500>Data stored in memory.</FONT><BR>"
	else
		dat += "No data stored in memory.<BR>"
	dat += "<A href='?src=\ref[src];scan=1'>\[Scan\]</A>"
	if(contents.len)
		dat += "       <A href='?src=\ref[src];eject=1'>\[Remove Book\]</A><BR>"

	if(cache)
		dat += "       <A href='?src=\ref[src];clear=1'>\[Clear Memory\]</A><BR>"
	else
		dat += "<BR>"

	var/datum/browser/popup = new(user, "window=scanner", "Scanner Control Interface")
	popup.set_content(dat)
	popup.open()

/obj/machinery/libraryscanner/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["scan"])
		for(var/obj/item/weapon/book/B in contents)
			cache = B
			break
	if(href_list["clear"])
		cache = null
	if(href_list["eject"])
		for(var/obj/item/weapon/book/B in contents)
			B.loc = src.loc
	src.updateUsrDialog()

/*
 * Book binder
 */
/obj/machinery/bookbinder
	name = "Book Binder"
	icon = 'icons/obj/library.dmi'
	icon_state = "binder"
	anchored = 1
	density = 1

/obj/machinery/bookbinder/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/paper))
		user.drop_item()
		O.loc = src
		user.SetNextMove(CLICK_CD_MELEE)
		user.visible_message("[user] loads some paper into [src].", "You load some paper into [src].")
		src.visible_message("[src] begins to hum as it warms up its printing drums.")
		sleep(rand(200,400))
		src.visible_message("[src] whirs as it prints and binds a new book.")
		var/obj/item/weapon/book/b = new(src.loc)
		b.dat = O:info
		b.name = "Print Job #" + "[rand(100, 999)]"
		b.icon_state = "book[rand(1,10)]"
		qdel(O)
	else
		..()

#undef LIBRETURNLIMIT
