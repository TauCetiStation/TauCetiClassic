/proc/get_living_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player in human_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

/datum/faction/revolution
	name = "Revolutionaries"
	ID = REVOLUTION
	required_pref = ROLE_REV
	initial_role = HEADREV
	late_role = REV
	desc = "Viva!"
	logo_state = "rev-logo"
	initroletype = /datum/role/syndicate/rev_leader
	roletype = /datum/role/rev

	max_roles = 3

	var/checkwin_counter = 0
	var/last_command_report = 0
	var/tried_to_add_revheads = 0

/datum/faction/revolution/proc/get_all_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player in human_list)
		if(player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

/datum/faction/revolution/OnPostSetup()
	var/list/heads = get_living_heads()

	for(var/datum/mind/head_mind in heads)
		var/datum/objective/rp_rev/rev_obj = AppendObjective(/datum/objective/rp_rev, TRUE)
		rev_obj.target = head_mind
		rev_obj.explanation_text = "Capture, convert or exile from station [head_mind.name], the [head_mind.assigned_role]. Assassinate if you have no choice."

	if(SSshuttle)
		SSshuttle.always_fake_recall = TRUE

	return ..()

/datum/faction/revolution/proc/check_heads_victory()
	for(var/datum/role/syndicate/rev_leader/R in members)
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
			SSshuttle.always_fake_recall = FALSE
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
			dat += "<span style='color: green; font-weight: bold;'>The heads of staff were overthrown! The revolutionaries win! It's a clear victory!</span>"
			feedback_add_details("[ID]_success","SUCCESS")
			score["roleswon"]++
		else
			dat += "<span style='color: orange; font-weight: bold;'>The heads of staff were overthrown, but many heads died. The revolutionaries win, but lose support.</span>"
			feedback_add_details("[ID]_success","MINOR_VICTORY")

	else
		dat += "<span style='color: red; font-weight: bold;'>The heads of staff managed to stop the revolution!</span>"
		feedback_add_details("[ID]_success","FAIL")
	return dat

/datum/faction/revolution/latespawn(mob/M)
	if(M.mind.assigned_role in command_positions)
		log_debug("Adding head kill/capture/convert objective for [M.name]")

		var/datum/objective/rp_rev/rev_obj = AppendObjective(/datum/objective/rp_rev)
		rev_obj.target = M.mind
		rev_obj.explanation_text = "Capture, convert or exile from station [M.name], the [M.mind.assigned_role]. Assassinate if you have no choice."
		AnnounceObjectives()

/datum/faction/revolution/process()
	// only perform rev checks once in a while
	if(tried_to_add_revheads < world.time)
		tried_to_add_revheads = world.time + 5 SECONDS
		var/active_revs = 0
		for(var/datum/role/syndicate/rev_leader/R in members)
			if(R.antag?.current?.client?.inactivity <= 20 MINUTES) // 20 minutes inactivity are OK
				active_revs++

		if(active_revs == 0)
			log_debug("There are zero active heads of revolution, trying to add some..")
			var/added_heads = FALSE
			for(var/mob/living/carbon/human/H in human_list)
				if(H.stat != DEAD && H.mind && H.client?.inactivity <= 20 MINUTES && isrev(H))
					var/datum/role/R = H.mind.GetRole(REV)
					R.RemoveFromRole(H.mind)
					HandleNewMind(H.mind)
					H.verbs += /mob/living/carbon/human/proc/RevConvert
					added_heads = TRUE
					break

			if(added_heads)
				log_admin("Managed to add new heads of revolution.")
				message_admins("Managed to add new heads of revolution.")
			else
				log_admin("Unable to add new heads of revolution.")
				message_admins("Unable to add new heads of revolution.")
				tried_to_add_revheads = world.time + 10 MINUTES

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
	else if(last_command_report == 2 && world.time >= 60 MINUTES)
		command_report("It is reported that merely closing down leisure facilities has not been successful. You and your Heads of Staff are to ensure that all crew are working hard, and not wasting time or energy. Any crew caught off duty without leave from their Head of Staff are to be warned, and on repeated offence, to be brigged until the next transfer shuttle arrives, which will take them to facilities where they can be of more use.")
		last_command_report = 3

	checkwin_counter++
	if(checkwin_counter >= 5)
		check_win()
		checkwin_counter = 0

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
