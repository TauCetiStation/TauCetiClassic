/client/proc/cmd_mentor_pm(client/C, msg)
	if(prefs.muted & MUTE_MENTORHELP)
		to_chat(src, "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>")
		return

	if(!istype(C,/client))
		if(holder)
			to_chat(src, "<font color='red'>Error: Private-Message: Client not found.</font>")
		else
			mentorhelp(msg)	//admin/mentor we are replying to left. mentorhelp instead
		return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = sanitize(input(src,"Message:", "Private message to [key_name(C, 0, holder ? 1 : 0, holder ? 1 : 0)]") as text|null)

		if(!msg)
			return
		if(!C)
			if(holder)
				to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
			else
				mentorhelp(msg)	//admin/mentor we are replying to has vanished, mentorhelp instead
			return

	if (handle_spam_prevention(msg, MUTE_MENTORHELP))
		return

	var/recieve_color = "purple"
	var/send_pm_type = " "
	var/recieve_pm_type = "Player"

	if(holder)
		//mentor PMs are maroon
		//PMs sent from admins display their rank
		if(C.holder && (holder.rights & R_ADMIN))
			recieve_color = "red"
		else
			recieve_color = "maroon"
		send_pm_type = holder.rank + " "
		if(!C.holder && holder && holder.fakekey)
			recieve_pm_type = "Admin"
		else
			recieve_pm_type = holder.rank
	else if(src in mentors)
		recieve_color = "maroon"
		send_pm_type = "Mentor "
		recieve_pm_type = "Mentor"
	else if(!C.holder && !(C in mentors))
		to_chat(src, "<font color='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</font>")
		return

	var/recieve_message = ""

	if(((src in mentors) || holder) && !C.holder)
		if(config.rus_language)
			recieve_message = "<font color='[recieve_color]' size='3'><b>-- [text("Нажмите на имя []'а для ответа.", recieve_pm_type)] --</b></font>\n"
		else
			recieve_message = "<font color='[recieve_color]' size='3'><b>-- Click the [recieve_pm_type]'s name to reply --</b></font>\n"
		if(C.mentorhelped)
			to_chat(C, recieve_message)
			C.mentorhelped = FALSE

	recieve_message = "<font color='[recieve_color]'>[recieve_pm_type] PM from-<b>[get_options_bar(src, C.holder ? 1 : 0, C.holder ? 1 : 0, 1, null, TRUE)]</b>: <span class='emojify linkify'>[msg]</span></font>"
	to_chat(C, recieve_message)
	to_chat(src, "<font color='blue'>[send_pm_type]PM to-<b>[get_options_bar(C, holder ? 1 : 0, holder ? 1 : 0, 1, null, TRUE)]</b>: <span class='emojify linkify'>[msg]</span></font>")

	//play the recieving admin the adminhelp sound (if they have them enabled)
	//non-admins shouldn't be able to disable this
	C.mob.playsound_local(null, 'sound/effects/adminhelp.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)

	log_admin("PM: [key_name(src)]->[key_name(C)]: [msg]")
	world.send2bridge(
		type = list(BRIDGE_ADMINLOG),
		attachment_title = "MENTOR PM",
		attachment_msg = "**[key_name(src)]->[key_name(C)]:** [msg]",
		attachment_color = BRIDGE_COLOR_ADMINLOG,
	)

	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/X in admins)
		//check client/X is an admin and isn't the sender or recipient
		if(X == C || X == src)
			continue
		if(X.key != key && X.key != C.key && X.holder.rights & R_ADMIN)
			to_chat(X, "<B><font color='blue'>PM: [key_name(src, X, 0)]-&gt;[key_name(C, X, 0)]:</B> <span class='emojify linkify'>[msg]</span></font>")//inform X
	for(var/client/X in mentors)
		if(X == C || X == src)
			continue
		if(X.key != key && X.key != C.key && !C.holder && !src.holder)
			to_chat(X, "<B><font color='blue'>PM: [key_name(src, X, 0, 0)]-&gt;[key_name(C, X, 0, 0)]:</B> <span class='emojify linkify'>[msg]</span></font>")//inform X
