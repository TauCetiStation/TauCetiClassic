/client/proc/dsay(msg as text)
	set category = "Special Verbs"
	set name = "Dsay" //Gave this shit a shorter name so you only have to time out "dsay" rather than "dead say" to use it --NeoFite
	set hidden = 1
	if(!src.holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(!src.mob)
		return
	if(prefs.muted & MUTE_DEADCHAT)
		to_chat(src, "<span class='warning'>You cannot send DSAY messages (muted).</span>")
		return

	if(!(prefs.chat_toggles & CHAT_DEAD))
		to_chat(src, "<span class='warning'>You have deadchat muted.</span>")
		return

	if (src.handle_spam_prevention(msg,MUTE_DEADCHAT))
		return

	var/stafftype = null

	if (src.holder.rights & R_ADMIN)
		stafftype = "ADMIN"

	msg = sanitize(msg)
	log_admin("[key_name(src)] : [msg]")

	if (!msg)
		return

	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[stafftype]([src.holder.fakekey ? pick("BADMIN", "hornigranny", "TLF", "scaredforshadows", "KSI", "Silnazi", "HerpEs", "BJ69", "SpoofedEdd", "Uhangay", "Wario90900", "Regarity", "MissPhareon", "LastFish", "unMportant", "Deurpyn", "Fatbeaver") : src.key])</span> says, <span class='message'>\"[msg]\"</span></span>"

	for (var/mob/M in player_list)
		if (isnewplayer(M))
			continue

		if(M.client && M.client.holder && (M.client.prefs.chat_toggles & CHAT_DEAD)) // show the message to admins who have deadchat toggled on
			to_chat(M, rendered)

		else if(M.stat == DEAD && (M.client.prefs.chat_toggles & CHAT_DEAD)) // show the message to regular ghosts who have deadchat toggled on
			to_chat(M, rendered)

	feedback_add_details("admin_verb","D") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
