/client/proc/cmd_admin_say(msg as text)
	set category = "Special Verbs"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(R_ADMIN))
		return
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<font color='red'>Error: ASAY: You cannot use asay (Muted).</font>")
		return

	msg = sanitize(msg)
	if(!msg)
		return

	log_adminsay("[key_name(src)] : [msg]", "ADMINSAY")

	msg = "<span class='adminsay'><span class='prefix'>ADMINSAY:</span> <EM>[key_name(usr, 1)]</EM> (<a href='?_src_=holder;adminplayerobservejump=\ref[mob]'>JMP</A>): <span class='message emojify linkify'>[msg]</span></span>"
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, msg)

	feedback_add_details("admin_verb","M") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
