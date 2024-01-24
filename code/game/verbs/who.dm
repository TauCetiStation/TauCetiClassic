
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

#define SW_NAME       1
#define SW_WHOTEXT    2
#define SW_COUNT      3
#define SW_CSS_CLASS  4
#define SW_ALL_PARAMS 4 //update this, if add more params

#define SW_TR(CKEY, RANK, EXTRA) "<tr><td>&emsp;[CKEY]</td><td><b>[SSholiday.get_staffwho_prefix(CKEY.ckey) ? SSholiday.get_staffwho_prefix(CKEY.ckey) + " " : ""][RANK]</b></td><td>[EXTRA]</td></tr>"
#define SW_INCREMENT(GROUP, CKEY, RANK, EXTRA) staffwho[GROUP][SW_WHOTEXT] += SW_TR(CKEY, RANK, EXTRA);staffwho[GROUP][SW_COUNT]++
/client/verb/staffwho()
	set category = "Admin"
	set name = "Staffwho"

	var/list/staffwho[SW_ALL_GROUPS][SW_ALL_PARAMS]
	staffwho[SW_ADMINS][SW_NAME] = SSholiday.get_admin_name(SW_ADMINS)
	staffwho[SW_MENTORS][SW_NAME] = SSholiday.get_admin_name(SW_MENTORS)
	staffwho[SW_XENOVISORS][SW_NAME] = SSholiday.get_admin_name(SW_XENOVISORS)
	staffwho[SW_DEVELOPERS][SW_NAME] = SSholiday.get_admin_name(SW_DEVELOPERS)

	// update tgui\packages\tgui-panel\styles\goon\chat-base.scss, if change this
	staffwho[SW_ADMINS][SW_CSS_CLASS] =     "Admins"
	staffwho[SW_MENTORS][SW_CSS_CLASS] =    "Mentors"
	staffwho[SW_XENOVISORS][SW_CSS_CLASS] = "Xenovisors"
	staffwho[SW_DEVELOPERS][SW_CSS_CLASS] = "Developers"

	for(var/client/C as anything in admins|mentors)
		if(C.ckey in stealth_keys)
			continue
		if(C.holder?.fakekey && (!holder || !(R_ADMIN & holder.rights)))
			continue
		var/extra = ""
		if(holder)
			if(C.holder?.fakekey)
				extra += "<i>(as [C.holder.fakekey])</i> "
			if(isobserver(C.mob))
				extra += "Observing"
			else if(isnewplayer(C.mob))
				extra += "Lobby"
			else
				extra += "Playing"
			if(C.is_afk())
				extra += " (AFK - [C.inactivity2text()])"
		if(C.ckey in mentor_ckeys)
			SW_INCREMENT(SW_MENTORS, C, "Mentor", extra)
		if(C.holder)
			if(R_BAN & C.holder.rights)
				SW_INCREMENT(SW_ADMINS, C, C.holder.rank, extra)
			else if(R_DEBUG & C.holder.rights)
				SW_INCREMENT(SW_DEVELOPERS, C, C.holder.rank, extra)
			else if(R_WHITELIST & C.holder.rights)
				SW_INCREMENT(SW_XENOVISORS, C, C.holder.rank, extra)
			else
				SW_INCREMENT(SW_ADMINS, C, C.holder.rank, extra)

	var/msg
	for(var/staff in staffwho)
		if(!staff[SW_COUNT])
			continue
		msg += "<tr><th class='[staff[SW_CSS_CLASS]]' colspan='3'>[staff[SW_NAME]] — [staff[SW_COUNT] || 0]</td></tr>"
		msg += "[staff[SW_WHOTEXT]]"
	if(!msg)
		var/no_staff_text = SSholiday.get_no_staff_text()
		if(!no_staff_text)
			no_staff_text = "No Staff Online"
		msg = "<b>[no_staff_text]</b>"
	else
		msg = "<table class='staffwho'>[msg]</table>"
	to_chat(src, msg)

#undef SW_NAME
#undef SW_WHOTEXT
#undef SW_COUNT
#undef SW_TR
#undef SW_INCREMENT
#undef SW_ALL_PARAMS
