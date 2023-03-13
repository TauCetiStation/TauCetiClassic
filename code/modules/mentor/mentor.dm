/var/list/mentor_ckeys = list()//all server mentors list
/var/list/mentors = list()     //online mentors

/world/proc/load_mentors()
	mentor_ckeys.Cut()
	mentors.Cut()

	var/legacy_system = FALSE

	if(config.admin_legacy_system)
		legacy_system = TRUE
	else if(!establish_db_connection("erro_mentor"))
		legacy_system = TRUE
		error("Failed to connect to database in load_mentors(). Reverting to legacy system.")
		log_misc("Failed to connect to database in load_mentors(). Reverting to legacy system.")

	if(legacy_system)
		var/text = file2text("config/mentors.txt")
		if (!text)
			error("Failed to load config/mentors.txt")
		else
			var/list/lines = splittext(text, "\n")
			for(var/line in lines)
				if (!line)
					continue
				if (copytext(line, 1, 2) == ";")
					continue
				var/ckey = copytext(line, 1)
				mentor_ckeys += ckey
				if(directory[ckey])
					mentors += directory[ckey]
	else
		var/DBQuery/query = dbcon.NewQuery("SELECT ckey FROM erro_mentor")
		query.Execute()
		while(query.NextRow())
			var/ckey = query.item[1]
			mentor_ckeys += ckey
			if(directory[ckey])
				mentors += directory[ckey]

/proc/message_mentors(msg, observer_only = FALSE, emphasize = FALSE)
	var/style = "admin"
	if (emphasize)
		style += " emphasized"
	msg = "<span class='[style]'><span class='prefix'>MENTOR LOG:</span> <span class='message'>[msg]</span></span>"
	for(var/client/C in mentors)
		if(!observer_only || (observer_only && isobserver(C.mob)))
			to_chat(C, msg)
