/client
		var/datum/mentor/mentorholder = null

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

/client/proc/cmd_mhelp_reply(whom)
	if(prefs.muted & MUTE_PM)
		to_chat(src, "<span class='pm warning'>Error: Mentor-PM: You are unable to use admin PM-s (muted).</span>")
		return
	var/client/C
	if(istext(whom))
		C = directory[whom]
	else if(istype(whom,/client))
		C = whom
	if(!C)
		if(has_mentor_powers(src))
			to_chat(src, "<span class='pm warning'>Error: Mentor-PM: Client not found.</span>")
		return


/proc/has_mentor_powers(client/C)
	return C.holder

/client/proc/cmd_mentor_pm(whom, msg, datum/mentor_help/MH)
	set category = "Admin"
	set name = "Mentor-PM"
	set hidden = 1

	if(prefs.muted & MUTE_PM)
		to_chat(src, "<span class='pm warning'>Error: Mentor-PM: You are unable to use admin PM-s (muted).</span>")
		return

	if(!has_mentor_powers(src) && !current_mentorhelp)
		to_chat(src, "<span class='pm warning'>You can no longer reply to this ticket, please open another one by using the Mentorhelp verb if need be.</span>")
		to_chat(src, "<span class='pm notice'>Message: [msg]</span>")
		return

	var/client/recipient

	if(istext(whom))
		recipient = directory[whom]

	else if(istype(whom,/client))
		recipient = whom

	//get message text, limit it's length.and clean/escape html
	if(!msg)

		if(prefs.muted & MUTE_PM)
			to_chat(src, "<span class='pm warning'>Error: Mentor-PM: You are unable to use admin PM-s (muted).</span>")
			return

		if(!recipient)
			if(has_mentor_powers(src))
				to_chat(src, "<span class='pm warning'>Error:Mentor-PM: Client not found.</span>")
				to_chat(src, msg)
			else
				log_admin("Mentorhelp: [key_name(src)]: [msg]")
				current_mentorhelp.MessageNoRecipient(msg)
			return

	//Has mentor powers but the recipient no longer has an open ticket
	if(has_mentor_powers(src) && !recipient.current_mentorhelp)
		to_chat(src, "<span class='pm warning'>You can no longer reply to this ticket.</span>")
		to_chat(src, "<span class='pm notice'>Message: [msg]</span>")
		return

	if (src.handle_spam_prevention(msg,MUTE_PM))
		return

	msg = trim(sanitize(copytext(msg,1,MAX_MESSAGE_LEN)))
	if(!msg)
		return

	var/interaction_message = "<span class='pm notice'>Mentor-PM from-<b>[src]</b> to-<b>[recipient]</b>: [msg]</span>"

	if (recipient.current_mentorhelp && !has_mentor_powers(recipient))
		recipient.current_mentorhelp.AddInteraction(interaction_message)
	if (src.current_mentorhelp && !has_mentor_powers(src))
		src.current_mentorhelp.AddInteraction(interaction_message)

	// It's a little fucky if they're both mentors, but while admins may need to adminhelp I don't really see any reason a mentor would have to mentorhelp since you can literally just ask any other mentors online
	if (has_mentor_powers(recipient) && has_mentor_powers(src))
		if (recipient.current_mentorhelp)
			recipient.current_mentorhelp.AddInteraction(interaction_message)
		if (src.current_mentorhelp)
			src.current_mentorhelp.AddInteraction(interaction_message)

	to_chat(recipient, "<i><span class='mentor'>Mentor-PM from-<b><a href='?mentorhelp_msg=\ref[src]'>[src]</a></b>: [msg]</span></i>")
	to_chat(src, "<i><span class='mentor'>Mentor-PM to-<b>[recipient]</b>: [msg]</span></i>")

	log_admin("[key_name(src)]->[key_name(recipient)]: [msg]")

	for(var/client/C in mentors)
		if (C != recipient && C != src)
			to_chat(C, interaction_message)
	for(var/client/C in admins)
		if (C != recipient && C != src)
			to_chat(C, interaction_message)
