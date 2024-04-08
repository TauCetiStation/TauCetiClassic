/proc/get_living_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in heads_positions))
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

	//associative
	var/list/reasons = list()

/datum/faction/revolution/proc/get_all_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(player.mind && (player.mind.assigned_role in heads_positions))
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
		var/datum/objective/target/rp_rev/rev_obj = AppendObjective(/datum/objective/target/rp_rev, TRUE)
		if(rev_obj)
			rev_obj.target = head_mind
			rev_obj.explanation_text = "Capture, convert or exile from station [head_mind.name], the [head_mind.assigned_role]. Assassinate if you have no choice."
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

/datum/faction/revolution/latespawn(mob/M)
	if(M.mind.assigned_role in heads_positions)
		log_debug("Adding head kill/capture/convert objective for [M.mind.name]")

		var/datum/objective/target/rp_rev/rev_obj = AppendObjective(/datum/objective/target/rp_rev, TRUE)
		if(rev_obj)
			rev_obj.target = M.mind
			rev_obj.explanation_text = "Capture, convert or exile from station [M.mind.name], the [M.mind.assigned_role]. Assassinate if you have no choice."
			AnnounceObjectives()

/datum/faction/revolution/process()
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

	if(last_command_report == 0 && world.time >= 10 MINUTES)
		command_report("Ваша низкая производительность вынуждает нас принять непростое решение о сокращении финансового обеспечения станции. В связи с этим вдвое уменьшены заработные платы всего персонала, за исключением сотрудников службы безопасности и командного состава.")
		last_command_report = 1
		var/list/excluded_rank = list("AI", "Cyborg", "Clown Police") + command_positions + security_positions + centcom_positions
		for(var/datum/job/J in SSjob.occupations)
			if(J.title in excluded_rank)
				continue
			J.salary_ratio = 0.5	//halve the salary of all professions except leading
		var/list/crew = my_subordinate_staff("Admin")
		for(var/person in crew)
			if(person["rank"] in excluded_rank)
				continue

			var/datum/money_account/account = get_account(person["account"])
			if(!account)
				continue

			account.change_salary(null, "CentComm", "CentComm", "Admin", force_rate = -50)	//halve the salary of all staff except heads

	else if(last_command_report == 1 && world.time >= 30 MINUTES)
		command_report("Согласно статистике, бесконтрольный досуг и сопутствующая ему деятельность пагубно влияют на производительность наших станций. Вам необходимо закрыть голопалубу, театр, бар и любые другие увеселительные заведения. Питание персонала следует организовать посредством торговых автоматов и столовой.")
		last_command_report = 2
	else if(last_command_report == 2 && world.time >= 45 MINUTES)
		command_report("У нас есть основания полагать, что вы не проявляете должной преданности НаноТрейзен. Мы настаиваем на том, чтобы все представители командного состава ввели себе имплант лояльности, если это ещё не было сделано. Отказ от прохождения процедуры имплантации расценивается как неподчинение приказам Центрального Командования и карается арестом до конца смены.")
		last_command_report = 3
	else if(last_command_report == 3 && world.time >= 60 MINUTES)
		command_report("Проверенные источники сообщают, что принятые ранее меры оказались недостаточными. Представители командного состава обязаны проследить за тем, чтобы их подчиненные работали максимально усердно и не слонялись без дела. Персоналу запрещено покидать свое рабочее место без согласования с начальством. При нарушении этого запрета кем-либо необходимо накладывать дисциплинарное взыскание, а при рецидиве — заключать под стражу до момента прибытия транспортного шаттла, который доставит нарушителей туда, где им гарантированно найдут применение.")
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
	dat += {"<B><U>Революционная статистика</U></B><BR>
	<B>Количество выживших глав революции:</B> [foecount]<BR>
	<B>Количество выживших глав станции:</B> [comcount]<BR>
	<B>Количество выживших революционеров:</B> [revcount]<BR>
	<B>Количество выживших лоялистов:</B> [loycount]<BR><BR>
	<B>Глав революции арестовано:</B> [SSStatistics.score.arrested] ([SSStatistics.score.arrested * 1000] очков)<BR>
	<B>Глав революции убито:</B> [SSStatistics.score.opkilled] ([SSStatistics.score.opkilled * 500] очков)<BR>
	<B>Глав станции убито:</B> [SSStatistics.score.deadcommand] (-[SSStatistics.score.deadcommand * 500] очков)<BR>
	<B>Революция преуспела:</B> [SSStatistics.score.traitorswon ? "Да" : "Нет"] (-[SSStatistics.score.traitorswon * revpenalty] очков)<BR>
 	<B>Все главы революции арестованы:</B> [SSStatistics.score.allarrested ? "Да (очки утроены)" : "Нет"]<BR>"}

	return dat

/datum/faction/revolution/GetScoreboard()
	var/count = 1
	var/score_results = ""
	if(objective_holder.objectives.len > 0)
		score_results += "<ul>"
		var/custom_result = custom_result()
		score_results += custom_result
		score_results += "<br><br>"
		for(var/datum/objective/objective in objective_holder.GetObjectives())
			objective.extra_info()
			score_results += "<B>Objective #[count]</B>: [objective.explanation_text] [objective.completion_to_string()]"
			feedback_add_details("[ID]_objective","[objective.type]|[objective.completion_to_string(FALSE)]")
			count++
			if(count <= objective_holder.objectives.len)
				score_results += "<br>"
		score_results += "</ul>"
	score_results += "<ul>"

	var/have_objectives = FALSE
	var/have_reason_string = FALSE
	if(reasons.len)
		have_reason_string = TRUE

	var/list/name_by_members = list()
	score_results += "<FONT size = 2><B>Members:</B></FONT><br>"
	for(var/datum/role/R in members)
		if(!name_by_members[R.name])
			name_by_members[R.name] = list()
		name_by_members[R.name] += R

	for(var/name in name_by_members)
		score_results += "<b>[name]:</b><ul>"
		for(var/datum/role/R in name_by_members[name])
			var/results = R.GetScoreboard()
			if(results)
				score_results += results
				score_results += "<br>"
				if(R.objectives.objectives.len)
					have_objectives = TRUE
			if(have_reason_string)
				var/reason_string = reasons[R.antag.key]
				if(reason_string)
					score_results += "<DD><B>Reason to join the revolution:</B> [reason_string]</DD><BR>"

		score_results += "</ul>"

	score_results += "</ul>"

	if(!have_objectives)
		score_results += "<br>"

	return score_results

/datum/faction/revolution/proc/convert_revolutionare_by_invite(mob/possible_rev, mob/inviter)
	if(!inviter)
		return FALSE
	var/datum/role/rev_leader/lead = get_member_by_mind(inviter.mind)
	var/choice = tgui_alert(possible_rev, "Asked by [inviter]: Do you want to join the revolution?", "Join the Revolution!", list("No!","Yes!"))
	if(choice == "Yes!")
		var/reason_string = find_reason(possible_rev)
		if(!reason_string)
			to_chat(inviter, "<span class='bold warning'>[possible_rev] has no reason to support the revolution!</span>")
			lead.rev_cooldown = world.time + 5 SECONDS
			return FALSE
		if(add_user_to_rev(possible_rev, reason_string))
			to_chat(inviter, "<span class='bold_notice'>[possible_rev] has joined the revolution!</span>")
			add_tc_to_headrev(inviter, lead)
			return TRUE
		else
			to_chat(inviter, "<span class='bold warning'>[possible_rev] cannot be converted.</span>")
			return FALSE
	to_chat(possible_rev, "<span class='warning'>You reject this traitorous cause!</span>")
	to_chat(inviter, "<span class='bold warning'>[possible_rev] does not support the revolution!</span>")
	lead.rev_cooldown = world.time + 5 SECONDS
	return FALSE

/datum/faction/revolution/proc/convert_revolutionare(mob/possible_rev)
	var/reason_string = find_reason(possible_rev)
	if(!reason_string)
		return FALSE
	if(add_user_to_rev(possible_rev, reason_string))
		return TRUE
	return FALSE

/datum/faction/revolution/proc/find_reason(mob/user)
	var/reason_string = sanitize_safe(input(user, "Please write the reason why you want to join the ranks of the revolution", "Write Reason") as null|message, MAX_REV_REASON_LEN)
	if(!reason_string)
		to_chat(user, "<span class='warning'>You have no reason to join the revolution!</span>")
		return null
	return reason_string

/datum/faction/revolution/proc/add_user_to_rev(mob/user, reason_string)
	if(add_faction_member(src, user, TRUE))
		reasons[user.mind.key] = reason_string
		to_chat(user, "<span class='notice'>You join the revolution!</span>")
		return TRUE
	return FALSE

/datum/faction/revolution/proc/add_tc_to_headrev(mob/headrev, datum/role/headrev_role)
	var/obj/item/device/uplink/hidden/U = find_syndicate_uplink(headrev)
	if(!U)
		return
	U.uses += 3
	var/datum/component/gamemode/syndicate/S = headrev_role.GetComponent(/datum/component/gamemode/syndicate)
	if(!S)
		return
	S.total_TC += 3
