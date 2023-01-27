/datum/digital/file/program/ntpict
	name = "NTPict"
	fileicon = "image"
	can_open_type = "Image"

	var/datum/digital/file/show_file

/datum/digital/file/program/ntpict/New(newtype, newname,  newcontent, newicon, drive, newfolder_id)
	. = ..()

/datum/digital/file/program/ntpict/open(datum/digital/file/File)
	if(File)
		show_file = File

/datum/digital/file/program/ntpict/close()
	show_file = null

/datum/digital/file/program/ntpict/process_data(list/data, mob/user)
	if(show_file)
		data["file_name"] = show_file.name
		user << browse_rsc(show_file.content["img"], "tmp_photo.png")
		data["file_content"] = show_file.content
	else
		data["file_name"] = null
		data["file_content"] = null

	return data

/datum/digital/file/program/ntpict/act(action, list/params, mob/user)
	return