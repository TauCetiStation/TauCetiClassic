/client/verb/mentorhelp(msg as text)
	set category = "Admin"
	set name = "Mentorhelp"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='alert'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return

	if(usr.client && usr.client in mentors)
		to_chat(src, "<span class='alert'>Error: Mentor-PM: You cannot send mentorhelps.</span>")
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_MENTORHELP)
		to_chat(src, "<span class='alert'>Error: Mentor-PM: You cannot send mentorhelps (Muted).</span>")
		return

	if(mob.mind && mob.mind.special_role)	//Mentors are just a players, so they shan't know gamemode from these ones who toggles all role prefs to yes
		to_chat(usr, "<span class='alert'>You cannot ask mentors for help while being antag. Your message was redirected to adminhelp instead.</span>")
		adminhelp(msg)
		return

	if(src.handle_spam_prevention(msg,MUTE_MENTORHELP))
		return

	staffhelp(msg, help_type = "MH")
