/datum/digital/file/program/ntdocs
	name = "NTDocs"
	fileicon = "book"
	can_open_type = "Document"

	var/datum/digital/file/show_file

/datum/digital/file/program/ntdocs/New(newtype, newname,  newcontent, newicon, drive, newfolder_id)
	. = ..()

/datum/digital/file/program/ntdocs/open(datum/digital/file/File)
	if(File)
		show_file = File

/datum/digital/file/program/ntdocs/close()
	show_file = null

/datum/digital/file/program/ntdocs/process_data(list/data, mob/user)
	data["file_name"] = show_file ? show_file.name : null
	data["file_content"] = show_file ? show_file.content : null

	var/list/all_docs_to_front = list()
	for(var/datum/digital/file/File in Drive.filesystem)
		if(File.filetype == "Document")
			all_docs_to_front += list(list("name" = File.name, "file_id" = Drive.filesystem.Find(File)))
	data["all_docs"] = all_docs_to_front

	return data

/datum/digital/file/program/ntdocs/act(action, list/params, mob/user)
	switch(action)
		if("open_file")
			var/file_id = sanitize(params["file_id"])
			if(isnum(file_id))
				show_file = Drive.filesystem[file_id]
			return
		if("edit_file")
			var/new_info = sanitize(params["new_info"])
			show_file.content["info"] = new_info
			return
		if("send_file")
			return
		if("rename")
			var/new_filename = sanitize(params["new_filename"])
			if(new_filename)
				show_file.name = new_filename
			return
		if("new_file")
			var/newfile = Drive.add_file(folder_id = 1, filename = "Новый Документ", filecontent = list("info" = ""), path = null, filetype = "Document")
			if(newfile)
				show_file = newfile
			return
		if("print")
			return
