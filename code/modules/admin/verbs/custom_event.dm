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

/client/proc/stationdebt_change()
	set category = "Event"
	set name = "CHANGE STATION DEBT"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/amount =  input("Enter new debt. Enter 0 to abort","new debt",0) as num
	if(!amount || amount == 0)
		return


	global.station_debt_cost = amount
	log_admin("[key_name(usr)] changed station debt to [amount].")
	message_admins("[key_name_admin(usr)] changed station debt to [amount].")

/client/proc/stationdebt_announce()
	set category = "Event"
	set name = "ANNOUNCE STATION DEBT"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return

	var/result = global.station_debt_cost - global.donkandco_balance_sold

	log_admin("[key_name(usr)] announced station debt.")
	message_admins("[key_name_admin(usr)] announced station debt.")
	to_chat(world, "<h2 style='text-color:#A50400\'>Текущий долг станции: [result] кредитов.</h2>")

// normal verb for players to view info
/client/verb/cmd_view_custom_event()
	set category = "OOC"
	set name = "Custom Event Info"

	if(!SSevents.custom_event_msg)
		to_chat(src, "There currently is no known custom event taking place.")
		to_chat(src, "Keep in mind: it is possible that an admin has not properly set this.")
		return

	SSevents.custom_event_announce(src)
