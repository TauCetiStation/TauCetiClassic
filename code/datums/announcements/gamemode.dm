/* GAME MODES */
/datum/announcement/centcomm/malf
	subtitle = "Сетевой Мониторинг"

/* Blob */
/datum/announcement/centcomm/blob/outbreak5
	name = "Blob: Level 5 Outbreak"
	subtitle = "Тревога. Биоугроза"
	message = "Подтвержден 5 уровень биологической угрозы на борту КСН Исход. " + \
			"Всему персоналу предотвратить распространение заражения. " + \
			"Активирован протокол изоляции экипажа станции."
	sound = "outbreak5"
/datum/announcement/centcomm/blob/outbreak5/play()
	message = "Подтвержден 5 уровень биологической угрозы на борту [station_name_ru()]. " + \
			"Всему персоналу предотвратить распространение заражения. " + \
			"Активирован протокол изоляции экипажа станции."
	..()

/datum/announcement/centcomm/blob/critical
	name = "Blob: Blob Critical Mass"
	subtitle = "Тревога. Биоугроза"
	message = "Биологическая опасность достигла критической массы. Потеря станции неминуема."

/* Nuclear */
/datum/announcement/centcomm/nuclear/war
	name = "Nuclear: Declaration of War"
	subtitle = "Объявление Войны"
	message = "Синдикат объявил, что намерен полностью уничтожить станцию с помощю ядерного устройства и весь экипаж, что будет пытаться их остановить."
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
	message = "Внимание, [station_name_ru()], неподалёку от вашей станции проходит корабль не отвечающий на наши запросы. " + \
			"По последним данным этот корабль принадлежит Торговой Конфедерации."

/datum/announcement/centcomm/vox/returns
	name = "Vox: Shuttle Returns"
	subtitle = "ВКН Икар"
	message = "Ваши гости улетают, Станция 13 - двигаются слишком быстро, мы не можем навестись на них. " + \
			"Похоже они покидают систему без оглядки."
/datum/announcement/centcomm/vox/returns/play()
	message = "Ваши гости улетают, [station_name_ru()] - двигаются слишком быстро, мы не можем навестись на них. " + \
			"Похоже они покидают систему [system_name_ru()] без оглядки."

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
	message = "Осторожно, КСН Исход. Мы фиксируем необычные показатели в вашей сети. " + \
			"Вероятно кто-то пытается взломать ваши системы. Сообщим вам позже, когда получим больше информации."
	sound = "malf1"
/datum/announcement/centcomm/malf/first/play()
	message = "Осторожно, [station_name_ru()]. Мы фиксируем необычные показатели в вашей сети. " + \
			"Вероятно кто-то пытается взломать ваши системы. Сообщим вам позже, когда получим больше информации."
	..()

/datum/announcement/centcomm/malf/second
	name = "Malf: Announce №2"
	message = "Мы начали отслеживать взломшика. Кто-бы это не делал, они находятся на самой станции. " + \
			"Предлагаем проверить все терминалы, управляющие сетью. Будем держать вас в курсе."
	sound = "malf2"

/datum/announcement/centcomm/malf/third
	name = "Malf: Announce №3"
	message = "Это крайне не нормально и достаточно тревожно. " + \
			"Взломщик слишком быстр, он обходит все попытки его выследить. Это нечеловеческая скорость..."
	sound = "malf3"

/datum/announcement/centcomm/malf/fourth
	name = "Malf: Announce №4"
	message = "Мы отследили взломшик#, это каже@&# ва3) сист7ма ИИ, он# *#@амыает меха#7зм самоун@чт$#енiя. Оста*##ивте )то по*@!)$#&&@@  <СВЯЗЬ ПОТЕРЯНА>"
	sound = "malf4"
