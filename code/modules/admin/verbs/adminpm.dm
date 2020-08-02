//allows right clicking mobs to send an admin PM to their client, forwards the selected mob's client to cmd_admin_pm
/client/proc/cmd_admin_pm_context(mob/M as mob in mob_list)
	set category = null
	set name = "Admin PM Mob"
	if(!check_rights(R_ADMIN))
		to_chat(src, "<font color='red'>Error: Admin-PM-Context: Only administrators may use this command.</font>")
		return
	if( !ismob(M) || !M.client )	return
	cmd_admin_pm(M.client,null)
	feedback_add_details("admin_verb","APMM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

//shows a list of clients we could send PMs to, then forwards our choice to cmd_admin_pm
/client/proc/cmd_admin_pm_panel()
	set category = "Admin"
	set name = "Admin PM"
	if(!check_rights(R_ADMIN))
		to_chat(src, "<font color='red'>Error: Admin-PM-Panel: Only administrators may use this command.</font>")
		return
	var/list/client/targets[0]
	for(var/client/T)
		if(T.mob)
			if(isnewplayer(T.mob))
				targets["(New Player) - [T]"] = T
			else if(isobserver(T.mob))
				targets["[T.mob.name](Ghost) - [T]"] = T
			else
				targets["[T.mob.real_name](as [T.mob.name]) - [T]"] = T
		else
			targets["(No Mob) - [T]"] = T
	var/list/sorted = sortList(targets)
	var/target = input(src,"To whom shall we send a message?","Admin PM",null) in sorted|null
	cmd_admin_pm(targets[target],null)
	feedback_add_details("admin_verb","APM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_ahelp_reply(whom, reply_type)
	if(prefs.muted & (MUTE_ADMINHELP|MUTE_MENTORHELP))
		to_chat(src, "<font color='red'>Error: Admin-PM: You are unable to use admin PM-s (muted).</font>")
		return
	var/client/C
	if(istype(whom, /client))
		C = whom
	if(!C)
		if(holder)
			to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
		return
	if(src in mentors)
		message_mentors("[key_name(src, 0, 0, 0)] has started replying to [key_name(C, 0, 0, 0)]'s help request.")
	message_admins("[key_name_admin(src)] has started replying to [key_name(C, 0, 0)]'s help request.")
	var/msg = sanitize(input(src,"Message:", "Private message to [key_name(C, 0, 0)]") as text|null)
	if (!msg)
		message_admins("[key_name_admin(src)] has cancelled their reply to [key_name(C, 0, 0)]'s help request.")
		if(src in mentors)
			message_mentors("[key_name(src, 0, 0, 0)] has cancelled their reply to [key_name(C, 0, 0, 0)]'s help request.")
		return
	if(reply_type != MHELP_REPLY)
		cmd_admin_pm(whom, msg)
	else
		if(!holder && mob.mind && mob.mind.special_role && !(src in mentors))
			to_chat(src, "<font color='red'>You cannot ask mentors for help while being antag. File a ticket instead if you wish question this to admins.</font>")
			return
		cmd_mentor_pm(whom, msg)

//takes input from cmd_admin_pm_context, cmd_admin_pm_panel or /client/Topic and sends them a PM.
//Fetching a message if needed. src is the sender and C is the target client

/client/proc/cmd_admin_pm(whom, msg)
	if(prefs.muted & (MUTE_ADMINHELP|MUTE_MENTORHELP))
		to_chat(src, "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>")
		return

	if(!holder && !current_ticket)	//no ticket? https://www.youtube.com/watch?v=iHSPf6x1Fdo
		to_chat(src, "<font color='red'>You can no longer reply to this ticket, please open another one by using the Adminhelp verb if need be.</font>")
		to_chat(src, "<font color='blue'>Message: [msg]</font>")
		return

	var/client/recipient
	if(istype(whom, /client))
		recipient = whom

	if(!recipient)
		if(holder)
			to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
			if(msg)
				to_chat(src, "Returned message: [msg]") // this just returns original msg back, so you can copy and paste again or whatever.
			return
		else if(msg) // you want to continue if there's no message instead of returning now
			current_ticket.MessageNoRecipient(msg)
			return

	//get message text, limit it's length.and clean/escape html
	if(!msg)
		msg = sanitize(input(src,"Message:", "Private message to [key_name(recipient, 0, holder ? 1 : 0, holder ? 1 : 0)]") as text|null)
		if(!msg)
			return

		if(prefs.muted & (MUTE_ADMINHELP|MUTE_MENTORHELP)) // maybe client were muted while typing input.
			to_chat(src, "<font color='red'>Error: Admin-PM: You are unable to use admin PM-s (muted).</font>")
			return

		if(!recipient)
			if(holder)
				to_chat(src, "<font color='red'>Error: Admin-PM: Client not found.</font>")
				to_chat(src, "Returned message: [msg]")
			else
				current_ticket.MessageNoRecipient(msg)
			return

	if (src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return

	if(recipient.holder)
		if(holder)	//both are admins
			to_chat(recipient, "<font color='red'>Admin PM from-<b>[key_name(src, recipient, 1)]</b>: <span class='emojify linkify'>[msg]</span></font>")
			to_chat(src, "<font color='blue'>Admin PM to-<b>[key_name(recipient, src, 1)]</b>: <span class='emojify linkify'>[msg]</span></font>")

			//omg this is dumb, just fill in both their tickets
			var/interaction_message = "<font color='purple'>PM from-<b>[key_name(src, recipient, 1)]</b> to-<b>[key_name(recipient, src, 1)]</b>: [msg]</font>"
			admin_ticket_log(src, interaction_message)
			if(recipient != src)	//reeee
				admin_ticket_log(recipient, interaction_message)

		else		//recipient is an admin but sender is not
			if(!current_ticket)
				to_chat(src, "<font color='red'>You can no longer reply to this ticket, please open another one by using the Adminhelp verb if need be.</font>")
				to_chat(src, "<font color='blue'>Message: [msg]</font>")
				return
			else
				var/replymsg = "<font color='red'>Reply PM from-<b>[key_name(src, recipient, 1)]</b>: <span class='emojify linkify'>[msg]</span></font>"
				admin_ticket_log(src, replymsg)
				to_chat(recipient, replymsg)
				to_chat(src, "<font color='blue'>PM to-<b>Admins</b>: <span class='emojify linkify'>[msg]</span></font>")

		//play the receiving admin the adminhelp sound (if they have them enabled)
		recipient.mob.playsound_local(null, 'sound/effects/adminhelp.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)

	else
		if(holder)	//sender is an admin but recipient is not. Do BIG RED TEXT
			if(!recipient.current_ticket)
				new /datum/admin_help(msg, recipient, TRUE)

			to_chat(recipient, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")
			to_chat(recipient, "<font color='red'>Admin PM from-<b>[key_name(src, recipient, 0)]</b>: <span class='emojify linkify'>[msg]</span></font>")
			if(config.rus_language)
				to_chat(recipient, "<font color='red'><i>Нажмите на имя администратора для ответа.</i></font>")
			else
				to_chat(recipient, "<font color='red'><i>Click on the administrator's name to reply.</i></font>")
			to_chat(src, "<font color='blue'>Admin PM to-<b>[key_name(recipient, src, 1)]</b>: <span class='emojify linkify'>[msg]</span></font>")

			admin_ticket_log(recipient, "<font color='blue'>PM From [key_name_admin(src)]: [msg]</font>")

			//always play non-admin recipients the adminhelp sound
			recipient.mob.playsound_local(null, 'sound/effects/adminhelp.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)

		else		//neither are admins
			to_chat(src, "<font color='red'>Error: Admin-PM: Non-admin to non-admin PM communication is forbidden.</font>")
			return

	world.send2bridge(
		type = list(BRIDGE_ADMINLOG),
		attachment_title = "PM",
		attachment_msg = "**[key_name(src)]->[key_name(recipient)]:** [msg]",
		attachment_color = BRIDGE_COLOR_ADMINLOG,
	)
	window_flash(recipient)
	log_admin_private("[key_name(src)]->[key_name(recipient)]: [msg]")
	//we don't use message_admins here because the sender/receiver might get it too
	for(var/client/X in global.admins)
		if(X.key != key && X.key != recipient.key) //check client/X is an admin and isn't the sender or recipient
			to_chat(X, "<font color='blue'><B>PM: [key_name(src, X, 0)]-&gt;[key_name(recipient, X, 0)]:</B> <span class='emojify linkify'>[msg]</span></font>" )


/client/proc/cmd_admin_irc_pm()
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: Private-Message: You are unable to use PM-s (muted).</font>")
		return

	var/msg = sanitize(input(src,"Message:", "Private message to admins on IRC / 400 character limit") as text|null)

	if(!msg)
		return

	if(length(msg) > 400) // TODO: if message length is over 400, divide it up into seperate messages, the message length restriction is based on IRC limitations.  Probably easier to do this on the bots ends.
		to_chat(src, "<span class='warning'>Your message was not sent because it was more then 400 characters find your message below for ease of copy/pasting</span>")
		to_chat(src, "<span class='notice'>[msg]</span>")
		return

	to_chat(src, "<font color='blue'>IRC PM to-<b>IRC-Admins</b>: [msg]</font>")

	log_admin("PM: [key_name(src)]->IRC: [msg]")
	for(var/client/X in admins)
		if(X == src)
			continue
		if(X.holder.rights & R_ADMIN)
			to_chat(X, "<B><font color='blue'>PM: [key_name(src, X, 0)]-&gt;IRC-Admins:</B> <span class='notice'>[msg]</span></font>")

