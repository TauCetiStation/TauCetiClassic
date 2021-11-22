/proc/get_living_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player in human_list)
		if(player.stat != DEAD && player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

/datum/faction/revolution
	name = "Revolutionaries"
	ID = F_REVOLUTION
	required_pref = ROLE_REV

	initroletype = /datum/role/rev_leader
	roletype = /datum/role/rev

	min_roles = 0
	max_roles = 2

	logo_state = "rev-logo"

	var/last_command_report = 0
	var/tried_to_add_revheads = 0
	var/NT_announce_interval = 10
	var/NT_announce_time = 30

	var/list/Rev_announces = list()

/datum/faction/revolution/proc/get_all_heads()
	var/list/heads = list()
	for(var/mob/living/carbon/human/player in human_list)
		if(player.mind && (player.mind.assigned_role in command_positions))
			heads += player.mind
	return heads

/datum/faction/revolution/OnPostSetup()
	if(SSshuttle)
		SSshuttle.fake_recall = TRUE
	Rev_announces = subtypesof(/datum/announcement/centcomm/revolution/random)
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
			score["roleswon"]++
		else
			dat += "<span class='orange'>The heads of staff were overthrown, but many heads died. The revolutionaries win, but lose support.</span>"
			feedback_add_details("[ID]_success","HALF")

	else
		dat += "<span class='red'>The heads of staff managed to stop the revolution!</span>"
		feedback_add_details("[ID]_success","FAIL")
	return dat

/datum/faction/revolution/latespawn(mob/M)
	if(M.mind.assigned_role in command_positions)
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
			if(R.antag?.current?.client?.inactivity <= 20 MINUTES) // 20 minutes inactivity are OK
				active_revs++

		if(active_revs == 0)
			log_debug("There are zero active heads of revolution, trying to add some..")
			var/added_heads = FALSE
			for(var/mob/living/carbon/human/H in human_list)
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

	else if(last_command_report == 1 && world.time >= 20 MINUTES)
		last_command_report = 2

	else if(last_command_report > 1 && world.time >= NT_announce_time MINUTES && Rev_announces.len)
		last_command_report += 1
		NT_announce_time += NT_announce_interval
		var/R = pick_n_take(Rev_announces)
		var/datum/announcement/centcomm/revolution/random/RA = new R
		RA.play()
		RA.do_event()


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
		if (!lead?.antag?.current)
			score["opkilled"]++
			continue
		var/turf/T = lead.antag.current.loc
		if(T)
			if (istype(T.loc, /area/station/security/brig))
				score["arrested"] += 1
			else if (lead.antag.current.stat == DEAD)
				score["opkilled"]++
	if(foecount == score["arrested"])
		score["allarrested"] = 1
	for(var/mob/living/carbon/human/player in human_list)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
				if (player.stat == DEAD)
					score["deadcommand"]++

	var/arrestpoints = score["arrested"] * 1000
	var/killpoints = score["opkilled"] * 500
	var/comdeadpts = score["deadcommand"] * 500
	if (score["traitorswon"])
		score["crewscore"] -= 10000
	score["crewscore"] += arrestpoints
	score["crewscore"] += killpoints
	score["crewscore"] -= comdeadpts

/datum/faction/revolution/get_scorestat()
	var/dat = ""
	var/foecount = 0
	var/comcount = 0
	var/revcount = 0
	var/loycount = 0

	for(var/datum/role/rev_leader/lead in members)
		if (lead.antag?.current?.stat != DEAD)
			foecount++
	for(var/datum/role/rev/rev in members)
		if (rev.antag?.current?.stat != DEAD)
			revcount++

	for(var/mob/living/carbon/human/player in human_list)
		if(!player.mind)
			continue
		var/role = player.mind.assigned_role
		if(role in list("Captain", "Head of Security", "Head of Personnel", "Chief Engineer", "Research Director"))
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
	<B>Revolution Heads Arrested:</B> [score["arrested"]] ([score["arrested"] * 1000] Points)<BR>
	<B>Revolution Heads Slain:</B> [score["opkilled"]] ([score["opkilled"] * 500] Points)<BR>
	<B>Command Staff Slain:</B> [score["deadcommand"]] (-[score["deadcommand"] * 500] Points)<BR>
	<B>Revolution Successful:</B> [score["traitorswon"] ? "Yes" : "No"] (-[score["traitorswon"] * revpenalty] Points)<BR>
	<B>All Revolution Heads Arrested:</B> [score["allarrested"] ? "Yes" : "No"] (Score tripled)<BR>"}

	return dat

/datum/announcement/centcomm/revolution/first
	name = "Revolution: First announce"
/datum/announcement/centcomm/revolution/first/New()
	message = "Мы с сожалением сообщаем что разочарованы качеством вашей работы, и потому мы вынуждены урезать финансирование вашей станции. В связи с этим зарплата всех сотрудников за исключением глав и службы безопасности сокращена вдвое."

/datum/announcement/centcomm/revolution/first/do_event()
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

/datum/announcement/centcomm/revolution/second
	name = "Revolution: Second announce"
/datum/announcement/centcomm/revolution/second/New()
	message = "Статистика показывает что качество работы многих станций снижено из-за большого количества свободного времени и развлечений. Командованию станции следует прекратить работу развлекательных отсеков, таких как голодек, бар, театр и прочих и заблокировать доступ в них. Еда будет выдаваться через автоматы и на кухне."

/datum/announcement/centcomm/revolution/random/rand_1
	name = "Revolution: zero salary"
/datum/announcement/centcomm/revolution/random/rand_1/New()
	message = "К сожалению, нам все еще не удалось компенсировать все убытки, так как качество и скорость работы сотрудников [station_name_ru()] по-прежнему недостаточны. Мы вынуждены вновь сократить финансирование за счет зарплат всего персонала, за исключением глав и сотрудников СБ."

/datum/announcement/centcomm/revolution/random/rand_1/do_event()
	var/list/excluded_rank = list("AI", "Cyborg", "Clown Police", "Internal Affairs Agent")	+ command_positions + security_positions
	for(var/datum/job/J in SSjob.occupations)
		if(J.title in excluded_rank)
			continue
		J.salary_ratio = 0.0	//halve the salary of all professions except leading
	var/list/crew = my_subordinate_staff("Admin")
	for(var/person in crew)
		if(person["rank"] in excluded_rank)
			continue
		var/datum/money_account/account = person["acc_datum"]
		account.change_salary(null, "CentComm", "CentComm", "Admin", force_rate = -100)	//zero the salary of all staff except heads

/datum/announcement/centcomm/revolution/random/rand_2
	name = "Revolution: increase heads salary"
/datum/announcement/centcomm/revolution/random/rand_2/New()
	message = "Мы рады сообщить что прибыль НТ постепенно растет, и хотя мы все еще несем убытки, у нас появились свободные средства на поощрение наших сотрудников. Благодаря увеличению финансирования [station_name_ru()], зарплаты глав и работников службы безопасности повышены на 50%."

/datum/announcement/centcomm/revolution/random/rand_2/do_event()
	var/list/included_rank = list("Clown Police", "Internal Affairs Agent")	+ command_positions + security_positions
	for(var/datum/job/J in SSjob.occupations)
		if(J.title in included_rank)
			J.salary_ratio = 1.5
	var/list/crew = my_subordinate_staff("Admin")
	for(var/person in crew)
		if(person["rank"] in included_rank)
			var/datum/money_account/account = person["acc_datum"]
			account.change_salary(null, "CentComm", "CentComm", "Admin", force_rate = 50)

/datum/announcement/centcomm/revolution/random/rand_3
	name = "Revolution: workhard"
/datum/announcement/centcomm/revolution/random/rand_3/New()
	message = "Сообщается что закрытия развлекательных отсеков оказалось недостаточно для повышения производительности труда. Главам следует убедиться что все сотрудники работают с полной отдачей, не тратя силы и время ни на что другое. Все сотрудники, пойманные не за работой и не имеющие разрешения их руководителя, должны быть предупреждены, а при повторном нарушении помещены под стражу до окончания смены и доставки их на объекты где они будут использованы с большей пользой."

/datum/announcement/centcomm/revolution/random/rand_4
	name = "Revolution: beatlazys"
/datum/announcement/centcomm/revolution/random/rand_4/New()
	message = "Поскольку корпорация все еще несет убытки, мы вынуждены пойти на жесткие меры для мотивации работников. С этого момента главам рекомендуется применять телесные наказания к подчиненным выполняющим свою работу недостаточно старательно. Сотрудникам СБ следует оказать им полное содействие в качестве исполнителей."

/datum/announcement/centcomm/revolution/random/rand_5
	name = "Revolution: bumstation"
/datum/announcement/centcomm/revolution/random/rand_5/New()
	message = "Для дополнительной экономии средств мы приняли решение сократить затраты на снаряжение. Главы и сотрудники безопасности должны следить чтобы работники [station_name_ru()] не использовали и не имели при себе предметы одежды или инструменты которые не являются строго необходимыми для выполнения их обязанностей."

/datum/announcement/centcomm/revolution/random/rand_6
	name = "Revolution: steal money"
/datum/announcement/centcomm/revolution/random/rand_6/New()
	message = "Ненадлежащее исполнение обязанностей должно строго пресекаться. Руководство НТ намерено показать что не станет мириться с ленью и беспечностью своих сотрудников, которые причиняют корпорации финансовый ущерб. Весь персонал [station_name_ru()] за исключением командования и службы безопасности будет оштрафован на 500 кредитов. С этого момента СБ следует применять финансовые штрафы при малейших нарушениях трудовой дисциплины."

/datum/announcement/centcomm/revolution/random/rand_2/do_event()
	var/list/excluded_rank = list("AI", "Cyborg", "Clown Police", "Internal Affairs Agent")	+ command_positions + security_positions
	var/list/crew = my_subordinate_staff("Admin")
	for(var/person in crew)
		if(person["rank"] in excluded_rank)
			continue
		var/datum/money_account/account = person["acc_datum"]
		charge_to_account(account.account_number, "CentComm", "Штраф", "CentComm", -500)

/datum/announcement/centcomm/revolution/random/rand_7
	name = "Revolution: no healing"
/datum/announcement/centcomm/revolution/random/rand_7/New()
	message = "Продолжая сокращать расходы на функционирование ненужных для работы отсеков и несущественные задачи, руководство НТ приняло решение отменить медицинскую страховку для персонала. С этого момента медработники на борту [station_name_ru()] не имеют права выдавать лекарства или оказывать медицинскую помощь никому кроме глав и сотрудников службы безопасности. Нарушение запрета должно расцениваться как превышение полномочий и разбазаривание имущества НТ с соответствующими последствиями."
