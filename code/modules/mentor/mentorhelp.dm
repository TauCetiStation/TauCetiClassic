/client/verb/mentorhelp(msg as text)
	set category = "Admin"
	set name = "Mentorhelp"

	if(!mob || !msg)
		return

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	if(mob.mind && mob.mind.special_role && !(src in mentors))
		to_chat(usr, "<font color='red'>You cannot ask mentors for help while being antag. File a ticket instead if you wish question this to admins.</font>")
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_MENTORHELP)
		to_chat(src, "<font color='red'>Error: Mentor-PM: You cannot send mentorhelps (Muted).</font>")
		return
	if(handle_spam_prevention(msg, MUTE_MENTORHELP))
		return

	msg = sanitize(msg)
	if(!msg)
		return

	var/ai_found = isAI(mob)
	var/ref_mob = "\ref[mob]"

	var/prefix = "MHELP"
	var/colour = "maroon"

	//send this msg to all admins
	var/admin_number_afk = 0
	for(var/client/X in admins)
		if(R_ADMIN & X.holder.rights)
			if(X.is_afk())
				admin_number_afk++
			X.mob.playsound_local(null, 'sound/effects/adminhelp.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)
			to_chat(X, "<font color=blue><b><font color=[colour]>[prefix]: </font>[get_options_bar(mob, 2, 1, 1, MHELP_REPLY, TRUE)][ai_found ? " (<A HREF='?_src_=holder;adminchecklaws=[ref_mob]'>CL</A>)" : ""]:</b> <span class='emojify linkify'>[msg]</span></font>")

	var/mentor_number_afk = 0
	var/jump = null
	for(var/client/X in mentors)
		if(X.is_afk())
			mentor_number_afk++
		if(isobserver(X.mob))
			jump = "(<A HREF='?src=\ref[X.mob];ghostplayerobservejump=[ref_mob]'>JMP</A>) "
		X.mob.playsound_local(null, 'sound/effects/adminhelp.ogg', VOL_NOTIFICATIONS, vary = FALSE, ignore_environment = TRUE)
		to_chat(X, "<font color=blue><b><font color=[colour]>[prefix]: </font>[key_name(src, 1, 0, 0, MHELP_REPLY, TRUE)][jump]:</b> <span class='emojify linkify'>[msg]</span></font>")

	mentorhelped = TRUE //Determines if they get the message to reply by clicking the name.

	//show it to the person mentorhelping too
	to_chat(src, "<font color='blue'>PM to-<b>Mentors</b>: <span class='emojify linkify'>[msg]</span></font>")

	var/mentor_number_present = mentors.len - mentor_number_afk
	var/admin_number_present = admins.len - admin_number_afk

	world.send2bridge(
		type = list(BRIDGE_ADMINLOG),
		attachment_title = "MENTOR HELP",
		attachment_msg = "**[key_name(src)]:** [msg]",
		attachment_color = BRIDGE_COLOR_ADMINLOG,
	)

	feedback_add_details("admin_verb", "MH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[prefix]: [key_name(src)]: [msg] - heard by [mentor_number_present] non-AFK mentors and [admin_number_present] non-AFK admins.")
