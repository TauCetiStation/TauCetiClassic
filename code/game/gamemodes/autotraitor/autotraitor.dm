//This is a beta game mode to test ways to implement an "infinite" traitor round in which more traitors are automatically added in as needed.
//Automatic traitor adding is complete pending the inevitable bug fixes.  Need to add a respawn system to let dead people respawn after 30 minutes or so.


/datum/game_mode/traitor/autotraitor
	name = "AutoTraitor"
	//config_tag = "extend-a-traitormongous"
	config_tag = "autotraitor"
	role_type = ROLE_TRAITOR

	votable = 0

	var/num_players = 0

/datum/game_mode/traitor/autotraitor/announce()
	..()
	to_chat(world, "<B>Game mode is AutoTraitor. Traitors will be added to the round automagically as needed.</B>")


/datum/game_mode/traitor/autotraitor/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)
			if(player.assigned_role == job)
				antag_candidates -= player

	//var/r = rand(5)
	var/num_traitors = 1
	var/max_traitors = 1
	var/traitor_prob = 0
	num_players = num_players()
	max_traitors = round(num_players / 10) + 1
	traitor_prob = (num_players - (max_traitors - 1) * 10) * 10

	// Stop setup if no possible traitors
	if(!antag_candidates.len)
		return 0

	if(config.traitor_scaling)
		num_traitors = max_traitors - 1 + prob(traitor_prob)
		log_game("Number of traitors: [num_traitors]")
		message_admins("Players counted: [num_players]  Number of traitors chosen: [num_traitors]")
	else
		num_traitors = max(1, min(num_players(), traitors_possible))


	for(var/i = 0, i < num_traitors, i++)
		var/datum/mind/traitor = pick(antag_candidates)
		traitors += traitor
		antag_candidates.Remove(traitor)

	for(var/datum/mind/traitor in traitors)
		if(!traitor || !istype(traitor))
			traitors.Remove(traitor)
			continue
		if(istype(traitor))
			traitor.special_role = "traitor"

//	if(!traitors.len)
//		return 0
	return 1




/datum/game_mode/traitor/autotraitor/post_setup()
	abandon_allowed = 1
	return ..()

/datum/game_mode/proc/traitorcheckloop()
	if(SSshuttle.departed)
		return

	if(SSshuttle.online)//shuttle in the way, but may be revoked
		addtimer(CALLBACK(src, .proc/traitorcheckloop), autotraitor_delay)
		return

	//message_admins("Performing AutoTraitor Check")
	var/list/possible_autotraitor = list()
	var/playercount = 0
	var/traitorcount = 0

	for(var/mob/living/player in living_list)
		if (player.client && player.mind && player.stat != DEAD)
			playercount++
			if(player.mind.special_role)
				traitorcount++
			else if((player.client && (ROLE_TRAITOR in player.client.prefs.be_role)) && !jobban_isbanned(player, "Syndicate") && !jobban_isbanned(player, ROLE_TRAITOR) && !role_available_in_minutes(player, ROLE_TRAITOR) && !isloyal(player))
				if(!possible_autotraitor.len || !possible_autotraitor.Find(player))
					possible_autotraitor += player

	for(var/mob/living/player in possible_autotraitor)
		if(!player.mind || !player.client)
			possible_autotraitor -= player
			continue
		for(var/job in restricted_jobs_autotraitor)
			if(player.mind.assigned_role == job)
				possible_autotraitor -= player

	//message_admins("Live Players: [playercount]")
	//message_admins("Live Traitors: [traitorcount]")
//		message_admins("Potential Traitors:")
//		for(var/mob/living/traitorlist in possible_autotraitor)
//			message_admins("[traitorlist.real_name]")

//		var/r = rand(5)
//		var/target_traitors = 1
	var/max_traitors = 1
	var/traitor_prob = 0
	max_traitors = round(playercount / 10) + 1
	traitor_prob = (playercount - (max_traitors - 1) * 10) * 5
	if(traitorcount < max_traitors - 1)
		traitor_prob += 50

	if(traitorcount < max_traitors)
		//message_admins("Number of Traitors is below maximum.  Rolling for new Traitor.")
		//message_admins("The probability of a new traitor is [traitor_prob]%")

		if(prob(traitor_prob))
			message_admins("Making a new Traitor.")
			if(!possible_autotraitor.len)
				message_admins("No potential traitors.  Cancelling new traitor.")
				addtimer(CALLBACK(src, .proc/traitorcheckloop), autotraitor_delay)
				return
			var/mob/living/newtraitor = pick(possible_autotraitor)
			//message_admins("[newtraitor.real_name] is the new Traitor.")

			if (!config.objectives_disabled)
				forge_traitor_objectives(newtraitor.mind)

			if(istype(newtraitor, /mob/living/silicon))
				add_law_zero(newtraitor)
			else
				equip_traitor(newtraitor)

			traitors += newtraitor.mind
			to_chat(newtraitor, "<span class='warning'><B>ATTENTION:</B></span> It is time to pay your debt to the Syndicate...")
			to_chat(newtraitor, "<B>You are now a traitor.</B>")
			newtraitor.mind.special_role = "traitor"
			newtraitor.hud_updateflag |= 1 << SPECIALROLE_HUD
			var/obj_count = 1
			to_chat(newtraitor, "<span class='notice'>Your current objectives:</span>")
			if(!config.objectives_disabled)
				for(var/datum/objective/objective in newtraitor.mind.objectives)
					to_chat(newtraitor, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
					obj_count++
			else
				to_chat(newtraitor, "<i>You have been selected this round as an antagonist- <font color=blue>Within the rules,</font> try to act as an opposing force to the crew- This can be via corporate payoff, personal motives, or maybe just being a dick. Further RP and try to make sure other players have </i>fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonist.</i></b>")
		//else
			//message_admins("No new traitor being added.")
	//else
		//message_admins("Number of Traitors is at maximum.  Not making a new Traitor.")

	addtimer(CALLBACK(src, .proc/traitorcheckloop), autotraitor_delay)



/datum/game_mode/traitor/autotraitor/latespawn(mob/living/carbon/human/character)
	..()
	if(SSshuttle.departed || SSshuttle.online)
		return

	for(var/job in restricted_jobs)
		if(character.mind.assigned_role == job)
			return
	//message_admins("Late Join Check")
	if((character.client && (ROLE_TRAITOR in character.client.prefs.be_role)) && !jobban_isbanned(character, "Syndicate") \
	 && !jobban_isbanned(character, ROLE_TRAITOR) && !role_available_in_minutes(character, ROLE_TRAITOR) && isloyal(character, FALSE))
		//message_admins("Late Joiner has Be Syndicate")
		//message_admins("Checking number of players")
		var/playercount = 0
		var/traitorcount = 0
		for(var/mob/living/player in living_list)

			if (player.client && player.mind && player.stat != DEAD)
				playercount += 1
				if(player.mind.special_role)
					traitorcount += 1
		//message_admins("Live Players: [playercount]")
		//message_admins("Live Traitors: [traitorcount]")

		//var/r = rand(5)
		//var/target_traitors = 1
		var/max_traitors = 2
		var/traitor_prob = 0
		max_traitors = round(playercount / 10) + 1
		traitor_prob = (playercount - (max_traitors - 1) * 10) * 5
		if(traitorcount < max_traitors - 1)
			traitor_prob += 50

		//target_traitors = max(1, min(round((playercount + r) / 10, 1), traitors_possible))
		//message_admins("Target Traitor Count is: [target_traitors]")
		if (traitorcount < max_traitors)
			//message_admins("Number of Traitors is below maximum.  Rolling for New Arrival Traitor.")
			//message_admins("The probability of a new traitor is [traitor_prob]%")
			if(prob(traitor_prob))
				message_admins("New traitor roll passed.  Making a new Traitor.")
				if (!config.objectives_disabled)
					forge_traitor_objectives(character.mind)
				equip_traitor(character)
				traitors += character.mind
				to_chat(character, "<span class='warning'><B>You are the traitor.</B></span>")
				character.mind.special_role = "traitor"
				if (config.objectives_disabled)
					to_chat(character, "<i>You have been selected this round as an antagonist- <font color=blue>Within the rules,</font> try to act as an opposing force to the crew- This can be via corporate payoff, personal motives, or maybe just being a dick. Further RP and try to make sure other players have </i>fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonist.</i></b>")
				else
					var/obj_count = 1
					to_chat(character, "<span class='notice'>Your current objectives:</span>")
					for(var/datum/objective/objective in character.mind.objectives)
						to_chat(character, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
						obj_count++
			//else
				//message_admins("New traitor roll failed.  No new traitor.")
	//else
		//message_admins("Late Joiner does not have Be Syndicate")
