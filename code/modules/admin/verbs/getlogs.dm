//This proc allows download of past server logs saved within the data/logs/ folder.
/client/proc/getserverlogs()
	set name = "Get Server Logs"
	set desc = "View/retrieve logfiles."
	set category = "Logs"

	browseserverlogs()

/client/proc/getcurrentlogs()
	set name = "Get Current Logs"
	set desc = "View/retrieve logfiles for the current round."
	set category = "Logs"

	browseserverlogs("[global.log_directory]/")

/client/proc/getlogsbyid()
	set name = "Get Logs By ID"
	set desc = "View/retrieve logfiles for the specific round."
	set category = "Logs"

	if(!dbcon.IsConnected())
		to_chat(usr, "<span class='alert'>Database connection required</span>")
		return

	var/id = input("Enter round ID", "Round ID") as num|null

	if(!id)
		return

	var/DBQuery/round_query = dbcon.NewQuery("SELECT DATE_FORMAT(initialize_datetime, '%Y/%m/%d') FROM erro_round WHERE id = [id];")
	round_query.Execute()

	if(round_query.NextRow())
		var/round_date = round_query.item[1]
		world.log << round_date

		if(!length(round_date) || fexists("[global.log_directory]/[round_date]"))
			to_chat(usr, "<span class='alert'>No logs found</span>")

		browseserverlogs("data/logs/[round_date]/round-[id]/")


/client/proc/getoldlogs() // todo: remove me someday in 2021
	set name = "Get Logs (old)"
	set desc = "View/retrieve old formated logfiles."
	set category = "Logs"

	browseserverlogs("data/old_logs/")

/client/proc/investigate_show()
	set name = "Investigate"
	set category = "Logs"

	//var/list/investigates = list(INVESTIGATE_RESEARCH, INVESTIGATE_EXONET, INVESTIGATE_PORTAL, INVESTIGATE_SINGULO, INVESTIGATE_WIRES, INVESTIGATE_TELESCI, INVESTIGATE_GRAVITY, INVESTIGATE_RECORDS, INVESTIGATE_CARGO, INVESTIGATE_SUPERMATTER, INVESTIGATE_ATMOS, INVESTIGATE_EXPERIMENTOR, INVESTIGATE_BOTANY, INVESTIGATE_HALLUCINATIONS, INVESTIGATE_RADIATION, INVESTIGATE_NANITES, INVESTIGATE_PRESENTS)

	browseserverlogs("[global.log_investigate_directory]/")

//current round runtimes
/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the runtime Viewer"

	if(!check_rights(R_DEBUG))
		return

	error_cache.show_to(src)


/client/proc/browseserverlogs(path = "data/logs/")

	if(!check_rights(R_LOG))
		return

	path = browse_files(path)
	if(!path)
		to_chat(usr, "<span class='alert'>No logs found</span>")
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(alert("View (in game), Open (in your system's text editor), or Download?", path, "View", "Open", "Download", "Cancel"))
		if ("View")
			src << browse("<pre style='word-wrap: break-word;'>[entity_ja(html_encode(file2text(file(path))))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(file(path))
		if ("Download")
			src << ftp(file(path))
		else
			return
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.")
	return

///get_log_by_id


/*

//This proc allows download of past server logs saved within the data/logs/ folder.
//It works similarly to show-server-log.
/client/proc/getserverlog()
	set name = ".getserverlog"
	set desc = "Fetch logfiles from data/logs"
	set category = "Logs"

	var/path = browse_files("data/logs/")
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	src << run( file(path) )
	to_chat(src, "Attempting to send file, this may take a fair few minutes if the file is very large.")
	return

//This proc allows download of past server logs saved within the data/stat_logs/ folder.
//It works similarly to show-server-log.
/client/proc/getreplay()
	set name = ".getreplay"
	set desc = "Fetch replay from data/stat_logs"
	set category = "Logs"

	var/path = browse_files("data/stat_logs/")
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	src << ftp( file(path) )
	to_chat(src, "Attempting to send file, this may take a fair few minutes if the file is very large.")
	return

//Other log stuff put here for the sake of organisation

//Shows today's server log
/datum/admins/proc/view_txt_log()
	set name = "Show Server Log"
	set desc = "Shows today's server log."
	set category = "Logs"

	var/path = "data/logs/[time2text(world.realtime,"YYYY/MM-Month/DD-Day")].log"
	if( fexists(path) )
		src << run( file(path) )
	else
		to_chat(src, "<font color='red'>Error: view_txt_log(): File not found/Invalid path([path]).</font>")
		return
	feedback_add_details("admin_verb","VTL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

//Shows today's attack log
/datum/admins/proc/view_atk_log()
	set name = "Show Server Attack Log"
	set desc = "Shows today's server attack log."
	set category = "Logs"

	var/path = "data/logs/[time2text(world.realtime,"YYYY/MM-Month/DD-Day")] Attack.log"
	if( fexists(path) )
		src << run( file(path) )
	else
		to_chat(src, "<font color='red'>Error: view_atk_log(): File not found/Invalid path([path]).</font>")
		return
	usr << run( file(path) )
	feedback_add_details("admin_verb","SSAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return


*/