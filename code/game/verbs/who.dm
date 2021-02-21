
/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Current Players:</b>\n"

	var/list/Lines = list()

	if(holder && (R_ADMIN & holder.rights))
		for(var/client/C in clients)
			if(C.ckey in stealth_keys) continue
			var/entry = "&emsp;[C.key]"
			if(C.holder && C.holder.fakekey)
				entry += " <i>(as [C.holder.fakekey])</i>"
			entry += " - Playing as [C.mob.real_name]"
			switch(C.mob.stat)
				if(UNCONSCIOUS)
					entry += " - <font color='darkgray'><b>Unconscious</b></font>"
				if(DEAD)
					if(isobserver(C.mob))
						var/mob/dead/observer/O = C.mob
						if(O.started_as_observer)
							entry += " - <font color='gray'>Observing</font>"
						else
							entry += " - <font color='black'><b>DEAD</b></font>"
					else
						entry += " - <font color='black'><b>DEAD</b></font>"

			var/age
			if(isnum(C.player_age))
				age = C.player_age
			else
				age = 0

			if(age <= 1)
				age = "<font color='red'><b>[age]</b></font>"
			else if(age < 10)
				age = "<font color='#ff8c00'><b>[age]</b></font>"

			entry += " - [age]"

			var/ingame_age
			if(isnum(C.player_ingame_age))
				ingame_age = C.player_ingame_age
			else
				ingame_age = 0

			if(ingame_age <= 60)
				ingame_age = "<font color='red'><b>[ingame_age]</b></font>"
			else if(ingame_age < 1440)
				ingame_age = "<font color='#ff8c00'><b>[ingame_age]</b></font>"

			entry += " - [ingame_age]"

			if(is_special_character(C.mob))
				entry += " - <b><font color='red'>Antagonist</font></b>"
			if(C.is_afk())
				entry += " (AFK - [C.inactivity2text()])"
			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
			Lines += entry
	else
		for(var/client/C in clients)
			if(C.ckey in stealth_keys) continue
			if(C.holder && C.holder.fakekey)
				Lines += C.holder.fakekey
			else
				Lines += C.key

	for(var/line in sortList(Lines))
		msg += "[line]\n"

	msg += "<b>Total Players: [length(Lines)]</b>"
	to_chat(src, msg)

#define SW_ADMINS     1
#define SW_MENTORS    2
#define SW_XENOVISORS 3
#define SW_DEVELOPERS 4
#define SW_NAME    1
#define SW_WHOTEXT 2
#define SW_COUNT   3
/client/verb/staffwho()
	set category = "Admin"
	set name = "Staffwho"

	var/list/staffwho[4][3]
	staffwho[SW_ADMINS][SW_NAME] = "Admins"
	staffwho[SW_MENTORS][SW_NAME] = "Mentors"
	staffwho[SW_XENOVISORS][SW_NAME] = "Xenovisors"
	staffwho[SW_DEVELOPERS][SW_NAME] = "Developers"

	for(var/client/C in admins|mentors)
		if(C.ckey in stealth_keys)
			continue
		if(C.holder?.fakekey && !(R_ADMIN & holder.rights))
			continue
		var/extra = ""
		if(holder)
			if(C.holder?.fakekey)
				extra += " <i>(as [C.holder.fakekey])</i>"
			if(isobserver(C.mob))
				extra += " - Observing"
			else if(isnewplayer(C.mob))
				extra += " - Lobby"
			else
				extra += " - Playing"
			if(C.is_afk())
				extra += " (AFK - [C.inactivity2text()])"
		if(C.ckey in mentor_ckeys)
			staffwho[SW_MENTORS][SW_WHOTEXT] = "&emsp;[C] is a <b>Mentor</b>[extra]<br>"
			staffwho[SW_MENTORS][SW_COUNT]++
		if(C.holder)
			if(R_BAN & C.holder.rights)
				staffwho[SW_ADMINS][SW_WHOTEXT] = "&emsp;[C] is a <b>[C.holder.rank]</b>[extra]<br>"
				staffwho[SW_ADMINS][SW_COUNT]++
			else if(R_DEBUG & C.holder.rights)
				staffwho[SW_DEVELOPERS][SW_WHOTEXT] = "&emsp;[C] is a <b>[C.holder.rank]</b>[extra]<br>"
				staffwho[SW_DEVELOPERS][SW_COUNT]++
			else if(R_WHITELIST & C.holder.rights)
				staffwho[SW_XENOVISORS][SW_WHOTEXT] = "&emsp;[C] is a <b>[C.holder.rank]</b>[extra]<br>"
				staffwho[SW_XENOVISORS][SW_COUNT]++
			else
				staffwho[SW_ADMINS][SW_WHOTEXT] = "&emsp;[C] is a <b>[C.holder.rank]</b>[extra]<br>"
				staffwho[SW_ADMINS][SW_COUNT]++


	for(var/staff in staffwho)
		if(!staff[SW_COUNT])
			to_chat(src, "<b>No [staff[SW_NAME]] online</b><br>")
			continue
		to_chat(src, "<b>Current [staff[SW_NAME]] ([staff[SW_COUNT]]):</b><br>[staff[SW_WHOTEXT]]")
	return // https://secure.byond.com/forum/post/2072419

#undef SW_ADMINS
#undef SW_MENTORS
#undef SW_XENOVISORS
#undef SW_DEVELOPERS
#undef SW_NAME
#undef SW_WHOTEXT
#undef SW_COUNT
