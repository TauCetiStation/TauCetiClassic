/* GAME MODES */
/datum/announcement/centcomm/malf
	subtitle = "Сетевой Мониторинг"

/* Blob */
/datum/announcement/centcomm/blob/outbreak5
	name = "Blob: Level 5 Outbreak"
	subtitle = "Тревога. Биоугроза"
	sound = "outbreak5"
/datum/announcement/centcomm/blob/outbreak5/play()
	message = "Подтвержден 5 уровень биологической угрозы на борту [station_name_ru()]. " + \
			"Персонал должен предотвратить распространение заражения. " + \
			"Активирован протокол изоляции экипажа станции."
	..()

/datum/announcement/centcomm/blob/critical
	name = "Blob: Blob Critical Mass"
	subtitle = "Тревога. Биоугроза"
	message = "Биологическая опасность достигла критической массы. Потеря станции неминуема."

/datum/announcement/centcomm/blob/biohazard_station_unlock
	name = "Biohazard Level Updated - Lock Down Lifted"
	subtitle = "Biohazard Alert"
	message = "Вспышка биологической угрозы успешно локализована. Карантин снят. Удалите биологически опасные материалы и возвращайтесь к исполнению своих обязанностей."

/* Nuclear */
/datum/announcement/centcomm/nuclear/war
	name = "Nuclear: Declaration of War"
	subtitle = "Объявление Войны"
	message = "Синдикат объявил о намерении полностью уничтожить станцию с помощью ядерного устройства. И всех, кто попытается их остановить."
/datum/announcement/centcomm/nuclear/war/play(message)
	if(message)
		src.message = message
	..()

/* Vox */
/datum/announcement/centcomm/vox/arrival
	name = "Vox: Shuttle Arrives"
/datum/announcement/centcomm/vox/arrival/play()
	message = "Внимание, [station_name_ru()], неподалёку от вашей станции проходит корабль не отвечающий на наши запросы. " + \
			"По последним данным, этот корабль принадлежит Торговой Конфедерации."

/datum/announcement/centcomm/vox/returns
	name = "Vox: Shuttle Returns"
	subtitle = "ВКН Икар"
/datum/announcement/centcomm/vox/returns/play()
	message = "Ваши гости улетают, [station_name_ru()]. Они движутся слишком быстро, что бы мы могли навестись на них. " + \
			"Похоже, они покидают систему [system_name_ru()] без оглядки."

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
	sound = "malf1"
/datum/announcement/centcomm/malf/first/play()
	message = "Осторожно, [station_name_ru()]. Мы фиксируем необычные показатели в вашей сети. " + \
			"Похоже, кто-то пытается взломать ваши электронные системы. Мы сообщим вам, когда у нас будет больше информации."
	..()

/datum/announcement/centcomm/malf/second
	name = "Malf: Announce №2"
	message = "Мы начали отслеживать взломщика. Кто-бы это не делал, они находятся на самой станции. " + \
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

/* Cult */
/datum/announcement/station/cult/capture_area
	name = "Anomaly: Bluespace"
	message = "На сканерах дальнего действия обнаружена нестабильная блюспейс аномалия. Ожидаемое местоположение: неизвестно."
	sound = "bluspaceanom"
/datum/announcement/station/cult/capture_area/play(area/A)
	if(A)
		message = "На сканерах дальнего действия обнаружена нестабильная блюспейс аномалия. Ожидаемое местоположение: [A.name]."
	..()
