#define SAY_ASAY "ADMINSAY"
#define SAY_ESAY "EVENTSAY"

/client/proc/cmd_admin_say(msg as text)
	set category = "Special Verbs"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(R_ADMIN))
		return
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: ASAY: You cannot use asay (Muted).</font>")
		return

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	admin_say_handler(src, msg, SAY_ASAY, R_ADMIN)
	feedback_add_details("admin_verb","M") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_event_say(msg as text)
	set category = "Special Verbs"
	set name = "Esay"
	set hidden = 1
	if(!check_rights(R_EVENT))
		return
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: ESAY: You cannot use esay (Muted).</font>")
		return

	msg = sanitize(copytext(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	admin_say_handler(src, msg, SAY_ESAY, R_EVENT)
	feedback_add_details("admin_verb","E") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/proc/admin_say_handler(client/sender, message, say_type, req_flag)
	if(!sender || !sender.holder)
		return

	message = "<span class='[lowertext(say_type)]'><span class='prefix'>[say_type]:</span> <EM>[key_name(usr, 1)]</EM> (<a href='?_src_=holder;adminplayerobservejump=\ref[sender.mob]'>JMP</A>): <span class='message'>[message]</span></span>"
	for(var/client/C in admins)
		if(req_flag & C.holder.rights)
			to_chat(C, message)

	log_adminsay(message, say_type)

#undef SAY_ASAY
#undef SAY_ESAY