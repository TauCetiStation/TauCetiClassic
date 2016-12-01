
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

/client/verb/staffwho()
	set category = "Admin"
	set name = "Staffwho"

	var/msg = ""
	var/mentmsg = ""
	var/num_admins_online = 0
	var/num_mentors_online = 0
	if(holder)
		for(var/client/C in admins)
			if(C.ckey in stealth_keys)
				continue
			if(C.holder.fakekey && (!R_ADMIN & holder.rights))
				continue
			msg += "&emsp;[C] is a [C.holder.rank]"
			if(C.holder.fakekey)
				msg += " <i>(as [C.holder.fakekey])</i>"
			if(isobserver(C.mob))
				msg += " - Observing"
			else if(istype(C.mob,/mob/new_player))
				msg += " - Lobby"
			else
				msg += " - Playing"
			if(C.is_afk())
				msg += " (AFK)"
			msg += "\n"
			num_admins_online++
		for(var/client/C in mentors)
			mentmsg += "&emsp;[C] is a Mentor"
			if(isobserver(C.mob))
				mentmsg += " - Observing"
			else if(istype(C.mob,/mob/new_player))
				mentmsg += " - Lobby"
			else
				mentmsg += " - Playing"
			if(C.is_afk())
				mentmsg += " (AFK)"
			mentmsg += "\n"
			num_mentors_online++
	else
		for(var/client/C in admins)
			if(C.ckey in stealth_keys)
				continue
			if(!C.holder.fakekey)
				msg += "&emsp;[C] is a [C.holder.rank]\n"
				num_admins_online++
		for(var/client/C in mentors)
			mentmsg += "&emsp;[C] is a Mentor\n"
			num_mentors_online++
	to_chat(src, "<b>Current Admins ([num_admins_online]):</b>\n" + msg + "\n<b>Current Mentors ([num_mentors_online]):</b>\n" + mentmsg)
