/* Library Items
 *
 * Contains:
 *		Bookcase
 *		Book
 *		Barcode Scanner
 */


/*
 * Bookcase
 */

/obj/structure/bookcase
	name = "bookcase"
	icon = 'icons/obj/objects.dmi'
	icon_state = "book-0"
	anchored = 1
	density = 1
	opacity = 1

/obj/structure/bookcase/atom_init()
	. = ..()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/weapon/book))
			I.loc = src
	update_icon()

/obj/structure/bookcase/attackby(obj/O, mob/user)
	if(istype(O, /obj/item/weapon/book))
		user.drop_item()
		O.loc = src
		update_icon()
	else if(istype(O, /obj/item/weapon/pen))
		var/newname = sanitize_safe(input(usr, "What would you like to title this bookshelf?"))
		if(!newname)
			return
		else
			name = ("bookcase ([sanitize(newname)])")
	else
		..()

/obj/structure/bookcase/attack_hand(mob/user)
	if(contents.len)
		var/obj/item/weapon/book/choice = input("Which book would you like to remove from the shelf?") in contents
		if(choice)
			if(usr.incapacitated() || !in_range(loc, usr))
				return
			if(ishuman(user))
				if(!user.get_active_hand())
					user.put_in_hands(choice)
			else
				choice.loc = get_turf(src)
			update_icon()

/obj/structure/bookcase/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/obj/item/weapon/book/b in contents)
				qdel(b)
			qdel(src)
			return
		if(2.0)
			for(var/obj/item/weapon/book/b in contents)
				if (prob(50)) b.loc = (get_turf(src))
				else del(b)
			qdel(src)
			return
		if(3.0)
			if (prob(50))
				for(var/obj/item/weapon/book/b in contents)
					b.loc = (get_turf(src))
				qdel(src)
			return
		else
	return

/obj/structure/bookcase/update_icon()
	if(contents.len < 5)
		icon_state = "book-[contents.len]"
	else
		icon_state = "book-5"


/obj/structure/bookcase/manuals/medical
	name = "Medical Manuals bookcase"

/obj/structure/bookcase/manuals/medical/atom_init()
	. = ..()
	new /obj/item/weapon/book/manual/wiki/medical_surgery(src)
	new /obj/item/weapon/book/manual/wiki/medical_genetics(src)
	new /obj/item/weapon/book/manual/wiki/medical_virology(src)
	new /obj/item/weapon/book/manual/wiki/medical_chemistry(src)
	for (var/i in 1 to 3)
		new /obj/item/weapon/book/manual/wiki/medical_guide_to_medicine(src)
	update_icon()


/obj/structure/bookcase/manuals/engineering
	name = "Engineering Manuals bookcase"

/obj/structure/bookcase/manuals/engineering/atom_init()
	. = ..()
	new /obj/item/weapon/book/manual/wiki/basic_engineering(src)
	new /obj/item/weapon/book/manual/wiki/construction(src)
	new /obj/item/weapon/book/manual/wiki/atmospipes(src)
	new /obj/item/weapon/book/manual/wiki/supermatter_engine(src)
	new /obj/item/weapon/book/manual/wiki/engineering_hacking(src)
	new /obj/item/weapon/book/manual/wiki/engineering_singularity(src)
	new /obj/item/weapon/book/manual/wiki/engineering_solars(src)
	new /obj/item/weapon/book/manual/wiki/engineering_tesla(src)
	update_icon()


/obj/structure/bookcase/manuals/research_and_development
	name = "R&D Manuals bookcase"

/obj/structure/bookcase/manuals/research_and_development/atom_init()
	. = ..()
	new /obj/item/weapon/book/manual/wiki/research_and_development(src)
	new /obj/item/weapon/book/manual/wiki/guide_to_robotics(src)
	new /obj/item/weapon/book/manual/wiki/guide_to_toxins(src)
	new /obj/item/weapon/book/manual/wiki/guide_to_xenobiology(src)
	new /obj/item/weapon/book/manual/wiki/guide_to_exosuits(src)
	new /obj/item/weapon/book/manual/wiki/guide_to_telescience(src)
	update_icon()

/obj/structure/bookcase/manuals/security
	name = "Law and Order bookcase"

/obj/structure/bookcase/manuals/security/atom_init()
	. = ..()
	for (var/i in 1 to 3)
		new /obj/item/weapon/book/manual/wiki/security_space_law(src)
	for (var/i in 1 to 2)
		new /obj/item/weapon/book/manual/wiki/sop(src)
	new /obj/item/weapon/book/manual/detective(src)
	update_icon()

/*
 * Book
 */
/obj/item/weapon/book
	name = "book"
	icon = 'icons/obj/library.dmi'
	force = 1.0
	hitsound = list('sound/items/misc/book-slap.ogg')
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL		 //upped to three because books are, y'know, pretty big. (and you could hide them inside eachother recursively forever)
	attack_verb = list("bashed", "whacked", "educated")
	var/dat			 // Actual page content
	var/due_date = 0 // Game time in 1/10th seconds
	var/author		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	var/unique = 0   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified
	var/title		 // The real name of the book.
	var/carved = 0	 // Has the book been hollowed out for use as a secret storage item?
	var/window_size
	var/obj/item/store	//What's in the book?

/obj/item/weapon/book/attack_self(mob/user)
	if(carved)
		if(store)
			to_chat(user, "<span class='notice'>[store] falls out of [title]!</span>")
			store.loc = get_turf(src.loc)
			store = null
			return
		else
			to_chat(user, "<span class='notice'>The pages of [title] have been cut out!</span>")
			return
	if(src.dat)
		user << browse(entity_ja("<TT><I>Penned by [author].</I></TT> <BR>[dat]"), "window=book[window_size != null ? ";size=[window_size]" : ""]")
		user.visible_message("[user] opens a book titled \"[src.title]\" and begins reading intently.")
		onclose(user, "book")
	else
		to_chat(user, "This book is completely blank!")

/obj/item/weapon/book/attackby(obj/item/I, mob/user, params)
	if(carved)
		if(!store)
			if(I.w_class < ITEM_SIZE_NORMAL)
				user.drop_from_inventory(I, src)
				store = I
				to_chat(user, "<span class='notice'>You put [I] in [title].</span>")
				return
			else
				to_chat(user, "<span class='notice'>[I] won't fit in [title].</span>")
				return
		else
			to_chat(user, "<span class='notice'>There's already something in [title]!</span>")
			return

	if(istype(I, /obj/item/weapon/pen))
		if(unique)
			to_chat(user, "These pages don't seem to take the ink well. Looks like you can't modify it.")
			return
		var/choice = input("What would you like to change?") in list("Title", "Contents", "Author", "Cancel")
		switch(choice)
			if("Title")
				var/newtitle = sanitize_safe(input(usr, "Write a new title:"), MAX_NAME_LEN)
				if(!newtitle)
					to_chat(usr, "The title is invalid.")
					return
				else
					src.name = newtitle
					src.title = newtitle
			if("Contents")
				var/content = sanitize(input(usr, "Write your book's contents (HTML NOT allowed):") as message|null, MAX_BOOK_MESSAGE_LEN)
				if(!content)
					to_chat(usr, "The content is invalid.")
					return
				else
					src.dat += content//infiniti books?
			if("Author")
				var/newauthor = sanitize(input(usr, "Write the author's name:"), MAX_NAME_LEN)
				if(!newauthor)
					to_chat(usr, "The name is invalid.")
					return
				else
					src.author = newauthor
			else
				return

	else if(istype(I, /obj/item/weapon/barcodescanner))
		var/obj/item/weapon/barcodescanner/scanner = I
		if(!scanner.computer)
			to_chat(user, "[I]'s screen flashes: 'No associated computer found!'")
		else
			switch(scanner.mode)
				if(0)
					scanner.book = src
					to_chat(user, "[I]'s screen flashes: 'Book stored in buffer.'")
				if(1)
					scanner.book = src
					scanner.computer.buffer_book = src.name
					to_chat(user, "[I]'s screen flashes: 'Book stored in buffer. Book title stored in associated computer buffer.'")
				if(2)
					scanner.book = src
					for(var/datum/borrowbook/b in scanner.computer.checkouts)
						if(b.bookname == src.name)
							scanner.computer.checkouts.Remove(b)
							to_chat(user, "[I]'s screen flashes: 'Book stored in buffer. Book has been checked in.'")
							return
					to_chat(user, "[I]'s screen flashes: 'Book stored in buffer. No active check-out record found for current title.'")
				if(3)
					scanner.book = src
					for(var/obj/item/weapon/book in scanner.computer.inventory)
						if(book == src)
							to_chat(user, "[I]'s screen flashes: 'Book stored in buffer. Title already present in inventory, aborting to avoid duplicate entry.'")
							return
					scanner.computer.inventory.Add(src)
					to_chat(user, "[I]'s screen flashes: 'Book stored in buffer. Title added to general inventory.'")
	else if(istype(I, /obj/item/weapon/kitchenknife) || iswirecutter(I))
		if(carved)
			return
		if(user.is_busy(src))
			return
		to_chat(user, "<span class='notice'>You begin to carve out [title].</span>")
		if(I.use_tool(user, user, 30, volume = 50))
			to_chat(user, "<span class='notice'>You carve out the pages from [title]! You didn't want to read it anyway.</span>")
			carved = 1
			return
	else
		return ..()

/obj/item/weapon/book/attack(mob/living/carbon/M, mob/living/carbon/user, def_zone)
	if(def_zone == O_EYES)
		user.visible_message("<span class='notice'>You open up the book and show it to [M]. </span>", \
			"<span class='notice'> [user] opens up a book and shows it to [M]. </span>")
		M << browse(entity_ja("<TT><I>Penned by [author].</I></TT> <BR>[dat]"), "window=book")


/*
 * Barcode Scanner
 */
/obj/item/weapon/barcodescanner
	name = "barcode scanner"
	icon = 'icons/obj/library.dmi'
	icon_state ="scanner"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	var/obj/machinery/computer/libraryconsole/bookmanagement/computer // Associated computer - Modes 1 to 3 use this
	var/obj/item/weapon/book/book	 //  Currently scanned book
	var/mode = 0 					// 0 - Scan only, 1 - Scan and Set Buffer, 2 - Scan and Attempt to Check In, 3 - Scan and Attempt to Add to Inventory

/obj/item/weapon/barcodescanner/attack_self(mob/user)
	mode += 1
	if(mode > 3)
		mode = 0
	to_chat(user, "[src] Status Display:")
	var/modedesc
	switch(mode)
		if(0)
			modedesc = "Scan book to local buffer."
		if(1)
			modedesc = "Scan book to local buffer and set associated computer buffer to match."
		if(2)
			modedesc = "Scan book to local buffer, attempt to check in scanned book."
		if(3)
			modedesc = "Scan book to local buffer, attempt to add book to general inventory."
		else
			modedesc = "ERROR!"
	to_chat(user, " - Mode [mode] : [modedesc]")
	if(src.computer)
		to_chat(user, "<font color=green>Computer has been associated with this unit.</font>")
	else
		to_chat(user, "<font color=red>No associated computer found. Only local scans will function properly.</font>")
	to_chat(user, "\n")
