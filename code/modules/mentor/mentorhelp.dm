/client/verb/mentorhelp(msg as text)
	set category = "Admin"
	set name = "Mentorhelp"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "\red Speech is currently admin-disabled.")
		return

	if(!mob)
		return

	if(mob.mind && mob.mind.special_role)	//Mentors are just a players, so they shan't know gamemode from these ones who toggles all role prefs to yes
		to_chat(usr, "<font color='red'>You cannot ask mentors for help while being antag. Your message was redirected to adminhelp instead.</font>")
		adminhelp(msg)
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_MENTORHELP)
		to_chat(src, "<font color='red'>Error: Mentor-PM: You cannot send mentorhelps (Muted).</font>")
		return
	if(src.handle_spam_prevention(msg,MUTE_MENTORHELP))
		return

	staffhelp(msg, help_type = "MH")
