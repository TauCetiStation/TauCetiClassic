/* GAME MODES */
/datum/announcement/centcomm/malf
	subtitle = "Сетевой Мониторинг"

/datum/announcement/station/gang
	subtitle = "Брандмауэр Станции"


/* Blob */
/datum/announcement/centcomm/blob/outbreak5
	name = "Blob: Level 5 Outbreak"
	subtitle = "Тревога. Биоугроза"
	message = "Подтвержден 5 уровень биологической угрозы на борту КСН Исход. " + \
			"Всему персоналу предотвратить распространение заражения. " + \
			"Активирован протокол изоляции экипажа станции."
	sound = "outbreak5"
/datum/announcement/centcomm/blob/outbreak5/play()
	message = "Подтвержден 5 уровень биологической угрозы на борту [station_name()]. " + \
			"Всему персоналу предотвратить распространение заражения. " + \
			"Активирован протокол изоляции экипажа станции."
	..()

/datum/announcement/centcomm/blob/critical
	name = "Blob: Blob Critical Mass"
	subtitle = "Тревога. Биоугроза"
	message = "Биологическая опасность достигла критической массы. Потеря станции неминуема."

/* Epidemic */
/datum/announcement/centcomm/epidemic/cruiser
	name = "Epidemic: Cruiser"
	subtitle = "Система Раннего Оповещения"
	message = "Подлетающий крейсер обнаружен на встречном курсе. " + \
			"Сканирование показывает наличие вооружения на борту и его готовность открыть огонь. " + \
			"Время прибытия: 5 минут."
/datum/announcement/centcomm/epidemic/cruiser/play()
	subtitle = "Система Раннего Оповещения [station_name()]"
	..()

/* Mutiny */
/datum/announcement/centcomm/mutiny/reveal
	name = "Mutiny: Directive Reveal"
	subtitle = "Черезвычайная Передача"
	message = "Входящая черезвычайная директива: факс в кабинете капитана, КСН Исход."
/datum/announcement/centcomm/mutiny/reveal/play()
	message = "Входящая черезвычайная директива: факс в кабинете капитана, [station_name()]."
	..()

/datum/announcement/centcomm/mutiny/noert
	name = "Mutiny: ERT is busy"
	subtitle = "Черезвычайная Передача"
	message = "Присутсвие ЭРИ в регионе требует все местные аварийные ресурсы. Сейчас отряд быстрого реагирования не может быть вызван."
/datum/announcement/centcomm/mutiny/noert/play(reason)
	if(reason)
		message = "Присутсвие [reason] в регионе требует все местные аварийные ресурсы. Сейчас отряд быстрого реагирования не может быть вызван."
	..()

/* Nuclear */
/datum/announcement/centcomm/nuclear/war
	name = "Nuclear: Declaration of War"
	subtitle = "Объявление Войны"
	message = "Синдикат объявил, что намерен полностью уничтожить станцию с помощю ядерного устройства и весь экипаж, что будет попытается их остановить."
/datum/announcement/centcomm/nuclear/war/play(message)
	if(message)
		src.message = message
	..()

/* Vox */
/datum/announcement/centcomm/vox/arrival
	name = "Vox: Shuttle Arrives"
	message = "Внимание, Космическая Станция 13, неподалёку от вашей станции проходит корабль не отвечающий на наши запросы. " + \
			"По последним данным этот корабль принадлежит Торговой Конфедерации."
/datum/announcement/centcomm/vox/arrival/play()
	message = "Внимание, [station_name()], неподалёку от вашей станции проходит корабль не отвечающий на наши запросы. " + \
			"По последним данным этот корабль принадлежит Торговой Конфедерации."

/datum/announcement/centcomm/vox/returns
	name = "Vox: Shuttle Returns"
	subtitle = "ВКН Икар"
	message = "Ваши гости улетают, Исход - двигаются слишком быстро, мы не можем навестись на них. " + \
			"Похоже они покидают систему без оглядки."
/datum/announcement/centcomm/vox/returns/play()
	message = "Ваши гости улетают, Исход - двигаются слишком быстро, мы не можем навестись на них. " + \
			"Похоже они покидают [system_name()] без оглядки."

/* Malfunction */
/datum/announcement/centcomm/malf/declared
	name = "Malf: Declared Victory"
	title = null
	subtitle = null
	message = null
	flags = ANNOUNCE_SOUND
	sound = "malf"

/datum/announcement/centcomm/malf/first
	name = "Malf: Announce №1"
	message = "Внимание, КСН Исход. Мы фиксируем необычные показатели в вашей сети. " + \
			"Кажется, кто-то пытается взломать ваши системы. Сообщим вам когда получим больше информации."
	sound = "malf1"
/datum/announcement/centcomm/malf/first/play()
	message = "Осторожно, [station_name]. Мы фиксируем необычные показатели в вашей сети. " + \
			"Вероятно кто-то пытается взломать ваши системы. Сообщим вам позже, когда получим больше информации."
	..()

/datum/announcement/centcomm/malf/second
	name = "Malf: Announce №2"
	message = "Мы начали отслеживать взломшика. Кто-бы это не делал, они находятся на самой станции. " + \
			"Предлагаем проверить все терминалы, управляющие сетью. Будем держать вас в курсе."
	sound = "malf2"

/datum/announcement/centcomm/malf/third
	name = "Malf: Announce №3"
	message = "Это крайне не нормально и сильно беспокоит. " + \
			"Взломщик слишком быстр, он обходит все попытки его выследить. Никто не может быть так быстр..."
	sound = "malf3"

/datum/announcement/centcomm/malf/fourth
	name = "Malf: Announce №4"
	message = "Мы отследили взломшик#, это каже@&# ва3) сист7ма ИИ, он# *#@амыает меха#7зм самоун@чт$#енiя. Оста*##ивте )то по*@!)$#&&@@  <СВЯЗЬ ПОТЕРЯНА>"
	sound = "malf4"

/* Gang */
/datum/announcement/station/gang/breach
	name = "Gang: Dominator Activation"
	message = "Network breach detected somewhere on the station. Some Gang is attempting to seize control of the station!"
/datum/announcement/station/gang/breach/play(area/A, gang)
	if(A && gang)
		message = "Network breach detected in [initial(A.name)]. The [gang_name(gang)] Gang is attempting to seize control of the station!"
	..()

/datum/announcement/station/gang/multiple
	name = "Gang: Multiple Dominators"
	message = "Multiple station takeover attempts have made simultaneously. Conflicting hostile runtimes appears to have delayed both attempts."
