// verb for admins to set custom event
/client/proc/cmd_admin_change_custom_event()
	set category = "Event"
	set name = "Change Custom Event"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/input = sanitize(input(usr, "Enter the description of the custom event. Be descriptive. To cancel the event, make this blank or hit cancel.", "Custom Event", input_default(SSevents.custom_event_msg)) as message|null, MAX_BOOK_MESSAGE_LEN, extra = FALSE)
	if(!input || input == "")
		SSevents.setup_custom_event(null, null)
		log_admin("[key_name(usr)] has cleared the custom event text.")
		message_admins("[key_name_admin(usr)] has cleared the custom event text.")
		return

	log_admin("[key_name(usr)] has changed the custom event text.")
	message_admins("[key_name_admin(usr)] has changed the custom event text.")

	SSevents.setup_custom_event(input, "Event")

	if(tgui_alert(usr, "Do you want to make an announcement to chat conference?", "Chat announcement", list("Yes", "No, I don't want these people at my party")) == "Yes")
		SSevents.custom_event_announce_bridge()

// normal verb for players to view info
/client/verb/cmd_view_custom_event()
	set category = "OOC"
	set name = "Custom Event Info"

	if(!SSevents.custom_event_msg)
		to_chat(src, "There currently is no known custom event taking place.")
		to_chat(src, "Keep in mind: it is possible that an admin has not properly set this.")
		return

	SSevents.custom_event_announce(src)
