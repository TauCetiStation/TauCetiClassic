/* STATION */
/datum/announcement/station
	title = "Приоритетное Оповещение"
	sound = "announce"
	flags = ANNOUNCE_TEXT | ANNOUNCE_SOUND
/datum/announcement/station/play()
	..()
	SSStatistics.add_communication_log(type = "station", title = title ? title : subtitle, author = announcer, content = message)

/datum/announcement/station/command/play(message)
	if(message)
		src.message = message
	..()

/datum/announcement/station/code
	title = null


/* Command */
/datum/announcement/station/command/department
	name = "Heads: Department"
	sound = "department"

/datum/announcement/station/command/department/captain
	name = "Heads: Captain"
	sound = "kep"

/datum/announcement/station/command/department/hop
	name = "Heads: Head of Personnel"
	sound = "hop"

/datum/announcement/station/command/department/hos
	name = "Heads: Head of Security"
	sound = "hos"

/datum/announcement/station/command/department/rd
	name = "Heads: Research Director"
	sound = "rd"

/datum/announcement/station/command/department/cmo
	name = "Heads: Chief Medical Officer"
	sound = "cmo"

/datum/announcement/station/command/department/ce
	name = "Heads: Chief Engineer"
	sound = "se"

/datum/announcement/station/command/department/play(department, message, mob/user)
	if(department && message)
		title = "Оповещение из [department]"
	announcer = user?.GetVoice()
	..(message)

/datum/announcement/station/command/ai
	name = "Heads: AI"
	title = "Оповещение от ИИ"
	sound = "aiannounce"
/datum/announcement/station/command/ai/play(mob/user, message)
	if(user && message)
		announcer = user.name
	..(message)

/* Alerts */
/datum/announcement/station/nuke
	name = "Alert: Nuke Activation"
	message =  "Тревога! На станции была обнаружена активация ядерной боеголовки!"
	sound = "nuke1"
/datum/announcement/station/nuke/play(area/A)
	if(A)
		message = "Тревога! На станции была обнаружена активация ядерной боеголовки [initial(A.name)]!"
	..()

/datum/announcement/station/nuke_teleport
	name = "Alert: Nuke Translocation"
	message =  "Обнаружено подпространственное перемещение ядерной боеголовки. Требуется немедленное вмешательство!"
	sound = "nuke2"

/datum/announcement/station/nuke_teleport/play(area/new_loc, area/old_loc)
	if(new_loc && old_loc)
		message = "Обнаружено подпространственное перемещение ядерной боеголовки из [initial(old_loc.name)] в [initial(new_loc.name)]. Требуется немедленное вмешательство!"
	..()

/datum/announcement/station/maint_revoke
	name = "Alert: Maintenance Access Revoked"
	sound = "maint_revoke"
	message = "Был аннулирован доступ на все технические туннели."

/datum/announcement/station/maint_readd
	name = "Alert: Maintenance Access Readded"
	sound = "maint_readd"
	message = "Требование доступа вернулось на все технические туннели."

/datum/announcement/station/gravity_on
	name = "Secret: Gravity On"
	message = "Генераторы гравитации снова функционируют с нормальными показателями. Приносим извинения за неудобства."
	sound = "gravon"
/datum/announcement/station/gravity_on/New()
	subtitle = "Система Предотвращения Аварий [station_name_ru()]"

/datum/announcement/station/gravity_off
	name = "Secret: Gravity Off"
	message = "Обнаружен всплеск ошибок в системе распределения массы. Дальнейшие ошибки могут привести к гравитационному коллапсу и формированию черной дыры. " + \
			"Для перезагрузки системы, искусственная гравитация будет выключена. Хорошего дня."
	sound = "gravoff"
/datum/announcement/station/gravity_off/New()
	subtitle = "Система Предотвращения Аварий [station_name_ru()]"

/* Shuttles */
/datum/announcement/station/shuttle/crew_called
	name = "Shuttle: Crew Called"
	message = "Процедура смены экипажа начата. Шаттл вызван. Он прибудет через несколько минут."
	sound = "crew_shut_called"
/datum/announcement/station/shuttle/crew_called/play()
	message = "Процедура смены экипажа начата. Шаттл вызван. Он прибудет через [shuttleminutes2text()]."
	..()

/datum/announcement/station/shuttle/crew_recalled
	name = "Shuttle: Crew Recalled"
	message = "Шаттл был отозван."
	sound = "crew_shut_recalled"

/datum/announcement/station/shuttle/crew_docked
	name = "Shuttle: Crew Docked"
	message = "Шаттл Транспортировки Экипажа пристыковался к станции в соответствии с расписанием. Отправление через несколько минут."
	sound = "crew_shut_docked"
/datum/announcement/station/shuttle/crew_docked/play()
	message = "Шаттл Транспортировки Экипажа пристыковался к станции в соответствии с расписанием. Отправление через [shuttleminutes2text()]."
	..()

/datum/announcement/station/shuttle/crew_left
	name = "Shuttle: Crew Left"
	message = "Шаттл Транспортировки Экипажа покинул станцию. Он прибудет на Центральное Командование через несколько минут."
	sound = "crew_shut_left"
/datum/announcement/station/shuttle/crew_left/play()
	message = "Шаттл Транспортировки Экипажа покинул станцию. Остается [shuttleminutes2text()] до стыковки шаттла к Центральному Командованию."
	..()


/datum/announcement/station/shuttle/emer_called
	name = "Shuttle: Emergency Called"
	message = "Эвакуационный Шаттл был вызван. Он прибудет через несколько минут."
	sound = "emer_shut_called"
/datum/announcement/station/shuttle/emer_called/play()
	message = "Эвакуационный Шаттл был вызван. Он прибудет через [shuttleminutes2text()]."
	..()

/datum/announcement/station/shuttle/emer_recalled
	name = "Shuttle: Emergency Recalled"
	message = "Эвакуационный Шаттл был отозван."
	sound = "emer_shut_recalled"

/datum/announcement/station/shuttle/emer_docked
	name = "Shuttle: Emergency Docked"
	message = "Эвакуационный Шаттл пристыковался к станции. У вас есть несколько минут для посадки."
	sound = "emer_shut_docked"
/datum/announcement/station/shuttle/emer_docked/play()
	message = "Эвакуационный Шаттл пристыковался к станции. У вас есть [shuttleminutes2text()] для посадки."
	..()

/datum/announcement/station/shuttle/emer_left
	name = "Shuttle: Emergency Left"
	message = "Эвакуационный Шаттл покинул станцию. Он прибудет на Центральное Командование через несколько минут."
	sound = "emer_shut_left"
/datum/announcement/station/shuttle/emer_left/play()
	message = "Эвакуационный Шаттл покинул станцию. Остается [shuttleminutes2text()] до стыковки шаттла к Центральному Командованию."
	..()

/* Security codes */
/datum/announcement/station/code/downtogreen
	name = "Code: Down to Green"
	subtitle = "Внимание! Код безопасности понижен до Зеленого."
	message = "Непосредственные или явные угрозы для станции отсутствуют. " + \
			"Служба безопасности обязана спрятать оружие, а также уважать личное право и пространство персонала, несанкционированные обыски запрещены."
	sound = "downtogreen"

/datum/announcement/station/code/uptoblue
	name = "Code: Up to Blue"
	subtitle = "Внимание! Код Синий."
	message = "Командование получило надежную информацию о возможной враждебной активности на борту станции. " + \
			"Служба безопасности может носить оружие на виду, однако, не следует вынимать его без необходимости. " + \
			"Разрешается личный обыск персонала и отсеков станции без предварительных санкций."
	sound = "blue"

/datum/announcement/station/code/downtoblue
	name = "Code: Down to Blue"
	subtitle = "Внимание! Код безопасности понижен до Синего"
	message = "Непосредственная угроза станции отсутствует. " + \
			"Служба безопасности не имеет права вынимать оружие, однако может носить его на виду. " + \
			"Спонтанные обыски всё еще разрешены."
	sound = "downtoblue"

/datum/announcement/station/code/uptored
	name = "Code: Up to Red"
	subtitle = "Внимание! Код красный!"
	message = "Существует прямая угроза станции или возможно причинение значительного ущерба. " + \
			"Боевое положение! Служба безопасности имеет право носить оружие наготове по собственному усмотрению. " + \
			"Рекомендуются спонтанные обыски персонала и отсеков. Весь персонал станции обязан оставаться в своих отделах. " + \
			"Весь персонал станции обязан повиноваться требованиям СБ и вышестоящих офицеров."
	sound = "red"

/datum/announcement/station/code/downtored
	name = "Code: Down to Red"
	subtitle = "Внимание! Код понижен до красного!"
	message = "Механизм самоуничтожения деактивирован и над ситуацией был вернут частичный контроль. " + \
			"Тем не менее существует прямая угроза станции. Служба безопасности имеет право носить оружие наготове по собственному усмотрению. " + \
			"Рекомендуются спонтанные обыски персонала и отсеков."
	sound = "downtored"

/datum/announcement/station/code/delta
	name = "Code: Up to Delta"
	subtitle = "Тревога! Код Дельта!"
	message = "Активирован механизм самоуничтожения или ситуация вышла полностью из под контроля! " + \
			"Все приказы глав станции должны выполняться беспрекословно, любое неповиновение карается смертью! " + \
			"Всему персоналу перевести датчики костюмов в третий режим! Это не учебная тревога!"
	sound = "delta"
