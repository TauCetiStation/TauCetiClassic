/datum/event/pda_spam
	endWhen = 6000
	var/last_spam_time = 0
	var/obj/machinery/message_server/useMS

/datum/event/pda_spam/setup()
	last_spam_time = world.time
	for (var/obj/machinery/message_server/MS in message_servers)
		if(MS.active)
			useMS = MS
			break

/datum/event/pda_spam/tick()
	if(world.time > last_spam_time + 1200)
		//if there's no server active for two minutes, give up
		kill()
		return

	if(!useMS || !useMS.active)
		useMS = null
		if(message_servers)
			for (var/obj/machinery/message_server/MS in message_servers)
				if(MS.active)
					useMS = MS
					break

	if(useMS)
		last_spam_time = world.time
		if(prob(2))
			var/obj/item/device/pda/P
			var/list/viables = list()
			for(var/obj/item/device/pda/check_pda in sortAtom(PDAs))
				if (!check_pda.owner||check_pda.toff||check_pda == src||check_pda.hidden)
					continue
				viables.Add(check_pda)

			if(!viables.len)
				return
			P = pick(viables)

			var/sender
			var/message
			switch(pick(1,2,3,4,5,6,7,8))
				if(1)
					sender = pick("ВоксБэт","ТауБэт","ВокСтавка","Ставки на Лазертаг","Ставки на Голоспорт")
					message = pick("Тройные депозиты, ставки, казино всё это и не только на [sender]!",\
					"Зарегистрируйтесь на [sender] сегодня и получайте игровые бонусы!",\
					"Став игроком на [sender], вы будете получать выгодные еженедельные акции и промокоды на 100 кредитов ежемесячно. Пройдите регистрацию прямо сейчас!",\
					"Более 450 первоклассных азартных игр, крупные выигрыши, надежность и проверенный миллионами пользователей сервис ожидают вас. [sender]!")
				if(2)
					sender = pick(300;"СистемаБыстрыхЗнакомств",200;"Найди свою Марсианскую невесту",50;"Таяранские красавицы ждут",50;"Найди свою тайную Скрелльскую возлюбленную",50;"Горячие Согханки Могеса")
					message = pick("Ваш профиль привлек мое внимание и я хотела бы узнать вас поближе. (Быстрые Знакомства).",\
					"Напишете мне на почту [pick(first_names_female)]@[pick(last_names)].[pick("ru","ck","tj","ur","nt")] и я обязательно отправлю вам мое фото. (Быстрые Знакомства).",\
					"Я хотела бы переписываться с вами. Надеюсь, что вы лайкните мой профиль и ответите мне. (Быстрые Знакомства).",\
					"У вас одно непрочитанное сообщение!",\
					"Ваше фото профиля, получило две новые симпатии.")
				if(3)
					if(global.online_shop_lots.len)
						sender = CARGOSHOPNAME

						var/list/available_items = list()
						for(var/datum/shop_lot/lot in global.online_shop_lots)
							if(lot.sold)
								continue
							available_items += lot

						if(available_items.len)
							var/datum/shop_lot/lot_item = pick(available_items)
							message = "[lot_item.name] всего за [lot_item.get_discounted_price()]$! Успейте купить!"
						else
							message = "Начните зарабатывать с крупнейшим онлайн-магазином станции! Покупают ваши коллеги, а зарабатываете вы!"
					else
						sender = pick("Галактическая Платежная Ассоциация","Лучшее Бюро Бизнеса","Электронные выплаты Тау Кита","Финансовый Департамент НаноТрейзен","Роскошные реплики")
						message = pick("Роскошные часы по взрывным ценам!",\
						"Часы, Ювелирные Изделия и Аксессуары, Сумки и Модные Кошельки!",\
						"Вложите первые 100 кредитов и получите 300 кредитов кэшбэка совершенно бесплатно!",\
						"100K NT.|WOWGOLD всего за 89 кредитов! <ГОРЯЧЕЕ ПРЕДЛОЖЕНИЕ>",\
						"Мы получили жалобу от одного из ваших клиентов о его деловых отношениях с вами.",\
						"Убедительно просим вас открыть ОТЧЕТ О ЖАЛОБЕ (прилагается), чтобы ответить на эту жалобу.")
				if(4)
					sender = pick("Наймите Доктора Максмана","Проблемы с эрекцией?")
					message = pick("ДОКТОР МАКСМАН: НАСТОЯЩИЕ Врачи, НАСТОЯЩАЯ Наука, НАСТОЯЩИЕ Результаты!",\
					"Доктор Максман был создан Джорджем Алленом, магистром медицинских наук, сертифицированным урологом ЦентрКома, который вылечил более 70 000 пациентов во всем секторе от 'мужских проблем'.",\
					"После семи лет исследований, Доктор Аллен и его команда придумали эту простую и революционную формулу улучшения мужской силы, которая состоит из пяти... <Читать далее>",\
					"Мужчины всех видов сообщают об ПОТРЯСАЮЩЕМ увеличении длины, ширины и выносливости всего от трех... <Читать далее>")
				if(5)
					sender = pick("Доктор","Кронпринц","Король-Регент","Профессор","Капитан")
					sender += " " + pick("Роберт","Альфред","Джозефат","Кингсли","Сэхи","Збахи")
					sender += " " + pick("Мугаве", "Нкем", "Гбатоквия", "Нчеквубе", "Ндим", "Ндубиси")
					message = pick("ВАШ СЧЕТ БЫЛ ПЕРЕМЕЩЕН В БАНК РАЗВИТИЯ [pick("Salusa","Segunda","Cepheus","Andromeda","Gruis","Corona","Aquila","ARES","Asellus")]  ДЛЯ ДАЛЬНЕЙШИХ ПЕРЕВОДОВ СРЕДСТВ.",\
					"Мы рады сообщить, что в связи с задержкой, нам было поручено НЕЗАМЕДЛИТЕЛЬНО перевести все средства на ваш счет.",\
					"Уважаемый получатель средств. Мы рады вам сообщить, что просроченная выплата средств была окончательно утверждена и переведена на ваш счет.",\
					"В связи с нехваткой моих агентов, мне требуется независимый финансовый счет, чтобы немедленно перевести на него ОДИН МИЛЛИОН кредитов.",\
					"Приветствую вас, сэр. С сожалением сообщаю, что я умираю. И из-за отсутствия наследников я выбрал вас, чтобы перевести полную сумму моих сбережений в размере 1,5 миллиарда кредитов.")
				if(6)
					sender = pick("Подразделение морального духа НаноТрейзен","Одиноко?","Скучно?","www.wetskrell.nt")
					message = pick("Подразделение морального духа НаноТрейзен хочет обеспечить вас качественными развлекательными сайтами.",\
					"WetSkrell.nt - это ксенофильный веб-сайт, одобренный НТ для использования членами экипажа мужского пола во множестве станций и аванпостов.",\
					"Wetskrell.nt предоставляет только самое высокое качество мужских развлечений для сотрудников НаноТрейзен!",\
					"Просто введите номер вашего счета и PIN-код. Сделав три простых шага, сервис развлекательных услуг станет вашим!")
				if(7)
					sender = pick("Вы выиграли бесплатные билеты!", "Нажмите сюда, чтобы забрать свой приз!", "Вы - 1000-й посетитель!", "Вы счастливый обладатель нашего гран-при!")
					message = pick("Вы выиграли билеты на новейший фильм ЗВЕЗДА ПО ИМЕНИ ТАУ!",\
					"Вы выиграли билеты на новейшую криминальную драму ДЕТЕКТИВНАЯ ЗАГАДКА В КАПЕРСАХ МОЛЛЮСКОВ!",\
					"Вы выиграли билеты на новейшую романтическую комедию 16 ПРАВИЛ ЛЮБВИ!",\
					"Вы выиграли билеты на новейший триллер КУЛЬТ ВСЕСПЯЩЕГО!")
				if(8)
					if(global.online_shop_lots.len)
						sender = CARGOSHOPNAME

						var/list/available_items = list()
						for(var/datum/shop_lot/lot in global.online_shop_lots)
							if(!lot || lot.sold)
								continue
							available_items += lot

						if(available_items.len)
							var/datum/shop_lot/lot_item = pick(available_items)
							message = "[lot_item.name] всего за [lot_item.get_discounted_price()]$! Успейте купить!"
						else
							message = "Начните зарабатывать с крупнейшим онлайн-магазином станции! Покупают ваши коллеги, а зарабатываете вы!"
					else
						sender = pick("Вайлдбананас", "Таяразон", "Вокс-Маркет", "Товарочка", "Красное и Чёрное")
						message = pick("Стоит взглянуть! Из всех объявлений о продаже шаттла мы выбрали 12. Они больше всего похожи на то, что вы искали. Посмотрите — среди них может быть подходящее предложение.",\
						"Успейте до повышения цен! Запасайтесь товарами для работы и творчества!",\
						"Начало выгодных недель! Новые товары со скидкой до 50%",\
						"Ваше объявление в избранном у 6 человек!",\
						"Скидки до 50% и кэшбэк 23%! Лучшие подарки к праздникам!")

			useMS.send_pda_message("[P.owner]", sender, message)

			if (prob(50)) //Give the AI an increased chance to intercept the message
				for(var/mob/living/silicon/ai/ai as anything in ai_list)
					// Allows other AIs to intercept the message but the AI won't intercept their own message.
					if(ai.pda != P && ai.pda != src)
						to_chat(ai, "<i>Перехваченное сообщение от <b>[sender]</b></i> (Неизвестно / спам?) <i>to <b>[P:owner]</b>: [message]</i>")

			//Commented out because we don't send messages like this anymore.  Instead it will just popup in their chat window.
			//P.tnote += "<i><b>&larr; From [sender] (Unknown / spam?):</b></i><br>[message]<br>"

			if (!P.message_silent)
				playsound(P, 'sound/machines/twobeep.ogg', VOL_EFFECTS_MASTER)
			if(!P.message_silent)
				P.audible_message("[bicon(P)] *[P.ttone]*", hearing_distance = 3)
			//Search for holder of the PDA.
			var/mob/living/L = null
			if(P.loc && isliving(P.loc))
				L = P.loc
			//Maybe they are a pAI!
			else
				L = get(P, /mob/living/silicon)

			if(L)
				to_chat(L, "[bicon(P)] <b>Сообщение от [sender] (Неизвестно / спам?), </b>\"[message]\" (Невозможно ответить)")
