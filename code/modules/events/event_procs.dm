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

/datum/event/proc/findEventArea()
	var/static/list/allowed_areas
	if(!allowed_areas)
		//Places that shouldn't explode
		var/list/safe_area_types = list(
			/area/station/ai_monitored/storage_secure,
			/area/station/aisat/ai_chamber,
			/area/station/bridge/ai_upload,
			/area/station/engineering/engine,
			/area/station/engineering/singularity,
			/area/station/engineering/atmos) + typesof(/area/station/solar) + typesof(/area/station/civilian/holodeck)

		//Subtypes from the above that actually should explode.
		var/list/unsafe_area_subtypes = list(
			/area/station/engineering/break_room
			)

		allowed_areas = subtypesof(/area/station) - safe_area_types + unsafe_area_subtypes

	var/list/world_areas = list()
	var/list/possible_areas = list()
	for(var/area/A in world)
		world_areas.Add(A)

	for(var/area/A in allowed_areas)
		if(world_areas[A])
			possible_areas.Add(A)
	if(length(possible_areas))
		return pick(possible_areas)

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
		if(!M.mind || !M.client || M.client.inactivity > 10 MINUTES) // longer than 10 minutes AFK counts them as inactive
			continue

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

		if(M.mind.assigned_role in list("Head of Security",	"Warden", "Detective", "Security Officer", "Forensic Technician"))
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
