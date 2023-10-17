/obj/nano_module/crew_monitor
	name = "Crew monitor"
	var/list/tracked = new

/obj/nano_module/crew_monitor/Topic(href, href_list)
	if(..()) return
	var/turf/T = get_turf(src)
	if (!T || !(T.z in SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_MINING))))
		to_chat(usr, "<span class='warning'>Unable to establish a connection</span>: You're too far away from the station!")
		return 0
	if(href_list["close"] )
		var/mob/user = usr
		var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, "main")
		usr.unset_machine()
		ui.close()
		return 0
	if(href_list["update"])
		updateDialog()
		return 1

/obj/nano_module/crew_monitor/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	user.set_machine(src)
	scan()

	var/data[0]
	var/turf/monitor_turf = get_turf(src)
	var/list/crewmembers = list()

	for(var/tracked_atom in tracked)
		var/mob/living/carbon/human/H = null
		var/tracking_sensor = SUIT_SENSOR_TRACKING
		if(isunder(tracked_atom))
			var/obj/item/clothing/under/C = tracked_atom
			if(C.sensor_mode == SUIT_SENSOR_OFF)
				continue
			var/mob/living/carbon/human/who_weared_suit = C.loc
			if(!istype(who_weared_suit))
				continue
			tracking_sensor = C.sensor_mode
			H = who_weared_suit
		else if(ishuman(tracked_atom))
			H = tracked_atom
		var/turf/atom_position = get_turf(H)
		//nullspace? other z-level?
		if(!atom_position || atom_position.z != monitor_turf.z)
			continue

		var/list/crewmemberData = list("dead"=0, "oxy"=-1, "tox"=-1, "fire"=-1, "brute"=-1, "area"="", "x"=-1, "y"=-1)

		crewmemberData["sensor_type"] = tracking_sensor
		crewmemberData["name"] = H.get_authentification_name(if_no_id="Unknown")
		crewmemberData["rank"] = H.get_authentification_rank(if_no_id="Unknown", if_no_job="No Job")
		crewmemberData["assignment"] = H.get_assignment(if_no_id="Unknown", if_no_job="No Job")

		if(tracking_sensor >= SUIT_SENSOR_BINARY)
			crewmemberData["dead"] = H.stat > UNCONSCIOUS

		if(tracking_sensor >= SUIT_SENSOR_VITAL)
			crewmemberData["oxy"] = round(H.getOxyLoss(), 1)
			crewmemberData["tox"] = round(H.getToxLoss(), 1)
			crewmemberData["fire"] = round(H.getFireLoss(), 1)
			crewmemberData["brute"] = round(H.getBruteLoss(), 1)

		if(tracking_sensor >= SUIT_SENSOR_TRACKING)
			var/area/A = get_area(H)
			crewmemberData["area"] = html_encode(A.name)
			crewmemberData["x"] = atom_position.x
			crewmemberData["y"] = atom_position.y

		crewmembers[++crewmembers.len] = crewmemberData

	crewmembers = sortByKey(crewmembers, "name")

	data["crewmembers"] = crewmembers

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "crew_monitor.tmpl", "Crew Monitoring Computer", 900, 600)

		// adding a template with the key "mapContent" enables the map ui functionality
		ui.add_template("mapContent", "crew_monitor_map_content.tmpl")
		// adding a template with the key "mapHeader" replaces the map header content
		ui.add_template("mapHeader", "crew_monitor_map_header.tmpl")

		ui.set_initial_data(data)
		ui.open()

		// should make the UI auto-update; doesn't seem to?
		ui.set_auto_update(1)

/obj/nano_module/crew_monitor/proc/scan()
	for(var/mob/living/carbon/human/H as anything in human_list)
		var/obj/item/clothing/under/C
		if(isunder(H.w_uniform))
			C = H.w_uniform
			if(C.has_sensor)
				tracked |= C
				//remove virus record
				tracked -= H
		if(H in SSmobs.virus_monitored_mobs)
			tracked |= H
			//remove non virus record
			if(C)
				tracked -= C
	return 1
