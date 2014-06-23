var/list/admin_verbs_event = list(
	/client/proc/event_map_loader,
	/client/proc/gateway_fix,
	/client/proc/Noir_anomaly
	)

/client/proc/event_map_loader()
	set category = "Event"
	set name = "Event map loader"
	if(!check_rights(R_PERMISSIONS))	return

	var/list/AllowedMaps = list()

	var/list/Lines = file2list("tauceti/maps/event_maps/event_map_list.txt")
	if(!Lines.len)	return
	for (var/t in Lines)
		if (!t)
			continue
		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue
		var/pos = findtext(t, " ")
		var/name = null
		if (pos)
            // No, don't do lowertext here, that breaks paths on linux
			name = copytext(t, 1, pos)
		//	value = copytext(t, pos + 1)
		else
            // No, don't do lowertext here, that breaks paths on linux
			name = t
		if (!name)
			continue

		AllowedMaps.Add(name)


	AllowedMaps += "--CANCEL--"

	var/choice = input("Select a map", , "CANCEL") in AllowedMaps
	if(choice == "--CANCEL--") return

	message_admins("[key_name_admin(src)] started loading event-map [choice]", 1)
	log_admin("[key_name_admin(src)] started loading event-map [choice]", 1)

	var/file = file(choice)
	if(isfile(file))
		maploader.load_map(file, load_speed = 100)

	message_admins("[key_name_admin(src)] loaded event-map [choice], zlevel [world.maxz]", 1)
	log_admin("[key_name_admin(src)] loaded event-map [choice], zlevel [world.maxz]", 1)

/client/proc/Noir_anomaly()
	set category = "Event"
	set name = "Noir event(in dev!)"
	if(!check_rights(R_PERMISSIONS))	return

	if(alert("Are you really sure?",,"Yes","No") != "Yes")
		return

	for(var/atom/O in world)
		if(O.icon)
			if(O.color)
				O.color = null

			var/icon/newIcon = icon(O.icon)
			newIcon.GrayScale()
			O.icon = newIcon

	log_admin("[key_name(src)] started noir event!", 1)
	message_admins("\blue [key_name_admin(src)] started noir event!", 1)

/client/proc/gateway_fix()
	set category = "Event"
	set name = "Connect Gateways"

	if(!check_rights(R_FUN))	return

	for(var/obj/machinery/gateway/G in world)
		G.initialize()

	log_admin("[key_name(src)] connected gates", 1)
	message_admins("\blue [key_name_admin(src)] connected gates", 1)