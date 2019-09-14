// BS12's less violent revolution mode

/datum/game_mode/revolution/rp_revolution
	name = "rp-revolution"
	config_tag = "rp-revolution"
	role_type = ROLE_REV
	required_players = 4
	required_players_secret = 15
	required_enemies = 2
	recommended_enemies = 2

	votable = 0

	uplink_welcome = "AntagCorp Uplink Console:"
	uplink_uses = 14

	newscaster_announcements = /datum/news_announcement/revolution_inciting_event

	var/last_command_report = 0
	var/list/heads = list()
	var/tried_to_add_revheads = 0

///////////////////////////////////////////////////////////////////////////////
//Gets the round setup, cancelling if there's not enough players at the start//
///////////////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/rp_revolution/pre_setup()

	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	max_headrevs = 2
	recommended_enemies = max_headrevs

	var/head_check = 0
	for(var/mob/dead/new_player/player in player_list)
		if(player.mind.assigned_role in command_positions)
			head_check = 1
			break

	for(var/datum/mind/player in antag_candidates)
		for(var/job in restricted_jobs)//Removing heads and such from the list
			if(player.assigned_role == job)
				antag_candidates -= player

	for (var/i=1 to max_headrevs)
		if (antag_candidates.len==0)
			break
		var/datum/mind/lenin = pick(antag_candidates)	//>lenin LMAO
		antag_candidates -= lenin
		head_revolutionaries += lenin

	if((head_revolutionaries.len==0)||(!head_check))
		return 0

	return 1


/datum/game_mode/revolution/rp_revolution/post_setup()
	heads = get_living_heads()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		if(!config.objectives_disabled)
			for(var/datum/mind/head_mind in heads)
				var/datum/objective/mutiny/rp/rev_obj = new
				rev_obj.owner = rev_mind
				rev_obj.target = head_mind
				rev_obj.explanation_text = "Assassinate, convert or capture [head_mind.name], the [head_mind.assigned_role]."
				rev_mind.objectives += rev_obj

		update_all_rev_icons()

	for(var/datum/mind/rev_mind in head_revolutionaries)
		greet_revolutionary(rev_mind)
		equip_traitor(rev_mind.current, 1) //changing how revs get assigned their uplink so they can get PDA uplinks. --NEO

	modePlayer += head_revolutionaries
	return ..()

/datum/game_mode/revolution/rp_revolution/greet_revolutionary(datum/mind/rev_mind, you_are=1)
	var/obj_count = 1
	if (you_are)
		to_chat(rev_mind.current, "<span class='notice'>You are a member of the revolutionaries' leadership!</span>")
	if(!config.objectives_disabled)
		for(var/datum/objective/objective in rev_mind.objectives)
			to_chat(rev_mind.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			rev_mind.special_role = "Head Revolutionary"
			obj_count++
	else
		to_chat(rev_mind.current, "<font color=blue>Within the rules,</font> try to act as an opposing force to the crew. Further RP and try to make sure other players have fun<i>! If you are confused or at a loss, always adminhelp, and before taking extreme actions, please try to also contact the administration! Think through your actions and make the roleplay immersive! <b>Please remember all rules aside from those without explicit exceptions apply to antagonists.</i></b>")

	// Show each head revolutionary up to 3 candidates
	var/list/already_considered = list()
	for(var/i = 0, i < 2, i++)
		var/mob/rev_mob = rev_mind.current
		already_considered += rev_mob
		// Tell them about people they might want to contact.
		var/mob/living/carbon/human/M = get_nt_opposed()
		if(M && !(M.mind in head_revolutionaries) && !(M in already_considered))
			to_chat(rev_mob, "We have received credible reports that [M.real_name] might be willing to help our cause. If you need assistance, consider contacting them.")
			rev_mob.mind.store_memory("<b>Potential Collaborator</b>: [M.real_name]")

/////////////////////////////
//Checks for a head victory//
/////////////////////////////
/datum/game_mode/revolution/rp_revolution/check_heads_victory()
	for(var/datum/mind/rev_mind in head_revolutionaries)
		var/turf/T = get_turf(rev_mind.current)
		if(rev_mind.current.stat != DEAD)
			// TODO: add a similar check that also checks whether they're without ID in the brig..
			//       probably wanna export this stuff into a separate function for use by both
			//       revs and heads
			//assume that only carbon mobs can become rev heads for now
			if(!rev_mind.current:handcuffed && T && is_station_level(T.z))
				return 0
	return 1

///////////////////////////
//Announces the game type//
///////////////////////////
/datum/game_mode/revolution/rp_revolution/announce()
	to_chat(world, "<B>The current game mode is - Revolution!</B>")
	to_chat(world, "<B>Some crewmembers are attempting to start a revolution!</B>")


//////////////////////////////////////////////////////////////////////
//Announces the end of the game with all relavent information stated//
//////////////////////////////////////////////////////////////////////
/datum/game_mode/revolution/rp_revolution/declare_completion()
	completion_text += "<h3>RP-revolution mode resume:</h3>"
	if(!config.objectives_disabled)
		if(finished == 1)
			mode_result = "win - heads overthrown"
			feedback_set_details("round_end_result",mode_result)
			completion_text += "<span style='color: red; font-weight: bold;'>The heads of staff were overthrown! The revolutionaries win!</span>"
			score["traitorswon"]++
		else if(finished == 2)
			mode_result = "loss - revolution stopped"
			feedback_set_details("round_end_result",mode_result)
			completion_text += "<span style='color: red; font-weight: bold;'>The heads of staff managed to stop the revolution!</span>"
	..()
	return 1
/datum/game_mode/revolution/rp_revolution/process()
	// only perform rev checks once in a while
	if(tried_to_add_revheads < world.time)
		tried_to_add_revheads = world.time+50
		var/active_revs = 0
		for(var/datum/mind/rev_mind in head_revolutionaries)
			if(rev_mind.current && rev_mind.current.client && rev_mind.current.client.inactivity <= 10*60*20) // 20 minutes inactivity are OK
				active_revs++

		if(active_revs == 0)
			log_debug("There are zero active heads of revolution, trying to add some..")
			var/added_heads = 0
			for(var/mob/living/carbon/human/H in human_list) if(H.stat != DEAD && H.client && H.mind && H.client.inactivity <= 10*60*20 && !(H.mind.assigned_role in command_positions) && (ROLE_REV in H.client.prefs.be_role))
				head_revolutionaries += H.mind
				for(var/datum/mind/head_mind in heads)
					var/datum/objective/mutiny/rp/rev_obj = new
					rev_obj.owner = H.mind
					rev_obj.target = head_mind
					rev_obj.explanation_text = "Assassinate or capture [head_mind.name], the [head_mind.assigned_role]."
					H.mind.objectives += rev_obj

				update_all_rev_icons()

				to_chat(H, "<span class='warning'>You are a member of the revolutionaries' leadership!</span>")
				added_heads = 1
				break

			if(added_heads)
				log_admin("Managed to add new heads of revolution.")
				message_admins("Managed to add new heads of revolution.")
			else
				log_admin("Unable to add new heads of revolution.")
				message_admins("Unable to add new heads of revolution.")
				tried_to_add_revheads = world.time + 6000 // wait 10 minutes

	if(last_command_report == 0 && world.time >= 10 * 60 * 10)
		src.command_report("We are regrettably announcing that your performance has been disappointing, and we are thus forced to cut down on financial support to your station. To achieve this, the pay of all personnal, except the Heads of Staff, has been halved.")
		last_command_report = 1
	else if(last_command_report == 1 && world.time >= 10 * 60 * 30)
		src.command_report("Statistics hint that a high amount of leisure time, and associated activities, are responsible for the poor performance of many of our stations. You are to bolt and close down any leisure facilities, such as the holodeck, the theatre and the bar. Food can be distributed through vendors and the kitchen.")
		last_command_report = 2
	else if(last_command_report == 2 && world.time >= 10 * 60 * 60)
		src.command_report("It is reported that merely closing down leisure facilities has not been successful. You and your Heads of Staff are to ensure that all crew are working hard, and not wasting time or energy. Any crew caught off duty without leave from their Head of Staff are to be warned, and on repeated offence, to be brigged until the next transfer shuttle arrives, which will take them to facilities where they can be of more use.")
		last_command_report = 3

	return ..()

/datum/game_mode/revolution/rp_revolution/proc/command_report(message)
	for (var/obj/machinery/computer/communications/comm in communications_list)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "Cent. Com. Announcement"
			intercept.info = message
			intercept.update_icon()

			comm.messagetitle.Add("Cent. Com. Announcement")
			comm.messagetext.Add(message)

	station_announce(sound = "commandreport")

/datum/game_mode/revolution/rp_revolution/latespawn(mob/M)
	if(M.mind.assigned_role in command_positions)
		log_debug("Adding head kill/capture/convert objective for [M.name]")
		heads += M

		for(var/datum/mind/rev_mind in head_revolutionaries)
			var/datum/objective/mutiny/rp/rev_obj = new
			rev_obj.owner = rev_mind
			rev_obj.target = M.mind
			rev_obj.explanation_text = "Assassinate, convert or capture [M.real_name], the [M.mind.assigned_role]."
			rev_mind.objectives += rev_obj
			to_chat(rev_mind.current, "<span class='warning'>A new Head of Staff, [M.real_name], the [M.mind.assigned_role] has appeared. Your objectives have been updated.</span>")
