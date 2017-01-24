#define CB_CLEAN 0
#define CB_WET 1
#define CB_CONTENT 2
#define CB_HONK 3

/obj/structure/chalkboard
	name = "chalkboard"
	desc = "Don't eat the chalk. Just write something on it."
	icon = 'icons/obj/structures/chalkboard.dmi'
	icon_state = "board_clean"
	density = 0
	anchored = 1
	var/status = CB_CLEAN
	var/content

/obj/structure/chalkboard/verb/honk()
	set src in oview(1)
	set name = "HONK"
	set desc = "Make HONK!"
	set category = "Object"

	if (usr.stat != CONSCIOUS)
		return

	if(!ishuman(usr))
		to_chat(usr, "\red You want, but you don't. You try, but you can't.")
		return

	if(content)
		to_chat(usr, "\blue The board is full! Clean it to write again.")
		return

	add_fingerprint(usr)
	status = CB_HONK
	update()

/obj/structure/chalkboard/verb/wrtite()
	set src in oview(1)
	set name = "Write"
	set desc = "Don't stare, just write."
	set category = "Object"

	if (usr.stat != CONSCIOUS)
		return


	if(!ishuman(usr))
		to_chat(usr, "\red You want, but you don't. You try, but you can't.")
		return

	if(content)
		to_chat(usr, "\blue The board is full! Clean it to write again.")
		return

	//part wrom paper/write
	var/t =  input("What do you want to write here? 20 lines or 2000 symbols max.", "Write", null, null) as message

	if(length(t) > 2048)
		to_chat(usr, "\blue You can't post it all on board!")
		return

	//t = checkhtml(t)
	t = sanitize(t, list("\n"="\[br\]","ÿ"=LETTER_255))

	// check for exploits
	for(var/bad in paper_blacklist)
		if(findtext(t,bad))
			to_chat(usr, "\blue You think to yourself, \"Hm.. this is only chalkboard...\"")
			log_admin("Chalkboard: [usr] tried to use forbidden word in [src]: [bad].")
			message_admins("Chalkboard: [usr] tried to use forbidden word in [src]: [bad].")
			return

	//t = replacetext(t, "\n", "<BR>")
	t = parsepencode(t) // Encode everything from pencode to html

	if(!t)
		return
	if(count_occurrences(t, "<BR>") > 20)
		to_chat(usr, "\blue You can't post it all on board!")
		return

	content = t
	add_fingerprint(usr)
	status = CB_CONTENT
	update()



/obj/structure/chalkboard/verb/cleanup()
	set src in oview(1)
	set name = "Cleanup"
	set desc = "Make board clean"
	set category = "Object"
//	set src in usr

	if (usr.stat != CONSCIOUS)
		return

	if(!ishuman(usr))
		to_chat(usr, "\red You want, but you don't. You try, but you can't.")
		return

	if(status != CB_WET)
		status = CB_WET

	else
		status = CB_CLEAN

	add_fingerprint(usr)
	update()

/obj/structure/chalkboard/proc/update()

	switch (status)
		if(CB_CLEAN)
			desc = "Don't eat the chalk. Just write something on it."
			icon_state = "board_clean"
			content = null

		if(CB_WET)
			desc = "Dirty chalkboard."
			icon_state = "board_wet"
			content = null

		if(CB_CONTENT)
			desc = "Something is written out there, you start reading..."
			desc += "<HR>"
			desc +=	content
			desc += "<HR>"
			icon_state = "board_text[rand(1, 5)]"

		if(CB_HONK)
			desc = "Oh! Something offensive is written on a chalkboard!"
			icon_state = "board_honk[rand(1, 5)]"
			content = "HONK"

/obj/structure/chalkboard/proc/parsepencode(t)

	t = replacetext(t, "\[center\]", "<center>")
	t = replacetext(t, "\[/center\]", "</center>")
	t = replacetext(t, "\[br\]", "<BR>")
	t = replacetext(t, "\[b\]", "<B>")
	t = replacetext(t, "\[/b\]", "</B>")
	t = replacetext(t, "\[i\]", "<I>")
	t = replacetext(t, "\[/i\]", "</I>")
	t = replacetext(t, "\[u\]", "<U>")
	t = replacetext(t, "\[/u\]", "</U>")
	t = replacetext(t, "\[large\]", "<font size=\"4\">")
	t = replacetext(t, "\[/large\]", "</font>")
	t = replacetext(t, "\[*\]", "<li>")
	t = replacetext(t, "\[small\]", "<font size = \"1\">")
	t = replacetext(t, "\[/small\]", "</font>")
	t = replacetext(t, "\[list\]", "<ul>")
	t = replacetext(t, "\[/list\]", "</ul>")

	return t

/obj/structure/chalkboard/proc/count_occurrences(string, substring)
	var/count = 0
	var/found = 0
	var/length = length(substring)

	found = findtext(string, substring)

	while(found)
		count++
		found += length
		found = findtext(string, substring, found)

	return count

#undef CB_CLEAN
#undef CB_WET
#undef CB_CONTENT
#undef CB_HONK
