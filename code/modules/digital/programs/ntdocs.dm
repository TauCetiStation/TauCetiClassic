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
	if(show_file)
		data["file_name"] = show_file.name
		data["file_content"] = show_file.content
	else
		data["file_content"] = null

	return data

/datum/digital/file/program/ntdocs/act(action, list/params, mob/user)
	return