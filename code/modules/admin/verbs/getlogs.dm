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

	browseserverlogs_id()

/client/proc/getdebuglogsbyid() // shouldbeunderscored
	set name = "Get Debug Logs By ID"
	set desc = "View/retrieve logfiles for the specific round."
	set category = "Logs"

	browseserverlogs_id(subpath = "debug/")

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
	set category = "Logs"
	set name = "View Runtimes"
	set desc = "Open the runtime Viewer"

	if(!check_rights(R_LOG|R_DEBUG))
		return

	error_cache.show_to(src)

/client/proc/browseserverlogs(path = "data/logs/")

	if(!check_rights(R_LOG|R_DEBUG))
		return

	path = browse_files(path)
	if(!path)
		to_chat(usr, "<span class='alert'>No logs found</span>")
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	log_game("[key_name(src)] accessed file: [path]")
	
	switch(alert("View (in game), Open (in your system's text editor), or Download?", path, "View", "Open", "Download", "Cancel"))
		if ("View")
			var/datum/browser/popup = new(src, "window=viewfile.[path]", "[path]", ntheme = CSS_THEME_LIGHT)
			popup.set_content("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>")
			popup.open()
		if ("Open")
			src << run(file(path))
		if ("Download")
			src << ftp(file(path))
		else
			return
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.")
	return

/client/proc/browseserverlogs_id(subpath = "")

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

		if(!length(round_date))
			to_chat(usr, "<span class='alert'>No logs found</span>")
			return

		browseserverlogs("data/logs/[round_date]/round-[id]/[subpath]")