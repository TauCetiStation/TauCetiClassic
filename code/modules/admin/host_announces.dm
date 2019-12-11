/client/proc/host_announces()
	set name = "Host Announces"
	set desc = "Edit or make new sticky server announce"
	set category = "Server"

	var/folder = "data/announces/"
	var/edit_path
	
	var/choice = alert("You want to edit existent announce or create new?", "Host Announces", "New", "Edit", "Reload", "Cancel")

	if(choice == "Cancel")
		return

	if(choice == "Reload")
		world.load_host_announces()
		log_admin("[key_name(usr)] reloaded host announces")
		message_admins("<span class='notice'>[key_name(usr)] reloaded host announces</span>")
		return

	if(choice == "Edit")
		edit_path = browse_files("folder")

		if(!edit_path)
			to_chat(usr, "<span class='warning'>No existent announces or you have not chosen any.</span>")
			return

	else
		var/name = reject_bad_text(input("Enter short english name for file", "Name") as null|text, 25)
		
		if(!name)
			to_chat(usr, "<span class='warning'>Bad name.</span>")
			return

		edit_path = "[folder][name].htm"

	var/announce = sanitize(input("Edit announce [edit_path] (leave blank to cancel or delete).\nNo HTML allowed from ingame edit.", "Edit Host Announce", file2text(edit_path)) as null|message, max_length = 10000, extra = FALSE)

	if(!announce)
		choice = alert("Empty text. Cancel edit or delete announce?", "Host Announces", "Cancel", "Delete")
		if(choice == "Cancel")
			to_chat(usr, "<span class='warning'>No changes have been made.</span>")
			return
		else
			log_admin("[key_name(usr)] deleted [edit_path] announce")
			message_admins("<span class='notice'>[key_name(usr)] deleted [edit_path] announce</span>")
			fdel(edit_path)
			return

	fdel(edit_path)
	text2file(announce, edit_path)
	log_admin("[key_name(usr)] changed [edit_path] announce")
	message_admins("<span class='notice'>[key_name(usr)] changed [edit_path] announce</span>")