/client/proc/forceEvent(var/type in SSevents.allEvents)
	set name = "Trigger Event (Debug Only)"
	set category = "Debug"

	if(!holder)
		return

	if(ispath(type))
		new type(new /datum/event_meta(EVENT_LEVEL_MAJOR))
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])", 1)

/client/proc/event_manager_panel()
	set name = "Event Manager Panel"
	set category = "Event"
	if(SSevents)
		SSevents.Interact(usr)
	feedback_add_details("admin_verb","EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

/proc/findEventArea() //Here's a nice proc to use to find an area for your event to land in!
	var/area/candidate = null

	var/list/safe_areas = list(
	/area/station/aisat,
	/area/station/bridge/ai_upload,
	/area/station/engineering,
	/area/station/solar,
	/area/station/civilian/holodeck,
	/area/shuttle/arrival,
	/area/station/hallway/primary/fore,
	/area/station/hallway/primary/starboard,
	/area/station/hallway/primary/aft,
	/area/station/hallway/primary/port,
	/area/station/hallway/primary/central,
	/area/station/hallway/secondary/exit,
	/area/station/hallway/secondary/entry,
	/area/station/hallway/secondary/Podbay,
	/area/station/security/prison,
	)

	//These are needed because /area/engine has to be removed from the list, but we still want these areas to get fucked up.
	var/list/danger_areas = list(
	/area/station/engineering/break_room,
	/area/station/engineering/chiefs_office)

	var/list/event_areas = list()

	for(var/areapath in the_station_areas)
		event_areas += typesof(areapath)
	for(var/areapath in safe_areas)
		event_areas -= typesof(areapath)
	for(var/areapath in danger_areas)
		event_areas += typesof(areapath)

	while(event_areas.len > 0)
		var/list/event_turfs = null
		candidate = locate(pick_n_take(event_areas))
		event_turfs = get_area_turfs(candidate)
		if(event_turfs.len > 0)
			break

	return candidate

// Returns how many characters are currently active(not logged out, not AFK for more than 10 minutes)
// with a specific role.
// Note that this isn't sorted by department, because e.g. having a roboticist shouldn't make meteors spawn.
/proc/number_active_with_role()
	var/list/active_with_role = list()
	active_with_role["Engineer"] = 0
	active_with_role["Medical"] = 0
	active_with_role["Security"] = 0
	active_with_role["Scientist"] = 0
	active_with_role["AI"] = 0
	active_with_role["Cyborg"] = 0
	active_with_role["Janitor"] = 0
	active_with_role["Botanist"] = 0
	active_with_role["Any"] = player_list.len

	for(var/mob/M in player_list)
		if(!M.mind || !M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue

		to_chat(world, "[M].mind.assigned_role=[M.mind.assigned_role]")
		if(isrobot(M))
			var/mob/living/silicon/robot/R = M
			if(R.module && (R.modtype == "Engineering"))
				active_with_role["Engineer"]++

			if(R.module && (R.modtype in list("Surgeon", "Crisis")))
				active_with_role["Medical"]++

			if(R.module && (R.modtype == "Security"))
				active_with_role["Security"]++
			
			if(R.module && (R.modtype == "Janitor"))
				active_with_role["Janitor"]++

		if(M.mind.assigned_role in list("Chief Engineer", "Station Engineer"))
			active_with_role["Engineer"]++

		if(M.mind.assigned_role in list("Chief Medical Officer", "Medical Doctor"))
			active_with_role["Medical"]++

		if(M.mind.assigned_role in security_positions)
			active_with_role["Security"]++

		if(M.mind.assigned_role in list("Research Director", "Scientist"))
			active_with_role["Scientist"]++

		if(M.mind.assigned_role == "AI")
			active_with_role["AI"]++

		if(M.mind.assigned_role == "Cyborg")
			active_with_role["Cyborg"]++

		if(M.mind.assigned_role == "Janitor")
			active_with_role["Janitor"]++

		if(M.mind.assigned_role == "Botanist")
			active_with_role["Botanist"]++

	return active_with_role

/datum/event/proc/num_players()
	var/players = 0
	for(var/mob/living/carbon/human/P in player_list)
		if(P.client)
			players++
	return players
