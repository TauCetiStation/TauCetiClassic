#define CB_CLEAN 0
#define CB_WET 1
#define CB_CONTENT 2
#define CB_HONK 3

/obj/structure/chalkboard
	name = "chalkboard"
	desc = "Don't eat the chalk. Just write something on it."
	icon = 'tauceti/items/chalkboard/chalkboard.dmi'
	icon_state = "board_clean"
	flags = FPRINT
	density = 0
	anchored = 1
	var/state = CB_CLEAN
	var/content

/obj/structure/chalkboard/verb/honk(user as mob)
	set src in oview(1)
	set name = "HONK"
	set desc = "Make HONK"
	set category = "Object"
//	set src in usr

	if(!ishuman(user))
		user << "\red You want, but you don't. You try, but you can't."
		return

	if(content)
		usr << "\blue The board is full! Clean it to write again."
		return

	add_fingerprint(user)
	state = CB_HONK
	update()

/obj/structure/chalkboard/verb/wrtite(user as mob)
	set src in oview(1)
	set name = "Write"
	set desc = "Don't stare, just write."
	set category = "Object"
//	set src in usr

	if(!ishuman(user))
		user << "\red You want, but you don't. You try, but you can't."
		return

	if(content)
		user << "\blue The board is full! Clean it to write again."
		return

	//part wrom paper/write
	var/t =  input("What do you want to write here? 20 lines or 2000 symbols max.", "Write", null, null) as message

	if(length(t) > 2048)
		user << "\blue You can't post it all on board!"
		return

	t = checkhtml(t)

	var/index = findtext(t, "____255_")
	while(index)
		t = copytext(t, 1, index) + "&#255;" + copytext(t, index+8)
		index = findtext(t, "____255_")

	// check for exploits
	for(var/bad in paper_blacklist)
		if(findtext(t,bad))
			user << "\blue You think to yourself, \"Hm.. this is only chalkboard...\""
			log_admin("Chalkboard: [user] tried to use forbidden word in [src]: [bad].")
			message_admins("Chalkboard: [user] tried to use forbidden word in [src]: [bad].")
			return

	t = replacetext(t, "\n", "<BR>")
	t = parsepencode(t) // Encode everything from pencode to html

	if(!t)
		return
	if(count_occurrences(t, "<BR>") > 20)
		usr << "\blue You can't post it all on board!"
		return

	content = t
	add_fingerprint(user)
	state = CB_CONTENT
	update()



/obj/structure/chalkboard/verb/cleanup(user as mob)
	set src in oview(1)
	set name = "Cleanup"
	set desc = "Make board clean"
	set category = "Object"
//	set src in usr

	if(!ishuman(user))
		user << "\red You want, but you don't. You try, but you can't."
		return

	if(state != CB_WET)
		state = CB_WET

	else
		state = CB_CLEAN

	add_fingerprint(user)
	update()

/obj/structure/chalkboard/proc/update()

	switch (state)
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

/obj/structure/chalkboard/proc/parsepencode(var/t)

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

#undef CB_CLEAN
#undef CB_WET
#undef CB_CONTENT
#undef CB_HONK