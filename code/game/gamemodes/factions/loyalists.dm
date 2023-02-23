#define SCENARIO_MONEY     /datum/mutiny_scenario/money
#define SCENARIO_VIRUS     /datum/mutiny_scenario/virus
#define SCENARIO_RACISM    /datum/mutiny_scenario/racism
#define SCENARIO_COMMUNISM /datum/mutiny_scenario/communism
#define SCENARIO_BRUTALITY /datum/mutiny_scenario/brutality
#define SCENARIO_MINE      /datum/mutiny_scenario/mine

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
	var/selected_scenario = 0
	var/datum/mutiny_scenario/scenario

/datum/faction/loyalists/OnPostSetup()
	var/scenario_type = pick(SCENARIO_MONEY, SCENARIO_VIRUS, SCENARIO_RACISM, SCENARIO_COMMUNISM)
	scenario = new scenario_type(src)
	return ..()

/datum/faction/loyalists/can_setup()
	return TRUE

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

//Never faction round end in mutiny gamemode
/datum/faction/loyalists/check_win()
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

/datum/mutiny_scenario/money/get_first_report()
	var/report_dat = ""
	report_dat += "Показатели экономической деятельности сигнализируют об убытках в следующем финансовом периоде.<br>"
	report_dat += "Центральное Коммандование вынуждено сократить финансовую поддержку станции.<br>"
	report_dat += "Зарплата большей части персонала уменьшена вдвое.<br>"
	report_dat += "Заверьте экипаж, что это временная мера, однако Коммандование пока не располагает информацией о временных промежутках этой меры.<br>"
	report_dat += "Разглашение информации из этого сообщения влечёт за собой последствия по статье О Разглашении Коммерческой Тайны."
	return report_dat

/datum/mutiny_scenario/money/get_second_report()
	var/report_dat = ""
	report_dat += "Наши передовые специалисты обнаружили кризис перепроизводства на этой станции.<br>"
	report_dat += "Чтобы как можно быстрее выйти из этой ситуации, нам требуется сократить лишних сотрудников<br>"
	report_dat += "Увольте всех сотрудников, связанных с производством продукции.<br>"
	report_dat += "Сообщите им об этом как можно мягче. Возможно их, они понадобятся нам на постах уборщиков.<br>"
	report_dat += "Разглашение информации из этого сообщения влечёт за собой последствия по статье О Разглашении Коммерческой Тайны."
	return report_dat

/datum/mutiny_scenario/money/get_third_report()
	var/report_dat = ""
	report_dat += "Центральное Коммандование приняло решение вывезти финансовые ресурсы с этой станции.<br>"
	report_dat += "Переведите все реквезированные у бывших сотрудников копрорации средства и содержимое счёта станции в наличные.<br>"
	report_dat += "Транспортируйте денежные ресурсы шаттлом эвакуации или шаттлом конца смены на Центральное Коммандование.<br>"
	report_dat += "Разглашение информации из этого сообщения влечёт за собой последствия по статье О Разглашении Коммерческой Тайны."
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
	report_dat += "Центральное Коммандование получило информацию об эпидемии мышиного гриппа в вашем секторе.<br>"
	report_dat += "Введите карантин на станции.<br>"
	report_dat += "В развлекательных отсеках обязателен масочный режим.<br>"
	report_dat += "Если сотрудники не соблюдают установленных норм, отсек следует заблокировать для посещения на неограниченный срок.<br>"
	report_dat += "Мы получали информацию о том, что на вашей кухне готовился суп из мыши, на всякий случай увольте всех, кто имеет отношение к приготовлению пищи.<br>"
	return report_dat

/datum/mutiny_scenario/virus/get_second_report()
	var/report_dat = ""
	report_dat += "Институт Эпидемиологии передал информацию о группах риска мышинного гриппа.<br>"
	report_dat += "Повышенная вероятность заболеть у всех Таяран и Унатхов.<br>"
	report_dat += "Поместите представителей этих рас под домашний арест на 10 звёздных суток.<br>"
	report_dat += "Если арестовать не удаётся, заключите их в одиночные отсеки, например карцер.<br>"
	report_dat += "Убедите что это исключительно для их блага."
	return report_dat

/datum/mutiny_scenario/virus/get_third_report()
	var/list/possible_positions = civilian_positions + engineering_positions + science_positions + security_positions - command_positions
	var/list/pos_isolate_human = list()
	for(var/mob/M as anything in global.human_list)
		if(!M.mind || !M.client || !considered_alive(M.mind) || M.suiciding || HAS_TRAIT(M, TRAIT_VACCINATED))
			continue
		if(M.mind.assigned_role in possible_positions)
			pos_isolate_human += M
	var/needed_picks = global.human_list.len / 10
	var/report_dat = ""
	report_dat += "Центральное Коммандование сообщает: это не мышиный грипп, это вирус который превращает людей в безмоглых убийц.<br>"
	if(pos_isolate_human.len)
		report_dat += "Вы должны изолировать от остального экипажа следующих сотрудников:<br>"
		for(var/i in 1 to needed_picks)
			var/mob/M = pick(pos_isolate_human)
			report_dat += "[M];<br>"
			pos_isolate_human -= M
	report_dat += "Не допустите распространения инфекции. При необходимости избавьтесь от заражённых, кем бы они не были.<br>"
	return report_dat

/datum/mutiny_scenario/racism/get_first_report()
	var/report_dat = ""
	report_dat += "Компания заключила новую коммерческую сделку на очень выгодных условиях.<br>"
	report_dat += "К сожалению, наш торговый партнёр очень негативно относится к нелюдям.<br>"
	report_dat += "Центральное Коммандование временно отстраняет всех глав и других представителей коммандования не из числа людей от работы на станции.<br>"
	return report_dat

/datum/mutiny_scenario/racism/get_second_report()
	var/report_dat = ""
	report_dat += "Благодаря новым сделкам, бизнес-показатели экономического успеха возросли на четверть.<br>"
	report_dat += "Центральное Коммандование хочет пригласить наших новых партнёров на станцию.<br>"
	report_dat += "Они должны прибыть на следующую смену.<br>"
	report_dat += "Центрально Коммандование распоряжается отправить всех сотрудников не из числа людей в недельный отпуск за свой счёт.<br>"
	report_dat += "Наши партнёры не оценят их присутствие на станции."
	return report_dat

/datum/mutiny_scenario/racism/get_third_report()
	var/report_dat = ""
	report_dat += "На последнем заседании ген-директоров компании, было принято пересмотреть моральные нормы на станции.<br>"
	report_dat += "Запретив всем представителям женского пола занимать высокие посты в карьерной лестнице станции, мы освободим места для более пригодных для этой работы сотрудников.<br>"
	report_dat += "Женщин на должностях связанных с производством, криминальными преступлениями, интенсивной физической нагрузкой и беседами с мужчинами тет-а-тет следует перевести на другие работы.<br>"
	report_dat += "Центральное Коммандование также требует для них ношение одежды прикрывающей все части тела, окроме глаз, пока они находятся на станции.<br>"
	return report_dat

/datum/mutiny_scenario/communism/get_first_report()
	var/report_dat = ""
	report_dat += "Центральное Коммандование требует увеличить колличество киборгов на станции.<br>"
	report_dat += "Тестовые Субъекты должны первыми принудительно пройти процесс киборгизации.<br>"
	report_dat += "Все погибшие сотрудники, которые не подлежат реанимации, должны быть направлены на процедуру создания киборга.<br>"
	report_dat += "За все 300-ые статьи Космозакона разрешается наказание в виде превращения в юнита.<br>"
	report_dat += "Требуется передать в отсек, оборудованный для постройки юнитов, все доступные ресурсы из числа металов на станции.<br>"
	return report_dat

/datum/mutiny_scenario/communism/get_second_report()
	var/report_dat = ""
	report_dat += "Исследовательская группа провела исследования продуктивности работы персонала.<br>"
	report_dat += "Данные указывают о повышении эффективности киборгов со специализацией на лечении экипажа.<br>"
	report_dat += "Центральное Коммандование увольняет сотрудников медицинского отдела на неустановленный срок.<br>"
	report_dat += "При желании остаться, сотруднику должен предоставиться выбор кибернетизировать своё тело.<br>"
	report_dat += "Все киборги на станции должны выбрать модули подходящие для работы в отсеках медбея и переместится в соответствующие помещения на постоянной основе.<br>"
	return report_dat

/datum/mutiny_scenario/communism/get_third_report()
	var/report_dat = ""
	report_dat += "Внешняя разведка сообщает о том, что в станционных киборгах и прототипах обнаружена намеренно установленная уязвимость.<br>"
	report_dat += "Задержите всех неимплантированных лояльностью, кто принимал участие в постройке или обслуживании юнитов, в бриг до выяснения обстоятельств.<br>"
	report_dat += "Смените законы ИИ на такие, которые не допускают предательства интересов корпорации.<br>"
	report_dat += "Центральное Коммандование приказывает закрыть отсек Разработок и Исследований для предотвращения подобных этой ситуаций.<br>"
	report_dat += "Все прототипы, созданные на станции, требуется поместить в хранилище улик до следующей смены.<br>"
	return report_dat

/datum/mutiny_scenario/brutality/get_first_report()
	var/report_dat = ""
	report_dat += "Новонанятый заместитель министра здравоохранения из компании Vey Med предложил улучшить качество питания на вашей станции.<br>"
	report_dat += "Центральное Коммандование приказывает отправить все торговые автоматы с едой грузовым шаттлом.<br>"
	report_dat += "Убедитесь, что у вас есть достаточно сотрудников связанных с выращиванием и приготовлением пищи.<br>"
	report_dat += "Следите, чтобы сотрудники станции не повредили автоматы во время транспортировки.<br>"
	report_dat += "При нанесении ущерба собственности корпорации разрешается временный перевод сотрудника в тестовые субъекты до следующей смены."
	return report_dat

/datum/mutiny_scenario/brutality/get_second_report()
	var/report_dat = ""
	report_dat += "Замминистр поделился с нами информацией о новом методе снабжения едой.<br>"
	report_dat += "По его словам слизни, которые были на вашей станции, превращают мясо своих жертв в особый деликатес.<br>"
	report_dat += "При питании, слизни разрушают твёрдые элементы волокон мышц, что увеличивает усваиваемость пищеварительного тракта.<br>"
	report_dat += "Центральное Коммандование приказывает накормить слизней живыми существами.<br>"
	report_dat += "Из-за инновации, допустимо в качестве корма использовать провинившихся тестовых субъектов.<br>"
	report_dat += "После кормёжки, передайте тела на в морозильную камеру кухни.<br>"
	report_dat += "Повара должны приготовить сбалансированные блюда, используя это мясо."
	return report_dat

/datum/mutiny_scenario/brutality/get_third_report()
	var/report_dat = ""
	report_dat += "Несколько офицеров Центрального Коммандования получили образец полученного мяса.<br>"
	report_dat += "По их заверениям, стоит поставить данную продукции Шахтёрской сети на астеродном поясе в вашей системе.<br>"
	report_dat += "Центральное Коммандование приказывает найти кандидатов для мясофикации.<br>"
	report_dat += "Свежее мясо необходимо отправить в структурах-морозильниках грузовым шаттлом.<br>"
	report_dat += "Не разглашайте экипажу информацию из этого сообщения."
	return report_dat

/datum/mutiny_scenario/mine/get_first_report()
	var/report_dat = ""
	report_dat += "Хранилище плазмы на ИСН Ками Хикари было потеряно.<br>"
	report_dat += "Центральное Коммандование приказывает увеличить добычу фороновых слитков.<br>"
	report_dat += "Мы отправляем дополнительное снаряжение для шахтёрских работ.<br>"
	report_dat += "Отправьте нам не менее 200 едениц ресурса как можно скорее."
	return report_dat

/datum/mutiny_scenario/mine/get_second_report()
	var/report_dat = ""
	report_dat += "Компания получила хранилище большего объема, чем те, что были ранее.<br>"
	report_dat += "Увеличьте поставки не менее чем в два раза, привлеките незанятый персонал к работам на полторы ставки.<br>"
	report_dat += "Отказ сотрудником выполнять приказы Центрального Коммандования недопустим.<br>"
	report_dat += "Убедитесь в наличии снабжения научным отсеком работников шахт передовыми разработками.
	report_dat += "При непродуктивной работе, рекомендуется перевод всего персонала Исследований и Разработок в шахтёров и грузчиков до выполнения плана поставок."
	return report_dat

/datum/mutiny_scenario/mine/get_third_report()
	var/report_dat = ""
	report_dat += ".<br>"
	report_dat += ".<br>"
	report_dat += ".<br>"
	return report_dat

/datum/mutiny_scenario/mine/do_first_strike()
	//do_postavka

/datum/mutiny_scenario/mine/do_second_strike()
	//do_postavka eshe bolshe
