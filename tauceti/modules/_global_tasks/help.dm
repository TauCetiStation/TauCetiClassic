//analog /proc/number_active_with_role(role) from event_dinamic.dm, i just don't want to touch the original
/proc/gtActiveWithRole(role)
	var/list/active_with_role = list()
	active_with_role["Engineer"] = 0
	active_with_role["Medical"] = 0
	active_with_role["Security"] = 0
	active_with_role["Scientist"] = 0
	active_with_role["AI"] = 0
	active_with_role["Cyborg"] = 0
	active_with_role["Janitor"] = 0
	active_with_role["Botanist"] = 0

	active_with_role["Senior head"] = 0
	active_with_role["Cargo"] = 0
	active_with_role["Assistant"] = 0
	active_with_role["Badass"] = 0

	for(var/mob/M in player_list)
		if(!M.mind || !M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue

		if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "engineering robot module")
			active_with_role["Engineer"]++
		if(M.mind.assigned_role in list("Chief Engineer", "Station Engineer"))
			active_with_role["Engineer"]++

		if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "medical robot module")
			active_with_role["Medical"]++
		if(M.mind.assigned_role in list("Chief Medical Officer", "Medical Doctor"))
			active_with_role["Medical"]++

		if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "security robot module")
			active_with_role["Security"]++
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

		if(istype(M, /mob/living/silicon/robot) && M:module && M:module.name == "miner robot module")
			active_with_role["Cargo"]++

		if(M.mind.assigned_role in list("Quartermaster", "Shaft Miner", "Cargo Technician"))
			active_with_role["Cargo"]++

		if(M.mind.assigned_role == "Assistant")
			active_with_role["Assistant"]++

		if(M.mind.assigned_role in list("Mime", "Clown"))
			active_with_role["Badass"]++

		if(M.mind.assigned_role in list("Captain", "Head of Personnel", "AI"))
			active_with_role["Senior head"]++

	return active_with_role

