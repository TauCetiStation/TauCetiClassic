//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as")

client/proc/staffhelp(msg, help_type = null)
	if(!help_type)
		return

	var/prefix = null
	var/colour = null
	var/target_group = null

	switch(help_type)
		if("MH")
			prefix = "MHELP"
			colour = "maroon"
			target_group = "Mentors"
		if("AH")
			prefix = "AHELP"
			colour = "red"
			target_group = "Admins"

	if(!msg)
		return
	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)
		return
	var/original_msg = msg

	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	for(var/mob/M in mob_list)
		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)
			indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = splittext(string, " ")
			var/surname_found = 0
			//surnames
			for(var/i=L.len, i>=1, i--)
				var/word = ckey(L[i])
				if(word)
					surnames[word] = M
					surname_found = i
					break
			//forenames
			for(var/i=1, i<surname_found, i++)
				var/word = ckey(L[i])
				if(word)
					forenames[word] = M
			//ckeys
			ckeys[M.ckey] = M

	var/ai_found = 0
	msg = ""
	var/list/mobs_found = list()
	for(var/original_word in msglist)
		var/word = ckey(original_word)
		//if(word)
		if(!(word in adminhelp_ignored_words))
			if(word == "ai")
				ai_found = 1
			else
				var/mob/found = ckeys[word]
				if(!found)
					found = surnames[word]
					if(!found)
						found = forenames[word]
				if(found)
					if(!(found in mobs_found))
						mobs_found += found
						if(!ai_found && isAI(found))
							ai_found = 1
						msg += "<b><font color='black'>[original_word] (<A HREF='?_src_=holder;adminmoreinfo=\ref[found]'>?</A>)</font></b> "
						continue
		msg += "[original_word] "

	var/ref_mob = "\ref[mob]"
	msg = "\blue <b><font color=[colour]>[prefix]: </font>[get_options_bar(mob, 2, 1, 1, TRUE)][ai_found ? " (<A HREF='?_src_=holder;adminchecklaws=[ref_mob]'>CL</A>)" : ""]:</b> [msg]"

	//send this msg to all admins
	var/admin_number_afk = 0
	for(var/client/X in admins)
		if(R_ADMIN & X.holder.rights)
			if(X.is_afk())
				admin_number_afk++
			if(X.prefs.toggles & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'
			to_chat(X, msg)

	var/mentor_number_afk = 0
	if(help_type == "MH")
		var/jump = null
		for(var/client/X in mentors)
			if(X.is_afk())
				mentor_number_afk++
			if(isobserver(X.mob))
				jump = "(<A HREF='?src=\ref[X.mob];ghostplayerobservejump=[ref_mob]'>JMP</A>) "
			X << 'sound/effects/adminhelp.ogg'
			to_chat(X, "<font color=blue><b><font color=[colour]>[prefix]: </font>[key_name(src, 1, 0, 0, TRUE)][jump]:</b> [original_msg]</font>")

	adminhelped = 1 //Determines if they get the message to reply by clicking the name.

	//show it to the person adminhelping too
	to_chat(src, "<font color='blue'>PM to-<b>[target_group]</b>: [original_msg]</font>")

	var/mentor_number_present = mentors.len - mentor_number_afk
	var/admin_number_present = admins.len - admin_number_afk
	var/log_msg
	switch(help_type)
		if("MH")
			log_msg = "[prefix]: [key_name(src)]: [original_msg] - heard by [mentor_number_present] non-AFK mentors and [admin_number_present] non-AFK admins."
			send2slack_logs(key_name(src), original_msg, "(MHELP)")
		if("AH")
			log_msg = "[prefix]: [key_name(src)]: [original_msg] - heard by [admin_number_present] non-AFK admins."
			//clean the input msg
			send2slack_logs(key_name(src), original_msg, "(HELP)")
			if(admin_number_present <= 0)
				if(!admin_number_afk)
					send2adminirc("ADMINHELP from [key_name(src)]: [html_decode(original_msg)] - !!No admins online!!")
				else
					send2adminirc("ADMINHELP from [key_name(src)]: [html_decode(original_msg)] - !!All admins AFK ([admin_number_afk])!!")
			else
				send2adminirc("ADMINHELP from [key_name(src)]: [html_decode(original_msg)]")

	feedback_add_details("admin_verb", help_type) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin(log_msg)
	return
