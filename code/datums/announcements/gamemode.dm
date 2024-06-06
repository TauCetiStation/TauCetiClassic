/* GAME MODES */
/datum/announcement/centcomm/malf
	subtitle = "Сетевой Мониторинг"

/* Blob */
/datum/announcement/centcomm/blob/outbreak5
	name = "Blob: Level 5 Outbreak"
	subtitle = "Тревога. Биоугроза"
	sound = "outbreak5"
/datum/announcement/centcomm/blob/outbreak5/New()
	message = "Подтвержден 5 уровень биологической угрозы на борту [station_name_ru()]. " + \
			"Персонал должен предотвратить распространение заражения. " + \
			"Активирован протокол изоляции экипажа станции."

/datum/announcement/centcomm/blob/half
	name = "Blob: Dangerous Level Spread"
	subtitle = "Распространение биоугрозы"
	sound = "commandreport"

/datum/announcement/centcomm/blob/half/New()
	message = "Биоугроза продолжает своё распространение на [station_name_ru()]. \
			Персоналу предписывается любой ценой остановить распространение заражения по станции. \
			Высылаем через шаттл карго дополнительные средства по борьбе с угрозой."

/datum/announcement/centcomm/blob/critical
	name = "Blob: Blob Critical Mass"
	subtitle = "Тревога. Биоугроза"
	sound = "blob_critical"
	message = "Биологическая опасность достигла критической массы. Потеря станции неминуема."

/datum/announcement/centcomm/blob/biohazard_station_unlock
	name = "Biohazard Level Updated - Lock Down Lifted"
	subtitle = "Biohazard Alert"
	sound = "blob_dead"
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

/datum/announcement/centcomm/nuclear/gateway
	name = "Hacked gateway"
	subtitle = "Активация гейтвея."
	sound = "gateway"
	message = "Произведена синхронизация гейтвеев. Ожидайте гостей."

/* Vox */
/datum/announcement/centcomm/vox/arrival
	name = "Vox: Shuttle Arrives"
	sound = "vox_arrival"
/datum/announcement/centcomm/vox/arrival/New()
	message = "Внимание, [station_name_ru()], неподалёку от вашей станции проходит корабль не отвечающий на наши запросы. " + \
			"По последним данным, этот корабль принадлежит Торговой Конфедерации."

/datum/announcement/centcomm/vox/returns
	name = "Vox: Shuttle Returns"
	subtitle = "ВКН Икар"
	sound = "vox_returns"
/datum/announcement/centcomm/vox/returns/New()
	message = "Ваши гости улетают, [station_name_ru()]. Они двигаются слишком быстро, что бы мы могли навестись на них. " + \
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
/datum/announcement/centcomm/malf/first/New()
	message = "Внимание! Мы фиксируем необычные показатели в вашей сети. " + \
			"Кто-то пытается взломать ваши электронные системы. Советуем сообщать сотрудникам Службы Безопасности о сбоях электроники станции или о возможностях установленного вируса."

/datum/announcement/centcomm/malf/second
	name = "Malf: Announce №2"
	message = "Мы начали отслеживать взломщика. Кто-бы это не делал, они находятся на самой станции. " + \
			"Советуем проверять все терминалы, управляющие сетью."
	sound = "malf2"

/datum/announcement/centcomm/malf/third
	name = "Malf: Announce №3"
	message = "Это крайне странно и подозрительно.  " + \
			"Взломщик слишком быстр, он обходит все попытки его выследить. Это нечеловеческая скорость..."
	sound = "malf3"

/datum/announcement/centcomm/malf/fourth
	name = "Malf: Announce №4"
	message = "Мы отследили взломшик#, это каже@&# ва3) сист7ма ИИ, он# *#@амыает меха#7зм самоун@чт$#енiя. Оста*##ивте )то по*@!)$#&&@@  <СВЯЗЬ ПОТЕРЯНА>"
	sound = "malf4"

/* Gang */
/datum/announcement/centcomm/gang/announce_gamemode
	name = "Gang: Announce"
	flags = ANNOUNCE_ALL
	sound = "gang_announce"
/datum/announcement/centcomm/gang/announce_gamemode/New()
	message = "Из достоверных источников мы получили информацию, что на вашей станции зафиксирована деятельность банд." + \
	"Управлению станции поручается обеспечить безопасность экипажа.\n" + \
	" В течение часа должны прибыть сотрудники Отдела по Борьбе с Организованной Преступностью.\n\n" + \
	" Шаттл Транспортировки Экипажа сейчас находится на техобслуживании, поэтому вам придётся подождать около часа.\n"
/datum/announcement/centcomm/gang/announce_gamemode/play(gang_names)
	message = "Из достоверных источников мы получили информацию, что на [station_name_ru()] зафиксирована деятельность банд:" + \
	" [gang_names]. Управлению станции поручается обеспечить безопасность экипажа.\n" + \
	" В течение часа должны прибыть сотрудники Отдела по Борьбе с Организованной Преступностью.\n\n" + \
	" Шаттл Транспортировки Экипажа сейчас находится на техобслуживании, поэтому некоторое время вам придётся подождать.\n"
	..()

/datum/announcement/centcomm/gang/cops_closely
	name = "Gang: Cops Closely"
	sound = "gang_announce"
/datum/announcement/centcomm/gang/cops_closely/New()
	message = "Нам поступила информация, что сотрудники ОБОП уже приближаются к [station_name_ru()]." + \
	" Они прибудут примерно через 5 минут. Напоминаем еще раз, они находятся выше вас по иерархии" + \
	" и имеют право арестовать любого. Они будут действовать в интересах корпоративного закона."

/datum/announcement/centcomm/gang/cops_1
	subtitle = "Отдел по Борьбе с Организованной Преступностью"
	announcer = "Дежурный офицер"
	name = "Gang: Wanted Level 1"
	sound = "gang_announce"
/datum/announcement/centcomm/gang/cops_1/New()
	message = "Здравствуйте, экипаж!" + \
	" Мы получили несколько звонков о некой потенциальной деятельности преступных группировок на борту вашей станции." + \
	" Поэтому мы послали несколько офицеров для оценки ситуации. Ничего необычного, вам не о чем беспокоиться." + \
	" Однако, пока идёт десятиминутная проверка, мы попросили не отсылать вам шаттл.\n\nПриятного дня!"

/datum/announcement/centcomm/gang/cops_2
	subtitle = "Отдел по Борьбе с Организованной Преступностью"
	announcer = "Дежурный офицер"
	name = "Gang: Wanted Level 2"
	sound = "gang_announce"
/datum/announcement/centcomm/gang/cops_2/New()
	message = "Экипаж, мы получили подтверждённые сообщения о насильственной деятельности банд" + \
	" с вашего участка. Мы направили несколько вооружённых офицеров, чтобы помочь поддержать порядок и расследовать дела." + \
	" Не пытайтесь им помешать и выполняйте любые их требования. Мы попросили в течение десяти минут не отсылать вам шаттл.\n\nБезопасного дня!"

/datum/announcement/centcomm/gang/cops_3
	subtitle = "Отдел по Борьбе с Организованной Преступностью"
	announcer = "Дежурный офицер"
	name = "Gang: Wanted Level 3"
	sound = "gang_announce"
/datum/announcement/centcomm/gang/cops_3/New()
	message = "Экипаж [station_name_ru()]. Мы получили подтверждённые сообщения об экстремальной деятельности банд" + \
	" с вашей станции, что привело к жертвам среди гражданского персонала. Командование не потерпит такой халатности," + \
	" высланный отряд будет дейстовать в полную силу, чтобы сохранить мир и сократить количество жертв.\nСтанция окружена!" + \
	" Все бандиты должны бросить оружие и мирно сдаться!\n\nБезопасного дня!"

/datum/announcement/centcomm/gang/cops_4
	subtitle = "Отдел по Борьбе с Организованной Преступностью"
	announcer = "Дежурный офицер"
	name = "Gang: Wanted Level 4"
	sound = "gang_announce"
/datum/announcement/centcomm/gang/cops_4/New()
	message = "Мы отправили наших лучших агентов на [station_name_ru()]" + \
	" в связи с террористической деятельностью, направленной против нашей станции." + \
	" Все террористы должны НЕМЕДЛЕННО сдаться! Несоблюдение этого требования может привести и ПРИВЕДЁТ к смерти." + \
	" Мы собираемся завершить операцию в течение десяти минут, иначе же ждите шаттл и корпорация НаноТрейзен сама всё решит своим обычным методом.\n\nСдавайтесь сейчас или пожалеете!"

/datum/announcement/centcomm/gang/cops_5
	subtitle = "Отдел по Борьбе с Организованной Преступностью"
	announcer = "Дежурный офицер"
	name = "Gang: Wanted Level 5"
	sound = "gang_announce"
/datum/announcement/centcomm/gang/cops_5/New()
	message = "Из-за безумного количества жертв среди гражданского персонала на борту станции" + \
	" мы направили бойцов Вооружённых Сил НаноТрейзен, чтобы присечь любую деятельность банд на станции." + \
	" Наша блюспейс артиллерия направлена на станцию и шаттл транспортировки."

/datum/announcement/centcomm/gang/change_wanted_level
	title = "Система Обнаружения Кораблей Станции"
	subtitle = null
	name = "Gang: Change Wanted Level"
/datum/announcement/centcomm/gang/change_wanted_level/play(_message)
	message = _message
	..()

/* Xenomorph */
/datum/announcement/centcomm/xeno
	name = "Xeno threat"
	subtitle = "Тревога! Ксеноугроза!"

/datum/announcement/centcomm/xeno/first_help/New()
	message = "Мы получили информацию о наличии улья ксеноморфов на вашей станции. " + \
			"Нельзя допустить их проникновение на другие объекты. Поэтому мы активируем протокол изоляции станции. Он будет действовать пока вы не уничтожите всех взрослых особей ксеноморфов. " + \
			"Мы выслали вам шаттл снабжения с припасами и вооружением. " + \
			"Это должно быть достаточным для решения проблемы."
	sound = "xeno_first_help"

/datum/announcement/centcomm/xeno/first_help/fail/New()
	message = "Мы получили информацию о наличии улья ксеноморфов на вашей станции. " + \
			"Нельзя допустить их проникновение на другие объекты. Поэтому мы активируем протокол изоляции станции. Он будет действовать пока вы не уничтожите всех взрослых особей ксеноморфов. " + \
			"Мы добавили припасы и вооружение в список поставок. " + \
			"Освободите ваш шаттл снабжения и заберите груз."
	sound = "xeno_first_help_fail"

/datum/announcement/centcomm/xeno/second_help/New()
	message = "Похоже, нашей первой помощи оказалось недостаточно. Ксеноморфы продолжают увеличивать численность. " + \
			"Мы выслали вам шаттл снабжения с лучшим доступным набором спецсредств.  " + \
			"Рассматривается вопрос об отправке Отряда Быстрого Реагирования."
	sound = "xeno_second_help"

/datum/announcement/centcomm/xeno/second_help/fail/New()
	message = "Похоже, нашей первой помощи оказалось недостаточно. Ксеноморфы продолжают увеличивать численность. " + \
			"Мы добавили лучший доступный набор спецсредств, в список поставок. Освободите шаттл снабжения и заберите груз. " + \
			"Рассматривается вопрос об отправке Отряда Быстрого Реагирования."
	sound = "xeno_second_help_fail"

/datum/announcement/centcomm/xeno/crew_win
	name = "Xeno threat"
	subtitle = "Ксеноугроза устранена!"

/datum/announcement/centcomm/xeno/crew_win/New()
	message = "Похоже, что на борту станции больше не осталось взрослых особей ксеноморфов. " + \
			"Экипаж, вы справились! Мы выражаем благодарность вашей станции. " + \
			"Всему гражданскому персоналу необходимо сдать полученное вооружение сотрудникам безопасности. Протокол изоляции экипажа станции деактивирован." + \
			"Приятного дня!"
	sound = "xeno_crew_win"

/* Replicators */
/datum/announcement/centcomm/replicator
	name = "Bluespace Breach: Detected"
	subtitle = "Тревога! Блюспэйс прорыв"

/datum/announcement/centcomm/replicator/construction_began/play(area/A)
	message = "Обнаружено открытие блюспэйс прорыва в [CASE(A, PREPOSITIONAL_CASE)]. Полное раскрытие прорыва приведёт к дестабилизации реальности вокруг станции!"
	sound = "construction_began"
	..()

/datum/announcement/centcomm/replicator/construction_quarter/play(area/A)
	message = "Блюспэйс прорыв в [CASE(A, PREPOSITIONAL_CASE)] достиг 25% от критического гиперобъема."
	sound = "construction_quarter"
	..()

/datum/announcement/centcomm/replicator/construction_half/play(area/A)
	message = "Блюспэйс прорыв в [CASE(A, PREPOSITIONAL_CASE)] достиг 50% от критического гиперобъема."
	sound = "construction_half"
	..()

/datum/announcement/centcomm/replicator/construction_three_quarters/play(area/A)
	message = "Блюспэйс прорыв в [CASE(A, PREPOSITIONAL_CASE)] достиг 75% от критического гиперобъема."
	sound = "construction_three_quarters"
	..()

/datum/announcement/centcomm/replicator/doom/New()
	message = "Тревога! Блюспэйс прорыв достиг критического гиперобъёма! Дестабилизация реальности неизбежна!"
	sound = "construction_doom"

/datum/announcement/centcomm/ert
	title = "Оповещение ВКН Икар"
	subtitle = "Приближается Шаттл"
	name = "ERT Incoming"
/datum/announcement/centcomm/ert/New()
	message = "Наши сенсоры зафиксировали приближение неидентифицированного шаттла к [station_name_ru()] с активными процедурами стыковки. Готовьтесь встречать гостей."

/* "RP" Revolution */

/datum/announcement/centcomm/salary
	name = "Revolution: Salary"

/datum/announcement/centcomm/salary/New()
	message = "Ваша низкая производительность вынуждает нас принять непростое решение о сокращении финансового обеспечения станции. " + \
	"В связи с этим вдвое уменьшены заработные платы всего персонала, за исключением сотрудников службы безопасности, представителей ЦК и командного состава."

/datum/announcement/centcomm/recreation
	name = "Revolution: Recreation"

/datum/announcement/centcomm/recreation/New()
	message = "Согласно статистике, бесконтрольный досуг и сопутствующая ему деятельность пагубно влияют на производительность наших станций. " + \
	"Представителям командного состава необходимо закрыть голопалубу, театр, бар и любые другие увеселительные заведения. " + \
	"Питание персонала следует организовать посредством торговых автоматов и столовой."

/datum/announcement/centcomm/head_of_stuff_loyalty
	name = "Revolution: Loyalty"

/datum/announcement/centcomm/head_of_stuff_loyalty/New()
	message = "У нас есть основания полагать, что командный состав не проявляет должной преданности НаноТрейзен. " + \
	"Мы настаиваем на том, чтобы все представители командного состава ввели себе имплант лояльности, если это ещё не было сделано. " + \
	"Отказ от прохождения процедуры имплантации расценивается как неподчинение приказам Центрального Командования и карается арестом до конца смены."

/datum/announcement/centcomm/work_hard
	name = "Revolution: Work Hard"

/datum/announcement/centcomm/work_hard/New()
	message = "Проверенные источники сообщают, что принятые ранее меры оказались недостаточными. " + \
	"Представители командного состава обязаны проследить за тем, чтобы их подчиненные работали максимально усердно и не слонялись без дела. " + \
	"Персоналу запрещено покидать свое рабочее место без согласования с начальством. " + \
	"При нарушении этого запрета кем-либо необходимо накладывать дисциплинарное взыскание, а при рецидиве — заключать под стражу до момента прибытия транспортного шаттла, который доставит нарушителей туда, где им гарантированно найдут применение."
