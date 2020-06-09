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

	if (usr.incapacitated())
		return

	if(!ishuman(usr))
		to_chat(usr, "<span class='warning'>You want, but you don't. You try, but you can't.</span>")
		return

	if(content)
		to_chat(usr, "<span class='notice'>The board is full! Clean it to write again.</span>")
		return

	add_fingerprint(usr)
	status = CB_HONK
	update()

/obj/structure/chalkboard/verb/wrtite()
	set src in oview(1)
	set name = "Write"
	set desc = "Don't stare, just write."
	set category = "Object"

	if (usr.incapacitated())
		return


	if(!ishuman(usr))
		to_chat(usr, "<span class='warning'>You want, but you don't. You try, but you can't.</span>")
		return

	if(content)
		to_chat(usr, "<span class='notice'>The board is full! Clean it to write again.</span>")
		return

	//part wrom paper/write
	var/t =  input("What do you want to write here? 20 lines or 2000 symbols max.", "Write", null, null) as message

	if(length(t) > 2048)
		to_chat(usr, "<span class='notice'>You can't post it all on board!</span>")
		return

	t = sanitize(replacetext(t, "\n", "\[br\]"))

	// check for exploits
	for(var/bad in paper_blacklist)
		if(findtext(t,bad))
			to_chat(usr, "<span class='notice'>You think to yourself, \"Hm.. this is only chalkboard...\"</span>")
			log_admin("Chalkboard: [usr] tried to use forbidden word in [src]: [bad].")
			message_admins("Chalkboard: [usr] tried to use forbidden word in [src]: [bad].")
			return

	//t = replacetext(t, "\n", "<BR>")
	t = parsebbcode(t) // Encode everything from pencode to html

	if(!t)
		return
	if(count_occurrences(t, "<BR>") > 20)
		to_chat(usr, "<span class='notice'>You can't post it all on board!</span>")
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

	if (usr.incapacitated())
		return

	if(!ishuman(usr))
		to_chat(usr, "<span class='warning'>You want, but you don't. You try, but you can't.</span>")
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
			desc +=	"<span class='emojify'>[content]</span>"
			desc += "<HR>"
			icon_state = "board_text[rand(1, 5)]"

		if(CB_HONK)
			desc = "Oh! Something offensive is written on a chalkboard!"
			icon_state = "board_honk[rand(1, 5)]"
			content = "HONK"

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
