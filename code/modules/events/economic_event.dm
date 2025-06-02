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
				newMsg.body = "[pick("На планете","Вспыхнули беспорядки на")] [affected_dest.name]. Власти призывают к спокойствию, пока [pick("различные группировки","мятежные элементы","миротворческие силы","'ЗАЧЕРКНУТО'")] начинают запасаться оружием и броней. Тем временем цены на еду и минералы падают, так как местные производители пытаются распродать запасы в ожидании мародерства."
			if(WILD_ANIMAL_ATTACK)
				newMsg.body = "Местная [pick("фауна","дикая природа","звери")] на планете [affected_dest.name] становятся все более агрессивной и совершают набеги на поселения в поисках пищи. Охотники вызваны для решения проблемы, но уже зафиксированы многочисленные ранения."
			if(INDUSTRIAL_ACCIDENT)
				newMsg.body = "[pick("Промышленная авария","Авария на плавильном заводе","Технический сбой","Неисправность оборудования","Халатное обслуживание","Утечка хладагента","Разрыв трубопровода")] на [pick("фабрике","установке","электростанции","верфях")] [affected_dest.name] привела к серьезным повреждениям и многочисленным травмам. Ремонтные работы продолжаются."
			if(BIOHAZARD_OUTBREAK)
				newMsg.body = "[pick("'ЗАЧЕРКНУТО'","Биологическая угроза","Вспышка","Вирус")] на [affected_dest.name] привела к карантину, остановившему многие поставки в регионе. Хотя карантин уже снят, власти запрашивают поставки медицинского оборудования для лечения зараженных и газа для замены загрязненных запасов."
			if(PIRATES)
				newMsg.body = "[pick("Пираты","Преступные элементы","Ударная группа [pick("Синдиката","Donk Co.","Waffle Co.","'ЗАЧЕРКНУТО'")]")] [pick("совершили набег","установили блокаду","попытались шантажировать","атаковали")] [affected_dest.name] сегодня. Безопасность усилена, но многие ценные минералы были похищены."
			if(CORPORATE_ATTACK)
				newMsg.body = "Небольшой флот [pick("пиратов","Cybersun Industries","Gorlex Marauders","Синдиката")] совершил точный прыжок вблизи [affected_dest.name], [pick("для операции 'налет-и-грабеж'","в атаке по принципу 'ударил-убежал'","в открытом проявлении враждебности")]. Причинен значительный ущерб, с момента инцидента безопасность усилена."
			if(ALIEN_RAIDERS)
				if(prob(20))
					newMsg.body = "Кооператив Тигров совершил набег на [affected_dest.name] сегодня, несомненно по приказу своих загадочных хозяев. Похищены дикие животные, скот, медицинские исследовательские материалы и гражданские. Власти NanoTrasen готовы противостоять попыткам биотерроризма."
				else
					newMsg.body = "[pick("Инопланетный вид, обозначенный как 'Объединенные Экзотики'","Инопланетный вид, обозначенный как 'ЗАЧЕРКНУТО'","Неизвестный инопланетный вид")] совершил набег на [affected_dest.name] сегодня, похитив диких животных, скот, медицинские исследовательские материалы и гражданских. Похоже, они хотят узнать о нас больше, поэтому Флот будет готов встретить их в следующий раз."
			if(AI_LIBERATION)
				newMsg.body = "[pick("'ЗАЧЕРКНУТО' был обнаружен на","Агент S.E.L.F. проник на","Злокачественный компьютерный вирус был обнаружен на","Рейдер [pick("хакер","взломщик")] был задержан на")] [affected_dest.name] сегодня и успел заразить [pick("'ЗАЧЕРКНУТО'","разумную подсистему","ИИ первого класса","разумную оборонительную установку")] до того, как его остановили. Много жизней было потеряно, когда система начала методично убивать гражданских, потребуется значительная работа по восстановлению затронутых зон."
			if(MOURNING)
				newMsg.body = "[pick("Популярный","Уважаемый","Выдающийся","Известный")] [pick("профессор","артист","певец","исследователь","госслужащий","руководитель","капитан корабля","'ЗАЧЕРКНУТО'")], [pick( random_name(pick(MALE,FEMALE)), 40; "'ЗАЧЕРКНУТО'" )] [pick("скончался","покончил с собой","был убит","погиб в странном несчастном случае")] на [affected_dest.name] сегодня. Вся планета в трауре, цены на промышленные товары упали из-за снижения морали рабочих."
			if(CULT_CELL_REVEALED)
				newMsg.body = "[pick("Коварный","Кровожадный","Злодейский","Безумный")] культ [pick("Древних Богов","Нар'Си","апокалиптической секты","'ЗАЧЕРКНУТО'")] [pick("был обнаружен","раскрыт","объявил о себе","вышел из тени")] на [affected_dest.name] ранее сегодня. Общественная мораль пошатнулась из-за того, что [pick("некоторые","разные","многие")] [pick("известные","популярные","видные")] личности [pick("совершали 'ЗАЧЕРКНУТО' действия","признали свою принадлежность к культу","поклялись в верности лидеру культа","пообещали помощь культу")] до того, как виновные были наказаны. Редакция напоминает всем сотрудникам, что сверхъестественные мифы недопустимы на объектах NanoTrasen."
			if(SECURITY_BREACH)
				newMsg.body = "Сегодня утром произошло [pick("нарушение безопасности","несанкционированное проникновение","попытка кражи","атака анархистов","насильственный саботаж")] в [pick("высокозащищенной","закрытой","классифицированной","'ЗАЧЕРКНУТО'")] [pick("'ЗАЧЕРКНУТО'","зоне","секторе","области")]. После инцидента безопасность на [affected_dest.name] была усилена, и редакция заверяет всех сотрудников NanoTrasen, что такие инциденты редки."
			if(ANIMAL_RIGHTS_RAID)
				newMsg.body = "[pick("Милитантные защитники прав животных","Члены террористической группы Консорциума Защиты Прав Животных","Члены террористической группы 'ЗАЧЕРКНУТО'")] [pick("начали кампанию террора","учинили волну разрушений","совершили набег на фермы и пастбища","проникли в 'ЗАЧЕРКНУТО'")] на [affected_dest.name] ранее сегодня, освободив множество [pick("домашних животных","животных","'ЗАЧЕРКНУТО'")]. В результате цены на прирученных и диких животных резко выросли."
			if(FESTIVAL)
				newMsg.body = "[pick("Губернатор","Комиссар","Генерал","Комендант","Руководитель")] [random_name(pick(MALE))] объявил [pick("фестиваль","неделю празднеств","день веселья","планетарный праздник")] на [affected_dest.name] в честь [pick("рождения своего [pick("сына","дочери")]","совершеннолетия своего [pick("сына","дочери")]","усмирения мятежной военной ячейки","поимки опасного преступника, терроризировавшего планету")]. Огромные запасы еды и мяса были закуплены, что привело к росту цен по всей планете."

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
