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
			// /obj/machinery/message_server/proc/send_pda_message(var/recipient = "",var/sender = "",var/message = "")
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
			switch(pick(1,2,3,4,5,6,7))
				if(1)
					sender = pick("MaxBet","MaxBet Online Casino","Нет лучшего времени для регистрации","Я рад, что ты присоединишься к нам")
					message = pick("Тройные депозиты ждут вас на MaxBet Online, когда вы зарегистрируетесь, чтобы играть у нас.",\
					"Вы можете получить 200% приветственный бонус в Max Bet Online, когда зарегистрируетесь сегодня.",\
					"Став игроком на MaxBet, вы также будете получать выгодные еженедельные и ежемесячные акции.",\
					"На MaxBet вы сможете насладиться более чем 450 первоклассными играми в казино.")
				if(2)
					sender = pick(300;"СистемаБыстрыхЗнакомств",200;"Найди свою русскую невесту",50;"Таяранские красавицы ждут",50;"Найди свою тайную влюбленность в скреллок",50;"Красивые невесты Согханки")
					message = pick("Ваш профиль привлек мое внимание, и я хотел написать и поздороваться (Быстрые Знакомства).",\
					"Если вы напишете мне на почту [pick(first_names_female)]@[pick(last_names)].[pick("ru","ck","tj","ur","nt")] Я обязательно пришлю вам фото (Быстрые Знакомства).",\
					"Я хочу, чтобы мы писали друг другу и надеюсь, что тебе понравится мой профиль и ты мне ответитишь (Быстрые Знакомства).",\
					"У вас одно новое сообщение!",\
					"У вас два новых просмотра профиля!")
				if(3)
					sender = pick("Галактическая Платежная Ассоциация","Лучшее Бизнес-Бюро","Тау Кита E-Payments","Финансовый Департамент НаноТрейзен","Копии Люкс")
					message = pick("Премиум часы Галактика по небольшой цене!",\
					"Часы, Ювелирные Изделия И Аксессуары, Сумки И Кошельки!",\
					"Вложите 100 кредитов и получите на 300% больше совершенно бесплатно!",\
					"Переходите по ссылке 100K.NT/WOWGOLD и получите ГОРЯЧИЕ ПРЕДЛОЖЕНИЕ 1000 кредитов совершенно БЕСПЛАТНО",\
					"Мы получили жалобу от одного из ваших клиентов на его деловые отношения с вами.",\
					"Убедительно просим Вас открыть ОТЧЕТ О ЖАЛОБЕ (прилагается), чтобы ответить на эту жалобу.")
				if(4)
					sender = pick("Приобретите Доктора Максмана","Имеете дисфункциональные проблемы?")
					message = pick("Доктор Максман: НАСТОЯЩИЕ доктора, НАСТОЯЩАЯ наука, НАСТОЯЩИЕ результаты!",\
					"Доктор Максман был создан Джорджем Акуиларом, доктором медицинских наук, сертифицированным урологом CentComm, который вылечил более 70 000 пациентов по всему сектору с 'мужскими проблемами'.",\
					"После семи лет исследований доктор Акуилар и его команда придумали эту простую революционную формулу улучшения мужских качеств...",\
					"Мужчины всех видов сообщают об УДИВИТЕЛЬНОМ увеличении длины, ширины и выносливости.")
				if(5)
					sender = pick("Доктор","Кронпринц","Король-Регент","Профессор","Капитан")
					sender += " " + pick("Роберт","Альфред","Джозефат","Кингсли","Сэхи","Збахи")
					sender += " " + pick("Мугаве", "Нкем", "Гбатоквия", "Нчеквубе", "Ндим", "Ндубиси")
					message = pick("ВАШ ФОНД БЫЛ ПЕРЕМЕЩЕН В [pick("Salusa","Segunda","Cepheus","Andromeda","Gruis","Corona","Aquila","ARES","Asellus")] БАНК РАЗВИТИЯ ДЛЯ ДАЛЬНЕЙШИХ ПЕРЕВОДОВ СРЕДСТВ.",\
					"Мы рады сообщить вам, что в связи с задержкой, нам было поручено НЕЗАМЕДЛИТЕЛЬНО внести все средства на ваш счет.",\
					"Уважаемый получатель средств, просим вас сообщить, что просроченная выплата средств была окончательно утверждена и выпущена к оплате.",\
					"В связи с отсутствием у меня агентов я требую, чтобы на внебиржевом финансовом счете была немедленно внесена сумма в размере 1 миллион кредитов.",\
					"Приветствую вас, сэр, с сожалением сообщаю, что, умирая здесь из-за отсутствия наследников, я выбрал вас, чтобы получить полную сумму моих пожизненных сбережений в размере 1,5 миллиарда кредитов.")
				if(6)
					sender = pick("Подразделение морального духа НаноТрейзен","Чувствуешь себя одиноко?","Скучно?","www.wetskrell.nt")
					message = pick("Подразделение морального духа НаноТрейзен хочет предоставить вам качественные развлекательные сайты.",\
					"WetSkrell.nt - это ксенофиллический веб-сайт, одобренный НТ для использования членами экипажа мужского пола среди множества станций и аванпостов.",\
					"Wetskrell.nt предоставляет только самое высокое качество мужских развлечений для сотрудников НаноТрейзен",\
					"Просто введите системный номер и PIN-код вашего счета в банке НаноТрейзен. Сделав три простых шага, развлекательные услуги WetSkrell.nt станут вашими!")
				if(7)
					sender = pick("Вы выиграли бесплатные билеты!", "Нажмите сюда, чтобы забрать свой приз!", "Вы - 1000-й посетитель!", "Вы - счастливый обладатель нашего главного приза!")
					message = pick("Вы выиграли билеты на новейший фильм ДВИЖЕНИЕ ДЖЕКСОНА!",\
					"Вы выиграли билеты на новейшую криминальную драму ДЕТЕКТИВНАЯ ЗАГАДКА В КАПЕРСАХ МОЛЛЮСКОВ!",\
					"Вы выиграли билеты на новейшую романтическую комедию 16 ПРАВИЛ ЛЮБВИ!",\
					"Вы выиграли билеты на новейший триллер КУЛЬТ СПЯЩЕГО!")

			useMS.send_pda_message("[P.owner]", sender, message)

			if (prob(50)) //Give the AI an increased chance to intercept the message
				for(var/mob/living/silicon/ai/ai in ai_list)
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
