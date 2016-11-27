proc/admin_call_cooldown(value1)
	ac_nameholder.Add(value1)
	spawn(3000)
		ac_nameholder.Remove(value1)

/client/verb/admincall()
	set category = "Admin"
	set name = "Admin Call"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "\red Speech is currently admin-disabled.")
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: AdminCall: You cannot send admincalls (Muted).</font>")
		return

	if(key_name(src) in ac_nameholder)
		to_chat(src, "<font color='blue'>Можно использовать не чаще 1-го раза в 5 минут.</font>")
		return

	admin_call_cooldown(key_name(src))

	var/output_text = {"<font color='red'>============ADMINCALL============</font><BR>
<font color='red'>[sanitize_alt("1) Сообщение длинной не более 140 символов.")]</font><BR>
<font color='red'>[sanitize_alt("2) Описать коротко и внятно причину по которой нужен админ.")]</font><BR>
<font color='red'>[sanitize_alt("3) Ожидать.")]</font><BR>
<font color='red'>[sanitize_alt("4) Если и таким образом не выйдет вызвать админа, то в крайнем случае сообщение будет сохранено и не потеряется.")]</font><BR>
<font color='red'>=================================</font><BR>
"}

	src << browse(output_text, "window=admcl;size=600x300")

	src << 'sound/effects/adminhelp.ogg'

	var/msg = input(src, "Message:", "Admin Call", ) as text

	if(src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return
	//clean the input msg
	if(!msg)	return

	var/check_answer = alert(src, "Are you sure?",,"Yes","No")
	if(check_answer == "No")
		return

	msg = sanitize(copytext(msg,1,140))

	if(!msg)	return
	var/original_msg = msg

	if(!mob)	return						//this doesn't happen

	msg = "\blue <b><font color=red>ADMINCALL: </font>[get_options_bar(mob, 2, 1, 1)]:</b> [msg]"

	//send this msg to all admins
	var/admin_number_afk = 0
	var/admin_number = 0
	for(var/client/X in admins)
		//if((R_ADMIN|R_MOD|R_MENTOR) & X.holder.rights)
		if((R_ADMIN) & X.holder.rights)
			if(!(X.ckey in stealth_keys))
				admin_number++
				if(X.is_afk())
					admin_number_afk++
			if(X.prefs.toggles & SOUND_ADMINHELP)
				X << 'sound/effects/adminhelp.ogg'
			to_chat(X, msg)

	//show it to the person admincalling too
	to_chat(src, "<font color='blue'><b>AdminCall message</b>: [original_msg]</font>")

	//var/admin_number_present = admins.len - admin_number_afk
	var/admin_number_present = admin_number - admin_number_afk
	log_admin("ADMINCALL: [key_name(src)]: [original_msg] - heard by [admin_number_present] non-AFK admins.")
	if(admin_number_present <= 0)
		if(!admin_number_afk)
			send2slack_admincall("@here ADMINCALL from *[key_name(src)]*, !!No admins online!!", original_msg)
		else
			send2slack_admincall("@here ADMINCALL from *[key_name(src)]*, !!All admins AFK ([admin_number_afk])!!", original_msg)
	//else
	//	send2slack_admincall("ADMINCALL from [key_name(src)]: [original_msg]")
	feedback_add_details("admin_verb","ASC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return
