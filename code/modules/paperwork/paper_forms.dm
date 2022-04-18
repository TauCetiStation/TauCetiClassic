/obj/item/weapon/paper/warrant
	name = "Warrant: NAME GOES HERE"

	var/government = "Служба Безопасности КСН \"Исход\""
	var/authority1 = "Глава Службы Безопасности"
	var/authority2 = "Глава Персонала"

/obj/item/weapon/paper/warrant/atom_init()
	. = ..()
	var/obj/item/weapon/pen/P = new
	info = parsepencode("\[center\]\[large\]\[b\][government]\[/b\]\n\
Ордер на обыск\[/large\]\[/center\]\
\[hr\]Полное имя цели осмотра: \[field\]\n\
Полное имя офицера(ов): \[field\]\n\
Причина: \[field\]\n\
Обыск рабочего места: \[field\]\n\
Обыск подозреваемого: \[field\]\n\
\[hr\][authority1]: \[sfield\]\n\
[authority2]: \[sfield\]\
\[hr\]\[small\]*Протоколы обыска могут быть проигнорированы при уровне тревоги \"Синий\" и выше.\[br\]\
Графа \"Обыск рабочего места\" и \"Обыск подозреваемого\" должны быть обязательно заполнены.\
\"+\" - обыск разрешен \"-\" - обыск запрещен.\[/small\]\
\[hr\]Место для штампов.", P)
	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/warrant/velocity
	government = "Служба Безопасности НТС \"Велосити\""

//---------------CARGO---------------
var/global/list/cargo_forms = list(list("type" = /obj/item/weapon/paper/item_request, "name" = "Запрос в Отдел Поставок"),
							list("type" = /obj/item/weapon/paper/materials_request, "name" = "Запрос в Отдел Поставок на поставки сырья"),
							list("type" = /obj/item/weapon/paper/post_request, "name" = "Заказ на почтовую пересылку"),
							list("type" = /obj/item/weapon/paper/cargo_inventory, "name" = "Складская опись"),
							list("type" = /obj/item/weapon/paper/mining_waybill, "name" = "Накладная на поставки с шахтерского аванпоста"))
/obj/item/weapon/paper/item_request
	name = "Запрос в Отдел Поставок"
	info = {"<center><large><b>Отдел Поставок КСН "Исход"</b><br>
			Запрос в Отдел Поставок</large></center><br>
			<hr>Полное имя заказчика: <span class=\"paper_field\"></span><br>
			Заказ: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			Место доставки: <span class=\"paper_field\"></span><br>
			Примечания: <span class=\"paper_field\"></span><br>
			<hr>Заказчик: <span class=\"sign_field\"></span><br>
			Принимающий сотрудник: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*В случае получения разрешения на заказ он должен быть отмечен штампом "Одобрено" и штампом Квартирмейстера. Заказы, не получившие разрешения со стороны Глав или Квартирмейстера, должны быть отмечены штампом "Отказано". В случае отсутствия Глав, Квартирмейстер сам может решать, что заказывать, а что нет. После заполнения, накладная должна храниться в картотеке до конца смены.<br><br>
			За предметы не относящимся к работе может взиматься плата.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/materials_request
	name = "Запрос в Отдел Поставок на поставки сырья"
	info = {"<center><large><b>Отдел Поставок КСН "Исход"</b><br>
			Запрос в Отдел Поставок на поставки сырья</large></center><br>
			<hr>Полное имя заказчика: <span class=\"paper_field\"></span><br>
			Материалы: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			Количество: <span class=\"paper_field\"></span><br>
			Место доставки: <span class=\"paper_field\"></span><br>
			Примечания: <span class=\"paper_field\"></span><br>
			<hr>Заказчик: <span class=\"sign_field\"></span><br>
			Принимающий сотрудник: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*В случае получения разрешения на заказ он должен быть отмечен штампом "Одобрено" и штампом Квартирмейстера. Заказы, не получившие разрешения со стороны Глав или Квартирмейстера, должны быть отмечены штампом "Отказано". В случае отсутствия Глав, Квартирмейстер сам может решать, что заказывать, а что нет. После заполнения, накладная должна храниться в картотеке до конца смены.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/post_request
	name = "Заказ на почтовую пересылку"
	info = {"<center><large><b>Отдел Поставок КСН "Исход"</b><br>
			Заказ на почтовую пересылку</large></center><br>
			<hr>Полное имя заказчика: <span class=\"paper_field\"></span><br>
			Посылка: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			Место доставки: <span class=\"paper_field\"></span><br>
			Примечания: <span class=\"paper_field\"></span><br>
			<hr>Заказчик: <span class=\"sign_field\"></span><br>
			Принимающий сотрудник: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Если посылка не является предметом высокого риска то нужды в штампе глав нет. Но если это опасные для станции предметы то нужен штамп от Главы Службы Безопасности, Главы Персонала или Капитана.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/cargo_inventory
	name = "Складская опись"
	info = {"<center><large><b>Отдел Поставок КСН "Исход"</b><br>
			Складская опись</large></center><br>
			<hr>Время составления описи: <span class=\"paper_field\"></span><br>
			Опись составил: <span class=\"paper_field\"></span><br>
			<hr>Содержимое склада.<br>
			<font size = \"1\">В скобках пометить количество.</font><br>
			<ul>(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			(<li>)<span class=\"paper_field\"></span><br>
			</ul><hr>Составитель: <span class=\"sign_field\"></span>"}

/obj/item/weapon/paper/mining_waybill
	name = "Накладная на поставки с шахтерского аванпоста"
	info = {"<center><large><b>Отдел Поставок КСН "Исход"</b><br>
			Накладная на поставки с шахтерского аванпоста</large></center><br>
			<hr>Время составления накладной: <span class=\"paper_field\"></span><br>
			Номер поставки: <span class=\"paper_field\"></span><br>
			<hr><b>Руды/Материалы в этой поставке</b><br>
			Железная руда: <span class=\"paper_field\"></span>, Металл: <span class=\"paper_field\"></span>, Пласталь: <span class=\"paper_field\"></span><br>
			Песок: <span class=\"paper_field\"></span>, Стекло: <span class=\"paper_field\"></span>, Укрепленное стекло: <span class=\"paper_field\"></span><br>
			Золотая руда: <span class=\"paper_field\"></span>, Золотой слиток(слитки): <span class=\"paper_field\"></span><br>
			Серебряная руда: <span class=\"paper_field\"></span>, Серебряный слиток(слитки): <span class=\"paper_field\"></span><br>
			Неочищенная плазма: <span class=\"paper_field\"></span>, Твердая плазма: <span class=\"paper_field\"></span><br>
			Уран: <span class=\"paper_field\"></span>, Очищенный уран: <span class=\"paper_field\"></span><br>
			Алмаз: <span class=\"paper_field\"></span>, Ограненный алмаз(алмазы): <span class=\"paper_field\"></span><br>
			Разное: <span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			Принимающий сотрудник: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*В случае получения разрешения на заказ он должен быть отмечен штампом "Одобрено" и штампом Квартирмейстера. Заказы, не получившие разрешения со стороны Глав или Квартирмейстера, должны быть отмечены штампом "Отказано". В случае отсутствия Глав, Квартирмейстер сам может решать, что заказывать, а что нет. После заполнения, накладная должна храниться в картотеке до конца смены.</font>"}

//---------------Human Resources Department---------------
var/global/list/hrd_forms = list(list("type" = /obj/item/weapon/paper/temporary_access, "name" = "Анкета на получение временного дополнительного доступа"),
							list("type" = /obj/item/weapon/paper/permanent_access, "name" = "Анкета на получение постоянного дополнительного доступа"),
							list("type" = /obj/item/weapon/paper/dismissal, "name" = "Анкета на увольнение/понижение"),
							list("type" = /obj/item/weapon/paper/access_certificate, "name" = "Сертификат о выдаче дополнительного доступа"),
							list("type" = /obj/item/weapon/paper/change_job, "name" = "Анкета смены занимаемой должности"),
							list("type" = /obj/item/weapon/paper/test_subject, "name" = "Форма запроса подопытного в целях эксплуатации"),
							list("type" = /obj/item/weapon/paper/new_id, "name" = "Форма получения новой ID карты"))
/obj/item/weapon/paper/temporary_access
	name = "Анкета на получение временного дополнительного доступа"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b><br>
			Анкета на получение временного дополнительного доступа</large></center><br>
			<hr>Полное имя составителя: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Запрос доступа в: <span class=\"paper_field\"></span><br>
			Продолжительность: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			Глава Отдела Кадров: <span class=\"sign_field\"></span><br>
			Ответственный за помещения: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/permanent_access
	name = "Анкета на получение постоянного дополнительного доступа"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b><br>
			Анкета на получение постоянного дополнительного доступа</large></center><br>
			<hr>Полное имя составителя: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Запрос доступа в: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			Глава Отдела Кадров: <span class=\"sign_field\"></span><br>
			Ответственный за помещения: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/dismissal
	name = "Анкета на увольнение/понижение"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b><br>
			Анкета на увольнение/понижение</center></large><br>
			<hr>Полное имя сотрудника: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Причина увольнения/понижения: <span class=\"paper_field\"></span><br>
			Примечания: <span class=\"paper_field\"></span><br>
			<hr>Глава увольняемого/понижаемого: <span class=\"sign_field\"></span><br>
			Глава Отдела Кадров: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Форма должна быть заполнена только Главой увольняемого/понижаемого или Главой Отдела Кадров.<br>
			Увольняемый/понижаемый должен быть уведомлен о факте написания документа и передачи его в Отдел Кадров.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/access_certificate
	name = "Сертификат о выдаче дополнительного доступа"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b><br>
			Сертификат о выдаче дополнительного доступа</large></center><br>
			<hr>Полное имя сотрудника: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Выданные доступы: <span class=\"paper_field\"></span><br>
			Время выдачи: <span class=\"paper_field\"></span><br>
			Время действия: <span class=\"paper_field\"></span><br>
			<hr>Выдавший доступы: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/change_job
	name = "Анкета смены занимаемой должности"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b><br>
			Анкета смены занимаемой должности</large></center><br>
			<hr>Полное имя составителя: <span class=\"paper_field\"></span><br>
			Текущая должность: <span class=\"paper_field\"></span><br>
			Запрашиваемая должность: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			Текущий начальник отдела: <span class=\"sign_field\"></span><br>
			Принимающий начальник отдела: <span class=\"sign_field\"></span><br>
			Глава Отдела Кадров: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/test_subject
	name = "Форма запроса подопытного в целях эксплуатации"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b><br>
			Форма запроса подопытного в целях эксплуатации</large></center><br>
			<hr>Полное имя: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Причина запроса ассистента: <span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			Текущий начальник отдела:  <span class=\"sign_field\"></span><br>
			Глава Отдела Кадров: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/new_id
	name = "Форма получения новой ID карты"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b><br>
			Форма получения новой ID карты</large></center><br>
			<hr>Полное имя сотрудника: <span class=\"paper_field\"></span><br>
			Текущая должность: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			Текущий начальник отдела: <span class=\"sign_field\"></span><br>
			Глава Отдела Кадров: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

//---------------Medbay---------------
var/global/list/medbay_forms = list(list("type" = /obj/item/weapon/paper/recipe, "name" = "Рецепт на медицинский препарат"),
							list("type" = /obj/item/weapon/paper/surgery_report, "name" = "Отчёт о проведённой операции"),
							list("type" = /obj/item/weapon/paper/autopsy_report, "name" = "Отчет о вскрытии тела"),
							list("type" = /obj/item/weapon/paper/drugs_list, "name" = "Список выдачи препаратов"),
							list("type" = /obj/item/weapon/paper/disability_report, "name" = "Справка о нетрудоспособности"),
							list("type" = /obj/item/weapon/paper/chemistry_request, "name" = "Запрос в химическую лабораторию на выдачу препарата"))
/obj/item/weapon/paper/recipe
	name = "Рецепт на медицинский препарат"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b><br>
			Рецепт на медицинский препарат</large></center><br>
			<hr>Полное имя пациента: <span class=\"paper_field\"></span><br>
			Назначенные препараты: <span class=\"paper_field\"></span><br>
			<hr>Назначивший врач: <span class=\"sign_field\"></span><br>
			Фармацевт принявший рецепт: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Этот рецепт не может быть использован повторно.</font>"}

/obj/item/weapon/paper/surgery_report
	name = "Отчёт о проведённой операции"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b><br>
			Отчёт о проведённой операции</large></center><br>
			<hr>Вид и место операции: <span class=\"paper_field\"></span><br>
			<hr>Полное имя оперирующего: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			<hr>Полное имя пациента: <span class=\"paper_field\"></span><br>
			Время проведения: <span class=\"paper_field\"></span><br>
			<hr>Осложнения, возникшие по ходу операции (в случае отсутствия оставить пустым): <span class=\"paper_field\"></span><br>
			<hr>Оперирующий: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/autopsy_report
	name = "Отчет о вскрытии тела"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b><br>
			Отчет о вскрытии тела</large></center><br>
			<hr>Полное имя умершего: <span class=\"paper_field\"></span><br>
			Раса: <span class=\"paper_field\"></span><br>
			Пол: <span class=\"paper_field\"></span><br>
			Возраст: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			<hr>Тип смерти: <span class=\"paper_field\"></span><br>
			Визуальное описание тела: <span class=\"paper_field\"></span><br>
			Особые приметы и повреждения: <span class=\"paper_field\"></span><br>
			<hr>Вероятная причина смерти: <span class=\"paper_field\"></span><br>
			Примечания: <span class=\"paper_field\"></span><br>
			<hr>Патологоанатом: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">Настоящим я заявляю, что после заполнения отчета, описанного в данном документе, я взял на себя ответственность за тело и определил причину смерти в соответствии с разделом 38-701b патологического кодекса NanoTrasen и что информация, содержащаяся в документе, верна и правильна в меру моих знаний и убеждений.</font>"}

/obj/item/weapon/paper/drugs_list
	name = "Список выдачи препаратов"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b><br>
			Список выдачи препаратов</large></center><br>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span><br>
			Время выдачи: <span class=\"paper_field\"></span><br>
			Полное имя заказчика: <span class=\"paper_field\"></span><br>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span><br>
			Время выдачи: <span class=\"paper_field\"></span><br>
			Полное имя заказчика: <span class=\"paper_field\"></span><br>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span><br>
			Время выдачи: <span class=\"paper_field\"></span><br>
			Полное имя заказчика: <span class=\"paper_field\"></span><br>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span><br>
			Время выдачи: <span class=\"paper_field\"></span><br>
			Полное имя заказчика: <span class=\"paper_field\"></span><br>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span><br>
			Время выдачи: <span class=\"paper_field\"></span><br>
			Полное имя заказчика: <span class=\"paper_field\"></span><br>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span><br>
			Время выдачи: <span class=\"paper_field\"></span><br>
			Полное имя заказчика: <span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span>"}

/obj/item/weapon/paper/disability_report
	name = "Справка о нетрудоспособности"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b><br>
			Справка о нетрудоспособности</large></center><br>
			<hr>Полное имя сотрудника: <span class=\"paper_field\"></span><br>
			Пол: <span class=\"paper_field\"></span><br>
			Возраст: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			<hr>Диагноз: <span class=\"paper_field\"></span><br>
			Дополнительная информация: <span class=\"paper_field\"></span><br>
			Примечания: <span class=\"paper_field\"></span><br>
			<hr>Врач: <span class=\"sign_field\"></span><br>
			Глава Персонала: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Этот документ подтверждает нетрудоспособность работника станции в связи с его установленным в законном порядке диагнозом.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/chemistry_request
	name = "Запрос в химическую лабораторию на выдачу препарата"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b><br>
			Запрос в химическую лабораторию на выдачу препарата</large></center><br>
			Необходимые препараты: <span class=\"paper_field\"></span><br>
			Количество: <span class=\"paper_field\"></span><br>
			<hr>Заказчик: <span class=\"sign_field\"></span>"}

//---------------RnD---------------
var/global/list/rnd_forms = list(list("type" = /obj/item/weapon/paper/experiment_permission, "name" = "Разрешение на проведение опасного для жизни эксперимента"),
							list("type" = /obj/item/weapon/paper/genetics_permission, "name" = "Запрос на разрешение проведения экспериментальной генной терапии"),
							list("type" = /obj/item/weapon/paper/cyborgisation_permission, "name" = "Запрос на разрешение проведения прижизненной кибернетизации"),
							list("type" = /obj/item/weapon/paper/credit_equipment, "name" = "Займ оборудования"),
							list("type" = /obj/item/weapon/paper/exosuit_transfer, "name" = "Передача в пользование шагохода"),
							list("type" = /obj/item/weapon/paper/research_object, "name" = "Отчет о изучении неизвестного объекта"),
							list("type" = /obj/item/weapon/paper/transfer_object, "name" = "Транспортировка и передача исследуемого субъекта на СН 'ЦентКом'"),
							list("type" = /obj/item/weapon/paper/make_exosuit, "name" = "Запрос на изготовление экзоскелета"),
							list("type" = /obj/item/weapon/paper/exosuit_permission, "name" = "Разрешение на пользование экзоскелетом"),
							list("type" = /obj/item/weapon/paper/bomb_test, "name" = "Отчет о испытании взрывного устройства"),
							list("type" = /obj/item/weapon/paper/research_report, "name" = "Отчет о проведенных исследованиях"),
							list("type" = /obj/item/weapon/paper/scan_objects, "name" = "Отчет о сканировании ценных научно-исследовательских объектов"),
							list("type" = /obj/item/weapon/paper/space_structure, "name" = "Отчет об исследовании заброшенного объекта в дальнем космосе"),
							list("type" = /obj/item/weapon/paper/prototypes, "name" = "Акт об изготовлении прототипов"),
							list("type" = /obj/item/weapon/paper/make_exosuit_report, "name" = "Акт об изготовлении экзоскелета"))
/obj/item/weapon/paper/experiment_permission
	name = "Разрешение на проведение опасного для жизни эксперимента"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Разрешение на проведение опасного для жизни эксперимента</large></center><br>
			<hr>Полное имя подопытного: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Цель эксперимента: <span class=\"paper_field\"></span><br>
			Полное имя куратора: <span class=\"paper_field\"></span><br>
			Полное имя организатора: <span class=\"paper_field\"></span><br>
			Примечания: <span class=\"paper_field\"></span><br>
			<hr>Куратор: <span class=\"sign_field\"></span><br>
			Организатор: <span class=\"sign_field\"></span><br>
			Подопытный: <span class=\"sign_field\"></span><br>
			Директор Отдела R&D: <span class=\"sign_field\"></span><br>
			Глава Персонала: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Данный документ нужен в случае если вы собираетесь провести эксперимент который может нанести вред одному сотруднику станции(подопытному).<br>
			Куратором может являться Директор Отдела R&D или любой другой сотрудник Отдела Исследования и Разработки выше организатора по рангу. Подпись Директора Отдела R&D может быть заменена подписями Главы Персонала, Капитана.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/genetics_permission
	name = "Запрос на разрешение проведения экспериментальной генной терапии"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Запрос на разрешение проведения экспериментальной генной терапии</large></center><br>
			<hr>Полное имя подопытного: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			Полное имя врача-генетика проводящего эксперимент: <span class=\"paper_field\"></span><br>
			Куратор: <span class=\"paper_field\"></span><br>
			Прививаемые гены: <span class=\"paper_field\"></span><br>
			<hr>Куратор: <span class=\"sign_field\"></span><br>
			Врач-генетик: <span class=\"sign_field\"></span><br>
			Подопытный: <span class=\"sign_field\"></span><br>
			Главный Врач: <span class=\"sign_field\"></span><br>
			Директор Отдела R&D: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Куратором может являться Директор Отдела R&D или любой другой сотрудник Отдела Исследования и Разработки выше организатора по рангу. Подписи Директора Отдела R&D и Главного Врача могут быть заменены подписями Главы Персонала, Капитана.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/cyborgisation_permission
	name = "Запрос на разрешение проведения прижизненной кибернетизации"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Запрос на разрешение проведения прижизненной кибернетизации</large></center><br>
			<hr>Полное имя подопытного: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			Полное имя специалиста проводящего кибернетизацию: <span class=\"paper_field\"></span><br>
			<hr>Специалист: <span class=\"sign_field\"></span><br>
			Подопытный: <span class=\"sign_field\"></span><br>
			Врач-психиатр: <span class=\"sign_field\"></span><br>
			Глава Отдела Кадров: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Подписывая данный запрос, подопытный подтверждает своё желание пройти прижизненный процесс кибернетизации или слияния с Искусственным Интеллектом и полностью берет на себя ответственность за возможные последствия. Также, он подтверждает, что уведомлен о возможной необратимости процедуры.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/credit_equipment
	name = "Займ оборудования"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Займ оборудования</large></center><br>
			<hr><div style=\"border-width: 4px; border-style: dashed;\"><center>Следующие предметы числятся на учете как "экспериментальные". NanoTrasen не несет ответственности за ущерб, полученный в ходе использования этого оборудования.<br>
			Получатель должен использовать эти предметы только по их прямому назначению. Получатель не должен делится этим оборудованием с любыми другими лицами без прямого одобрения командного состава станции.</center></div><hr>Имя получающего: <span class=\"paper_field\"></span><br>
			Полное имя получателя: <span class=\"paper_field\"></span><br>
			Полное имя выдающего предметы в займ: <span class=\"paper_field\"></span><br>
			Предметы в займ: <span class=\"paper_field\"></span><br>
			<hr>Получатель: <span class=\"sign_field\"></span><br>
			Выдающий: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Пожалуйста, убедитесь в том, что под этой записью поставит штамп действующий Глава Персонала. Штамп должен быть получен до конца одной стандартной рабочей недели.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/exosuit_transfer
	name = "Передача в пользование шагохода"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Передача в пользование шагохода</large></center><br>
			<hr>Полное имя получателя: <span class=\"paper_field\"></span><br>
			Полное имя передающего: <span class=\"paper_field\"></span><br>
			Категория шагохода: <span class=\"paper_field\"></span><br>
			Модель шагохода: <span class=\"paper_field\"></span><br>
			Причина выдачи: <span class=\"paper_field\"></span><br>
			<hr>Получатель: <span class=\"sign_field\"></span><br>
			Передающий: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/research_object
	name = "Отчет о изучении неизвестного объекта"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Отчет о изучении неизвестного объекта</large></center><br>
			<hr>Кодовое название объекта: <span class=\"paper_field\"></span><br>
			Полное имя ученого (составителя): <span class=\"paper_field\"></span><br>
			Процедуры сдерживания/активации: <span class=\"paper_field\"></span><br>
			Обобщенное описание Объекта: <span class=\"paper_field\"></span><br>
			Полное описание Объекта: <span class=\"paper_field\"></span><br>
			<font size = \"1\">Заполняется по желанию, в случае отказа выставить прочерк, в случае заполнения колонки выше (Обобщенное описание) не заполнять.</font><br>
			Приблизительный возраст Объекта: <span class=\"paper_field\"></span><br>
			Уровень угрозы, исходящий от объекта: <span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			Подопытный/Ассистент: <span class=\"sign_field\"></span><br>
			<font size = \"1\">Заполнять если при исследование объекта проводились эксперименты с участием ассистента.</font><br>
			Директор Отдела R&D/принимающий Глава: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/transfer_object
	name = "Транспортировка и передача исследуемого субъекта на СН 'ЦентКом'"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Транспортировка и передача исследуемого субъекта на СН "ЦентКом"</large></center><br>
			<hr>Кодовое название объекта: <span class=\"paper_field\"></span><br>
			Полное имя ученого (составителя): <span class=\"paper_field\"></span><br>
			Обобщенное описание Объекта: <span class=\"paper_field\"></span><br>
			Уровень угрозы, исходящий от объекта: <span class=\"paper_field\"></span><br>
			Причина транспортировки/передачи объекта: <span class=\"paper_field\"></span><br>
			Условия транспортировки объекта: <span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			Ответственный за транспортировку: <span class=\"sign_field\"></span><br>
			<font size = \"1\">Подписывая данное поле я готов понести наказание в соотв. со статьей 201 космического закона и несу полную ответственность за сохранность объекта и членов экипажа.</font><br>
			Директор Отдела R&D/принимающий Глава: <span class=\"sign_field\"></span><br>
			Сопровождающие: <span class=\"sign_field\"></span><br>
			<font size = \"1\">Необходима, если объект затруднительно безопасно транспортировать на СН "ЦентКом" без помощи посторонних.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/make_exosuit
	name = "Запрос на изготовление экзоскелета"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Запрос на изготовление экзоскелета</large></center><br>
			<hr>Полное имя заказчика: <span class=\"paper_field\"></span><br>
			Должность заказчика: <span class=\"paper_field\"></span><br>
			Категория шагохода: <span class=\"paper_field\"></span><br>
			Модель шагохода: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			<hr>Заказчик: <span class=\"sign_field\"></span><br>
			Специалист по производству экзоскелетов: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/exosuit_permission
	name = "Разрешение на пользование экзоскелетом"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Разрешение на пользование экзоскелетом</large></center><br>
			<hr>Полное имя пилота: <span class=\"paper_field\"></span><br>
			Должность пилота: <span class=\"paper_field\"></span><br>
			Категория шагохода: <span class=\"paper_field\"></span><br>
			Модель шагохода: <span class=\"paper_field\"></span><br>
			<hr>Специалист по производству экзоскелетов: <span class=\"sign_field\"></span><br>
			Руководитель пилота: <span class=\"sign_field\"></span><br>
			Пилот: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*В случае одобрения данный документ должен быть отмечен штампом руководителя пилота.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/bomb_test
	name = "Отчет о испытании взрывного устройства"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Отчет о испытании взрывного устройства</large></center><br>
			<hr>Полное имя испытателя: <span class=\"paper_field\"></span><br>
			Полное имя изготовителя: <span class=\"paper_field\"></span><br>
			Использованные компоненты: <span class=\"paper_field\"></span><br>
			Использованные вещества (доля вещества в процентах, температура в кельвинах, давление в килопаскалях): <span class=\"paper_field\"></span><br>
			Мощность взрыва: <span class=\"paper_field\"></span><br>
			<hr>Испытатель: <span class=\"sign_field\"></span><br>
			Изготовитель: <span class=\"sign_field\"></span><br>
			Директор Отдела R&D: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Отчет должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/research_report
	name = "Отчет о проведенных исследованиях"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Отчет о проведенных исследованиях</large></center><br>
			<hr>Полное имя исследователя: <span class=\"paper_field\"></span><br>
			Области исследования: <span class=\"paper_field\"></span><br>
			Исследованные технологии (надежность технологии в процентах): <span class=\"paper_field\"></span><br>
			Количество потраченных научно-исследовательских пакетов данных: <span class=\"paper_field\"></span><br>
			<hr>Исследователь: <span class=\"sign_field\"></span><br>
			Директор Отдела R&D: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Отчет должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/scan_objects
	name = "Отчет о сканировании ценных научно-исследовательских объектов"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Отчет о сканировании ценных научно-исследовательских объектов</large></center><br>
			<hr>Полное имя сканировщика: <span class=\"paper_field\"></span><br>
			Полное имя сотрудника, предоставившего объект/объекты: <span class=\"paper_field\"></span><br>
			Должность сотрудника, предоставившего объект/объекты: <span class=\"paper_field\"></span><br>
			Объект сканирования: <span class=\"paper_field\"></span><br>
			Количество полученных научно-исследовательских пакетов данных: <span class=\"paper_field\"></span><br>
			<hr>Сканировщик: <span class=\"sign_field\"></span><br>
			Сотрудник, предоставивший объект/объекты: <span class=\"sign_field\"></span><br>
			Директор Отдела R&D: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Отчет должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/space_structure
	name = "Отчет об исследовании заброшенного объекта в дальнем космосе"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Отчет об исследовании заброшенного объекта в дальнем космосе</large></center><br>
			<hr>Полное имя оператора телепада: <span class=\"paper_field\"></span><br>
			Полное имя исследователя: <span class=\"paper_field\"></span><br>
			<hr>Имена, должности и подписи иных сотрудников, задействованных при исследовании: <span class=\"paper_field\"></span><br>
			<font size = \"1\">Если никакие иные сотрудники не были задействованы при исследовании, то ставится прочерк.</font><br>
			<hr>Координаты объекта: <span class=\"paper_field\"></span><br>
			Полное описание объекта: <span class=\"paper_field\"></span><br>
			Обнаруженные организмы (внешний вид, состояние, поведение): <span class=\"paper_field\"></span><br>
			Обнаруженные сооружения и предметы (внешний вид, состояние): <span class=\"paper_field\"></span><br>
			Изъятые предметы: <span class=\"paper_field\"></span><br>
			<hr>Оператор телепада: <span class=\"sign_field\"></span><br>
			Исследователь: <span class=\"sign_field\"></span><br>
			Директор Отдела R&D: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Отчет должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/prototypes
	name = "Акт об изготовлении прототипов"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Акт об изготовлении прототипов</large></center><br>
			<hr>Полное имя изготовителя: <span class=\"paper_field\"></span><br>
			Прототипы: <span class=\"paper_field\"></span><br>
			Количество прототипов: <span class=\"paper_field\"></span><br>
			Причина изготовления: <span class=\"paper_field\"></span><br>
			Потраченные виды ресурсов (количество в кубометрах): <span class=\"paper_field\"></span><br>
			<hr>Изготовитель: <span class=\"sign_field\"></span><br>
			Директор Отдела R&D: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Акт должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/make_exosuit_report
	name = "Акт об изготовлении экзоскелета"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b><br>
			Акт об изготовлении экзоскелета</large></center><br>
			<hr>Полное имя изготовителя: <span class=\"paper_field\"></span><br>
			Категория шагохода: <span class=\"paper_field\"></span><br>
			Модель шагохода: <span class=\"paper_field\"></span><br>
			Установленные модули: <span class=\"paper_field\"></span><br>
			Причина изготовления: <span class=\"paper_field\"></span><br>
			Потраченные виды ресурсов (количество в кубометрах): <span class=\"paper_field\"></span><br>
			<hr>Изготовитель: <span class=\"sign_field\"></span><br>
			Директор Отдела R&D: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Акт должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font><br>
			<hr>Место для штампов."}

//---------------Security---------------
var/global/list/security_forms = list(list("type" = /obj/item/weapon/paper/arrest_report, "name" = "Протокол задержания"),
							list("type" = /obj/item/weapon/paper/criminalist_report, "name" = "Отчет криминалиста"),
							list("type" = /obj/item/weapon/paper/search_warrant, "name" = "Ордер на обыск"),
							list("type" = /obj/item/weapon/paper/third_person, "name" = "Свидетельский лист"),
							list("type" = /obj/item/weapon/paper/legal_weapon, "name" = "Разрешение на оружие"),
							list("type" = /obj/item/weapon/paper/execution, "name" = "Приказ о высшей мере наказания"),
							list("type" = /obj/item/weapon/paper/loyality_volunt, "name" = "Заявление на добровольное внедрение импланта лояльности"),
							list("type" = /obj/item/weapon/paper/dismiss_test_subject, "name" = "Заявление на добровольно-принудительный перевод в статус 'Подопытный'"),
							list("type" = /obj/item/weapon/paper/loyality_force, "name" = "Заявление на принудительное введение импланта лояльности"))
/obj/item/weapon/paper/arrest_report
	name = "Протокол задержания"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b><br>
			Протокол задержания</large></center><br>
			<hr>Полное имя офицера проводившего задержание: <span class=\"paper_field\"></span><br>
			Полное имя задержанного: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Статьи предъявленные задержанному: <span class=\"paper_field\"></span><br>
			Свидетели преступления: <span class=\"paper_field\"></span><br>
			Место совершения преступления: <span class=\"paper_field\"></span><br>
			Описание преступления: <span class=\"paper_field\"></span><br>
			<hr>Офицер проводивший задержание: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*К данному документу могут прилагаться любые улики с места происшествия (показатели свидетелей, фотографии или любые другие улики которые следствие сочтет уместными)</font>"}

/obj/item/weapon/paper/criminalist_report
	name = "Отчет криминалиста"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b><br>
			Отчет криминалиста</large></center><br>
			<hr>Полное имя криминалиста: <span class=\"paper_field\"></span><br>
			Тип преступления: <span class=\"paper_field\"></span><br>
			Место преступления: <span class=\"paper_field\"></span><br>
			Примечания: <span class=\"paper_field\"></span><br>
			<hr><b>Отчет:</b><br>
			<span class=\"paper_field\"></span><br>
			<hr>Криминалист: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Документ может выдаваться только представителям Службы Безопасности, Главе Персонала, Капитану.</font>"}

/obj/item/weapon/paper/search_warrant
	name = "Ордер на обыск"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b><br>
			Ордер на обыск</large></center><br>
			<hr>Полное имя цели осмотра: <span class=\"paper_field\"></span><br>
			Полное имя офицера(ов): <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			Обыск рабочего места: <span class=\"paper_field\"></span><br>
			Обыск подозреваемого: <span class=\"paper_field\"></span><br>
			<hr>Глава Службы Безопасности: <span class=\"sign_field\"></span><br>
			Глава Персонала: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Протоколы обыска могут быть проигнорированы при уровне тревоги "Синий" и выше.<br><br>
			Графа "Обыск рабочего места" и "Обыск обыск подозреваемого" должны быть обязательно заполнены.<br>
			"+" - обыск разрешен "-" - обыск запрещен.</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/third_person
	name = "Свидетельский лист"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b><br>
			Свидетельский лист</large></center><br>
			<hr>Полное имя свидетеля: <span class=\"paper_field\"></span><br>
			Полное имя офицера составителя: <span class=\"paper_field\"></span><br>
			Тип происшествия: <span class=\"paper_field\"></span><br>
			Место происшествия: <span class=\"paper_field\"></span><br>
			Примечания: <span class=\"paper_field\"></span><br>
			<hr><b>Свидетельство:</b><br>
			<span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			Свидетель: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Заполняется сотрудником Службы Безопасности со слов свидетеля.</font>"}

/obj/item/weapon/paper/legal_weapon
	name = "Разрешение на оружие"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b><br>
			Разрешение на оружие</large></center><br>
			<hr>Полное имя заказчика: <span class=\"paper_field\"></span><br>
			Полное имя выдавшего оружие: <span class=\"paper_field\"></span><br>
			Тип оружия: <span class=\"paper_field\"></span><br>
			<font size = \"1\">Количество и наименование.</font><br>
			Цель выдачи: <span class=\"paper_field\"></span><br>
			Примечания: <span class=\"paper_field\"></span><br>
			<hr>Заказчик: <span class=\"sign_field\"></span><br>
			Выдавший оружие: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/execution
	name = "Приказ о высшей мере наказания"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b><br>
			Приказ о высшей мере наказания</large></center><br>
			<hr>Полное имя арестанта: <span class=\"paper_field\"></span><br>
			Причина казни: <span class=\"paper_field\"></span><br>
			Полное имя палача: <span class=\"paper_field\"></span><br>
			Полное имя должностного лица, выдавшего приказ: <span class=\"paper_field\"></span><br>
			<hr>Должностное лицо: <span class=\"sign_field\"></span><br>
			Палач: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/loyality_volunt
	name = "Заявление на добровольное внедрение импланта лояльности"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b><br>
			Заявление на добровольное внедрение импланта лояльности</large></center><br>
			<hr>Полное имя лица, которому внедряется имплант: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			<hr>Лицо, которому внедряется имплант: <span class=\"sign_field\"></span><br>
			Капитан/Глава Службы Безопасности: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/dismiss_test_subject
	name = "Заявление на добровольно-принудительный перевод в статус 'Подопытный'"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b><br>
			Заявление на добровольно-принудительный перевод в статус "Подопытный"</large></center><br>
			<hr>Полное имя лица, переводящегося в подопытные: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			<hr>Подпись: <span class=\"sign_field\"></span><br>
			<font size = \"1\">Только при необходимости.</font><br>
			Капитан/Глава Службы Безопасности: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/loyality_force
	name = "Заявление на принудительное введение импланта лояльности"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b><br>
			Заявление на принудительное введение импланта лояльности</large></center><br>
			<hr>Полное имя лица, которому внедряется имплант: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Причина: <span class=\"paper_field\"></span><br>
			<hr>Подпись: <span class=\"sign_field\"></span><br>
			<font size = \"1\">Только при необходимости.</font><br>
			Капитан/Глава Службы Безопасности: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

//---------------Engineering---------------
var/global/list/engineering_forms = list(/obj/item/weapon/paper/exploitation = "Документ по эксплуатации отсека")
/obj/item/weapon/paper/exploitation
	name = "Документ по эксплуатации отсека"
	info = {"<center><large><b>Инженерный Отдел КСН "Исход"</b><br>
			Документ по эксплуатации отсека</center></large><br>
			<hr>Полное имя ответственного за постройку: <span class=\"paper_field\"></span><br>
			Полное имя помощника(ов): <span class=\"paper_field\"></span><br>
			Тип работ: <span class=\"paper_field\"></span><br>
			Место проведения работ: <span class=\"paper_field\"></span><br>
			<hr><b>Описание:</b><br>
			Короткое описание изменений: <span class=\"paper_field\"></span><br>
			Основные позитивные моменты: <span class=\"paper_field\"></span><br>
			<hr>Ответственный за постройку: <span class=\"sign_field\"></span><br>
			Помощник(и): <span class=\"sign_field\"></span><br>
			Главный Инженер: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Подписывая этот документ, я обязываюсь выполнить всю намеченную работу до конца, и несу полную ответственность за проведения работ на этой территории, до тех пор пока не сдам объект в полностью готовом состоянии и не предъявлю работу своему начальству.</font><br>
			<hr>Место для штампов."}

//---------------Important---------------
var/global/list/important_forms = list(list("type" = /obj/item/weapon/paper/emergency_shuttle, "name" = "Отчет по причине вызова экстренного эвакуационного шаттла"),
							list("type" = /obj/item/weapon/paper/ert, "name" = "Отчет вызова экстренной команды"),
							list("type" = /obj/item/weapon/paper/delta, "name" = "Инициация кода 'Дельта'"),
							list("type" = /obj/item/weapon/paper/incident_report, "name" = "Стандартный отчет о произошедшем инциденте"),
							list("type" = /obj/item/weapon/paper/internal_affairs, "name" = "Отчет Агента Внутренних Дел"))
/obj/item/weapon/paper/emergency_shuttle
	name = "Отчет по причине вызова экстренного эвакуационного шаттла"
	info = {"<center><large><b>Командный Cостав КСН "Исход"</b><br>
			Отчет по причине вызова экстренного эвакуационного шаттла</large></center><br>
			<hr>Полное имя представителя командования: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Бортовое время: <span class=\"paper_field\"></span><br>
			<hr><b>Отчет:</b><br>
			<span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/ert
	name = "Отчет вызова экстренной команды"
	info = {"<center><large><b>Командный Cостав КСН "Исход"</b><br>
			Отчет вызова экстренной команды</large></center><br>
			<hr>Полное имя представителя командования: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Бортовое время: <span class=\"paper_field\"></span><br>
			Тип экстренной ситуации: <span class=\"paper_field\"></span><br>
			Размеры ущерба/Сколько погибло/Текущее состояние всей станции и персонала: <span class=\"paper_field\"></span><br>
			<hr><b>Краткое/Полное изложение сути проишествия:</b><br>
			<span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/delta
	name = "Инициация кода 'Дельта'"
	info = {"<center><large><b>Командный Cостав КСН "Исход"</b><br>
			Инициация кода "Дельта"<large></center><br>
			<hr>Полное имя представителя командования: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Бортовое время: <span class=\"paper_field\"></span><br>
			Причина инициации кода "Дельта": <span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Внимание, инициируя код "Дельта" данное лицо берет на себя полную ответственность за происходящее. Данная глава станции КСН "Исход" полностью понимает, что активация кода "Дельта" крайняя мера и означает, что ситуация на станции полностью вышла из под контроля</font><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/incident_report
	name = "Стандартный отчет о произошедшем инциденте"
	info = {"<center><large><b>Командный Cостав КСН "Исход"</b><br>
			Стандартный отчет о произошедшем инциденте</large></center><br>
			<hr>Полное имя представителя командования: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			Инцидент: <span class=\"paper_field\"></span><br>
			Последствия инцидента: <span class=\"paper_field\"></span><br>
			Принятые меры для предотвращения инцидента: <span class=\"paper_field\"></span><br>
			<hr><b>Запрос действий/инструкций от ЦК (если необходимы):</b><br>
			<span class=\"paper_field\"></span><br>
			<hr>Составитель: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

/obj/item/weapon/paper/internal_affairs
	name = "Отчет Агента Внутренних Дел"
	info = {"<center><large><b>КСН "Исход"</b><br>
			Отчет Агента Внутренних Дел</large></center><br>
			<hr>Полное имя Агента: <span class=\"paper_field\"></span><br>
			Субъект/интересующий инцидент под вопросом: <span class=\"paper_field\"></span><br>
			Инцидент: <span class=\"paper_field\"></span><br>
			Местоположение: <span class=\"paper_field\"></span><br>
			Персонал, вовлеченные в инцидент: <span class=\"paper_field\"></span><br>
			<hr><b>Изложение фактов:</b><br>
			<span class=\"paper_field\"></span><br>
			<hr>Агент: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}

//---------------Misc---------------
var/global/list/misc_forms = list(list("type" = /obj/item/weapon/paper/bar_menu, "name" = "Меню бара"),
							list("type" = /obj/item/weapon/paper/canteen_menu, "name" = "Меню столовой"),
							list("type" = /obj/item/weapon/paper/offence_report, "name" = "Заявление о правонарушении"),
							list("type" = /obj/item/weapon/paper/noname_fax_reply, "name" = "Неименной ответ на факс"),
							list("type" = /obj/item/weapon/paper/name_fax_reply, "name" = "Именной ответ на факс"),
							list("type" = /obj/item/weapon/paper/transport_visa, "name" = "Транспортная виза"),
							list("type" = /obj/item/weapon/paper/customs_report, "name" = "Протокол растаможивания"))
/obj/item/weapon/paper/bar_menu
	name = "Меню бара"
	info = {"<font size=\"4\"><center><b><span class=\"paper_field\"></span></b></center></font><br>
			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Алкогольные напитки</b></center></font></div><br>
			Space Beer<span class=\"paper_field\"></span><br>
			Iced Space Beer<span class=\"paper_field\"></span><br>
			Station 13 Grog<span class=\"paper_field\"></span><br>
			Magm-Ale<span class=\"paper_field\"></span><br>
			Griffeater's Gin<span class=\"paper_field\"></span><br>
			Uncle Git's Special Reserve<span class=\"paper_field\"></span><br>
			Caccavo Guaranteed Quality Tequilla<span class=\"paper_field\"></span><br>
			Tunguska Triple Distilled<span class=\"paper_field\"></span><br>
			Goldeneye Vermouth<span class=\"paper_field\"></span><br>
			Captain Pete's Cuban Spiced Rum<span class=\"paper_field\"></span><br>
			Doublebeard Beared Special Wine<span class=\"paper_field\"></span><br>
			Chateua De Baton Premium Cognac<span class=\"paper_field\"></span><br>
			Robert Robust's Coffee Liqueur<span class=\"paper_field\"></span><br><br><br>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Коктейли </b></center></font></div><br>
			Allies Cocktail<span class=\"paper_field\"></span><br>
			Andalusia<span class=\"paper_field\"></span><br>
			Anti-Freeze<span class=\"paper_field\"></span><br>
			Bahama Mama<span class=\"paper_field\"></span><br>
			Classic Martini<span class=\"paper_field\"></span><br>
			Cuba Libre<span class=\"paper_field\"></span><br>
			Gin Fizz<span class=\"paper_field\"></span><br>
			Gin and Tonic<span class=\"paper_field\"></span><br>
			Irish Car Bomb<span class=\"paper_field\"></span><br>
			Irish Coffee<span class=\"paper_field\"></span><br>
			Irish Cream<span class=\"paper_field\"></span><br>
			Long Island Iced Tea<span class=\"paper_field\"></span><br>
			Manhattan<span class=\"paper_field\"></span><br>
			The Manly Dorf<span class=\"paper_field\"></span><br>
			Margarita<span class=\"paper_field\"></span><br>
			Screwdriver<span class=\"paper_field\"></span><br>
			Syndicate Bomb<span class=\"paper_field\"></span><br>
			Pan-Galactic Gargle Blaster<span class=\"paper_field\"></span><br>
			Tequilla Sunrise<span class=\"paper_field\"></span><br>
			Vodka Martini<span class=\"paper_field\"></span><br>
			Vodka and Tonic<span class=\"paper_field\"></span><br>
			Whiskey Cola<span class=\"paper_field\"></span><br>
			Whiskey Soda<span class=\"paper_field\"></span><br>
			White Russian<span class=\"paper_field\"></span><br><br><br>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Безалкогольные напитки</b></center></font></div><br>
			Coffee<span class=\"paper_field\"></span><br>
			Tea<span class=\"paper_field\"></span><br>
			Hot Chocolate<span class=\"paper_field\"></span><br>
			Iced Tea<span class=\"paper_field\"></span><br>
			Iced Coffee<span class=\"paper_field\"></span><br>
			Orange Juice<span class=\"paper_field\"></span><br>
			Tomato Juice<span class=\"paper_field\"></span><br>
			Tonic Water<span class=\"paper_field\"></span><br>
			Sodas<span class=\"paper_field\"></span>"}

/obj/item/weapon/paper/canteen_menu
	name = "Меню столовой"
	info = {"<font size=\"4\"><center><b>Меню питания</b></center></font><br>
			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Первое блюдо</b></center></font></div><br>
			<span class=\"paper_field\"></span><br><br><br>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Гарнир</b></center></font></div><br>
			<span class=\"paper_field\"></span><br><br><br>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Второе горячее блюдо</b></center></font></div><br>
			<span class=\"paper_field\"></span><br><br><br>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Десерт</b></center></font></div><br>
			<span class=\"paper_field\"></span><br><br><br>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Напитки</b></center></font></div><br>
			<span class=\"paper_field\"></span><br><br><br>


			<hr>Ответственный за меню: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Заведующий столовой оставляет за собой право изменения действующего меню. Наличие блюда в меню не дает полной гарантии наличия в настоящем или будущем времени данного блюда. </font>"}

/obj/item/weapon/paper/offence_report
	name = "Заявление о правонарушении"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b><br>
			Заявление о правонарушении</large></center><br>
			<hr>Полное имя пострадавшего: <span class=\"paper_field\"></span><br>
			Тип происшествия: <span class=\"paper_field\"></span><br>
			Место происшествия: <span class=\"paper_field\"></span><br>
			Примечания: <span class=\"paper_field\"></span><br>
			<hr><b>Описание происшествия:</b><br>
			<span class=\"paper_field\"></span><br>
			<hr>Пострадавший: <span class=\"sign_field\"></span><br>
			Ответственного лицо, принявшее заявление: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Заполняется только лицами пострадавшими от правонарушения. Присутствие офицера при заполнение не обязательно.</font>"}

/obj/item/weapon/paper/noname_fax_reply
	name = "Неименной ответ на факс"
	info = {"<center>NT<br>
			<large><b>Центральное Командование NanoTrasen</b><br>
			Официальный документ</large></center><br>
			<hr><span class=\"paper_field\"></span><br><br>

			СН ЦентКом, Тау Кита<br>
			<hr><font size = \"1\">*Несоблюдение распоряжений, описанных в настоящем документе, является прямым нарушением законов NanoTrasen. Лица, нарушившие действующий протокол, могут быть привлечены к ответственности по возвращении на СН ЦентКом.<br><br>
			Получатель(и) этого документа подтверждает, что он несет полную ответственность за любой ущерб, причиненный экипажу или станции, в результате игнорирования предписаний или рекомендаций, изложенных в настоящем документе.</font>"}

/obj/item/weapon/paper/name_fax_reply
	name = "Именной ответ на факс"
	info = {"<center>NT<br>
			<large><b>Центральное Командование NanoTrasen</b><br>
			Официальный документ</large></center><br>
			<hr><span class=\"paper_field\"></span><br><br>

			ДОЛЖНОСТЬ, <i>Фамилия Имя</i><br>
			СН ЦентКом, Тау Кита<br>
			<hr><font size = \"1\">*Несоблюдение распоряжений, описанных в настоящем документе, является прямым нарушением законов NanoTrasen. Лица, нарушившие действующий протокол, могут быть привлечены к ответственности по возвращении на СН ЦентКом.<br><br>
			Получатель(и) этого документа подтверждает, что он несет полную ответственность за любой ущерб, причиненный экипажу или станции, в результате игнорирования предписаний или рекомендаций, изложенных в настоящем документе.</font>"}

/obj/item/weapon/paper/transport_visa
	name = "Транспортная виза"
	info = {"<center><large><b>НТС "Велосити"</b><br>
			Транспортная виза</large></center><br>
			<hr>Полное имя: <span class=\"paper_field\"></span><br>
			Должность: <span class=\"paper_field\"></span><br>
			<b>Корпорация Карго Индастриз</b></center><br>
			<hr>Место отправления: НТС "Велосити"<br>
			Место прибытия: <span class=\"paper_field\"></span><br>
			Цель посещения: <span class=\"paper_field\"></span><br>
			Подпись: <span class=\"sign_field\"></span><br>
			<hr><b>Разрешение</b><br>
			Охрана транспортной системы: <span class=\"sign_field\"></span><br>
			<hr><font size = \"1\">*Если настоящий документ был изготовлен нелегально и/или вне пропускного пункта НТС "Велосити", заполнитель документа понесет административное наказание согласно пункту 46-7b кодекса Карго Индастриз.</font>"}

/obj/item/weapon/paper/customs_report
	name = "Протокол растаможивания"
	info = {"<center><large><b>Служба Безопасности НТС "Велосити"</b><br>
			Протокол растаможивания</large></center><br>
			<hr>Полное имя запросившего: <span class=\"paper_field\"></span><br>
			Полное имя офицера транзитной станции: <span class=\"paper_field\"></span><br>
			Тип предметов подлежащих растаможиванию: <span class=\"paper_field\"></span><br>
			<font size = \"1\">Количество и наименование.</font><br>
			Цель выдачи: <span class=\"paper_field\"></span><br>
			Примечания: <span class="paper_field"></span><br>
			Объект ввоза растаможенных предметов:<span class=\"paper_field\"></span><br>
			<hr>Запросивший: <span class=\"sign_field\"></span><br>
			Офицер, выдавший разрешение: <span class=\"sign_field\"></span><br>
			<hr>Место для штампов."}
