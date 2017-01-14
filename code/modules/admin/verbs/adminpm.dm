//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M as mob in mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Admin-PM-Context: Only administrators may use this command.</font>")
		return
	if( !ismob(M) || !M.client )	return
	cmd_admin_pm(M.client,null)
	feedback_add_details("admin_verb","APMM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM"
	if(!holder)
		to_chat(src, "<font color='red'>Error: Admin-PM-Panel: Only administrators may use this command.</font>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(istype(T.mob, /mob/new_player))
				targets["(New Player) - [T]"] = T
			else if(istype(T.mob, /mob/dead/observer))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) in sorted|null
	cmd_admin_pm(targets[target],null)
	feedback_add_details("admin_verb","APM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_ahelp_reply(whom)
	if(prefs.muted & MUTE_ADMINHELP || ((src in mentors) && (prefs.muted & MUTE_MENTORHELP)))
		to_chat(src, "<font color='red'>Error: Admin-PM: You are unable to use admin PM-s (muted).</font>")
		return
	var/client/C
	C = whom
	if(!C)
		if(holder)
			to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
		return
	if(usr.client in mentors)
		message_mentors("[key_name(src, 0, 0, 0)] has started replying to [key_name(C, 0, 0, 0)]'s help request.")
//	if(usr in mentors)
	message_admins("[key_name_admin(src)] has started replying to [key_name(C, 0, 0)]'s help request.")
	var/msg = input(src,"Message:", "Private message to [key_name(C, 0, 0)]") as text|null
	if (!msg)
		message_admins("[key_name_admin(src)] has cancelled their reply to [key_name(C, 0, 0)]'s help request.")
		if(usr.client in mentors)
			message_mentors("[key_name(src, 0, 0, 0)] has cancelled their reply to [key_name(C, 0, 0, 0)]'s help request.")
		return
	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	cmd_admin_pm(whom, msg)

//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client

/client/proc/cmd_admin_pm(client/C, msg = null)
	if(prefs.muted & MUTE_ADMINHELP || ((src in mentors) && (prefs.muted & MUTE_MENTORHELP)))
		to_chat(src, "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>")
		return

	if(!istype(C,/client))
		if(holder)
			to_chat(src, "<font color='red'>Error: Private-Message: Client not found.</font>")
		else
			adminhelp(msg)	//admin we are replying to left. adminhelp instead
		return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = input(src,"Message:", "Private message to [key_name(C, 0, holder ? 1 : 0, holder ? 1 : 0)]") as text|null

		msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))

		if(!msg)
			return
		if(!C)
			if(holder)
				to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
			else
				adminhelp(msg)	//admin we are replying to has vanished, adminhelp instead
			return

	if (src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	//clean the message if it's not sent by a high-rank admin
	if(!check_rights(R_SERVER|R_DEBUG,0))
		//msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
		if(!msg)
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
		recieve_message = "<font color='[recieve_color]' size='3'><b>-- Click the [recieve_pm_type]'s name to reply --</b></font>\n"
		if(C.adminhelped)
			to_chat(C, recieve_message)
			C.adminhelped = 0

		//AdminPM popup for ApocStation and anybody else who wants to use it. Set it with POPUP_ADMIN_PM in config.txt ~Carn
		if(config.popup_admin_pm)
			spawn(0)	//so we don't hold the caller proc up
				var/sender = src
				var/sendername = key
				var/reply = input(C, msg,"[recieve_pm_type] PM from-[sendername]", "") as text|null		//show message and await a reply
				if(C && reply)
					if(sender)
						C.cmd_admin_pm(sender,reply)										//sender is still about, let's reply to them
					else
						adminhelp(reply)													//sender has left, adminhelp instead
				return

	recieve_message = "<font color='[recieve_color]'>[recieve_pm_type] PM from-<b>[get_options_bar(src, C.holder ? 1 : 0, C.holder ? 1 : 0, 1)]</b>: [msg]</font>"
	to_chat(C, recieve_message)
	to_chat(src, "<font color='blue'>[send_pm_type]PM to-<b>[get_options_bar(C, holder ? 1 : 0, holder ? 1 : 0, 1)]</b>: [msg]</font>")

	//play the recieving admin the adminhelp sound (if they have them enabled)
	//non-admins shouldn't be able to disable this
	if(C.prefs && C.prefs.toggles & SOUND_ADMINHELP)
		C << 'sound/effects/adminhelp.ogg'

	log_admin("PM: [key_name(src)]->[key_name(C)]: [msg]")
	send2slack_logs("[key_name(src)]->[key_name(C)]",  msg, "(PM)")

	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/X in admins)
		//check client/X is an admin and isn't the sender or recipient
		if(X == C || X == src)
			continue
		if(X.key!=key && X.key!=C.key)
			to_chat(X, "<B><font color='blue'>PM: [key_name(src, X, 0)]-&gt;[key_name(C, X, 0)]:</B> \blue [msg]</font>")//inform X
	for(var/client/X in mentors)
		if(X == C || X == src)
			continue
		if(X.key!=key && X.key!=C.key && !C.holder && !src.holder)
			to_chat(X, "<B><font color='blue'>PM: [key_name(src, X, 0, 0)]-&gt;[key_name(C, X, 0, 0)]:</B> \blue [msg]</font>")//inform X

/client/proc/cmd_admin_irc_pm()
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>")
		return

	var/msg = input(src,"Message:", "Private message to admins on IRC / 400 character limit") as text|null

	if(!msg)
		return

	sanitize(msg)

	if(length(msg) > 400) // TODO: if message length is over 400, divide it up into seperate messages, the message length restriction is based on IRC limitations.  Probably easier to do this on the bots ends.
		to_chat(src, "\red Your message was not sent because it was more then 400 characters find your message below for ease of copy/pasting")
		to_chat(src, "\blue [msg]")
		return

	send2adminirc("PlayerPM from [key_name(src)]: [html_decode(msg)]")

	to_chat(src, "<font color='blue'>IRC PM to-<b>IRC-Admins</b>: [msg]</font>")

	log_admin("PM: [key_name(src)]->IRC: [msg]")
	for(var/client/X in admins)
		if(X == src)
			continue
		if(X.holder.rights & R_ADMIN)
			to_chat(X, "<B><font color='blue'>PM: [key_name(src, X, 0)]-&gt;IRC-Admins:</B> \blue [msg]</font>")

