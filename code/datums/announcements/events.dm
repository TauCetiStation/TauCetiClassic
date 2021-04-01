/* EVENTS */
/datum/announcement/centcomm/anomaly
	subtitle = "Anomaly Alert"


/datum/announcement/centcomm/anomaly/frost
	name = "Anomaly: Frost"
	message = "Atmospheric anomaly detected on long range scanners. Prepare for station temperature drop."

/datum/announcement/centcomm/access_override
	name = "Secret: Egalitarian"
	message = "Centcomm airlock control override activated. Please take this time to get acquainted with your coworkers."

/datum/announcement/centcomm/anomaly/radstorm
	name = "Anomaly: Radiation Belt"
	message = "Высокие уровни радиации обнаружены рядом со станцией. Пожалуйста, доложите в Мед-Бей если чувствуете себя странно. " + \
			"Всему экипажу станции рекомендуется найти убежище в техтоннелях станции."
	sound = "radiation"

/datum/announcement/centcomm/anomaly/radstorm_passed
	name = "Anomaly: Radiation Belt Passed"
	message = "станция покинула радиационный пояс. " + \
			"Пожалуйста, доложите в Мед-Бей, если вы почувствовали любые необычные симптомы. Доступ в теха скоро будет отозван."
	sound = "radpassed"

/datum/announcement/centcomm/anomaly/istorm
	name = "Anomaly: Ion Storm"
	message = "Ионный шторм обнаружен рядом со станцией. Пожалуйста, проверьте все устройства под управлением ИИ на наличие ошибок."
	sound = "istorm"

/datum/announcement/centcomm/bsa
	name = "Secret: BSA Shot"
	message = "Bluespace artillery fire detected. Brace for impact."
	sound = "artillery"
/datum/announcement/centcomm/bsa/play(area/A)
	if(A)
		message = "Bluespace artillery fire detected in [A.name]. Brace for impact."
	..()

/datum/announcement/centcomm/aliens
	name = "Event: Infestation"
	subtitle = "Lifesign Alert"
	message = "Обнаружены неопознанные признаки жизни на борту Космической Станции 13. Требуется обезопасить любой внешний доступ, включая воздуховоды и вентиляцию."
	sound = "lifesigns"

/datum/announcement/centcomm/fungi
	name = "Event: Fungi"
	subtitle = "Biohazard Alert"
	message = "На станции обнаружены предположительно вредные грибки. " + \
			"Возможно, что некоторые части станции могут быть заражены. " + \
			"Убедительная просьба носить маски и перчатки, а также соблюдать социальную дистанцию. Берегите себя и своих близких."
	sound = "fungi"

/datum/announcement/centcomm/wormholes
	name = "Event: Wormholes"
	subtitle = "Anomaly Alert"
	message = "Внимание! Пространственно-временные аномалии обнаружены на станции. Рекомендовано избегать данные феномены. Дополнительная информация отсутствует."
	sound = "wormholes"

/datum/announcement/centcomm/anomaly/bluespace
	name = "Anomaly: Bluespace"
	message = "Нестабильный разрыв варпа обнаружен посреди КСН Исход. Ожидаемое местоположение: Неизвестно."
	sound = "bluspaceanom"
/datum/announcement/centcomm/anomaly/bluespace/play(area/A)
	if(A)
		message = "Нестабильный разрыв варпа обнаружен посреди КСН Исход. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/bluespace_trigger
	name = "Anomaly: Bluespace Triggered"
	message = "Обнаружена массивная транслокация в Блюспейсе. Стоп. Почему у вас мостик вместо спутника ИИ?"
	sound = "bluspacetrans"

/datum/announcement/centcomm/anomaly/flux
	name = "Anomaly: Flux Wave"
	message = "Гипер-энергетический бдыщ-пакет обнаружен на дальних сканнерах станции. Ожидаемое местоположение: Неизвестно."
	sound = "fluxanom"
/datum/announcement/centcomm/anomaly/flux/play(area/A)
	if(A)
		message = "Localized hyper-energetic flux wave detected on long range scanners. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/gravity
	name = "Anomaly: Gravitational"
	message = "Маленький Лорд Сингуло обнаружен на дальних сканнерах станции. Ожидаемое местоположение: Неизвестно."
	sound = "gravanom"
/datum/announcement/centcomm/anomaly/gravity/play(area/A)
	if(A)
		message = "Маленький Лорд Сингуло обнаружен на дальних сканнерах станции. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/pyro
	name = "Anomaly: Pyroclastic"
	message = "КСН Исход, во что вы хотите сыграть сегодня: в горячую картошку или в \"Почини атмосферку\"? Ожидаемое местоположение: Неизвестно."
	sound = "pyroanom"
/datum/announcement/centcomm/anomaly/pyro/play(area/A)
	if(A)
		message = "КСН Исход, во что вы хотите сыграть сегодня: в горячую картошку или в \"Почини атмосферку\"? Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/anomaly/vortex
	name = "Anomaly: Vortex"
	message = "Внимание! Локальная высоко-частотная вортекс аномалия обнаружена волновыми сканнерами на станции. Ожидаемое местоположение: Неизвестно."
	sound = "vortexanom"
/datum/announcement/centcomm/anomaly/vortex/play(area/A)
	if(A)
		message = "Внимание! Локальная высоко-частотная вортекс аномалия обнаружена волновыми сканнерами на станции. Ожидаемое местоположение: [A.name]."
	..()

/datum/announcement/centcomm/brand
	name = "Event: Brand Intelligence"
	subtitle = "Machine Learning Alert"
	message = "Торговые автоматы на борту КСН Исход немного обнаглели. Пожалуйста, ожидайте."
	sound = "rampbrand"

/datum/announcement/centcomm/carp
	name = "Event: Carp Migration"
	subtitle = "Lifesign Alert"
	message = "А сейчас в иллюминаторы КСН Исход вы можете наблюдать косяк карпов в естественной среде обитания. Будьте осторожнее, иначе вам откусят ногу. И не только ногу."
	sound = "carps"

/datum/announcement/centcomm/carp_major
	name = "Event: Major Carp Migration"
	subtitle = "Lifesign Alert"
	message = "А сейчас в иллюминаторы КСН Исход вы можете наблюдать косяк карпов в естественной среде обитания. Будьте осторожнее, иначе вам откусят ногу. И не только ногу."
	sound = "carps"

/datum/announcement/centcomm/comms_blackout
	name = "Event: Communication Blackout"
	message = "Ionospheri:%ďż˝ MCayj^j<.3-BZZZZZZT"
/datum/announcement/centcomm/comms_blackout/play(message)
	if(message)
		src.message = message
	..()

/datum/announcement/centcomm/dust
	name = "Event: Sand Storm"
	subtitle = "Station Sensor Array"
	message = "The Space Station 13 is now passing through a belt of space dust."
/datum/announcement/centcomm/dust/play()
	subtitle = "[station_name()] Sensor Array"
	message = "The [station_name()] is now passing through a belt of space dust."
	..()

/datum/announcement/centcomm/dust_passed
	name = "Event: Sand Storm Passed"
	subtitle = "Station Sensor Array"
	message = "The Space Station 13 has now passed through the belt of space dust."
/datum/announcement/centcomm/dust_passed/play()
	subtitle = "[station_name()] Sensor Array"
	message = "The [station_name()] has now passed through the belt of space dust."
	..()

/datum/announcement/centcomm/estorm
	name = "Event: Electrical Storm"
	subtitle = "Electrical Storm Alert"
	message = "КСН Исход входит в грозовую тучу. Приготовьтесь к перегрузке систем."
	sound = "estorm"

/datum/announcement/centcomm/grid_off
	name = "Event: Power Failure"
	subtitle = "Critical Power Failure"
	message = "Исход, ближайшие несколько минут вам придётся посидеть без света. " + \
			"Надеемся, ваша инженерная команда не забыла про седьмой коллектор?"
	sound = "poweroff"

/datum/announcement/centcomm/grid_on
	name = "Event: Power Restored"
	subtitle = "Power Systems Nominal"
	message = "Подача энергии восстановлена. Инженерной команде: сачки из ботаники не слишком хорошо подходят для поимки Сингулярности."
	sound = "poweron"

/datum/announcement/centcomm/grid_quick
	name = "Secret: SMES Restored"
	subtitle = "Power Systems Nominal"
	message = "Подача энергии восстановлена. Инженерной команде: сачки из ботаники не слишком хорошо подходят для поимки Сингулярности."
	sound = "poweron"

/datum/announcement/centcomm/irod
	name = "Event: Immovable Rod"
	subtitle = "General Alert"
	message = "Что это за нахуй?!"

/datum/announcement/centcomm/infestation
	name = "Event: Vermin infestation"
	subtitle = "Vermin infestation"
	message = "Bioscans indicate that something have been breeding somewhere on the station. Clear them out, before this starts to affect productivity."
/datum/announcement/centcomm/infestation/play(vermstring, locstring)
	if(vermstring && locstring)
		message = "Bioscans indicate that [vermstring] have been breeding in [locstring]. Clear them out, before this starts to affect productivity."
	..()

/datum/announcement/centcomm/meteor_wave
	name = "Event: Meteor Wave"
	subtitle = "Meteor Alert"
	message = "Внимание, сейчас на станции идёт метеоритный душ. Генератор энергетического поля отключён или отсутствует."
	sound = "meteors"

/datum/announcement/centcomm/meteor_wave_passed
	name = "Event: Meteor Wave Cleared"
	subtitle = "Meteor Alert"
	message = "Станция прошла через метеоритный душ."
	sound = "meteorcleared"

/datum/announcement/centcomm/meteor_shower
	name = "Event: Meteor Shower"
	subtitle = "Meteor Alert"
	message = "Внимание, сейчас на станции идёт метеоритный душ. Генератор энергетического поля отключён или отсутствует."
	sound = "meteors"

/datum/announcement/centcomm/meteor_shower_passed
	name = "Event: Meteor Shower Cleared"
	subtitle = "Meteor Alert"
	message = "Станция прошла через метеоритный душ."
	sound = "meteorcleared"

/datum/announcement/centcomm/organ_failure
	name = "Event: Organ Failure"
	subtitle = "Biohazard Alert"
	message = "Господа, у вас абсолютно точно не блоб. " + \
			"Но карантин мы всё же введём."
	sound = "outbreak"

/datum/announcement/centcomm/greytide
	name = "Event: Grey Tide"
	subtitle = "Security Alert"
	message = "Вирус типа \"Серая слизь Б.Ю. Александрова\", что является опасным трояном, обнаружен в подсистемах КСН Исход. Рекомендовано участие мыслящей подставки под кружку."
	sound = "greytide"

/datum/announcement/centcomm/icarus_lost
	name = "Event: Icarus Lost"
	subtitle = "Rogue drone alert"
	message = "Был утерян контакт с крылом боевых не очень-то-лётников покинувших КБС Икар. Если они будут обнаружены в данном районе, то приближайтесь к ним с особой осторожностью, они немного стесняются."
	sound = "icaruslost"
/datum/announcement/centcomm/icarus_lost/play(message)
	if(message)
		src.message = message
	..()

/datum/announcement/centcomm/icarus_recovered
	name = "Event: Icarus Recovered"
	subtitle = "Rogue drone alert"
	message = "Icarus drone control reports the malfunctioning wing has been recovered safely."
/datum/announcement/centcomm/icarus_recovered/play(message)
	if(message)
		src.message = message
	..()
