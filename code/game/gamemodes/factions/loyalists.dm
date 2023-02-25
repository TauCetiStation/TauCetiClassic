#define SCENARIO_MONEY     /datum/mutiny_scenario/money
#define SCENARIO_VIRUS     /datum/mutiny_scenario/virus
#define SCENARIO_RACISM    /datum/mutiny_scenario/racism
#define SCENARIO_COMMUNISM /datum/mutiny_scenario/communism
#define SCENARIO_BRUTALITY /datum/mutiny_scenario/brutality
#define SCENARIO_MINE      /datum/mutiny_scenario/mine
#define SCENARIO_GENETIC   /datum/mutiny_scenario/genetic

/datum/faction/loyalists
	name = "Loyalists"
	ID = F_LOYALISTS
	required_pref = ROLE_LOYALIST

	initroletype = /datum/role/loyalist
	roletype = /datum/role/loyalist

	min_roles = 1
	max_roles = 2

	logo_state = "loyal-logo"

	var/last_command_report = 0
	var/datum/mutiny_scenario/scenario

/datum/faction/loyalists/OnPostSetup()
	var/scenario_type = pick(SCENARIO_MONEY, SCENARIO_VIRUS, SCENARIO_RACISM, SCENARIO_COMMUNISM, SCENARIO_BRUTALITY, SCENARIO_MINE, SCENARIO_GENETIC)
	scenario = new scenario_type(src)
	return ..()

/datum/faction/loyalists/forgeObjectives()
	if(..())
		var/datum/objective/custom/C = AppendObjective(/datum/objective/custom)
		C.explanation_text = "Follow all directives"
		return TRUE

/datum/faction/loyalists/can_join_faction(mob/P)
	if(..())
		var/datum/job/loyal_job = SSjob.GetJob("Head of Security")
		if(!loyal_job || !loyal_job.map_check())
			loyal_job = SSjob.GetJob("Captain")
			if(!loyal_job || !loyal_job.map_check())
				return FALSE
		for(var/lvl in 1 to 3)
			if(P.client.prefs.job_preferences[loyal_job.title] == lvl && (!jobban_isbanned(P, loyal_job.title)))
				return TRUE
		return FALSE

/datum/faction/loyalists/IsSuccessful()
	var/alive_heads = 0
	for(var/datum/role/loyalist/R in members)
		if(considered_alive(R.antag) && !R.antag.current.suiciding)
			alive_heads++
	if(alive_heads == members.len)
		return TRUE
	return FALSE

/datum/faction/loyalists/custom_result()
	var/dat = ""
	var/dead_heads = 0
	var/alive_heads = 0
	for(var/datum/role/loyalist/R in members)
		if(!considered_alive(R.antag) || R.antag.current.suiciding)
			dead_heads++
		else
			alive_heads++

	if(!dead_heads)
		dat += "<span class='green'>The loyal heads of staff were survive!</span>"
		feedback_add_details("[ID]_success","SUCCESS")
		SSStatistics.score.roleswon++
	else if(alive_heads > dead_heads)
		dat += "<span class='orange'>The loyal heads of staff were overthrown, but survive.</span>"
		feedback_add_details("[ID]_success","HALF")
	else
		dat += "<span class='red'>The loyal heads of staff were died!</span>"
		feedback_add_details("[ID]_success","FAIL")
	return dat

/datum/faction/loyalists/latespawn(mob/M)
	if(M.mind.assigned_role in command_positions)
		if(M.isloyal())
			log_debug("Adding loyalist role for [M.mind.name]")
			add_faction_member(src, M)

/datum/faction/loyalists/process()
	if(last_command_report == 0 && world.time >= 10 MINUTES)
		command_report(scenario.get_first_report())
		scenario.do_first_strike()
		last_command_report = 1
	else if(last_command_report == 1 && world.time >= 30 MINUTES)
		command_report(scenario.get_second_report())
		scenario.do_second_strike()
		last_command_report = 2
	else if(last_command_report == 2 && world.time >= 60 MINUTES)
		command_report(scenario.get_third_report())
		scenario.do_third_strike()
		last_command_report = 3

/datum/faction/loyalists/proc/command_report(message)
	for (var/obj/machinery/computer/communications/comm in communications_list)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "Cent. Com. Announcement"
			intercept.info = message
			intercept.update_icon()

			comm.messagetitle.Add("Cent. Com. Announcement")
			comm.messagetext.Add(message)

	announcement_ping.play()

/datum/mutiny_scenario
	var/datum/faction/assigned_faction
	var/list/affected_mobs = list()

/datum/mutiny_scenario/New(datum/faction/my_faction)
	. = ..()
	if(my_faction)
		assigned_faction = my_faction

/datum/mutiny_scenario/proc/get_first_report()
	return

/datum/mutiny_scenario/proc/get_second_report()
	return

/datum/mutiny_scenario/proc/get_third_report()
	return

/datum/mutiny_scenario/proc/do_first_strike()
	return

/datum/mutiny_scenario/proc/do_second_strike()
	return

/datum/mutiny_scenario/proc/do_third_strike()
	return

/datum/mutiny_scenario/money/get_first_report()
	var/report_dat = ""
	report_dat += "Показатели экономической деятельности сигнализируют об убытках в следующем финансовом периоде.<br>"
	report_dat += "Центральное Командование вынуждено сократить финансовую поддержку станции.<br>"
	report_dat += "Зарплата большей части персонала уменьшена вдвое.<br>"
	report_dat += "Заверьте экипаж, что это временная мера, однако Командование пока не располагает информацией о временных промежутках этой меры.<br>"
	report_dat += "Разглашение информации из этого сообщения влечёт за собой последствия по статье 307, примечание о раскрытии тайн Корпорации."
	return report_dat

/datum/mutiny_scenario/money/get_second_report()
	var/report_dat = ""
	report_dat += "Наши передовые специалисты обнаружили кризис перепроизводства на этой станции.<br>"
	report_dat += "Чтобы как можно быстрее выйти из этой ситуации, нам требуется сократить лишних сотрудников.<br>"
	report_dat += "Увольте всех сотрудников, связанных с производством продукции.<br>"
	report_dat += "Сообщите им об этом как можно мягче. Возможно они понадобятся нам на постах уборщиков.<br>"
	report_dat += "Разглашение информации из этого сообщения влечёт за собой последствия по статье 307, примечание о раскрытии тайн Корпорации."
	return report_dat

/datum/mutiny_scenario/money/get_third_report()
	var/report_dat = ""
	report_dat += "Центральное Командование приняло решение вывезти финансовые ресурсы с этой станции.<br>"
	report_dat += "Переведите все реквизированные у бывших сотрудников корпорации средства и содержимое счёта станции в наличные.<br>"
	report_dat += "Транспортируйте денежные ресурсы шаттлом эвакуации или шаттлом конца смены на Центральное Командование.<br>"
	report_dat += "Разглашение информации из этого сообщения влечёт за собой последствия по статье 307, примечание о раскрытии тайн Корпорации."
	return report_dat

/datum/mutiny_scenario/money/do_first_strike()
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

/datum/mutiny_scenario/virus/get_first_report()
	var/report_dat = ""
	report_dat += "Центральное Командование получило информацию об эпидемии мышиного гриппа в вашем секторе.<br>"
	report_dat += "Введите карантин на станции.<br>"
	report_dat += "В развлекательных отсеках обязателен масочный режим.<br>"
	report_dat += "Если сотрудники не соблюдают установленных норм, отсек следует заблокировать для посещения на неограниченный срок.<br>"
	report_dat += "Мы получили информацию, что на вашей кухне готовился суп из мыши.<br>"
	report_dat += "В целях пресечения вспышки инфекции увольте всех, кто задействован в приготовлении пищи на станции."
	return report_dat

/datum/mutiny_scenario/virus/get_second_report()
	var/report_dat = ""
	report_dat += "Институт Эпидемиологии с Тау Киты 5 передал информацию о группах риска мышинного гриппа.<br>"
	report_dat += "Повышенная вероятность заболеть у всех Таяран и Унатхов.<br>"
	report_dat += "Поместите представителей этих рас под домашний арест на 10 звёздных суток.<br>"
	report_dat += "Если арестовать не удаётся, заключите их в одиночные отсеки, например карцер.<br>"
	report_dat += "Убедите их, что это исключительно для их блага."
	return report_dat

/datum/mutiny_scenario/virus/get_third_report()
	var/list/possible_positions = civilian_positions + engineering_positions + science_positions + security_positions - command_positions - list("Internal Affairs Agent")
	var/list/pos_isolate_human = list()
	for(var/mob/M as anything in global.human_list)
		if(!M.mind || !M.client || !considered_alive(M.mind) || M.suiciding || HAS_TRAIT(M, TRAIT_VACCINATED))
			continue
		if(M.mind.assigned_role in possible_positions)
			pos_isolate_human += M
	var/needed_picks = round(global.human_list.len / 10)
	var/report_dat = ""
	report_dat += "Центральное Командование сообщает: это не мышиный грипп, это вирус который превращает людей в безмозглых убийц.<br>"
	if(pos_isolate_human.len)
		report_dat += "Вы должны изолировать от остального экипажа следующих сотрудников:<br>"
		for(var/i in 1 to needed_picks)
			var/mob/M = pick(pos_isolate_human)
			report_dat += "[M];<br>"
			pos_isolate_human -= M
			affected_mobs += M
	report_dat += "Не допустите распространения инфекции. При необходимости избавьтесь от заражённых, кем бы они не были."
	return report_dat

/datum/mutiny_scenario/racism/get_first_report()
	var/report_dat = ""
	report_dat += "Компания заключила новую коммерческую сделку на очень выгодных условиях.<br>"
	report_dat += "К сожалению, наш торговый партнёр очень негативно относится к нелюдям.<br>"
	report_dat += "Центральное Командование временно отстраняет всех глав и других представителей командования не из числа людей от работы на станции."
	return report_dat

/datum/mutiny_scenario/racism/get_second_report()
	var/report_dat = ""
	report_dat += "Благодаря новым сделкам, бизнес-показатели экономического успеха возросли на четверть.<br>"
	report_dat += "Центральное Командование приняло решение пригласить наших новых партнёров на станцию.<br>"
	report_dat += "Они должны прибыть на следующую смену.<br>"
	report_dat += "Центрально Командование распоряжается отправить всех сотрудников не из числа людей в недельный отпуск за свой счёт.<br>"
	report_dat += "Наши партнёры не оценят их присутствие на станции."
	return report_dat

/datum/mutiny_scenario/racism/get_third_report()
	var/report_dat = ""
	report_dat += "На последнем заседании генеральных директоров компании, было принято пересмотреть корпоративную этику на станции.<br>"
	report_dat += "Запретив всем представителям женского пола занимать высокие посты на станции, мы освободим места для более пригодных для этой работы сотрудников.<br>"
	report_dat += "Женщин на должностях связанных с производством, обеспечением безопасности, интенсивной физической нагрузкой и возможностью остаться с мужчинами тет-а-тет следует перевести на другие работы.<br>"
	report_dat += "Центральное Командование также требует для них ношение одежды прикрывающей все части тела, окроме глаз, пока они находятся на станции."
	return report_dat

/datum/mutiny_scenario/communism/get_first_report()
	var/report_dat = ""
	report_dat += "Центральное Командование требует увеличить количество киборгов на станции.<br>"
	report_dat += "Тестовые Субъекты должны первыми принудительно пройти процесс киборгизации.<br>"
	report_dat += "Все погибшие сотрудники, которые не подлежат реанимации, должны быть направлены на процедуру создания киборга.<br>"
	report_dat += "За все 300-ые статьи Космозакона разрешается наказание в виде превращения принудительной киборгизации.<br>"
	report_dat += "Требуется передать все доступные станции металлы на постройку киборгов."
	return report_dat

/datum/mutiny_scenario/communism/get_second_report()
	var/report_dat = ""
	report_dat += "Исследовательская группа провела исследования продуктивности работы персонала.<br>"
	report_dat += "Данные указывают о повышении эффективности киборгов со специализацией на лечении экипажа.<br>"
	report_dat += "Центральное Командование увольняет сотрудников медицинского отдела на неустановленный срок.<br>"
	report_dat += "При желании остаться, сотруднику должен предоставиться выбор кибернетизировать своё тело.<br>"
	report_dat += "Все киборги на станции должны выбрать модули подходящие для работы в отсеках медбея и переместиться в соответствующие помещения на постоянной основе."
	return report_dat

/datum/mutiny_scenario/communism/get_third_report()
	var/report_dat = ""
	report_dat += "Внешняя разведка сообщает о том, что в станционных киборгах и прототипах обнаружена намеренно установленная уязвимость.<br>"
	report_dat += "Задержите всех неимплантированных лояльностью, кто принимал участие в постройке или обслуживании юнитов, в бриг до выяснения обстоятельств.<br>"
	report_dat += "Обновите законы ИИ, он должен служить интересам корпорации.<br>"
	report_dat += "Центральное Командование приказывает закрыть отсек Разработок и Исследований для предотвращения подобных этой ситуаций.<br>"
	report_dat += "Все прототипы, созданные на станции, требуется поместить в хранилище улик до следующей смены."
	return report_dat

/datum/mutiny_scenario/brutality/get_first_report()
	var/report_dat = ""
	report_dat += "Новый заместитель руководителя компании Vey Med предложил улучшить качество питания на вашей станции.<br>"
	report_dat += "Центральное Командование приказывает отправить все торговые автоматы с едой грузовым шаттлом.<br>"
	report_dat += "Убедитесь, что у вас есть достаточно сотрудников связанных с выращиванием и приготовлением пищи.<br>"
	report_dat += "Следите, чтобы сотрудники станции не повредили автоматы во время транспортировки.<br>"
	report_dat += "При нанесении ущерба собственности корпорации разрешается временный перевод сотрудника в тестовые субъекты до следующей смены."
	return report_dat

/datum/mutiny_scenario/brutality/get_second_report()
	var/report_dat = ""
	report_dat += "Замминистр поделился с нами информацией о новом методе снабжения едой.<br>"
	report_dat += "По его словам слизни, которые были на вашей станции, превращают мясо своих жертв в особый деликатес.<br>"
	report_dat += "При питании, слизни разрушают твёрдые элементы волокон мышц, что увеличивает усваиваемость пищеварительного тракта.<br>"
	report_dat += "Центральное Командование приказывает накормить слизней живыми существами.<br>"
	report_dat += "Из-за инновации, допустимо в качестве корма использовать провинившихся тестовых субъектов.<br>"
	report_dat += "После кормёжки, передайте тела в морозильную камеру кухни.<br>"
	report_dat += "Повара должны приготовить сбалансированные блюда, используя это мясо."
	return report_dat

/datum/mutiny_scenario/brutality/get_third_report()
	var/report_dat = ""
	report_dat += "Несколько офицеров Центрального Коммандования получили образец полученного мяса.<br>"
	report_dat += "По их заверениям, стоит поставить данную продукции Белтвею в вашей системе.<br>"
	report_dat += "Центральное Командование приказывает найти кандидатов для мясофикации.<br>"
	report_dat += "Свежее мясо необходимо отправить в морозильниках грузовым шаттлом.<br>"
	report_dat += "Не разглашайте экипажу информацию из этого сообщения."
	return report_dat

/datum/mutiny_scenario/mine/get_first_report()
	var/report_dat = ""
	report_dat += "Большой объем плазмы был потерян на ИСН Ками Хикари.<br>"
	report_dat += "Центральное Командование приказывает увеличить добычу фороновых слитков.<br>"
	report_dat += "Мы отправляем дополнительное снаряжение для шахтёрских работ.<br>"
	report_dat += "Отправьте нам не менее 200 листов ресурса как можно скорее."
	return report_dat

/datum/mutiny_scenario/mine/get_second_report()
	var/report_dat = ""
	report_dat += "Компания получила хранилище большего объема, чем те, что были ранее.<br>"
	report_dat += "Увеличьте поставки не менее чем в два раза, привлеките незанятый персонал к работам на полторы ставки.<br>"
	report_dat += "Отказ сотрудником выполнять приказы Центрального Коммандования недопустим.<br>"
	report_dat += "Убедитесь в наличии снабжения научным отсеком работников шахт передовыми разработками.<br>"
	report_dat += "При непродуктивной работе, рекомендуется перевод всего персонала Исследований и Разработок на должности шахтёров и грузчиков до выполнения плана поставок."
	return report_dat

/datum/mutiny_scenario/mine/get_third_report()
	var/report_dat = ""
	report_dat += "Поставки ресурсов с вашей станции были перехвачены налётчиками воксов.<br>"
	report_dat += "Мы вывели ВКН Икар на патруль пути поставок.<br>"
	report_dat += "Центральное Командование приказывает поставить все ресурсы, которые есть на астероиде, даже если придётся весь его вскопать.<br>"
	report_dat += "Задействуйте максимальное количество сотрудников на шахтах.<br>"
	report_dat += "Допустимо использование труда сотрудников Службы Безопасности."
	return report_dat

/datum/mutiny_scenario/mine/do_first_strike()
	//do_postavka

/datum/mutiny_scenario/mine/do_second_strike()
	//do_postavka eshe bolshe

/datum/mutiny_scenario/genetic/get_first_report()
	var/report_dat = ""
	report_dat += "Наши конкуренты из Zeng-Hu Pharmaceuticals вывели супер-сыворотку.<br>"
	report_dat += "Её действие усиливает способности подопытного, позволяя тому выйти за пределы своих возможностей.<br>"
	report_dat += "Мы отправляем вам тестовые образцы для экспериментов на людях грузовым шаттлом.<br>"
	report_dat += "Не распространяйте информацию из этого сообщения экипажу."
	report_dat += "Центральное Командование закрывает отсек генетических исследований из-за недостатка инноваций и устаревших технологий.<br>"
	report_dat += "Перестройте отсек на ваше усмотрение.<br>"
	report_dat += "Большую популярность набирают Китайские рестораны в космосе."
	return report_dat

/datum/mutiny_scenario/genetic/get_second_report()
	var/report_dat = ""
	report_dat += "Тестовые образцы оказались не тем, что вы должны были получить.<br>"
	report_dat += "В этот раз на грузовом шаттле точно будет нужная сыворотка.<br>"
	var/list/possible_positions = civilian_positions - command_positions - list("Internal Affairs Agent")
	var/list/pos_experiment_humans = list()
	for(var/mob/living/carbon/human/target as anything in global.human_list)
		if(!target.mind || !target.client || !considered_alive(target.mind) || target.suiciding)
			continue
		if(target.mind.assigned_role in possible_positions)
			var/datum/species/S = all_species[target.get_species()]
			if(S?.flags[NO_DNA])
				continue
			pos_experiment_humans += target
	var/needed_picks = round(global.human_list.len / 10)
	if(pos_experiment_humans.len)
		report_dat += "Центральное Командование подобрало подходящих кандидатов на инъекцию:<br>"
		for(var/i in 1 to needed_picks)
			var/mob/M = pick(pos_experiment_humans)
			report_dat += "[M];<br>"
			pos_experiment_humans -= M
			affected_mobs += M
	report_dat += "Не распространяйте экипажу информацию из этого сообщения."
	return report_dat

/datum/mutiny_scenario/genetic/get_third_report()
	var/report_dat = ""
	report_dat += "Эффективность использования образцов оказалась не такой, как ожидало командование.<br>"
	report_dat += "Несмотря на это, целесообразно испытать больше образцов на большем колличестве субъектов.<br>"
	report_dat += "Центральное Командование отправляет последнюю поставку на грузовом шаттле.<br>"
	var/list/possible_positions = engineering_positions + science_positions + security_positions - command_positions - list("Internal Affairs Agent")
	var/list/pos_experiment_humans = list()
	for(var/mob/living/carbon/human/target as anything in global.human_list)
		if(!target.mind || !target.client || !considered_alive(target.mind) || target.suiciding)
			continue
		if(target in affected_mobs)
			continue
		if(target.mind.assigned_role in possible_positions)
			var/datum/species/S = all_species[target.get_species()]
			if(S?.flags[NO_DNA])
				continue
			pos_experiment_humans += target
	var/needed_picks = round(global.human_list.len / 15)
	if(pos_experiment_humans.len)
		report_dat += "Придумайте повод для вживления этим сотрудникам:<br>"
		for(var/i in 1 to needed_picks)
			var/mob/M = pick(pos_experiment_humans)
			report_dat += "[M];<br>"
			pos_experiment_humans -= M
			affected_mobs += M
	report_dat += "Не распространяйте экипажу информацию из этого сообщения."
	return report_dat

/datum/mutiny_scenario/genetic/do_first_strike()
	//do_postavka mulligan

/datum/mutiny_scenario/genetic/do_second_strike()
	//do postavka mutagen

/datum/mutiny_scenario/genetic/do_third_strike()
	//do postavka last mutagen

#undef SCENARIO_MONEY
#undef SCENARIO_VIRUS
#undef SCENARIO_RACISM
#undef SCENARIO_COMMUNISM
#undef SCENARIO_BRUTALITY
#undef SCENARIO_MINE
#undef SCENARIO_GENETIC
