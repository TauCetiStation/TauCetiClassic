/* EVENTS */
/datum/announcement/centcomm/anomaly
	subtitle = "Тревога. Аномалия"


/datum/announcement/centcomm/anomaly/frost
	name = "Anomaly: Frost"
	message = "На сканерах дальнего действия обнаружена атмосферная аномалия. Ожидается снижение температуры станции."

/datum/announcement/centcomm/access_override
	name = "Secret: Egalitarian"
	message = "Центком запустил сброс контроля доступа шлюзов. Пожалуйста, найдите время познакомиться с вашими коллегами."

/datum/announcement/centcomm/anomaly/radstorm
	name = "Anomaly: Radiation Belt"
	message = "Обнаружен высокий уровень радиации рядом с станцией. " + \
			"Докладывайте в медотсек, если чувствуете себя необычно. " + \
			"Всему экипажу станции рекомендуется укрыться в технических туннелях станции."
	sound = "radiation"

/datum/announcement/centcomm/anomaly/radstorm_passed
	name = "Anomaly: Radiation Belt Passed"
	message = "Станция прошла радиационный пояс. " + \
			"Просим доложить в медотсек, если вы чувствуете необычные симптомы. " + \
			"Вскоре доступ к эксплуатационным отсекам будет закрыт."
	sound = "radpassed"

/datum/announcement/centcomm/anomaly/istorm
	name = "Anomaly: Ion Storm"
	message = "Обнаружен ионный шторм рядом со станцией. Просьба проверить всё подконтрольное ИИ оборудование на ошибки."
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
	message = "Неопределенные формы жизни замечены на КСН Исход. Закройте любые внешние доступны, включая трубопровод и вентиляцию."
	sound = "lifesigns"
/datum/announcement/centcomm/aliens/play()
	message = "Неопределенные формы жизни замечены на [station_name()]. Перекройте все входы и выходы, включая трубопровод и вентиляцию."
	..()

/datum/announcement/centcomm/fungi
	name = "Event: Fungi"
	subtitle = "Тревога. Биоугроза"
	message = "Вредный грибок обнаружен на станции. Структура станции заражена."
	sound = "fungi"

/datum/announcement/centcomm/wormholes
	name = "Event: Wormholes"
	subtitle = "Тревога. Аномалия"
	message = "Космо-временная аномалия обнаружена на станции. Рекомендуется избегать подозрительных вещей и феноменов. Дополнительные данные отсутствуют."
	sound = "wormholes"

/datum/announcement/centcomm/anomaly/bluespace
	name = "Anomaly: Bluespace"
	message = "На сканерах дальнего действия обнаружена нестабильная блюспейс аномалия. Ожидаемое место: неизвестно."
	sound = "bluspaceanom"
/datum/announcement/centcomm/anomaly/bluespace/play(area/A)
	if(A)
		message = "На сканерах дальнего действия обнаружена нестабильная блюспейс аномалия. Ожидаемое место: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/bluespace_trigger
	name = "Anomaly: Bluespace Triggered"
	message = "Обнаружено массивное блюспейс перемещение."
	sound = "bluspacetrans"

/datum/announcement/centcomm/anomaly/flux
	name = "Anomaly: Flux Wave"
	message = "На сканерах дальнего действия зафиксирован гиперэнерегетический волновой поток. Ожидаемое место: неизвестно."
	sound = "fluxanom"
/datum/announcement/centcomm/anomaly/flux/play(area/A)
	if(A)
		message = "На сканерах дальнего действия зафиксирован гиперэнерегетический волновой поток. Ожидаемое место: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/gravity
	name = "Anomaly: Gravitational"
	message = "На сканерах дальнего действия обнаружена гравитационная аномалия. Ожидаемое место: неизвестно."
	sound = "gravanom"
/datum/announcement/centcomm/anomaly/gravity/play(area/A)
	if(A)
		message = "На сканерах дальнего действия обнаружена гравитационная аномалия. Ожидаемое место: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/pyro
	name = "Anomaly: Pyroclastic"
	message = "На сканерах дальнего действия обнаружена пирокластическая аномалия. Ожидаемое место: неизвестно."
	sound = "pyroanom"
/datum/announcement/centcomm/anomaly/pyro/play(area/A)
	if(A)
		message = "На сканерах дальнего действия обнаружена пирокластическая аномалия. Ожидаемое место: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/vortex
	name = "Anomaly: Vortex"
	message = "На сканерах дальнего действия зафиксирована высоко-интенсивная аномалия воронок. Ожидаемое место: неизвестно."
	sound = "vortexanom"
/datum/announcement/centcomm/anomaly/vortex/play(area/A)
	if(A)
		message = "На сканерах дальнего действия зафиксирована высоко-интенсивная аномалия воронок. Ожидаемое место: [A.name]."
	..()

/datum/announcement/centcomm/brand
	name = "Event: Brand Intelligence"
	subtitle = "Тревога. Машинное обучение"
	message = "На борту КСН Исход обнаружен неконтролируемый брендовый интеллект, готовьтесь."
	sound = "rampbrand"
/datum/announcement/centcomm/brand/play()
	message = "На борту [station_name()] обнаружен неконтролируемый брендовый интеллект, готовьтесь."
	..()

/datum/announcement/centcomm/carp
	name = "Event: Carp Migration"
	subtitle = "Тревога. Формы жизни"
	message = "Неизвестная форма жизни обнаружена вблизи КСН Исход, готовьтесь."
	sound = "carps"
/datum/announcement/centcomm/carp/play()
	message = "Неизвестная форма жизни обнаружена вблизи КСН Исход [station_name()], готовьтесь."
	..()

/datum/announcement/centcomm/carp_major
	name = "Event: Major Carp Migration"
	subtitle = "Тревога. Формы жизни"
	message = "Массовая миграция неизвестной формы жизни вблизи КСН Исход, готовьтесь."
	sound = "carps"
/datum/announcement/centcomm/carp_major/play()
	message = "Массовая миграция неизвестной формы жизни вблизи [station_name()], готовьтесь."
	..()

/datum/announcement/centcomm/comms_blackout
	name = "Event: Communication Blackout"
	message = "Ионносфе:%ďż˝ MCayj^j<.3-БЗЗЗЗТ"
/datum/announcement/centcomm/comms_blackout/play(message)
	if(message)
		src.message = message
	..()

/datum/announcement/centcomm/dust
	name = "Event: Sand Storm"
	subtitle = "Сенсоры станции"
	message = "КСН Исход сейчас проходит сквозь кольцо космической пыли."
/datum/announcement/centcomm/dust/play()
	subtitle = "Сенсоры [station_name()]"
	message = "[station_name()] сейчас проходит сквозь кольцо космической пыли."
	..()

/datum/announcement/centcomm/dust_passed
	name = "Event: Sand Storm Passed"
	subtitle = "Сенсоры станции"
	message = "КСН Исход прошел сквозь кольцо космической пыли."
/datum/announcement/centcomm/dust_passed/play()
	subtitle = "Сенсоры [station_name()]"
	message = "[station_name()] прошел сквозь кольцо космической пыли."
	..()

/datum/announcement/centcomm/estorm
	name = "Event: Electrical Storm"
	subtitle = "Тревога. Электрический Шторм"
	message = "В вашей области обнаружен электрический шторм, пожалуйста, восстановите перегруженное оборудование."
	sound = "estorm"

/datum/announcement/centcomm/grid_off
	name = "Event: Power Failure"
	subtitle = "Критический Сбой Питания"
	message = "Обнаружена необычная активность в сети питания КСН Исход. " + \
			 "В предохранительных мерах питание станции будет отключено на неопределенный срок."
	sound = "poweroff"
/datum/announcement/centcomm/grid_off/play()
	message = "Обнаружена необычная активность в сети питания [station_name()]." + \
			"В предохранительных мерах питание станции будет отключено на неопределенный срок."
	..()

/datum/announcement/centcomm/grid_on
	name = "Event: Power Restored"
	subtitle = "Системы Питания в Норме"
	message = "Питание будет восстановлено на КСН Исход. Приносим свои извинения за неудобство."
	sound = "poweron"
/datum/announcement/centcomm/grid_on/play()
	message = "Питание будет восстановлено на [station_name()]. Приносим свои извинения за неудобство."
	..()

/datum/announcement/centcomm/grid_quick
	name = "Secret: SMES Restored"
	subtitle = "Системы Питания в Норме"
	message = "Все СМЭХи на КСН Исход будут перезаряжены. Приносим свои извинения за неудобство."
	sound = "poweron"
/datum/announcement/centcomm/grid_quick/play()
	message = "Все СМЭХи на [station_name()] будут перезаряжены. Приносим свои извинения за неудобство."
	..()

/datum/announcement/centcomm/irod
	name = "Event: Immovable Rod"
	subtitle = "Общая Тревога"
	message = "Что это за хрень?!"

/datum/announcement/centcomm/infestation
	name = "Event: Vermin infestation"
	subtitle = "Заражение Паразитами"
	message = "Биосканеры зафиксировали, что что-то размножается где-то на станции. Вычистите это, пока не начало влиять на производительность."
/datum/announcement/centcomm/infestation/play(vermstring, locstring)
	if(vermstring && locstring)
		message = "Биосканеры зафиксировали, что [vermstring] размножается в [locstring]. Вычистите это, пока не начало влиять на производительность."
	..()

/datum/announcement/centcomm/meteor_wave
	name = "Event: Meteor Wave"
	subtitle = "Тревога. Метеоры"
	message = "Обнаружены метеоры на курсе столкновения со станцией. Генератор энергетического поля выключен или отсутствует."
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
	message = "Подтвержден 7 уровень биологической угрозы на борту станции. Всему персоналу предотвратить распространение заражения."
	sound = "outbreak7"
/datum/announcement/centcomm/organ_failure/play()
	message = "Подтвержден 7 уровень биологической угрозы на борту [station_name()]. Всему персоналу предотвратить распространение заражения."

/datum/announcement/centcomm/greytide
	name = "Event: Grey Tide"
	subtitle = "Тревога Безопастности"
	message = "В подпрограммах заключения КСН Исход обнаружен вирус. Рекомендуется привлечь ИИ."
	sound = "greytide"
/datum/announcement/centcomm/greytide/play()
	message = "В подпрограммах заключения [station_name()] обнаружен [pick("Gr3y.T1d3","вредоностный троян")]. Рекомендуется привлечь ИИ."

/datum/announcement/centcomm/icarus_lost
	name = "Event: Icarus Lost"
	subtitle = "Тревога. Сбойные дроны"
	message = "На ВКН Икар был потерян контакт с боевым крылом дронов. При обнаружении их в этой области, приближаться с осторожностью."
	sound = "icaruslost"
/datum/announcement/centcomm/icarus_lost/play(message)
	if(message)
		src.message = message
	..()

/datum/announcement/centcomm/icarus_recovered
	name = "Event: Icarus Recovered"
	subtitle = "Тревога. Сбойные дроны"
	message = "Контроль дронов на ВКН Икар докладывает о восстановлении контроля над сбойным боевым крылом."
/datum/announcement/centcomm/icarus_recovered/play(message)
	if(message)
		src.message = message
	..()
