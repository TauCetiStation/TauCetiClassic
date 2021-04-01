/* STATION */
/datum/announcement/station
	title = "Priority Announcement"
	sound = "announce"
	flags = ANNOUNCE_TEXT | ANNOUNCE_SOUND
/datum/announcement/station/play()
	..()
	add_communication_log(type = "station", title = title ? title : subtitle, author = announcer, content = message)

/datum/announcement/station/command/play(message)
	if(message)
		src.message = message
	..()

/datum/announcement/station/code
	title = null


/* Command */
/datum/announcement/station/command/department
	name = "Heads: Department"
/datum/announcement/station/command/department/play(department, message)
	if(department && message)
		title = "[department] Announcement"
	..(message)

/datum/announcement/station/command/ai
	name = "Heads: AI"
	title = "A.I. Announcement"
	sound = "aiannounce"
/datum/announcement/station/command/ai/play(mob/user, message)
	if(user && message)
		announcer = user.name
	..(message)

/* Alerts */
/datum/announcement/station/nuke
	name = "Alert: Nuke Activation"
	message = "Обнаружена активация ядерной боеголовки на борту станции. Кто-то пытается взорвать станцию!"
	sound = "nuke"
/datum/announcement/station/nuke/play(area/A)
	if(A)
		message = "Обнаружена активация ядерной боеголовки в [initial(A.name)]. Кто-то пытается взорвать станцию!"
	..()

/datum/announcement/station/maint_revoke
	name = "Alert: Maintenance Access Revoked"
	message = "The maintenance access requirement has been revoked on all airlocks."

/datum/announcement/station/maint_readd
	name = "Alert: Maintenance Access Readded"
	message = "The maintenance access requirement has been readded on all airlocks."

/datum/announcement/station/gravity_on
	name = "Secret: Gravity On"
	subtitle = "Station Fail-Safe System"
	message = "Генератор гравитации вновь работает в штатном режиме. Приносим свои извинения за внеплановое восхождение человека с земли на небо."
	sound = "gravon"
/datum/announcement/station/gravity_on/play()
	subtitle = "[station_name()] Fail-Safe System"
	..()

/datum/announcement/station/gravity_off
	name = "Secret: Gravity Off"
	subtitle = "Station Fail-Safe System"
	message = "Обнаружен всплеск обратной связи не очень-то массивных масс-распределителей. " + \
			"Рукотворная гравитация отключена на время повторного осознания системой всех своих внутренних страхов и противоречий."
	sound = "gravoff"
/datum/announcement/station/gravity_off/play()
	subtitle = "[station_name()] Fail-Safe System"
	..()

/* Shuttles */
/datum/announcement/station/shuttle/crew_called
	name = "Shuttle: Crew Called"
	message = "Трансферный шаттл отправлен. Он прибудет в целости и сохранности. Когда-нибудь. Но мы вам этого не гарантируем."
	sound = "crew_shut_called"
/datum/announcement/station/shuttle/crew_called/play()
	message = "Трансферный шаттл отправлен. Он прибудет в целости и сохранности. Через [shuttleminutes2text()] минут. Но мы вам этого не гарантируем."
	..()

/datum/announcement/station/shuttle/crew_recalled
	name = "Shuttle: Crew Recalled"
	message = "Внимание, шаттл отозван. ШО, ОПЯТЬ?."
	sound = "crew_shut_recalled"

/datum/announcement/station/shuttle/crew_docked
	name = "Shuttle: Crew Docked"
	message = "Трансферный шаттл успешно пристыковался к станции. Мы сами удивлены. Единая Тау Кита. Занимайте места согласно купленным билетам. Мы отправимся тогда, когда я этого захочу."
	sound = "crew_shut_docked"
/datum/announcement/station/shuttle/crew_docked/play()
	message = "Трансферный шаттл успешно пристыковался к станции. Мы сами удивлены. Единая Тау Кита. Занимайте места согласно купленным билетам. Мы отправимся через [shuttleminutes2text()] минут."
	..()

/datum/announcement/station/shuttle/crew_left
	name = "Shuttle: Crew Left"
	message = "Трансферный шаттл покинул станцию. Слава NT и добро пожаловать отсюда."
	sound = "crew_shut_left"
/datum/announcement/station/shuttle/crew_left/play()
	message = "Трансферный шаттл покинул станцию. Слава NT и добро пожаловать отсюда. Прибудем через [shuttleminutes2text()] минут."
	..()


/datum/announcement/station/shuttle/emer_called
	name = "Shuttle: Emergency Called"
	message = "Вызван аварийный шаттл. Он прибудет в скором времени."
	sound = "emer_shut_called"
/datum/announcement/station/shuttle/emer_called/play()
	message = "Вызван аварийный шаттл. Он прибудет через [shuttleminutes2text()] минут."
	..()

/datum/announcement/station/shuttle/emer_recalled
	name = "Shuttle: Emergency Recalled"
	message = "Аварийный шаттл отозван."
	sound = "emer_shut_recalled"

/datum/announcement/station/shuttle/emer_docked
	name = "Shuttle: Emergency Docked"
	message = "Аварийный шаттл прибывает на станцию. Начата посадка на рейс Исход - Центральное Коммандование."
	sound = "emer_shut_docked"
/datum/announcement/station/shuttle/emer_docked/play()
	message = "Аварийный шаттл прибывает на станцию. Начата посадка на рейс Исход - Центральное Коммандование. Осталось [shuttleminutes2text()] минут."
	..()

/datum/announcement/station/shuttle/emer_left
	name = "Shuttle: Emergency Left"
	message = "Аварийный шаттл отбывает с платформы. Следующая остановка Центральное Коммандование."
	sound = "emer_shut_left"
/datum/announcement/station/shuttle/emer_left/play()
	message = "Аварийный шаттл отбывает с платформы. Следующая остановка Центральное Коммандование. Прибытие через [shuttleminutes2text()] минут."
	..()

/* Security codes */
/datum/announcement/station/code/downtogreen
	name = "Code: Down to Green"
	subtitle = "Внимание! Уровень тревоги понижен до Зелёного!"
	message = "Охрана больше не может ходить с оружием на виду. Соблюдение личных прав сведено к норме."
	sound = "downtogreen"

/datum/announcement/station/code/uptoblue
	name = "Code: Up to Blue"
	subtitle = "Внимание! Уровень тревоги поднят до Синего!"
	message = "Руководство станции получило достоверную информацию о враждебной активности на борту станции. Охранный персонал может держать оружие на виду. Разрешены случайные обыски."
	sound = "blue"

/datum/announcement/station/code/downtoblue
	name = "Code: Down to Blue"
	subtitle = "Внимание! Уровень тревоги понижен до Синего!"
	message = "Охранный персонал не может больше держать оружие наготове, но может держать его на виду. Случайные обыски разрешены."
	sound = "downtoblue"

/datum/announcement/station/code/uptored
	name = "Code: Up to Red"
	subtitle = "Внимание! Код Красный!"
	message = "Присутствует прямая серьезная угроза станции. Случайные обыски разрешены и рекомендуемы."
	sound = "red"

/datum/announcement/station/code/downtored
	name = "Code: Down to Red"
	subtitle = "Внимание! Код Красный!"
	message = "Механизм самоунитожения станции был отключён, но прямая угроза станции всё ещё присутствует. Случайные обыски разрешены и рекомендуемы."
	sound = "downtored"

/datum/announcement/station/code/delta
	name = "Code: Up to Delta"
	subtitle = "Внимание! Достигнут уровень тревоги Дельта!"
	message = "Был взведён механизм самоуничтожения станции. Весь персонал должен бесприкословно выполнять приказы глав. Любое неповиновение может караться смертью. Это не буровая установка."
	sound = "delta"
