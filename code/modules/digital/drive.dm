/datum/digital/file
	var/name = ""
	var/filetype = "" //"Folder"(system type, do not use), "Document", "Image", "Program"
	var/list/content = list()
	var/fileicon = "folder-open"
	var/folder_id = 0

	var/obj/item/weapon/drive/Drive

/datum/digital/file/New(newtype, newname,  newcontent, newicon, drive, newfolder_id)
	if(newname)
		src.name = newname
	if(newcontent)
		src.content = newcontent
	if(newicon)
		src.fileicon = newicon

	src.folder_id = newfolder_id
	src.filetype = newtype
	src.Drive = drive
	return src

/datum/digital/file/proc/copy(datum/digital/file/Copyfile)
	src.name = Copyfile.name
	src.filetype = Copyfile.filetype
	src.content = Copyfile.content



/datum/digital/file/program
	name = ""
	filetype = "Program"
	fileicon = "Program_FileIcon"

	var/can_open_type = ""

/datum/digital/file/program/New()
	. = ..()
	return src

/datum/digital/file/program/proc/open()
	return

/datum/digital/file/program/proc/close()
	return

/datum/digital/file/program/proc/process_data(list/data, mob/user)
	return data

/datum/digital/file/program/proc/act(action, list/params, mob/user)
	return




/obj/item/weapon/drive
	name = "Drive"
	desc = "Stores information"
	icon = 'icons/obj/machines/computers.dmi'
	icon_state = "drive"
	w_class = SIZE_MINUSCULE

	var/list/filesystem = list()
	var/filesystem_storage = 10

	var/list/folders = list(list()) //1 = Desktop
	var/list/filetype_to_program = list()

/obj/item/weapon/drive/atom_init()
	. = ..()

	filesystem.len = filesystem_storage

	add_file(2, "Стандартные", filetype = "Folder")

	add_file(0, path = /datum/digital/file/program/filesystem)
	add_file(2, path = /datum/digital/file/program/ntdocs)
	add_file(2, path = /datum/digital/file/program/ntpict)

/obj/item/weapon/drive/proc/add_file(folder_id, filename, filecontent, path, filetype)
	if(!path)
		path = /datum/digital/file
	if(!filetype)
		filetype = "Program"

	for(var/i = 1, i < filesystem_storage, i++)
		if(!filesystem[i])
			filesystem[i] = new path(newtype = filetype, newfolder_id = folder_id, drive = src)
			if(folder_id)
				if(folder_id > folders.len)
					folders += list(list())
					folders[1] += i
				else
					folders[folder_id] += i

			var/datum/digital/file/File = filesystem[i]

			if(filetype == "Program")
				var/datum/digital/file/program/Prog = File
				if(Prog.can_open_type != "")
					filetype_to_program[Prog.can_open_type] = i
			else
				File.name = filename
				File.content = filecontent
				switch(filetype)
					if("Folder")
						File.fileicon = "folder-open"
					if("Document")
						File.fileicon = "file-word"
					if("Image")
						File.fileicon = "file-image"
			return TRUE
	return FALSE

/obj/item/weapon/drive/proc/open_file(file_id)
	var/datum/digital/file/File = filesystem[file_id]
	var/datum/digital/file/program/App

	if(File.filetype == "Program")
		App = File
		App.open()
	else
		var/datum/digital/file/program/Program_to_Open = filesystem[filetype_to_program[File.filetype]]
		App = Program_to_Open
		App.open(File)

	return App

/obj/item/weapon/drive/proc/delete_file(file_id)
	var/datum/digital/file/File = filesystem[file_id]

	folders[File.folder_id] -= file_id
	filesystem -= File
	if(File.filetype == "Program")
		var/datum/digital/file/program/Prog = File
		if(Prog.can_open_type)
			filetype_to_program -= Prog.can_open_type

/obj/item/weapon/drive/hard
	name = "Hard Drive"
	desc = "Stores information"
	icon_state = "hard_drive"
	w_class = SIZE_SMALL
	m_amt = 150
	g_amt = 0

	filesystem_storage = 50

/obj/item/weapon/drive/disk
	name = "Disk Drive"
	desc = "Wow. Is that a save icon?"
	icon_state = "disk_drive"
	w_class = SIZE_TINY
	m_amt = 30
	g_amt = 0

	filesystem_storage = 15
