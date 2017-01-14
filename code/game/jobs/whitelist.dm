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

/var/list/alien_whitelist = list()

/proc/load_alienwhitelist()
	var/text = file2text("config/alienwhitelist.txt")
	if (!text)
		log_misc("Failed to load config/alienwhitelist.txt")
	else
		alien_whitelist = splittext(text, "\n")

//todo: admin aliens
/proc/is_alien_whitelisted(mob/M, species)
	if(!config.usealienwhitelist)
		return 1
	if(species == "human" || species == "Human")
		return 1
//	if(species == "machine" || species == "Machine")
//		return 1
	if(check_rights(R_ADMIN, 0))
		return 1
	if(!alien_whitelist)
		return 0
	if(M && species)
		switch(species) //When something passes language name instead race name, we magically change variable.
			if("Sinta'unathi")
				species = "Unathi"
			if("Siik'maas","Siik'tajr")
				species = "Tajaran"
			if("Skrellian")
				species = "Skrell"
		for (var/s in alien_whitelist)
			if(findtext(s,"[M.ckey] - [species]"))
				return 1
			if(findtext(s,"[M.ckey] - All"))
				return 1

	return 0

client/proc/get_alienwhitelist()
	set category = "Server"
	set name = "Whitelist(Alien): Check"
	if(!check_rights(R_ADMIN))
		return

	var/path = "config/alienwhitelist.txt"
	if(fexists(path))
		src << run(file(path))
	else
		to_chat(src, "<font color='red'>Error: get_alienwhitelist(): File not found/Invalid path([path]).</font>")
		return
	return

/client/proc/add_to_alienwhitelist()
	set category = "Server"
	set name = "Whitelist(Alien): Add"
	if(!check_rights(R_ADMIN))	return

	var/path = "config/alienwhitelist.txt"
	var/player = ckey(input("Input player byound key", "\n") as text)
	if(length(player) == 0)
		return
	player += " - "
	player += input("Input alien species, e.g. Unathi, Tajaran, Skrell, Diona, Machine") as text
	var/log_text = player + ",added by [src.key]."	//log without creating new line buy \n macros
	player += " ,added by [src.key]\n"
	if(fexists(path))
		text2file(player,path)
		load_alienwhitelist()
	else
		to_chat(src, "<font color='red'>Error: get_alienwhitelist(): File not found/Invalid path([path]).</font>")
	log_admin("[log_text]")
	message_admins("[log_text]", 1)
	return

client/proc/get_whitelist()
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
	if(!check_rights(R_ADMIN))	return

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
