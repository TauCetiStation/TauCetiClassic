var/list/whitelist = list()

/proc/load_whitelist()
	whitelist = file2list("config/whitelist.txt")
	if(!whitelist.len)	whitelist = null

/proc/check_whitelist(mob/M /*, rank*/)
//	if(!whitelist)
//		return 0
//	return ("[M.ckey]" in whitelist)
	for (var/s in whitelist)
		if(findtext(s,"[M.ckey]"))
			return 1
	return 0

/client/proc/get_whitelist()
	set category = "Server"
	set name = "Whitelist: Check"
	if(!check_rights(R_ADMIN))
		return

	var/path = "config/whitelist.txt"
	if(fexists(path))
		src << run(file(path))
	else
		to_chat(src, "<font color='red'>Error: get_whitelist(): File not found/Invalid path([path]).</font>")
		return
	feedback_add_details("admin_verb","GWL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return


/client/proc/add_to_whitelist()
	set category = "Server"
	set name = "Whitelist: Add"
	if(!check_rights(R_ADMIN))
		return

	var/path = "config/whitelist.txt"
	var/player = ckey(input("Input player byound key", "\n") as text)
	if(length(player) == 0)
		return
	player += " ,added by [src.key]\n"
	if(fexists(path))
		text2file(player,path)
		load_whitelist()
	else
		to_chat(src, "<font color='red'>Error: get_whitelist(): File not found/Invalid path([path]).</font>")
	log_admin("Whitelist: [player]")
	message_admins("Whitelist: [player]", 1)
	return
