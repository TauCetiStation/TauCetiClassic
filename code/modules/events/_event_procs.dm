/client/proc/forceEvent(var/type in SSevents.allEvents)
	set name = "Trigger Event (Debug Only)"
	set category = "Debug"

	if(!holder || !check_rights(R_DEBUG))
		return

	if(ispath(type))
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])", 1)
		new type(new /datum/event_meta(EVENT_LEVEL_MAJOR, "[type]"))

/client/proc/event_manager_panel()
	set name = "Event Manager Panel"
	set category = "Event"
	if(SSevents)
		SSevents.Interact(usr)
	feedback_add_details("admin_verb","EMP") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return

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
		if(!M.mind || !M.client || M.client.inactivity > 10 MINUTES || isobserver(M)) // longer than 10 minutes AFK counts them as inactive
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

/proc/get_vents()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/temp_vent in machines)
		if(is_station_level(temp_vent.loc.z) && !temp_vent.welded)
			var/datum/pipeline/temp_vent_parent = temp_vent.PARENT1
			//Stops Aliens getting stuck in small networks.
			//See: Security, Virology
			if(temp_vent_parent.other_atmosmch.len > 50)
				vents += temp_vent
	return vents
