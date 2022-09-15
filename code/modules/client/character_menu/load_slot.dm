/datum/preferences/proc/ShowLoadSlot(mob/user)
	. = "<center>"
	var/savefile/S = new /savefile(path)
	if(S)
		. += "<b>Select a character slot to load</b><br>"
		var/name
		for(var/i in 1 to MAX_SAVE_SLOTS)
			S.cd = "/character[i]"
			S["real_name"] >> name
			if(!name)
				name = "Character [i]"
			if(i==default_slot)
				name = "<b>[name]</b>"
			. += "<a href='?_src_=prefs;preference=changeslot;num=[i];'>[name]</a><br>"
	. += "</center>"
