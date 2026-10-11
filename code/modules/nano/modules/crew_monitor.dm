/obj/crew_monitor_module
	name = "Crew monitor"
	flags = ABSTRACT
	var/list/tracked = new

/obj/crew_monitor_module/tgui_host(mob/user)
	return loc

/obj/crew_monitor_module/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CrewMonitor", "Crew Monitoring Computer")
		ui.open()

/obj/crew_monitor_module/tgui_data(mob/user)
	scan()
	var/list/data = list()
	var/turf/monitor_turf = get_turf(src)
	var/list/crewmembers = list()

	var/list/available_z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_STATION, ZTRAIT_MINING))
	available_z_levels.Add(monitor_turf.z)

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
		if(!atom_position || !available_z_levels.Find(atom_position.z))
			continue

		var/list/crewmemberData = list("dead"=FALSE)

		crewmemberData["sensorType"] = tracking_sensor
		crewmemberData["name"] = H.get_authentification_name(if_no_id="Unknown")
		crewmemberData["rank"] = H.get_authentification_rank(if_no_id="Unknown", if_no_job="No Job")
		crewmemberData["assignment"] = H.get_assignment(if_no_id="Unknown", if_no_job="No Job")
		crewmemberData["ref"] = "\ref[H]"

		if(tracking_sensor >= SUIT_SENSOR_BINARY)
			crewmemberData["dead"] = H.stat > UNCONSCIOUS

		if(tracking_sensor >= SUIT_SENSOR_VITAL)
			crewmemberData["vitals"] = list(
				"oxy" = round(H.getOxyLoss(), 1),
				"tox" = round(H.getToxLoss(), 1),
				"fire" = round(H.getFireLoss(), 1),
				"brute" = round(H.getBruteLoss(), 1)
			)

		if(tracking_sensor >= SUIT_SENSOR_TRACKING)
			var/area/A = get_area(H)
			crewmemberData["position"] = list(
				"area" = html_decode(A.name),
				"x" = atom_position.x,
				"y" = atom_position.y,
				"z" = atom_position.z
			)

		crewmembers[++crewmembers.len] = crewmemberData


	data["crewMembers"] = crewmembers

	data["currentZ"] = monitor_turf.z

	return data

/obj/crew_monitor_module/tgui_static_data(mob/user)
	var/list/data = list()
	data["nanomapPayload"] = SSmapping.tgui_nanomap_payload()
	return data

/obj/crew_monitor_module/proc/scan()
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
