/datum/controller/subsystem/ticker/proc/scoreboard(completions, mob/one_mob)
	if(SSStatistics.achievements.len)
		completions += "<div class='Section'>[achievement_declare_completion()]</div>"

	// Who is alive/dead, who escaped
	for (var/mob/living/silicon/ai/I as anything in ai_list)
		if (I.stat == DEAD && is_station_level(I.z))
			SSStatistics.score.deadaipenalty = 1
			SSStatistics.score.crew_dead += 1

	for (var/mob/living/carbon/human/I as anything in human_list)
		if (I.stat == DEAD && is_station_level(I.z))
			SSStatistics.score.crew_dead += 1
		if (I.job == "Clown")
			for(var/thing in I.attack_log)
				if(findtext(thing, "<font color='orange'>")) //</font>
					SSStatistics.score.clownabuse++

	var/area/escape_zone = get_area_by_type(/area/shuttle/escape/centcom)

	var/cashscore = 0
	var/dmgscore = 0
	for(var/mob/living/carbon/human/E as anything in human_list)
		if(E.stat == DEAD)
			continue
		cashscore = 0
		dmgscore = 0
		var/turf/location = get_turf(E.loc)
		if(location in escape_zone) // Escapee Scores
			if(E.mind)
				var/datum/money_account/MA = get_account(E.mind.get_key_memory(MEM_ACCOUNT_NUMBER))
				if(MA)
					cashscore += MA.money

			for (var/obj/item/weapon/spacecash/C2 in get_contents_in_object(E, /obj/item/weapon/spacecash))
				cashscore += C2.worth

			for (var/obj/item/weapon/ewallet/EW in get_contents_in_object(E, /obj/item/weapon/ewallet))
				cashscore += EW.get_money()

			if (cashscore > SSStatistics.score.richestcash)
				SSStatistics.score.richestcash = cashscore
				SSStatistics.score.richestname = E.real_name
				SSStatistics.score.richestjob = E.job
				SSStatistics.score.richestkey = E.key
			dmgscore = E.bruteloss + E.fireloss + E.toxloss + E.oxyloss
			if (dmgscore > SSStatistics.score.dmgestdamage)
				SSStatistics.score.dmgestdamage = dmgscore
				SSStatistics.score.dmgestname = E.real_name
				SSStatistics.score.dmgestjob = E.job
				SSStatistics.score.dmgestkey = E.key

	// Check station's power levels
	for (var/obj/machinery/power/apc/A in apc_list)
		if (!is_station_level(A.z))
			continue
		for (var/obj/item/weapon/stock_parts/cell/C in A.contents)
			if (C.charge < 2300)
				SSStatistics.score.powerloss += 1 // 200 charge leeway

	// Check how much uncleaned mess is on the station
	for (var/obj/effect/decal/cleanable/M in decal_cleanable)
		if (!is_station_level(M.z))
			continue
		if (istype(M, /obj/effect/decal/cleanable/blood/gibs))
			SSStatistics.score.mess += 3
		if (istype(M, /obj/effect/decal/cleanable/blood))
			SSStatistics.score.mess += 1
		if (istype(M, /obj/effect/decal/cleanable/vomit))
			SSStatistics.score.mess += 1

	// How many antags did we deconvert
	for(var/name in global.deconverted_roles)
		var/list/L = global.deconverted_roles[name]
		SSStatistics.score.rec_antags += L.len

	//Research Levels
	var/research_levels = 0
	for(var/obj/machinery/r_n_d/server/core/C in rnd_server_list)
		for(var/tech_tree_id in C.files.tech_trees)
			var/datum/tech/T = C.files.tech_trees[tech_tree_id]
			research_levels += T.level

	if(research_levels)
		SSStatistics.score.researchdone += research_levels

	// Bonus Modifiers
	var/rolesuccess = SSStatistics.score.roleswon * 250
	var/deathpoints = SSStatistics.score.crew_dead * 250 //done
	var/researchpoints = SSStatistics.score.researchdone * 30
	var/eventpoints = SSStatistics.score.eventsendured * 50
	var/escapoints = SSStatistics.score.crew_escaped * 25 //done
	var/harvests = SSStatistics.score.stuffharvested //done
	var/shipping = SSStatistics.score.stuffshipped * 75
	var/mining = SSStatistics.score.oremined //done
	var/meals = SSStatistics.score.meals * 5 //done, but this only counts cooked meals, not drinks served
	var/power = SSStatistics.score.powerloss * 30
	var/plaguepoints = SSStatistics.score.disease * 30
	var/messpoints = SSStatistics.score.mess != 0 ? SSStatistics.score.mess : null

	for(var/datum/faction/F in mode.factions)
		F.build_scorestat()

	// Good Things
	SSStatistics.score.crewscore += shipping + harvests + mining + meals + researchpoints + eventpoints + escapoints

	if (power == 0)
		SSStatistics.score.crewscore += 2500
		SSStatistics.score.powerbonus = 1
	if (SSStatistics.score.mess == 0)
		SSStatistics.score.crewscore += 3000
		SSStatistics.score.messbonus = 1
	if (SSStatistics.score.allarrested)
		SSStatistics.score.crewscore *= 3 // This needs to be here for the bonus to be applied properly

	// Bad Things
	SSStatistics.score.crewscore -= rolesuccess
	SSStatistics.score.crewscore -= deathpoints
	if (SSStatistics.score.deadaipenalty)
		SSStatistics.score.crewscore -= 250
	SSStatistics.score.crewscore -= power
	SSStatistics.score.crewscore -= messpoints
	SSStatistics.score.crewscore -= plaguepoints

	completions += scorestats()

	if(one_mob)
		one_mob.scorestats(completions)
	else
		for(var/mob/E in player_list)
			if(E.client)
				E.scorestats(completions)

/datum/controller/subsystem/ticker/proc/scorestats(completions)
	var/dat = completions
	dat += {"<h2>Статистика и рейтинги раунда</h2><div class='Section'>"}

	for(var/datum/faction/F in SSticker.mode.factions)
		var/stat = F.get_scorestat()
		if(stat)
			dat += stat
			dat += "<hr>"

	if(global.deconverted_roles.len)
		dat += "<B>Деконвертированные роли:</B><BR>"
		dat += "<ul>"
		for(var/name in global.deconverted_roles)
			dat += "<li>"
			dat += "[name]: [get_english_list(global.deconverted_roles[name])]."
			dat += "</li>"
		dat += "</ul>"

	var/totalfunds = station_account.money
	dat += {"<B><U>ОБЩАЯ СТАТИСТИКА</U></B><BR>
	<U>ХОРОШО:</U><BR>
	<B>Полезные ящики отгружены:</B> [SSStatistics.score.stuffshipped] ([SSStatistics.score.stuffshipped * 75] очков)<BR>
	<B>Урожай, полученный в гидропонике:</B> [SSStatistics.score.stuffharvested] ([SSStatistics.score.stuffharvested] очков)<BR>
	<B>Руды добыто:</B> [SSStatistics.score.oremined] ([SSStatistics.score.oremined] очков)<BR>
	<B>Приготовлено закусок:</B> [SSStatistics.score.meals] ([SSStatistics.score.meals * 5] очков)<BR>
	<B>Завершенных исследований:</B> [SSStatistics.score.researchdone] ([SSStatistics.score.researchdone * 30] очков)<BR>"}
	dat += "<B>Cбежавшие на шаттле:</B> [SSStatistics.score.crew_escaped] ([SSStatistics.score.crew_escaped * 25] очков)<BR>"
	dat += {"<B>Случайные события пережили:</B> [SSStatistics.score.eventsendured] ([SSStatistics.score.eventsendured * 50] очков)<BR>
	<B>Электропитание по всей станции:</B> [SSStatistics.score.powerbonus ? "Да" : "Нет"] ([SSStatistics.score.powerbonus * 2500] очков)<BR>
	<B>Ультра чистота на станции:</B> [SSStatistics.score.mess ? "Нет" : "Да"] ([SSStatistics.score.messbonus * 3000] очков)<BR><BR>
	<U>ПЛОХО:</U><BR>
	<B>Успешность действий Ролей:</B> [SSStatistics.score.roleswon] (-[SSStatistics.score.roleswon * 250] очков)<BR>
	<B>Мёртвые тела на станции:</B> [SSStatistics.score.crew_dead] (-[SSStatistics.score.crew_dead * 250] очков)<BR>
	<B>Неубранный мусор:</B> [SSStatistics.score.mess] (-[SSStatistics.score.mess] очков)<BR>
	<B>Проблемы с электропитанием станции:</B> [SSStatistics.score.powerloss] (-[SSStatistics.score.powerloss * 30] очков)<BR>
	<B>Распространенные заболевания:</B> [SSStatistics.score.disease] (-[SSStatistics.score.disease * 30] очков)<BR>
	<B>ИИ уничтожен:</B> [SSStatistics.score.deadaipenalty ? "Да" : "Нет"] (-[SSStatistics.score.deadaipenalty * 250] очков)<BR><BR>
	<U>Остальное:</U><BR>
	<B>Итоговый бюджет станции:</B> $[num2text(totalfunds,50)]<BR>"}
	var/profit = totalfunds - global.initial_station_money
	if (profit > 0)
		dat += "<B>Прибыль станции:</B> +[num2text(profit,50)]<BR>"
	else if (profit < 0)
		dat += "<B>Траты станции:</B> [num2text(profit,50)]<BR>"
	dat += {"<B>Еды съедено:</b> [SSStatistics.score.foodeaten]<BR>
	<B>Случаи жестокого обращения с клоуном:</B> [SSStatistics.score.clownabuse]<BR><BR>"}
	if (SSStatistics.score.crew_escaped)
		dat += "<B>Самый богатый беглец:</B> [SSStatistics.score.richestname], [SSStatistics.score.richestjob]: [SSStatistics.score.richestcash] credits ([SSStatistics.score.richestkey])<BR>"
		dat += "<B>Самый избитый беглец:</B> [SSStatistics.score.dmgestname], [SSStatistics.score.dmgestjob]: [SSStatistics.score.dmgestdamage] damage ([SSStatistics.score.dmgestkey])<BR>"
	else
		dat += "Станция не была эвакуирована, и никто не спасся!<BR>"
	dat += {"<HR><BR>
	<B><U>ФИНАЛЬНЫЙ СЧЁТ: [SSStatistics.score.crewscore]</U></B><BR>"}
	SSStatistics.score.rating = "Аристократы!"
	switch(SSStatistics.score.crewscore)
		if(-99999 to -50000) SSStatistics.score.rating = "Даже сингулярность заслуживает большего"
		if(-49999 to -5000) SSStatistics.score.rating = "Корм для сингулярности"
		if(-4999 to -1000) SSStatistics.score.rating = "Вы все уволены!"
		if(-999 to -500) SSStatistics.score.rating = "Пустая трата чистого кислорода"
		if(-499 to -250) SSStatistics.score.rating = "Жалкая кучка подонков и некомпетентных людей"
		if(-249 to -100) SSStatistics.score.rating = "Превзошли лабораторных обезьян"
		if(-99 to -21) SSStatistics.score.rating = "Нежданные гости"
		if(-20 to -1) SSStatistics.score.rating = "Могло быть и хуже"
		if(0) SSStatistics.score.rating = "Ничего ценного"
		if(1 to 20) SSStatistics.score.rating = "Среднестатистическая смена"
		if(21 to 99) SSStatistics.score.rating = "Не плохо, но и не хорошо"
		if(100 to 249) SSStatistics.score.rating = "Искусные служители науки"
		if(250 to 499) SSStatistics.score.rating = "Лучшие из лучших"
		if(500 to 999) SSStatistics.score.rating = "Бережиливая, среднестатическая станция 13"
		if(1000 to 4999) SSStatistics.score.rating = "Повышение для всех!"
		if(5000 to 9999) SSStatistics.score.rating = "Послы научных открытий"
		if(10000 to 49999) SSStatistics.score.rating = "Гордость самой науки"
		if(50000 to INFINITY) SSStatistics.score.rating = "Лучшие в НаноТрайзен"
	dat += "<B><U>Рейтинг:</U></B> [SSStatistics.score.rating]"
	dat += "</div>"

	log_game(dat)

	return dat

/mob/proc/scorestats(completions)//omg why we count this for every player
	// Show the score - might add "ranks" later
	to_chat(src, "<b>Итоговый результат персонала таков:</b>")
	to_chat(src, "<b><font size='4'>[SSStatistics.score.crewscore]</font></b>")

	for(var/i in 1 to end_icons.len)
		src << browse_rsc(end_icons[i],"logo_[i].png")

	var/datum/browser/popup = new(src, "roundstats", "Round #[global.round_id] Stats", 1000, 600)
	popup.set_content(completions)
	popup.open()
