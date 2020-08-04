/client/proc/host_announcements()
	set name = "Host Announcements"
	set desc = "Edit or make new sticky server announcement"
	set category = "Server"

	var/folder = "data/announcements/"
	var/edit_path
	
	var/choice = alert("Do you want to edit an existent announcement or create a new one?", "Host Announcement", "New", "Edit", "Reload", "Cancel")

	if(choice == "Cancel")
		return

	if(choice == "Reload")
		world.load_host_announcements()
		log_admin("[key_name(usr)] reloaded host announcements")
		message_admins("<span class='notice'>[key_name(usr)] reloaded host announcements</span>")
		return

	if(choice == "Edit")
		edit_path = browse_files(folder, valid_extensions = list("htm"))

		if(!edit_path)
			to_chat(usr, "<span class='warning'>No existent announcement or you have not chosen any.</span>")
			return

	else
		var/name = ckey(input("Enter short english name for file", "Name") as null|text)
		
		if(!name)
			to_chat(usr, "<span class='warning'>Bad name.</span>")
			return

		edit_path = "[folder][name].htm"

	var/announcement = sanitize(input("Edit announcement [edit_path] (leave blank to cancel or delete).\nNo HTML allowed from ingame edit.", "Edit Host Announcement", file2text(edit_path)) as null|message, max_length = 10000, extra = FALSE)

	if(!announcement)
		choice = alert("Empty text. Cancel edit or delete announcement?", "Host Announcement", "Cancel", "Delete")
		if(choice == "Cancel")
			to_chat(usr, "<span class='warning'>No changes have been made.</span>")
			return
		else
			log_admin("[key_name(usr)] deleted [edit_path] announcement")
			message_admins("<span class='notice'>[key_name(usr)] deleted [edit_path] announcement</span>")
			fdel(edit_path)
			return

	fdel(edit_path)
	text2file(announcement, edit_path)
	log_admin("[key_name(usr)] changed [edit_path] announcement")
	message_admins("<span class='notice'>[key_name(usr)] changed [edit_path] announcement</span>")
