/datum/digital/file/program/filesystem
	name = "Filesystem"
	can_open_type = "Folder"
	fileicon = "folder-open"

	var/show_folder = 0
	var/datum/digital/file/Folder

/datum/digital/file/program/filesystem/New(newtype, newname,  newcontent, newicon, drive, newfolder_id)
	. = ..()

/datum/digital/file/program/filesystem/open(datum/digital/file/File)
	Folder = File
	show_folder = Folder.folder_id

/datum/digital/file/program/filesystem/close()
	show_folder = 0

/datum/digital/file/program/filesystem/process_data(list/data, mob/user)
	var/list/folder_to_front = list()

	for(var/i in Drive.folders[show_folder])
		var/datum/digital/file/File = Drive.filesystem[i]
		folder_to_front += list(list("name" = File.name, "filetype" = filetype, "file_id" = i, "file_icon" = File.fileicon))

	data["folder_files"] = folder_to_front
	data["folder_name"] = Folder.name
	return data

/datum/digital/file/program/filesystem/act(action, list/params, mob/user)
	switch(action)
		if("create_file")
			Drive.add_file(show_folder, name = sanitize(params["file_name"]), filetype = sanitize(params["file_type"]))
			return

		if("delete_file")
			Drive.delete_file(text2num(sanitize(params["file_id"])))
			return

		if("move_file")
			Drive.folders[show_folder] -= text2num(sanitize(params["file_id"]))
			Drive.folders[text2num(sanitize(params["newfolder_id"]))] += text2num(sanitize(params["file_id"]))
			return

		if("open_file")
			Drive.open_file(text2num(sanitize(params["file_id"])))
			return
