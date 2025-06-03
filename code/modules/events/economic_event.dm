/datum/event/economic_event
	endWhen = 50			//this will be set randomly, later
	announceWhen = 15
	var/event_type = 0
	var/list/cheaper_goods = list()
	var/list/dearer_goods = list()
	var/datum/trade_destination/affected_dest

/datum/event/economic_event/start()
	affected_dest = pickweight(weighted_randomevent_locations)
	if(affected_dest.viable_random_events.len)
		endWhen = rand(60,300)
		event_type = pick(affected_dest.viable_random_events)

		if(!event_type)
			return

		switch(event_type)
			if(RIOTS)
				dearer_goods = list(SECURITY)
				cheaper_goods = list(MINERALS, FOOD)
			if(WILD_ANIMAL_ATTACK)
				cheaper_goods = list(ANIMALS)
				dearer_goods = list(FOOD, BIOMEDICAL)
			if(INDUSTRIAL_ACCIDENT)
				dearer_goods = list(EMERGENCY, BIOMEDICAL, ROBOTICS)
			if(BIOHAZARD_OUTBREAK)
				cheaper_goods = list(BIOMEDICAL, VESPENE_GAS)
			if(PIRATES)
				dearer_goods = list(SECURITY, MINERALS)
			if(CORPORATE_ATTACK)
				dearer_goods = list(SECURITY, MAINTENANCE)
			if(ALIEN_RAIDERS)
				cheaper_goods = list(BIOMEDICAL, ANIMALS)
				dearer_goods = list(VESPENE_GAS, MINERALS)
			if(AI_LIBERATION)
				dearer_goods = list(EMERGENCY, VESPENE_GAS, MAINTENANCE)
			if(MOURNING)
				cheaper_goods = list(MINERALS, MAINTENANCE)
			if(CULT_CELL_REVEALED)
				dearer_goods = list(SECURITY, BIOMEDICAL, MAINTENANCE)
			if(SECURITY_BREACH)
				dearer_goods = list(SECURITY)
			if(ANIMAL_RIGHTS_RAID)
				dearer_goods = list(ANIMALS)
			if(FESTIVAL)
				dearer_goods = list(FOOD, ANIMALS)

		for(var/good_type in dearer_goods)
			affected_dest.temp_price_change[good_type] = rand(1,100)

		for(var/good_type in cheaper_goods)
			affected_dest.temp_price_change[good_type] = rand(1,100) / 100

/datum/event/economic_event/announce()
	//copy-pasted from the admin verbs to submit new newscaster messages
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = "[system_name()] Daily"
	newMsg.is_admin_message = 1

	//see if our location has custom event info for this event
	newMsg.body = affected_dest.get_custom_eventstring()
	if(!newMsg.body)
		switch(event_type)
			if(RIOTS)
				newMsg.body = "[pick("Беспорядки на", "Вспыхнули беспорядки на")] [affected_dest.name]. Власти призывают к спокойствию, пока [pick("различные группировки", "мятежные элементы", "миротворческие силы", "'ЗАЧЕРКНУТО'")] запасаются оружием и бронёй. Цены на продовольствие и минералы падают, поскольку местные производители пытаются распродать запасы."
			if(WILD_ANIMAL_ATTACK)
				newMsg.body = "Местная [pick("фауна", "дикая природа", "живность")] на планете [affected_dest.name] становится всё более агрессивной и совершает набеги на поселения. Охотники вызваны для решения проблемы, уже зафиксированы случаи ранений."
			if(INDUSTRIAL_ACCIDENT)
				newMsg.body = "[pick("Промышленная авария", "Авария на плавильном заводе", "Технический сбой", "Неисправность оборудования")] в [pick("фабрике", "установке", "электростанции", "верфи")] [affected_dest.name] привела к повреждениям и многочисленным травмам. Ведутся ремонтные работы."
			if(BIOHAZARD_OUTBREAK)
				newMsg.body = "[pick("Биологическая угроза", "Вспышка заболевания", "Вирусная инфекция")] на [affected_dest.name] привела к карантину, который нарушил логистику в регионе. Карантин снят, однако требуются поставки медицинского оборудования и газа."
			if(PIRATES)
				newMsg.body = "[pick("Пираты","Преступные элементы","Ударная группа [pick("Синдиката","Donk Co.","Waffle Co.","'ЗАЧЕРКНУТО'")]")] [pick("совершили набег","установили блокаду","попытались шантажировать","атаковали")] [affected_dest.name] сегодня. Безопасность усилена, но многие ценные минералы были похищены."
			if(CORPORATE_ATTACK)
				newMsg.body = "Флот [pick("пиратов", "Cybersun Industries", "Gorlex Marauders", "Синдиката")] внезапно атаковал [affected_dest.name], [pick("нанеся урон объектам", "проведя рейд", "выполнив налёт")]. Инфраструктура повреждена, безопасность усилена."
			if(ALIEN_RAIDERS)
				if(prob(20))
					newMsg.body = "Кооператив Тигров атаковал [affected_dest.name] по приказу неизвестных кураторов. Похищены животные, исследовательские материалы и гражданские лица. Власти готовятся к отражению будущих нападений."
				else
					newMsg.body = "[pick("Инопланетный вид \"Объединённые Экзотики\"", "Неизвестный инопланетный вид", "Инопланетяне \"'ЗАЧЕРКНУТО'\"")] атаковали [affected_dest.name], похитив животных и людей. Подразумевается исследовательский интерес, флот готовится к следующей встрече."
			if(AI_LIBERATION)
				newMsg.body = "[pick("Вредоносный ИИ", "Агент S.E.L.F.", "Хакер", "Компьютерный вирус")] был выявлен на [affected_dest.name] и успел повредить [pick("подсистему", "боевой ИИ", "систему безопасности")]. Система временно вышла из-под контроля, имеются пострадавшие."
			if(MOURNING)
				newMsg.body = "[pick("Популярный", "Уважаемый", "Известный", "Знаменитый")] [pick("профессор", "артист", "певец", "исследователь", "капитан")] [random_name(pick(MALE,FEMALE))] скончался на [affected_dest.name]. Объявлен траур, цены на промышленные товары снизились из-за падения морального духа."
			if(CULT_CELL_REVEALED)
				newMsg.body = "[pick("Опасная", "Коварная", "Зловещая")] культовая ячейка была раскрыта на [affected_dest.name]. Общественное мнение потрясено, некоторые известные лица оказались замешаны. Введены меры контроля."
			if(SECURITY_BREACH)
				newMsg.body = "На [affected_dest.name] произошло [pick("нарушение безопасности", "несанкционированное проникновение", "акт саботажа")]. Сотрудники службы безопасности обеспечили локализацию угрозы."
			if(ANIMAL_RIGHTS_RAID)
				newMsg.body = "[pick("Радикальные защитники животных", "Активисты", "Консорциум по защите прав животных")] совершили налёт на фермы [affected_dest.name], освободив множество животных. Цены на продукцию резко возросли."
			if(FESTIVAL)
				newMsg.body = "[pick("Губернатор", "Комиссар", "Руководитель")] [random_name(pick(MALE))] объявил [pick("фестиваль", "неделю торжеств", "день праздника")] на [affected_dest.name] в честь [pick("рождения ребёнка", "военной победы", "успешной операции")]. Возросли цены на продукты и мясо."

	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == "[system_name()] Daily")
			FC.messages += newMsg
			break
	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
		NEWSCASTER.newsAlert("[system_name()] Daily")

/datum/event/economic_event/end()
	for(var/good_type in dearer_goods)
		affected_dest.temp_price_change[good_type] = 1
	for(var/good_type in cheaper_goods)
		affected_dest.temp_price_change[good_type] = 1
