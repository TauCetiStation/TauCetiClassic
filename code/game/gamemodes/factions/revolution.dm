#define PERCENT_FOR_OVERTHROW 70

/proc/get_living_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

/datum/faction/revolution
	name = "Revolutionaries"
	ID = F_REVOLUTION
	required_pref = ROLE_REV

	initroletype = /datum/role/rev_leader
	roletype = /datum/role/rev

	min_roles = 2
	max_roles = 2

	logo_state = "rev-logo"

	var/last_command_report = 0
	var/tried_to_add_revheads = 0

	var/type_of_objective = /datum/objective/target/rp_rev

/datum/faction/revolution/proc/get_all_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

/datum/faction/revolution/OnPostSetup()
	if(SSshuttle)
		SSshuttle.fake_recall = TRUE

	return ..()

/datum/faction/revolution/forgeObjectives()
	if(!..())
		return FALSE
	var/list/heads = get_living_heads()

	for(var/datum/mind/head_mind in heads)
		var/datum/objective/target/rev_obj = AppendObjective(type_of_objective, TRUE)
		if(rev_obj)
			rev_obj.target = head_mind
			rev_obj.explanation_text = rev_obj.format_explanation()
	return TRUE

/datum/faction/revolution/proc/check_heads_victory()
	for(var/datum/role/rev_leader/R in members)
		var/turf/T = get_turf(R.antag.current)
		if(R.antag.current.stat != DEAD)
			var/mob/living/carbon/C = R.antag
			if(!C.handcuffed && T && is_station_level(T.z))
				return FALSE
	return TRUE

/datum/faction/revolution/check_win()
	var/win = IsSuccessful()
	if(config.continous_rounds)
		if(win && SSshuttle)
			SSshuttle.fake_recall = FALSE
		return FALSE

	if(win)
		return TRUE
	return FALSE

/datum/faction/revolution/custom_result()
	var/dat = ""
	if(IsSuccessful())
		var/dead_heads = 0
		var/alive_heads = 0
		for(var/datum/mind/head_mind in get_all_heads())
			if(head_mind.current.stat == DEAD)
				dead_heads++
			else
				alive_heads++

		if(alive_heads >= dead_heads)
			dat += "<span class='green'>The heads of staff were overthrown! The revolutionaries win! It's a clear victory!</span>"
			feedback_add_details("[ID]_success","SUCCESS")
			SSStatistics.score.roleswon++
		else
			dat += "<span class='orange'>The heads of staff were overthrown, but many heads died. The revolutionaries win, but lose support.</span>"
			feedback_add_details("[ID]_success","HALF")

	else
		dat += "<span class='red'>The heads of staff managed to stop the revolution!</span>"
		feedback_add_details("[ID]_success","FAIL")
	return dat

/datum/faction/revolution/proc/add_new_objective(mob/M)
	//ApendObjective or handleNewObjective ???
	var/datum/objective/target/rev_obj = AppendObjective(type_of_objective, TRUE)
	if(rev_obj)
		rev_obj.target = M.mind
		rev_obj.explanation_text = rev_obj.format_explanation()
		AnnounceObjectives()

/datum/faction/revolution/latespawn(mob/M)
	if(M.mind.assigned_role in command_positions)
		log_debug("Adding head kill/capture/convert objective for [M.mind.name]")
		add_new_objective(M)

/datum/faction/revolution/proc/add_revhead()
	// only perform rev checks once in a while
	if(tried_to_add_revheads < world.time)
		tried_to_add_revheads = world.time + 5 SECONDS
		var/active_revs = 0
		for(var/datum/role/rev_leader/R in members)
			if(R.antag.current?.client?.inactivity <= 20 MINUTES) // 20 minutes inactivity are OK
				active_revs++

		if(active_revs == 0)
			log_debug("There are zero active heads of revolution, trying to add some..")
			var/added_heads = FALSE
			for(var/mob/living/carbon/human/H as anything in human_list)
				if(H.stat != DEAD && H.mind && H.client?.inactivity <= 20 MINUTES && isrev(H))
					var/datum/role/R = H.mind.GetRole(REV)
					R.Drop(H.mind)
					R = HandleNewMind(H.mind)
					R.OnPostSetup(TRUE)
					added_heads = TRUE
					break

			if(added_heads)
				log_admin("Managed to add new heads of revolution.")
				message_admins("Managed to add new heads of revolution.")
			else
				log_admin("Unable to add new heads of revolution.")
				message_admins("Unable to add new heads of revolution.")
				tried_to_add_revheads = world.time + 10 MINUTES

/datum/faction/revolution/process()
	add_revhead()
	if(last_command_report == 0 && world.time >= 10 MINUTES)
		command_report("We are regrettably announcing that your performance has been disappointing, and we are thus forced to cut down on financial support to your station. To achieve this, the pay of all personnal, except the Heads of Staff, has been halved.")
		last_command_report = 1
		var/list/excluded_rank = list("AI", "Cyborg", "Clown Police", "Internal Affairs Agent")	+ command_positions + security_positions
		for(var/datum/job/J in SSjob.occupations)
			if(J.title in excluded_rank)
				continue
			J.salary_ratio = 0.5	//halve the salary of all professions except leading
		var/list/crew = my_subordinate_staff("Admin")
		for(var/person in crew)
			if(person["rank"] in excluded_rank)
				continue
			var/datum/money_account/account = person["acc_datum"]
			account.change_salary(null, "CentComm", "CentComm", "Admin", force_rate = -50)	//halve the salary of all staff except heads

	else if(last_command_report == 1 && world.time >= 30 MINUTES)
		command_report("Statistics hint that a high amount of leisure time, and associated activities, are responsible for the poor performance of many of our stations. You are to bolt and close down any leisure facilities, such as the holodeck, the theatre and the bar. Food can be distributed through vendors and the kitchen.")
		last_command_report = 2
	else if(last_command_report == 2 && world.time >= 45 MINUTES)
		command_report("We began to suspect that the heads of staff might be disloyal to Nanotrasen. We ask you and other heads to implant the loyalty implant, if you have not already implanted it in yourself. Heads who do not want to implant themselves should be arrested for disobeying the orders of the Central Command until the end of the shift.")
		last_command_report = 3
	else if(last_command_report == 3 && world.time >= 60 MINUTES)
		command_report("It is reported that merely closing down leisure facilities has not been successful. You and your Heads of Staff are to ensure that all crew are working hard, and not wasting time or energy. Any crew caught off duty without leave from their Head of Staff are to be warned, and on repeated offence, to be brigged until the next transfer shuttle arrives, which will take them to facilities where they can be of more use.")
		last_command_report = 4

/datum/faction/revolution/proc/command_report(message)
	for (var/obj/machinery/computer/communications/comm in communications_list)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "Cent. Com. Announcement"
			intercept.info = message
			intercept.update_icon()

			comm.messagetitle.Add("Cent. Com. Announcement")
			comm.messagetext.Add(message)

	announcement_ping.play()

/datum/faction/revolution/build_scorestat()
	var/foecount = 0
	for(var/datum/role/rev_leader/lead in members)
		foecount++
		if (!lead.antag.current)
			SSStatistics.score.opkilled++
			continue
		var/turf/T = lead.antag.current.loc
		if(T)
			if (istype(T.loc, /area/station/security/brig))
				SSStatistics.score.arrested += 1
			else if (lead.antag.current.stat == DEAD)
				SSStatistics.score.opkilled++
	if(foecount == SSStatistics.score.arrested)
		SSStatistics.score.allarrested = 1
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in global.command_positions)
				if (player.stat == DEAD)
					SSStatistics.score.deadcommand++

	var/arrestpoints = SSStatistics.score.arrested * 1000
	var/killpoints = SSStatistics.score.opkilled * 500
	var/comdeadpts = SSStatistics.score.deadcommand * 500
	if (SSStatistics.score.traitorswon)
		SSStatistics.score.crewscore -= 10000
	SSStatistics.score.crewscore += arrestpoints
	SSStatistics.score.crewscore += killpoints
	SSStatistics.score.crewscore -= comdeadpts

/datum/faction/revolution/get_scorestat()
	var/dat = ""
	var/foecount = 0
	var/comcount = 0
	var/revcount = 0
	var/loycount = 0

	for(var/datum/role/rev_leader/lead in members)
		if (lead.antag.current?.stat != DEAD)
			foecount++
	for(var/datum/role/rev/rev in members)
		if (rev.antag.current?.stat != DEAD)
			revcount++

	for(var/mob/living/carbon/human/player as anything in human_list)
		if(!player.mind)
			continue
		var/role = player.mind.assigned_role
		if(role in global.command_positions)
			if(player.stat != DEAD)
				comcount++
		else
			if(isrev(player))
				continue
			loycount++

	var/revpenalty = 10000
	dat += {"<B><U>REVOLUTION STATS</U></B><BR>
	<B>Number of Surviving Revolution Heads:</B> [foecount]<BR>
	<B>Number of Surviving Command Staff:</B> [comcount]<BR>
	<B>Number of Surviving Revolutionaries:</B> [revcount]<BR>
	<B>Number of Surviving Loyal Crew:</B> [loycount]<BR><BR>
	<B>Revolution Heads Arrested:</B> [SSStatistics.score.arrested] ([SSStatistics.score.arrested * 1000] Points)<BR>
	<B>Revolution Heads Slain:</B> [SSStatistics.score.opkilled] ([SSStatistics.score.opkilled * 500] Points)<BR>
	<B>Command Staff Slain:</B> [SSStatistics.score.deadcommand] (-[SSStatistics.score.deadcommand * 500] Points)<BR>
	<B>Revolution Successful:</B> [SSStatistics.score.traitorswon ? "Yes" : "No"] (-[SSStatistics.score.traitorswon * revpenalty] Points)<BR>
	<B>All Revolution Heads Arrested:</B> [SSStatistics.score.allarrested ? "Yes" : "No"] (Score tripled)<BR>"}

	return dat

/datum/faction/revolution/flash_revolution
	name = F_FLASH_REVOLUTION
	ID = F_FLASH_REVOLUTION
	initroletype = /datum/role/rev_leader/flash_rev_leader
	min_roles = 1
	type_of_objective = /datum/objective/target/syndicate_rev
	var/victory_is_near = FALSE
	var/shuttle_timer_started = FALSE

/datum/faction/revolution/flash_revolution/add_new_objective(mob/M)
	//located not on station - you are not a headstuff, goodbye
	var/turf/T = get_turf(M)
	if(T && is_station_level(T.z))
		return ..()

/datum/faction/revolution/flash_revolution/latespawn(mob/M)
	if(M.mind.assigned_role in command_positions)
		//shuttle delay
		addtimer(CALLBACK(src, .proc/add_new_objective, M), 6000)

/datum/faction/revolution/flash_revolution/proc/send_evac_to_centcom()
	if(SSshuttle.online || SSshuttle.departed)
		return
	SSshuttle.incall(1)
	SSshuttle.announce_emer_called.play()
	//lore: CentCom does not expect to save the remaining heads with this shuttle. That one is for civilians workers.
	var/datum/announcement/centcomm/revolution_succesfull/announcement = new
	announcement.play()

/datum/faction/revolution/flash_revolution/IsSuccessful()
	var/all_heads = objective_holder.objectives.len
	if(all_heads <= 0)
		//no heads stuff. Victory?
		return TRUE
	var/heads_overrun = 0
	for(var/datum/objective/objective in GetObjectives())
		if(objective.calculate_completion() != OBJECTIVE_LOSS)
			heads_overrun++
	if(((heads_overrun / all_heads) * 100) > PERCENT_FOR_OVERTHROW)
		return TRUE
	return FALSE

/datum/faction/revolution/flash_revolution/check_win()
	//check half-win revolution
	if(IsSuccessful())
		//create enemies of revolution
		if(!victory_is_near)
			victory_is_near = TRUE
			var/datum/faction/enemy_revs/enemies = create_uniq_faction(/datum/faction/enemy_revs)
			if(!enemies)
				return FALSE
			for(var/mob/living/carbon/human/M in global.player_list)
				if(!considered_alive(M.mind) || M.suiciding)
					continue
				if(!M.mind)
					continue
				if(M.mind.assigned_role in (global.command_positions + global.security_positions))
					add_faction_member(enemies, M)
			//empty faction will be destroyed
			enemies.check_populated()
			return FALSE
		//enemies created, now try finish round
		//call shuttle after few minutes.
		if(!shuttle_timer_started)
			shuttle_timer_started = TRUE
			SSshuttle.fake_recall = FALSE
			addtimer(CALLBACK(src, .proc/send_evac_to_centcom), rand(300, 1200), TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
			return FALSE
		//try to end if revolution already killed all headstuff
		for(var/datum/objective/obj in GetObjectives())
			if(obj.calculate_completion() != OBJECTIVE_WIN)
				return FALSE
			//full-victory of the revolution
			return TRUE
	return FALSE

//I couldn't think of anything better than leaving the current heads count and colorize custom text output
/datum/faction/revolution/flash_revolution/custom_result()
	var/dat = ""
	if(IsSuccessful())
		var/dead_heads = 0
		var/alive_heads = 0
		for(var/datum/mind/head_mind in get_all_heads())
			if(!considered_alive(head_mind))
				dead_heads++
			else
				alive_heads++

		if(alive_heads >= dead_heads)
			dat += "<span class='green'>The heads of staff were overthrown!</span><br>"
			dat += "<span class='green'>The Syndicate extends its influence to the system.</span>"
			feedback_add_details("[ID]_success","SUCCESS")
			SSStatistics.score.roleswon++
		else
			dat += "<span class='orange'>The heads of staff were overthrown, but many heads died.</span><br>"
			dat += "<span class='orange'>The revolutionaries were victorious, but they did not win overt support from the Syndicate.</span>"
			dat += "<span class='orange'>Nanotrasen's battle groups will be sent to the station.</span><br>"
			feedback_add_details("[ID]_success","HALF")

	else
		dat += "<span class='red'>The heads of staff managed to stop the revolution!</span>"
		feedback_add_details("[ID]_success","FAIL")
	return dat

#undef PERCENT_FOR_OVERTHROW
