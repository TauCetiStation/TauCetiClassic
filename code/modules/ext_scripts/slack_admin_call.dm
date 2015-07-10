proc/admin_call_cooldown(var/value1)
	ac_nameholder.Add(value1)
	//world << "added [value1] to the ac_nameholder list"
	spawn(3000)
		ac_nameholder.Remove(value1)
		//world << "Removed [value1] to the ac_nameholder list"

/client/verb/admincall()
	set category = "Admin"
	set name = "Admin Call"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		src << "<font color='red'>Error: AdminCall: You cannot send admincalls (Muted).</font>"
		return

	//for(var/test in ac_nameholder)
	//	world << test

	if(key_name(src) in ac_nameholder)
		return

	admin_call_cooldown(key_name(src))

	var/output_text = {"<font color='red'>============ADMINCALL============</font><BR>
<font color='red'>[sanitize_popup("1) Сообщение длинной не более 140 символов.")]</font><BR>
<font color='red'>[sanitize_popup("2) Описать коротко и внятно причину по которой нужен админ.")]</font><BR>
<font color='red'>[sanitize_popup("3) Ожидать.</font>")]<BR>
<font color='red'>[sanitize_popup("4) Если и таким образом не выйдет вызвать админа, то в крайнем случае сообщение будет сохранено и не потеряется.")]</font><BR>
<font color='red'>=================================</font><BR>
"}

	src << browse(output_text, "window=admcl;size=600x300")

	src << 'sound/effects/adminhelp.ogg'

	var/msg = input(src, "Message:", "Admin Call", ) as text

	if(src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return
	//clean the input msg
	if(!msg)	return

	var/check_answer = alert(src, sanitize("Send?"),,"Yes","No")
	if(check_answer == "No")
		return

	msg = sanitize(copytext(msg,1,140))
	if(!msg)	return
	var/original_msg = msg

	//explode the input msg into a list
	var/list/msglist = text2list(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	for(var/mob/M in mob_list)
		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)	indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = text2list(string, " ")
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

	if(!mob)	return						//this doesn't happen

	var/ref_mob = "\ref[mob]"
	msg = "\blue <b><font color=red>ADMINCALL: </font>[get_options_bar(mob, 2, 1, 1)][ai_found ? " (<A HREF='?_src_=holder;adminchecklaws=[ref_mob]'>CL</A>)" : ""]:</b> [msg]"

	//send this msg to all admins
	var/admin_number_afk = 0
	for(var/client/X in admins)
		if((R_ADMIN|R_MOD|R_MENTOR) & X.holder.rights)
		//if((R_ADMIN|R_MOD) & X.holder.rights)
			if(X.is_afk())
				admin_number_afk++
			if(X.prefs.toggles & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'
			X << msg

	//show it to the person adminhelping too
	src << "<font color='blue'><b>AdminCall message</b>: [original_msg]</font>"

	var/admin_number_present = admins.len - admin_number_afk
	log_admin("ADMINCALL: [key_name(src)]: [original_msg] - heard by [admin_number_present] non-AFK admins.")
	if(admin_number_present <= 0)
		if(!admin_number_afk)
			send2slack_admincall("ADMINCALL from [key_name(src)]: [original_msg] - !!No admins online!!")
		else
			send2slack_admincall("ADMINCALL from [key_name(src)]: [original_msg] - !!All admins AFK ([admin_number_afk])!!")
	//else
	//	send2slack_admincall("ADMINCALL from [key_name(src)]: [original_msg]")
	feedback_add_details("admin_verb","ASC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return
