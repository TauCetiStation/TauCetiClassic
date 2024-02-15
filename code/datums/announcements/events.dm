/* EVENTS */
/datum/announcement/centcomm/anomaly
	subtitle = "Тревога. Аномалия"

/datum/announcement/centcomm/anomaly/frost
	name = "Anomaly: Frost"
	message = "На сканерах дальнего действия обнаружена атмосферная аномалия. Ожидается снижение температуры станции."
	sound = "frost"

/datum/announcement/centcomm/access_override
	name = "Secret: Egalitarian"
	message = "Центком перегрузил контроль доступа шлюзов. Воспользуйтесь этим временем для знакомства с вашими коллегами."
	sound = "access_override"

/datum/announcement/centcomm/anomaly/radstorm
	name = "Anomaly: Radiation Belt"
	message = "Станция приближается к зоне с высоким уровнем радиации. " + \
			"Всему экипажу станции срочно укрыться в технических туннелях станции. "
	sound = "radiation"

/datum/announcement/centcomm/anomaly/radstorm_passed
	name = "Anomaly: Radiation Belt Passed"
	message = "Станция прошла опасную зону. " + \
			"Обратитесь в медотсек, если у вас возникнут необычные симптомы. " + \
			"Вскоре общий доступ к техническим туннелям будет аннулирован.."
	sound = "radpassed"

/datum/announcement/centcomm/anomaly/istorm
	name = "Anomaly: Ion Storm"
	message = "Обнаружен ионный шторм рядом со станцией. Просьба проверить на ошибки всё оборудование под контролем ИИ."
	sound = "istorm"

/datum/announcement/centcomm/bsa
	name = "Secret: BSA Shot"
	message = "Тревога! Обнаружен огонь блюспейс артиллерии. Приготовиться к удару."
	sound = "artillery"
/datum/announcement/centcomm/bsa/play(area/A)
	if(A)
		message = "Тревога! Обнаружен огонь блюспейс артиллерии на [A.name]. Приготовиться к удару."
	..()

/datum/announcement/centcomm/aliens
	name = "Event: Infestation"
	subtitle = "Тревога. Неопознанные Формы Жизни"
	sound = "lifesigns"
/datum/announcement/centcomm/aliens/New()
	message = "Обнаружены неопознанные формы жизни на [station_name_ru()]. Обезопасьте внешние доступы, включая трубопровод и вентиляцию."

/datum/announcement/centcomm/fungi
	name = "Event: Fungi"
	subtitle = "Тревога. Биоугроза"
	message = "Обнаружен вредоносный грибок на станции. Структура станции может быть заражена."
	sound = "fungi"

/datum/announcement/centcomm/wormholes
	name = "Event: Wormholes"
	subtitle = "Тревога. Аномалия"
	sound = "wormholes"
	message = "На станции была обнаружена пространственно-временная аномалия. Рекомендуется исключить контакты с необычными явлениями и подозрительными вещами. Дополнительные данные отсутствуют."

/datum/announcement/centcomm/anomaly/bluespace
	name = "Anomaly: Bluespace"
	sound = "bluspaceanom"
	message = "На станции обнаружена нестабильная блюспейс аномалия. Ожидаемое местоположение: неизвестно."
/datum/announcement/centcomm/anomaly/bluespace/play(area/A)
	if(A)
		message = "На [station_name_ru()] обнаружена нестабильная блюспейс аномалия. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/massive_portals
	name = "Anomaly: Many Bluespace Alerts"
	message = "Внимание! Был зафиксирован кластер несанкционированных блюспейс сигнатур! Сохраните целостность объекта."
	sound = "bluspaceanom"

/datum/announcement/centcomm/anomaly/bluespace_trigger
	name = "Anomaly: Bluespace Triggered"
	message = "Обнаружено массивное блюспейс перемещение."
	sound = "bluspacetrans"

/datum/announcement/centcomm/anomaly/flux
	name = "Anomaly: Flux Wave"
	message = "На станции зафиксирован гиперэнерегетический волновой поток. Ожидаемое местоположение: неизвестно."
	sound = "fluxanom"
/datum/announcement/centcomm/anomaly/flux/play(area/A)
	if(A)
		message = "На [station_name_ru()] зафиксирован гиперэнерегетический волновой поток. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/gravity
	name = "Anomaly: Gravitational"
	message = "На станции обнаружена гравитационная аномалия. Ожидаемое местоположение: неизвестно."
	sound = "gravanom"
/datum/announcement/centcomm/anomaly/gravity/play(area/A)
	if(A)
		message = "На [station_name_ru()] обнаружена гравитационная аномалия. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/pyro
	name = "Anomaly: Pyroclastic"
	message = "На станции обнаружена пирокластическая аномалия. Ожидаемое местоположение: неизвестно."
	sound = "pyroanom"
/datum/announcement/centcomm/anomaly/pyro/play(area/A)
	if(A)
		message = "На [station_name_ru()] обнаружена пирокластическая аномалия. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/vortex
	name = "Anomaly: Vortex"
	message = "На станции зафиксирована вихревая аномалия. Ожидаемое местоположение: неизвестно."
	sound = "vortexanom"
/datum/announcement/centcomm/anomaly/vortex/play(area/A)
	if(A)
		message = "На [station_name_ru()] зафиксирована вихревая аномалия. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/brand
	name = "Event: Brand Intelligence"
	subtitle = "Тревога. Машинное обучение"
	sound = "rampbrand"
/datum/announcement/centcomm/brand/New()
	message = "На борту станции был обнаружен вышедший из под контроля машинный интеллект. Будьте внимательны."

/datum/announcement/centcomm/carp
	name = "Event: Carp Migration"
	subtitle = "Тревога. Формы жизни"
	sound = "carps"
/datum/announcement/centcomm/carp/New()
	message = "Внимание! Неизвестные формы жизни были обнаружены рядом со станцией."

/datum/announcement/centcomm/carp_major
	name = "Event: Major Carp Migration"
	subtitle = "Тревога. Формы жизни"
	sound = "carp_major"
/datum/announcement/centcomm/carp_major/New()
	message = "Внимание! Обнаружена массовая миграция неизвестных форм жизни вблизи станции."

/datum/announcement/centcomm/comms_blackout
	name = "Event: Communication Blackout"
	message = "Ионносфе:%дз˝ МКаaдж^ж<.3-БЗЗЗЗЗЗТ"
	sound = "comms_blackout"
	always_random = TRUE
/datum/announcement/centcomm/comms_blackout/New()
	message = "Обнаружена ионносферная аномалия. Временный сбой связи неизбежен. Пожалуйста, свяжитесь с ваши*%фж00)`5вц-БЗЗТ"

/datum/announcement/centcomm/comms_blackout_traitor
	name = "Event: Traitor Communication Blackout"
	message = "Зафиксирован несанкционированный доступ к хранилищу данных центрального узла телеко%ци˝ ВРА^ж<.3-БЗЗЗЗЗЗТ"
	sound = "commandreport"

/datum/announcement/centcomm/dust
	name = "Event: Sand Storm"
/datum/announcement/centcomm/dust/New()
	subtitle = "Сенсоры [station_name_ru()]"
	sound = "dust"
	message = "[station_name_ru()] попала в облако космической пыли."

/datum/announcement/centcomm/dust_passed
	name = "Event: Sand Storm Passed"
/datum/announcement/centcomm/dust_passed/New()
	subtitle = "Сенсоры [station_name_ru()]"
	sound = "dust_passed"
	message = "[station_name_ru()] прошел сквозь облако космической пыли."

/datum/announcement/centcomm/estorm
	name = "Event: Electrical Storm"
	subtitle = "Внимание. Электрический Шторм"
	message = "Рядом со станцией обнаружен электрический шторм. Просьба восстановить перегруженное оборудование."
	sound = "estorm"

/datum/announcement/centcomm/grid_off
	name = "Event: Power Failure"
	subtitle = "Критический Сбой Электропитания"
	sound = "poweroff"
/datum/announcement/centcomm/grid_off/New()
	message = "Обнаружена нетипичная активность в сети станции. " + \
			"В предохранительных мерах, электропитание станции будет отключено на неопределенный срок."

/datum/announcement/centcomm/grid_on
	name = "Event: Power Restored"
	subtitle = "Системы Электропитания в Норме"
	sound = "poweron1"
/datum/announcement/centcomm/grid_on/New()
	message = "Энергопитание станции было восстановлено. Приносим извинения за доставленные неудобства."

/datum/announcement/centcomm/grid_quick
	name = "Secret: SMES Restored"
	subtitle = "Системы Электропитания в Норме"
	sound = "poweron2"
/datum/announcement/centcomm/grid_quick/New()
	message = "Все СМЭХи на [station_name_ru()] будут перезаряжены. Приносим свои извинения за неудобство."

/datum/announcement/centcomm/irod
	name = "Event: Immovable Rod"
	subtitle = "Общая Тревога"
	message = "Цитирую вопрос из ЦентКома. Какого хрена это было?!"
	sound = "irod"

/datum/announcement/centcomm/infestation
	name = "Event: Vermin infestation"
	subtitle = "Заражение Паразитами"
	sound = "infestation"
	message = "Биосканеры зафиксировали размножение паразитов. Рекомендуется остановить это, пока их не стало слишком много."
/datum/announcement/centcomm/infestation/play(vermstring, locstring)
	if(vermstring && locstring)
		message = "Биосканеры зафиксировали размножение [vermstring], местоположение: [locstring]. Рекомендуется остановить это, пока их не стало слишком много."
	..()

/datum/announcement/centcomm/meteor_wave
	name = "Event: Meteor Wave"
	subtitle = "Тревога. Метеоры"
	message = "Обнаружены метеоры на траектории столкновения со станцией. Генератор энергетического поля выключен или отсутствует. Приготовьтесь к столкновениям."
	sound = "meteors"

/datum/announcement/centcomm/meteor_wave_passed
	name = "Event: Meteor Wave Cleared"
	subtitle = "Тревога. Метеоры"
	message = "Станция прошла метеорный шторм."
	sound = "meteorcleared"

/datum/announcement/centcomm/meteor_shower
	name = "Event: Meteor Shower"
	subtitle = "Тревога. Метеоры"
	message = "Станция сейчас проходит метеорный поток. Генератор энергетического поля выключен или отсутствует."
	sound = "meteors"

/datum/announcement/centcomm/meteor_shower_passed
	name = "Event: Meteor Shower Cleared"
	subtitle = "Тревога. Метеоры"
	message = "Станция прошла метеорный поток."
	sound = "meteorcleared"

/datum/announcement/centcomm/organ_failure
	name = "Event: Organ Failure"
	subtitle = "Тревога. Биоугроза"
	sound = "outbreak7"
/datum/announcement/centcomm/organ_failure/New()
	message = "Подтвержден 7 уровень биологической угрозы на борту [station_name_ru()]. Персонал должен предотвратить распространение заражения."

/datum/announcement/centcomm/greytide
	name = "Event: Grey Tide"
	subtitle = "Тревога Безопасности"
	sound = "greytide"
/datum/announcement/centcomm/greytide/New()
	message = "В системах тюремного заключения [station_name_ru()] обнаружен [pick("Gr3y.T1d3","вредоносный троян")]."

/datum/announcement/centcomm/icarus_lost
	name = "Event: Icarus Lost"
	subtitle = "Тревога. Сбойные дроны"
	sound = "icaruslost"
	always_random = TRUE
/datum/announcement/centcomm/icarus_lost/randomize()
	if(prob(33))
		message = "Боевое крыло дронов не смогло вернуться с зачистки данного сектора, при обнаружении приближаться с осторожностью."
	else if(prob(50))
		message = "На ВКН Икар был потерян контакт с боевым крылом дронов. При обнаружении их в этой области, приближаться с осторожностью."
	else
		message = "Неизвестные хакеры атаковали боевое крыло дронов, запущенное с ВКН Икар. Если обнаружите их в данной области, то приближайтесь с осторожностью."

/datum/announcement/centcomm/icarus_recovered
	name = "Event: Icarus Recovered"
	subtitle = "Тревога. Сбойные дроны"
	message = "Контроль дронов на ВКН Икар докладывает о восстановлении контроля над сбойным боевым крылом дронов."

/datum/announcement/centcomm/icarus_destroyed
	name = "Event: Icarus Recovered"
	subtitle = "Тревога. Сбойные дроны"
	message = "Контроль дронов ВКН Икар разочарован в потере боевого крыла. Выжившие дроны будут восстановлены."
