/* EVENTS */
/datum/announcement/centcomm/anomaly
	subtitle = "Тревога. Аномалия"

/datum/announcement/centcomm/anomaly/frost
	name = "Anomaly: Frost"
	message = "На сканерах дальнего действия обнаружена атмосферная аномалия. Ожидается снижение температуры станции."

/datum/announcement/centcomm/access_override
	name = "Secret: Egalitarian"
	message = "Центком перегрузил контроль доступа шлюзов. Воспользуйтесь этим временем для знакомства с вашими коллегами."

/datum/announcement/centcomm/anomaly/radstorm
	name = "Anomaly: Radiation Belt"
	message = "Вблизи станции обнаружен высокий уровень радиации. " + \
			"Обратитесь в медотсек, если почувствуете себя странно. " + \
			"Всему экипажу станции рекомендуется укрыться в технических туннелях станции."
	sound = "radiation"

/datum/announcement/centcomm/anomaly/radstorm_passed
	name = "Anomaly: Radiation Belt Passed"
	message = "Станция прошла радиационный пояс. " + \
			"Обратитесь в медотсек, если у вас возникнут необычные симптомы. " + \
			"Вскоре общий доступ к техническим туннелям будет отключен."
	sound = "radpassed"

/datum/announcement/centcomm/anomaly/istorm
	name = "Anomaly: Ion Storm"
	message = "Обнаружен ионный шторм рядом со станцией. Просьба проверить на ошибки всё оборудование под контролем ИИ."
	sound = "istorm"

/datum/announcement/centcomm/bsa
	name = "Secret: BSA Shot"
	message = "Обнаружен огонь блюспейс артиллерии. Приготовиться к удару."
	sound = "artillery"
/datum/announcement/centcomm/bsa/play(area/A)
	if(A)
		message = "Обнаружен огонь блюспейс артиллерии на [A.name]. Приготовиться к удару."
	..()

/datum/announcement/centcomm/aliens
	name = "Event: Infestation"
	subtitle = "Тревога. Формы Жизни"
	sound = "lifesigns"
/datum/announcement/centcomm/aliens/play()
	message = "Обнаружены неопознанные формы жизни на [station_name_ru()]. Обезопасьте внешние доступы, включая трубопровод и вентиляцию."
	..()

/datum/announcement/centcomm/fungi
	name = "Event: Fungi"
	subtitle = "Тревога. Биоугроза"
	message = "Обнаружен вредный грибок на станции. Структура станции может быть заражена."
	sound = "fungi"

/datum/announcement/centcomm/wormholes
	name = "Event: Wormholes"
	subtitle = "Тревога. Аномалия"
	message = "Обнаружена пространственно-временная аномалия на станции. Рекомендуется избегать подозрительные вещи и явления. Дополнительные данные отсутствуют."
	sound = "wormholes"

/datum/announcement/centcomm/anomaly/bluespace
	name = "Anomaly: Bluespace"
	message = "На сканерах дальнего действия обнаружена нестабильная блюспейс аномалия. Ожидаемое местоположение: неизвестно."
	sound = "bluspaceanom"
/datum/announcement/centcomm/anomaly/bluespace/play(area/A)
	if(A)
		message = "На сканерах дальнего действия обнаружена нестабильная блюспейс аномалия. Ожидаемое местоположение: [A.name]."
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
	message = "На сканерах дальнего действия зафиксирован гиперэнерегетический волновой поток. Ожидаемое местоположение: неизвестно."
	sound = "fluxanom"
/datum/announcement/centcomm/anomaly/flux/play(area/A)
	if(A)
		message = "На сканерах дальнего действия зафиксирован гиперэнерегетический волновой поток. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/gravity
	name = "Anomaly: Gravitational"
	message = "На сканерах дальнего действия обнаружена гравитационная аномалия. Ожидаемое местоположение: неизвестно."
	sound = "gravanom"
/datum/announcement/centcomm/anomaly/gravity/play(area/A)
	if(A)
		message = "На сканерах дальнего действия обнаружена гравитационная аномалия. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/pyro
	name = "Anomaly: Pyroclastic"
	message = "На сканерах дальнего действия обнаружена пирокластическая аномалия. Ожидаемое местоположение: неизвестно."
	sound = "pyroanom"
/datum/announcement/centcomm/anomaly/pyro/play(area/A)
	if(A)
		message = "На сканерах дальнего действия обнаружена пирокластическая аномалия. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/vortex
	name = "Anomaly: Vortex"
	message = "На сканерах дальнего действия зафиксирована вихревая аномалия. Ожидаемое местоположение: неизвестно."
	sound = "vortexanom"
/datum/announcement/centcomm/anomaly/vortex/play(area/A)
	if(A)
		message = "На сканерах дальнего действия зафиксирована вихревая аномалия. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/brand
	name = "Event: Brand Intelligence"
	subtitle = "Тревога. Машинное обучение"
	sound = "rampbrand"
/datum/announcement/centcomm/brand/play()
	message = "На борту [station_name_ru()] обнаружен неконтролируемый брендовый интеллект, приготовьтесь."
	..()

/datum/announcement/centcomm/carp
	name = "Event: Carp Migration"
	subtitle = "Тревога. Формы жизни"
	sound = "carps"
/datum/announcement/centcomm/carp/play()
	message = "Обнаружены неизвестные формы жизни вблизи [station_name_ru()], приготовьтесь."
	..()

/datum/announcement/centcomm/carp_major
	name = "Event: Major Carp Migration"
	subtitle = "Тревога. Формы жизни"
	sound = "carps"
/datum/announcement/centcomm/carp_major/play()
	message = "Обнаружена массовая миграция неизвестных форм жизни вблизи [station_name_ru()], приготовьтесь."
	..()

/datum/announcement/centcomm/comms_blackout
	name = "Event: Communication Blackout"
	message = "Ионносфе:%дз˝ МКаaдж^ж<.3-БЗЗЗЗЗЗТ"
/datum/announcement/centcomm/comms_blackout/randomize_message()
	message = pick( \
		"Ионносферная аномалия обнаружена. Временный сбой связи неизбежен. Пожалуйста, свяжитесь с ваши*%фж00)`5вц-БЗЗТ", \
		"Ионносферная аномалия обнаружена. Временный сбой связи неизбе*3маг;б4;'1вдз˝-БЗЗЗЕ", \
		"Ионносферная аномалия обнаружена. Временный сбо#МЦi46:5.;@63-БЗЗЗЗТ", \
		"Ионносферная аномалия обнар'фЗ\\кг5_0-БЗЗЗЗЗТ", \
		"Ионносфе:%дз˝ МКаaдж^ж<.3-БЗЗЗЗЗЗТ", \
		"#4нд%;ф4у6,>ďż˝%-БЗЗЗЗЗЗЗТ" \
	)

/datum/announcement/centcomm/dust
	name = "Event: Sand Storm"
/datum/announcement/centcomm/dust/play()
	subtitle = "Сенсоры [station_name_ru()]"
	message = "[station_name_ru()] сейчас проходит сквозь облако космической пыли."
	..()

/datum/announcement/centcomm/dust_passed
	name = "Event: Sand Storm Passed"
/datum/announcement/centcomm/dust_passed/play()
	subtitle = "Сенсоры [station_name_ru()]"
	message = "[station_name_ru()] прошел сквозь облако космической пыли."
	..()

/datum/announcement/centcomm/estorm
	name = "Event: Electrical Storm"
	subtitle = "Тревога. Электрический Шторм"
	message = "В вашей области обнаружен электрический шторм, пожалуйста, восстановите перегруженное оборудование."
	sound = "estorm"

/datum/announcement/centcomm/grid_off
	name = "Event: Power Failure"
	subtitle = "Критический Сбой Электропитания"
	sound = "poweroff"
/datum/announcement/centcomm/grid_off/play()
	message = "Обнаружена нетипичная активность в сети [station_name_ru()]. " + \
			"В предохранительных мерах, электропитание станции будет отключено на неопределенный срок."
	..()

/datum/announcement/centcomm/grid_on
	name = "Event: Power Restored"
	subtitle = "Системы Электропитания в Норме"
	sound = "poweron"
/datum/announcement/centcomm/grid_on/play()
	message = "Электропитание было восстановлено на [station_name_ru()]. Приносим извинения за доставленные неудобства."
	..()

/datum/announcement/centcomm/grid_quick
	name = "Secret: SMES Restored"
	subtitle = "Системы Электропитания в Норме"
	sound = "poweron"
/datum/announcement/centcomm/grid_quick/play()
	message = "Все СМЭХи на [station_name_ru()] будут перезаряжены. Приносим свои извинения за неудобство."
	..()

/datum/announcement/centcomm/irod
	name = "Event: Immovable Rod"
	subtitle = "Общая Тревога"
	message = "Что, нахрен, это было?!"

/datum/announcement/centcomm/infestation
	name = "Event: Vermin infestation"
	subtitle = "Заражение Паразитами"
	message = "Биосканеры зафиксировали, что на станции разможаются неизвестные объекты. Избавьтесь от них, пока они не начали влиять на производительность."
/datum/announcement/centcomm/infestation/play(vermstring, locstring)
	if(vermstring && locstring)
		message = "Биосканеры зафиксировали размножение [vermstring], местоположение: [locstring]. Избавьтесь от них, пока они не начали влиять на производительность."
	..()

/datum/announcement/centcomm/meteor_wave
	name = "Event: Meteor Wave"
	subtitle = "Тревога. Метеоры"
	message = "Обнаружены метеоры на траектории столкновения со станцией. Генератор энергетического поля выключен или отсутствует."
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
/datum/announcement/centcomm/organ_failure/play()
	message = "Подтвержден 7 уровень биологической угрозы на борту [station_name_ru()]. Персонал должен предотвратить распространение заражения."
	..()

/datum/announcement/centcomm/greytide
	name = "Event: Grey Tide"
	subtitle = "Тревога Безопасности"
	sound = "greytide"
/datum/announcement/centcomm/greytide/play()
	message = "В системах тюремного заключения [station_name_ru()] обнаружен [pick("Gr3y.T1d3","вредоносный троян")]. Рекомендуется привлечь ИИ."
	..()

/datum/announcement/centcomm/icarus_lost
	name = "Event: Icarus Lost"
	subtitle = "Тревога. Сбойные дроны"
	sound = "icaruslost"
/datum/announcement/centcomm/icarus_lost/randomize_message()
	if(prob(33))
		message = "Боевое крыло дронов не смогло вернуться с зачистки данного сектора, при обнаружении приближаться с осторожностью."
	else if(prob(50))
		message = "На ВКН Икар был потерян контакт с боевым крылом дронов. При обнаружении их в этой области, приближаться с осторожностью."
	else
		message = "Неизвестные хакеры атаковали боевое крыло дронов, запущенное с ВКН Икар. Если обнаружите их в данной области, то приближайтесь с осторожностью."
/datum/announcement/centcomm/icarus_lost/play()
	randomize_message()
	..()

/datum/announcement/centcomm/icarus_recovered
	name = "Event: Icarus Recovered"
	subtitle = "Тревога. Сбойные дроны"
	message = "Контроль дронов на ВКН Икар докладывает о восстановлении контроля над сбойным боевым крылом дронов."

/datum/announcement/centcomm/icarus_destroyed
	name = "Event: Icarus Recovered"
	subtitle = "Тревога. Сбойные дроны"
	message = "Контроль дронов ВКН Икар разочарован в потере боевого крыла. Выжившие дроны будут восстановлены."
