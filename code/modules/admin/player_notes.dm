//This stuff was originally intended to be integrated into the ban-system I was working on
//but it's safe to say that'll never be finished. So I've merged it into the current player panel.
//enjoy				~Carn
/*
#define NOTESFILE "data/player_notes.sav"	//where the player notes are saved

/datum/admins/proc/notes_show(ckey)
	usr << browse("<head><title>Player Notes</title></head><body>[notes_gethtml(ckey)]</body>","window=player_notes;size=700x400")


/datum/admins/proc/notes_gethtml(ckey)
	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)	return "<font color='red'>Error: Cannot access [NOTESFILE]</font>"
	if(ckey)
		. = "<b>Notes for <a href='?src=\ref[src];notes=show'>[ckey]</a>:</b> <a href='?src=\ref[src];notes=add;ckey=[ckey]'>\[+\]</a> <a href='?src=\ref[src];notes=remove;ckey=[ckey]'>\[-\]</a><br>"
		notesfile.cd = "/[ckey]"
		var/index = 1
		while( !notesfile.eof )
			var/note
			notesfile >> note
			. += "[note] <a href='?src=\ref[src];notes=remove;ckey=[ckey];from=[index]'>\[-\]</a><br>"
			index++
	else
		. = "<b>All Notes:</b> <a href='?src=\ref[src];notes=add'>\[+\]</a> <a href='?src=\ref[src];notes=remove'>\[-\]</a><br>"
		notesfile.cd = "/"
		for(var/dir in notesfile.dir)
			. += "<a href='?src=\ref[src];notes=show;ckey=[dir]'>[dir]</a><br>"
	return


//handles adding notes to the end of a ckey's buffer
//originally had seperate entries such as var/by to record who left the note and when
//but the current bansystem is a heap of dung.
/proc/notes_add(ckey, note)
	if(!ckey)
		ckey = ckey(input(usr,"Who would you like to add notes for?","Enter a ckey",null) as text|null)
		if(!ckey)	return

	if(!note)
		note = html_encode(input(usr,"Enter your note:","Enter some text",null) as message|null)
		if(!note)	return

	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)	return
	notesfile.cd = "/[ckey]"
	notesfile.eof = 1		//move to the end of the buffer
	to_chat(notesfile, "[time2text(world.realtime,"DD-MMM-YYYY")] | [note][(usr && usr.ckey)?" ~[usr.ckey]":""]")
	return

//handles removing entries from the buffer, or removing the entire directory if no start_index is given
/proc/notes_remove(ckey, start_index, end_index)
	var/savefile/notesfile = new(NOTESFILE)
	if(!notesfile)	return

	if(!ckey)
		notesfile.cd = "/"
		ckey = ckey(input(usr,"Who would you like to remove notes for?","Enter a ckey",null) as null|anything in notesfile.dir)
		if(!ckey)	return

	if(start_index)
		notesfile.cd = "/[ckey]"
		var/list/noteslist = list()
		if(!end_index)	end_index = start_index
		var/index = 0
		while( !notesfile.eof )
			index++
			var/temp
			notesfile >> temp
			if( (start_index <= index) && (index <= end_index) )
				continue
			noteslist += temp

		notesfile.eof = -2		//Move to the start of the buffer and then erase.

		for( var/note in noteslist )
			to_chat(notesfile, note)
	else
		notesfile.cd = "/"
		if(alert(usr,"Are you sure you want to remove all their notes?","Confirmation","No","Yes - Remove all notes") == "Yes - Remove all notes")
			notesfile.dir.Remove(ckey)
	return

#undef NOTESFILE
*/

//Hijacking this file for BS12 playernotes functions. I like this ^ one systemm alright, but converting sounds too bothersome~ Chinsky.

/proc/notes_add(key, note, client/admin)
	if (!key || !note)
		return

	note = sanitize(note)

	//Loading list of notes for this key
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos) infos = list()

	//Overly complex timestamp creation
	var/modifyer = "th"
	switch(time2text(world.timeofday, "DD"))
		if("01","21","31")
			modifyer = "st"
		if("02","22",)
			modifyer = "nd"
		if("03","23")
			modifyer = "rd"
	var/day_string = "[time2text(world.timeofday, "DD")][modifyer]"
	if(copytext(day_string,1,2) == "0")
		day_string = copytext(day_string,2)
	var/full_date = time2text(world.timeofday, "DDD, Month DD of YYYY")
	var/day_loc = findtext(full_date, time2text(world.timeofday, "DD"))

	var/datum/player_info/P = new
	if (admin)
		P.author = admin.key
		P.rank = admin.holder.rank
	else
		P.author = "Adminbot"
		P.rank = "Friendly Robot"
	P.content = note
	P.timestamp = "[copytext(full_date,1,day_loc)][day_string][copytext(full_date,day_loc+2)]"

	infos += P
	info << infos

	message_admins("[admin ? key_name_admin(admin) : "Adminbot"] has edited [key]'s notes.")
	log_admin("[admin ? key_name(admin) : "Adminbot"] has edited [key]'s notes.")
	admin_ticket_log(ckey(key), "<font color='green'>[admin ? key_name(admin) : "Adminbot"] has edited [ckey(key)]'s notes: [note]</font>")

	del(info) // savefile, so NOT qdel

	//Updating list of keys with notes on them
	var/savefile/note_list = new("data/player_notes.sav")
	var/list/note_keys
	note_list >> note_keys
	if(!note_keys) note_keys = list()
	if(!note_keys.Find(key)) note_keys += key
	note_list << note_keys
	del(note_list)	// savefile, so NOT qdel

/proc/parse_notes_date_timestamp(note_timestamp_text)
	// return number of day after 1 Jan 2000
	// if date before 1 Jan 2000 or errors return 0
	//
	// Example of note_timestamp_text
	// Tue, January 28th of 2020
	// Wed, January 8th of 2020
	if (!length(note_timestamp_text) || !istext(note_timestamp_text))
		return 0
	var/list/month_names = list(
		"January"   = 1,
		"February"  = 2,
		"March"     = 3,
		"April"     = 4,
		"May"       = 5,
		"June"      = 6,
		"July"      = 7,
		"August"    = 8,
		"September" = 9,
		"October"   = 10,
		"November"  = 11,
		"December"  = 12
	)
	var/list/month_days = list(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
	var/regex/pattern = regex(@"^\l{3},\s(\l+)\s(\d{1,2})\l{2}\sof\s(\d{4})$")
	if (!pattern.Find(note_timestamp_text) || length(pattern.group) < 3)
		return 0
	var/day = pattern.group[2]
	var/month = pattern.group[1]
	var/year = pattern.group[3]
	if (!length(day) || !length(month) || !length(year) || !(month in month_names))
		return 0
	day = text2num(day)
	month = month_names[month]
	year = text2num(year)
	if (!day || !year || year < 2000 || day < 1)
		return 0
	var/days_passed = 0
	// past years to days
	if (year != 2000)
		for (var/Y in 2000 to year-1)
			if (is_leap_year(Y))
				days_passed += 366
			else
				days_passed += 365
	// past month to days
	if (month > 1)
		for (var/M in 1 to month-1)
			days_passed += month_days[M]
			if (M == 2 && is_leap_year(year))
				days_passed++
	return days_passed + day

/proc/notes_del(key, index, admin)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || infos.len < index) return

	var/datum/player_info/item = infos[index]
	infos.Remove(item)
	info << infos

	message_admins("[key_name_admin(admin)] deleted one of [key]'s notes.")
	log_admin("[key_name(admin)] deleted one of [key]'s notes.")

	del(info)	// savefile, so NOT qdel

/proc/show_player_info_irc(key)
	var/dat = "          Info on [key]%0D%0A"
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos)
		dat = "No information found on the given key."
	else
		for(var/datum/player_info/I in infos)
			dat += "[I.content]%0D%0Aby [I.author] ([I.rank]) on [I.timestamp]%0D%0A%0D%0A"

	return dat
