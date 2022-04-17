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
var/global/list/cargo_forms = list(/obj/item/weapon/paper/item_request,
							/obj/item/weapon/paper/materials_request,
							/obj/item/weapon/paper/post_request,
							/obj/item/weapon/paper/cargo_inventory,
							/obj/item/weapon/paper/mining_waybill)
/obj/item/weapon/paper/item_request
	name = "Запрос в Отдел Поставок"
	info = {"<center><large><b>Отдел Поставок КСН "Исход"</b>
			Запрос в Отдел Поставок</large></center>
			<hr>Полное имя заказчика: <span class=\"paper_field\"></span>
			Заказ: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			Место доставки: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			<hr>Заказчик: <span class=\"sign_field\"></span>
			Принимающий сотрудник: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*В случае получения разрешения на заказ он должен быть отмечен штампом "Одобрено" и штампом Квартирмейстера. Заказы, не получившие разрешения со стороны Глав или Квартирмейстера, должны быть отмечены штампом "Отказано". В случае отсутствия Глав, Квартирмейстер сам может решать, что заказывать, а что нет. После заполнения, накладная должна храниться в картотеке до конца смены.<br>
			За предметы не относящимся к работе может взиматься плата.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/materials_request
	name = "Запрос в Отдел Поставок на поставки сырья"
	info = {"<center><large><b>Отдел Поставок КСН "Исход"</b>
			Запрос в Отдел Поставок на поставки сырья</large></center>
			<hr>Полное имя заказчика: <span class=\"paper_field\"></span>
			Материалы: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			Количество: <span class=\"paper_field\"></span>
			Место доставки: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			<hr>Заказчик: <span class=\"sign_field\"></span>
			Принимающий сотрудник: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*В случае получения разрешения на заказ он должен быть отмечен штампом "Одобрено" и штампом Квартирмейстера. Заказы, не получившие разрешения со стороны Глав или Квартирмейстера, должны быть отмечены штампом "Отказано". В случае отсутствия Глав, Квартирмейстер сам может решать, что заказывать, а что нет. После заполнения, накладная должна храниться в картотеке до конца смены.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/post_request
	name = "Заказ на почтовую пересылку"
	info = {"<center><large><b>Отдел Поставок КСН "Исход"</b>
			Заказ на почтовую пересылку</large></center>
			<hr>Полное имя заказчика: <span class=\"paper_field\"></span>
			Посылка: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			Место доставки: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			<hr>Заказчик: <span class=\"sign_field\"></span>
			Принимающий сотрудник: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Если посылка не является предметом высокого риска то нужды в штампе глав нет. Но если это опасные для станции предметы то нужен штамп от Главы Службы Безопасности, Главы Персонала или Капитана.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/cargo_inventory
	name = "Складская опись"
	info = {"<center><large><b>Отдел Поставок КСН "Исход"</b>
			Складская опись</large></center>
			<hr>Время составления описи: <span class=\"paper_field\"></span>
			Опись составил: <span class=\"paper_field\"></span>
			<hr>Содержимое склада.
			<font size = \"1\">В скобках пометить количество.</font>
			<ul>(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			(<li>)<span class=\"paper_field\"></span>
			</ul><hr>Составитель: <span class=\"sign_field\"></span>"}

/obj/item/weapon/paper/mining_waybill
	name = "Накладная на поставки с шахтерского аванпоста"
	info = {"<center><large><b>Отдел Поставок КСН "Исход"</b>
			Накладная на поставки с шахтерского аванпоста</large></center>
			<hr>Время составления накладной: <span class=\"paper_field\"></span>
			Номер поставки: <span class=\"paper_field\"></span>
			<hr><b>Руды/Материалы в этой поставке</b>
			Железная руда: <span class=\"paper_field\"></span>, Металл: <span class=\"paper_field\"></span>, Пласталь: <span class=\"paper_field\"></span>
			Песок: <span class=\"paper_field\"></span>, Стекло: <span class=\"paper_field\"></span>, Укрепленное стекло: <span class=\"paper_field\"></span>
			Золотая руда: <span class=\"paper_field\"></span>, Золотой слиток(слитки): <span class=\"paper_field\"></span>
			Серебряная руда: <span class=\"paper_field\"></span>, Серебряный слиток(слитки): <span class=\"paper_field\"></span>
			Неочищенная плазма: <span class=\"paper_field\"></span>, Твердая плазма: <span class=\"paper_field\"></span>
			Уран: <span class=\"paper_field\"></span>, Очищенный уран: <span class=\"paper_field\"></span>
			Алмаз: <span class=\"paper_field\"></span>, Ограненный алмаз(алмазы): <span class=\"paper_field\"></span>
			Разное: <span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			Принимающий сотрудник: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*В случае получения разрешения на заказ он должен быть отмечен штампом "Одобрено" и штампом Квартирмейстера. Заказы, не получившие разрешения со стороны Глав или Квартирмейстера, должны быть отмечены штампом "Отказано". В случае отсутствия Глав, Квартирмейстер сам может решать, что заказывать, а что нет. После заполнения, накладная должна храниться в картотеке до конца смены.</font>"}

//---------------Human Resources Department---------------
var/global/list/hrd_forms = list(/obj/item/weapon/paper/temporary_access,
							/obj/item/weapon/paper/permanent_access,
							/obj/item/weapon/paper/dismissal,
							/obj/item/weapon/paper/access_certificate,
							/obj/item/weapon/paper/change_job,
							/obj/item/weapon/paper/test_subject,
							/obj/item/weapon/paper/new_id)
/obj/item/weapon/paper/temporary_access
	name = "Анкета на получение временного дополнительного доступа"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b>
			Анкета на получение временного дополнительного доступа</large></center>
			<hr>Полное имя составителя: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Запрос доступа в: <span class=\"paper_field\"></span>
			Продолжительность: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			Глава Отдела Кадров: <span class=\"sign_field\"></span>
			Ответственный за помещения: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/permanent_access
	name = "Анкета на получение постоянного дополнительного доступа"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b>
			Анкета на получение постоянного дополнительного доступа</large></center>
			<hr>Полное имя составителя: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Запрос доступа в: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			Глава Отдела Кадров: <span class=\"sign_field\"></span>
			Ответственный за помещения: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/dismissal
	name = "Анкета на увольнение/понижение"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b>
			Анкета на увольнение/понижение</center></large>
			<hr>Полное имя сотрудника: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Причина увольнения/понижения: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			<hr>Глава увольняемого/понижаемого: <span class=\"sign_field\"></span>
			Глава Отдела Кадров: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Форма должна быть заполнена только Главой увольняемого/понижаемого или Главой Отдела Кадров.<br>
			Увольняемый/понижаемый должен быть уведомлен о факте написания документа и передачи его в Отдел Кадров.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/access_certificate
	name = "Сертификат о выдаче дополнительного доступа"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b>
			Сертификат о выдаче дополнительного доступа</large></center>
			<hr>Полное имя сотрудника: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Выданные доступы: <span class=\"paper_field\"></span>
			Время выдачи: <span class=\"paper_field\"></span>
			Время действия: <span class=\"paper_field\"></span>
			<hr>Выдавший доступы: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/change_job
	name = "Анкета смены занимаемой должности"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b>
			Анкета смены занимаемой должности</large></center>
			<hr>Полное имя составителя: <span class=\"paper_field\"></span>
			Текущая должность: <span class=\"paper_field\"></span>
			Запрашиваемая должность: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			Текущий начальник отдела: <span class=\"sign_field\"></span>
			Принимающий начальник отдела: <span class=\"sign_field\"></span>
			Глава Отдела Кадров: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/test_subject
	name = "Форма запроса подопытного в целях эксплуатации"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b>
			Форма запроса подопытного в целях эксплуатации</large></center>
			<hr>Полное имя: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Причина запроса ассистента: <span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			Текущий начальник отдела:  <span class=\"sign_field\"></span>
			Глава Отдела Кадров: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/new_id
	name = "Форма получения новой ID карты"
	info = {"<center><large><b>Отдел Кадров КСН "Исход"</b>
			Форма получения новой ID карты</large></center>
			<hr>Полное имя сотрудника: <span class=\"paper_field\"></span>
			Текущая должность: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			Текущий начальник отдела: <span class=\"sign_field\"></span>
			Глава Отдела Кадров: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

//---------------Medbay---------------
var/global/list/medbay_forms = list(/obj/item/weapon/paper/recipe,
							/obj/item/weapon/paper/surgery_report,
							/obj/item/weapon/paper/autopsy_report,
							/obj/item/weapon/paper/drugs_list,
							/obj/item/weapon/paper/disability_report,
							/obj/item/weapon/paper/chemistry_request)
/obj/item/weapon/paper/recipe
	name = "Рецепт на медицинский препарат"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b>
			Рецепт на медицинский препарат</large></center>
			<hr>Полное имя пациента: <span class=\"paper_field\"></span>
			Назначенные препараты: <span class=\"paper_field\"></span>
			<hr>Назначивший врач: <span class=\"sign_field\"></span>
			Фармацевт принявший рецепт: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Этот рецепт не может быть использован повторно.</font>"}

/obj/item/weapon/paper/surgery_report
	name = "Отчёт о проведённой операции"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b>
			Отчёт о проведённой операции</large></center>
			<hr>Вид и место операции: <span class=\"paper_field\"></span>
			<hr>Полное имя оперирующего: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			<hr>Полное имя пациента: <span class=\"paper_field\"></span>
			Время проведения: <span class=\"paper_field\"></span>
			<hr>Осложнения, возникшие по ходу операции (в случае отсутствия оставить пустым): <span class=\"paper_field\"></span>
			<hr>Оперирующий: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/autopsy_report
	name = "Отчет о вскрытии тела"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b>
			Отчет о вскрытии тела</large></center>
			<hr>Полное имя умершего: <span class=\"paper_field\"></span>
			Раса: <span class=\"paper_field\"></span>
			Пол: <span class=\"paper_field\"></span>
			Возраст: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			<hr>Тип смерти: <span class=\"paper_field\"></span>
			Визуальное описание тела: <span class=\"paper_field\"></span>
			Особые приметы и повреждения: <span class=\"paper_field\"></span>
			<hr>Вероятная причина смерти: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			<hr>Патологоанатом: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">Настоящим я заявляю, что после заполнения отчета, описанного в данном документе, я взял на себя ответственность за тело и определил причину смерти в соответствии с разделом 38-701b патологического кодекса NanoTrasen и что информация, содержащаяся в документе, верна и правильна в меру моих знаний и убеждений.</font>"}

/obj/item/weapon/paper/drugs_list
	name = "Список выдачи препаратов"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b>
			Список выдачи препаратов</large></center>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span>
			Время выдачи: <span class=\"paper_field\"></span>
			Полное имя заказчика: <span class=\"paper_field\"></span>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span>
			Время выдачи: <span class=\"paper_field\"></span>
			Полное имя заказчика: <span class=\"paper_field\"></span>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span>
			Время выдачи: <span class=\"paper_field\"></span>
			Полное имя заказчика: <span class=\"paper_field\"></span>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span>
			Время выдачи: <span class=\"paper_field\"></span>
			Полное имя заказчика: <span class=\"paper_field\"></span>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span>
			Время выдачи: <span class=\"paper_field\"></span>
			Полное имя заказчика: <span class=\"paper_field\"></span>
			<hr>Запрошенный химикат(ы): <span class=\"paper_field\"></span>
			Время выдачи: <span class=\"paper_field\"></span>
			Полное имя заказчика: <span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>"}

/obj/item/weapon/paper/disability_report
	name = "Справка о нетрудоспособности"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b>
			Справка о нетрудоспособности</large></center>
			<hr>Полное имя сотрудника: <span class=\"paper_field\"></span>
			Пол: <span class=\"paper_field\"></span>
			Возраст: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			<hr>Диагноз: <span class=\"paper_field\"></span>
			Дополнительная информация: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			<hr>Врач: <span class=\"sign_field\"></span>
			Глава Персонала: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Этот документ подтверждает нетрудоспособность работника станции в связи с его установленным в законном порядке диагнозом.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/chemistry_request
	name = "Запрос в химическую лабораторию на выдачу препарата"
	info = {"<center><large><b>Медицинское Управление КСН "Исход"</b>
			Запрос в химическую лабораторию на выдачу препарата</large></center>
			Необходимые препараты: <span class=\"paper_field\"></span>
			Количество: <span class=\"paper_field\"></span>
			<hr>Заказчик: <span class=\"sign_field\"></span>"}

//---------------RnD---------------
var/global/list/rnd_forms = list(/obj/item/weapon/paper/experiment_permission,
							/obj/item/weapon/paper/genetics_permission,
							/obj/item/weapon/paper/cyborgisation_permission,
							/obj/item/weapon/paper/credit_equipment,
							/obj/item/weapon/paper/exosuit_transfer,
							/obj/item/weapon/paper/research_object,
							/obj/item/weapon/paper/transfer_object,
							/obj/item/weapon/paper/make_exosuit,
							/obj/item/weapon/paper/exosuit_permission,
							/obj/item/weapon/paper/bomb_test,
							/obj/item/weapon/paper/research_report,
							/obj/item/weapon/paper/scan_objects,
							/obj/item/weapon/paper/space_structure,
							/obj/item/weapon/paper/prototypes,
							/obj/item/weapon/paper/make_exosuit_report)
/obj/item/weapon/paper/experiment_permission
	name = "Разрешение на проведение опасного для жизни эксперимента"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Разрешение на проведение опасного для жизни эксперимента</large></center>
			<hr>Полное имя подопытного: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Цель эксперимента: <span class=\"paper_field\"></span>
			Полное имя куратора: <span class=\"paper_field\"></span>
			Полное имя организатора: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			<hr>Куратор: <span class=\"sign_field\"></span>
			Организатор: <span class=\"sign_field\"></span>
			Подопытный: <span class=\"sign_field\"></span>
			Директор Отдела R&D: <span class=\"sign_field\"></span>
			Глава Персонала: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Данный документ нужен в случае если вы собираетесь провести эксперимент который может нанести вред одному сотруднику станции(подопытному).
			Куратором может являться Директор Отдела R&D или любой другой сотрудник Отдела Исследования и Разработки выше организатора по рангу. Подпись Директора Отдела R&D может быть заменена подписями Главы Персонала, Капитана.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/genetics_permission
	name = "Запрос на разрешение проведения экспериментальной генной терапии"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Запрос на разрешение проведения экспериментальной генной терапии</large></center>
			<hr>Полное имя подопытного: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			Полное имя врача-генетика проводящего эксперимент: <span class=\"paper_field\"></span>
			Куратор: <span class=\"paper_field\"></span>
			Прививаемые гены: <span class=\"paper_field\"></span>
			<hr>Куратор: <span class=\"sign_field\"></span>
			Врач-генетик: <span class=\"sign_field\"></span>
			Подопытный: <span class=\"sign_field\"></span>
			Главный Врач: <span class=\"sign_field\"></span>
			Директор Отдела R&D: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Куратором может являться Директор Отдела R&D или любой другой сотрудник Отдела Исследования и Разработки выше организатора по рангу. Подписи Директора Отдела R&D и Главного Врача могут быть заменены подписями Главы Персонала, Капитана.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/cyborgisation_permission
	name = "Запрос на разрешение проведения прижизненной кибернетизации"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Запрос на разрешение проведения прижизненной кибернетизации</large></center>
			<hr>Полное имя подопытного: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			Полное имя специалиста проводящего кибернетизацию: <span class=\"paper_field\"></span>
			<hr>Специалист: <span class=\"sign_field\"></span>
			Подопытный: <span class=\"sign_field\"></span>
			Врач-психиатр: <span class=\"sign_field\"></span>
			Глава Отдела Кадров: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Подписывая данный запрос, подопытный подтверждает своё желание пройти прижизненный процесс кибернетизации или слияния с Искусственным Интеллектом и полностью берет на себя ответственность за возможные последствия. Также, он подтверждает, что уведомлен о возможной необратимости процедуры.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/credit_equipment
	name = "Займ оборудования"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Займ оборудования</large></center>
			<hr><div style=\"border-width: 4px; border-style: dashed;\"><center>Следующие предметы числятся на учете как "экспериментальные". NanoTrasen не несет ответственности за ущерб, полученный в ходе использования этого оборудования.
			Получатель должен использовать эти предметы только по их прямому назначению. Получатель не должен делится этим оборудованием с любыми другими лицами без прямого одобрения командного состава станции.</center></div><hr>Имя получающего: <span class=\"paper_field\"></span>
			Полное имя получателя: <span class=\"paper_field\"></span>
			Полное имя выдающего предметы в займ: <span class=\"paper_field\"></span>
			Предметы в займ: <span class=\"paper_field\"></span>
			<hr>Получатель: <span class=\"sign_field\"></span>
			Выдающий: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Пожалуйста, убедитесь в том, что под этой записью поставит штамп действующий Глава Персонала. Штамп должен быть получен до конца одной стандартной рабочей недели.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/exosuit_transfer
	name = "Передача в пользование шагохода"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Передача в пользование шагохода</large></center>
			<hr>Полное имя получателя: <span class=\"paper_field\"></span>
			Полное имя передающего: <span class=\"paper_field\"></span>
			Категория шагохода: <span class=\"paper_field\"></span>
			Модель шагохода: <span class=\"paper_field\"></span>
			Причина выдачи: <span class=\"paper_field\"></span>
			<hr>Получатель: <span class=\"sign_field\"></span>
			Передающий: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/research_object
	name = "Отчет о изучении неизвестного объекта"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Отчет о изучении неизвестного объекта</large></center>
			<hr>Кодовое название объекта: <span class=\"paper_field\"></span>
			Полное имя ученого (составителя): <span class=\"paper_field\"></span>
			Процедуры сдерживания/активации: <span class=\"paper_field\"></span>
			Обобщенное описание Объекта: <span class=\"paper_field\"></span>
			Полное описание Объекта: <span class=\"paper_field\"></span>
			<font size = \"1\">Заполняется по желанию, в случае отказа выставить прочерк, в случае заполнения колонки выше (Обобщенное описание) не заполнять.</font>
			Приблизительный возраст Объекта: <span class=\"paper_field\"></span>
			Уровень угрозы, исходящий от объекта: <span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			Подопытный/Ассистент: <span class=\"sign_field\"></span>
			<font size = \"1\">Заполнять если при исследование объекта проводились эксперименты с участием ассистента.</font>
			Директор Отдела R&D/принимающий Глава: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/transfer_object
	name = "Транспортировка и передача исследуемого субъекта на СН 'ЦентКом'"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Транспортировка и передача исследуемого субъекта на СН "ЦентКом"</large></center>
			<hr>Кодовое название объекта: <span class=\"paper_field\"></span>
			Полное имя ученого (составителя): <span class=\"paper_field\"></span>
			Обобщенное описание Объекта: <span class=\"paper_field\"></span>
			Уровень угрозы, исходящий от объекта: <span class=\"paper_field\"></span>
			Причина транспортировки/передачи объекта: <span class=\"paper_field\"></span>
			Условия транспортировки объекта: <span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			Ответственный за транспортировку: <span class=\"sign_field\"></span>
			<font size = \"1\">Подписывая данное поле я готов понести наказание в соотв. со статьей 201 космического закона и несу полную ответственность за сохранность объекта и членов экипажа.</font>
			Директор Отдела R&D/принимающий Глава: <span class=\"sign_field\"></span>
			Сопровождающие: <span class=\"sign_field\"></span>
			<font size = \"1\">Необходима, если объект затруднительно безопасно транспортировать на СН "ЦентКом" без помощи посторонних.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/make_exosuit
	name = "Запрос на изготовление экзоскелета"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Запрос на изготовление экзоскелета</large></center>
			<hr>Полное имя заказчика: <span class=\"paper_field\"></span>
			Должность заказчика: <span class=\"paper_field\"></span>
			Категория шагохода: <span class=\"paper_field\"></span>
			Модель шагохода: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			<hr>Заказчик: <span class=\"sign_field\"></span>
			Специалист по производству экзоскелетов: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/exosuit_permission
	name = "Разрешение на пользование экзоскелетом"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Разрешение на пользование экзоскелетом</large></center>
			<hr>Полное имя пилота: <span class=\"paper_field\"></span>
			Должность пилота: <span class=\"paper_field\"></span>
			Категория шагохода: <span class=\"paper_field\"></span>
			Модель шагохода: <span class=\"paper_field\"></span>
			<hr>Специалист по производству экзоскелетов: <span class=\"sign_field\"></span>
			Руководитель пилота: <span class=\"sign_field\"></span>
			Пилот: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*В случае одобрения данный документ должен быть отмечен штампом руководителя пилота.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/bomb_test
	name = "Отчет о испытании взрывного устройства"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Отчет о испытании взрывного устройства</large></center>
			<hr>Полное имя испытателя: <span class=\"paper_field\"></span>
			Полное имя изготовителя: <span class=\"paper_field\"></span>
			Использованные компоненты: <span class=\"paper_field\"></span>
			Использованные вещества (доля вещества в процентах, температура в кельвинах, давление в килопаскалях): <span class=\"paper_field\"></span>
			Мощность взрыва: <span class=\"paper_field\"></span>
			<hr>Испытатель: <span class=\"sign_field\"></span>
			Изготовитель: <span class=\"sign_field\"></span>
			Директор Отдела R&D: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Отчет должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/research_report
	name = "Отчет о проведенных исследованиях"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Отчет о проведенных исследованиях</large></center>
			<hr>Полное имя исследователя: <span class=\"paper_field\"></span>
			Области исследования: <span class=\"paper_field\"></span>
			Исследованные технологии (надежность технологии в процентах): <span class=\"paper_field\"></span>
			Количество потраченных научно-исследовательских пакетов данных: <span class=\"paper_field\"></span>
			<hr>Исследователь: <span class=\"sign_field\"></span>
			Директор Отдела R&D: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Отчет должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/scan_objects
	name = "Отчет о сканировании ценных научно-исследовательских объектов"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Отчет о сканировании ценных научно-исследовательских объектов</large></center>
			<hr>Полное имя сканировщика: <span class=\"paper_field\"></span>
			Полное имя сотрудника, предоставившего объект/объекты: <span class=\"paper_field\"></span>
			Должность сотрудника, предоставившего объект/объекты: <span class=\"paper_field\"></span>
			Объект сканирования: <span class=\"paper_field\"></span>
			Количество полученных научно-исследовательских пакетов данных: <span class=\"paper_field\"></span>
			<hr>Сканировщик: <span class=\"sign_field\"></span>
			Сотрудник, предоставивший объект/объекты: <span class=\"sign_field\"></span>
			Директор Отдела R&D: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Отчет должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/space_structure
	name = "Отчет об исследовании заброшенного объекта в дальнем космосе"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Отчет об исследовании заброшенного объекта в дальнем космосе</large></center>
			<hr>Полное имя оператора телепада: <span class=\"paper_field\"></span>
			Полное имя исследователя: <span class=\"paper_field\"></span>
			<hr>Имена, должности и подписи иных сотрудников, задействованных при исследовании: <span class=\"paper_field\"></span>
			<font size = \"1\">Если никакие иные сотрудники не были задействованы при исследовании, то ставится прочерк.</font>
			<hr>Координаты объекта: <span class=\"paper_field\"></span>
			Полное описание объекта: <span class=\"paper_field\"></span>
			Обнаруженные организмы (внешний вид, состояние, поведение): <span class=\"paper_field\"></span>
			Обнаруженные сооружения и предметы (внешний вид, состояние): <span class=\"paper_field\"></span>
			Изъятые предметы: <span class=\"paper_field\"></span>
			<hr>Оператор телепада: <span class=\"sign_field\"></span>
			Исследователь: <span class=\"sign_field\"></span>
			Директор Отдела R&D: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Отчет должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/prototypes
	name = "Акт об изготовлении прототипов"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Акт об изготовлении прототипов</large></center>
			<hr>Полное имя изготовителя: <span class=\"paper_field\"></span>
			Прототипы: <span class=\"paper_field\"></span>
			Количество прототипов: <span class=\"paper_field\"></span>
			Причина изготовления: <span class=\"paper_field\"></span>
			Потраченные виды ресурсов (количество в кубометрах): <span class=\"paper_field\"></span>
			<hr>Изготовитель: <span class=\"sign_field\"></span>
			Директор Отдела R&D: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Акт должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/make_exosuit_report
	name = "Акт об изготовлении экзоскелета"
	info = {"<center><large><b>Отдел Исследований и Разработок КСН "Исход"</b>
			Акт об изготовлении экзоскелета</large></center>
			<hr>Полное имя изготовителя: <span class=\"paper_field\"></span>
			Категория шагохода: <span class=\"paper_field\"></span>
			Модель шагохода: <span class=\"paper_field\"></span>
			Установленные модули: <span class=\"paper_field\"></span>
			Причина изготовления: <span class=\"paper_field\"></span>
			Потраченные виды ресурсов (количество в кубометрах): <span class=\"paper_field\"></span>
			<hr>Изготовитель: <span class=\"sign_field\"></span>
			Директор Отдела R&D: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Акт должен быть предоставлен Директору Отдела R&D и отмечен его штампом. После заполния, документ должен хранится в кабинете Директора Отдела R&D до конца смены.</font>
			<hr>Место для штампов."}

//---------------Security---------------
var/global/list/security_forms = list(/obj/item/weapon/paper/arrest_report,
							/obj/item/weapon/paper/criminalist_report,
							/obj/item/weapon/paper/search_warrant,
							/obj/item/weapon/paper/third_person,
							/obj/item/weapon/paper/legal_weapon,
							/obj/item/weapon/paper/execution,
							/obj/item/weapon/paper/loyality_volunt,
							/obj/item/weapon/paper/dismiss_test_subject,
							/obj/item/weapon/paper/loyality_force
							)
/obj/item/weapon/paper/arrest_report
	name = "Протокол задержания"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b>
			Протокол задержания</large></center>
			<hr>Полное имя офицера проводившего задержание: <span class=\"paper_field\"></span>
			Полное имя задержанного: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Статьи предъявленные задержанному: <span class=\"paper_field\"></span>
			Свидетели преступления: <span class=\"paper_field\"></span>
			Место совершения преступления: <span class=\"paper_field\"></span>
			Описание преступления: <span class=\"paper_field\"></span>
			<hr>Офицер проводивший задержание: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*К данному документу могут прилагаться любые улики с места происшествия (показатели свидетелей, фотографии или любые другие улики которые следствие сочтет уместными)</font>"}

/obj/item/weapon/paper/criminalist_report
	name = "Отчет криминалиста"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b>
			Отчет криминалиста</large></center>
			<hr>Полное имя криминалиста: <span class=\"paper_field\"></span>
			Тип преступления: <span class=\"paper_field\"></span>
			Место преступления: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			<hr><b>Отчет:</b>
			<span class=\"paper_field\"></span>
			<hr>Криминалист: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Документ может выдаваться только представителям Службы Безопасности, Главе Персонала, Капитану.</font>"}

/obj/item/weapon/paper/search_warrant
	name = "Ордер на обыск"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b>
			Ордер на обыск</large></center>
			<hr>Полное имя цели осмотра: <span class=\"paper_field\"></span>
			Полное имя офицера(ов): <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			Обыск рабочего места: <span class=\"paper_field\"></span>
			Обыск подозреваемого: <span class=\"paper_field\"></span>
			<hr>Глава Службы Безопасности: <span class=\"sign_field\"></span>
			Глава Персонала: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Протоколы обыска могут быть проигнорированы при уровне тревоги "Синий" и выше.<br>
			Графа "Обыск рабочего места" и "Обыск обыск подозреваемого" должны быть обязательно заполнены.
			"+" - обыск разрешен "-" - обыск запрещен.</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/third_person
	name = "Свидетельский лист"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b>
			Свидетельский лист</large></center>
			<hr>Полное имя свидетеля: <span class=\"paper_field\"></span>
			Полное имя офицера составителя: <span class=\"paper_field\"></span>
			Тип происшествия: <span class=\"paper_field\"></span>
			Место происшествия: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			<hr><b>Свидетельство:</b>
			<span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			Свидетель: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Заполняется сотрудником Службы Безопасности со слов свидетеля.</font>"}

/obj/item/weapon/paper/legal_weapon
	name = "Разрешение на оружие"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b>
			Разрешение на оружие</large></center>
			<hr>Полное имя заказчика: <span class=\"paper_field\"></span>
			Полное имя выдавшего оружие: <span class=\"paper_field\"></span>
			Тип оружия: <span class=\"paper_field\"></span>
			<font size = \"1\">Количество и наименование.</font>
			Цель выдачи: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			<hr>Заказчик: <span class=\"sign_field\"></span>
			Выдавший оружие: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/execution
	name = "Приказ о высшей мере наказания"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b>
			Приказ о высшей мере наказания</large></center>
			<hr>Полное имя арестанта: <span class=\"paper_field\"></span>
			Причина казни: <span class=\"paper_field\"></span>
			Полное имя палача: <span class=\"paper_field\"></span>
			Полное имя должностного лица, выдавшего приказ: <span class=\"paper_field\"></span>
			<hr>Должностное лицо: <span class=\"sign_field\"></span>
			Палач: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/loyality_volunt
	name = "Заявление на добровольное внедрение импланта лояльности"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b>
			Заявление на добровольное внедрение импланта лояльности</large></center>
			<hr>Полное имя лица, которому внедряется имплант: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			<hr>Лицо, которому внедряется имплант: <span class=\"sign_field\"></span>
			Капитан/Глава Службы Безопасности: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/dismiss_test_subject
	name = "Заявление на добровольно-принудительный перевод в статус 'Подопытный'"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b>
			Заявление на добровольно-принудительный перевод в статус "Подопытный"</large></center>
			<hr>Полное имя лица, переводящегося в подопытные: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			<hr>Подпись: <span class=\"sign_field\"></span>
			<font size = \"1\">Только при необходимости.</font>
			Капитан/Глава Службы Безопасности: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/loyality_force
	name = "Заявление на принудительное введение импланта лояльности"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b>
			Заявление на принудительное введение импланта лояльности</large></center>
			<hr>Полное имя лица, которому внедряется имплант: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Причина: <span class=\"paper_field\"></span>
			<hr>Подпись: <span class=\"sign_field\"></span>
			<font size = \"1\">Только при необходимости.</font>
			Капитан/Глава Службы Безопасности: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

//---------------Engineering---------------
var/global/list/engineering_forms = list(/obj/item/weapon/paper/exploitation)
/obj/item/weapon/paper/exploitation
	name = "Документ по эксплуатации отсека"
	info = {"<center><large><b>Инженерный Отдел КСН "Исход"</b>
			Документ по эксплуатации отсека</center></large>
			<hr>Полное имя ответственного за постройку: <span class=\"paper_field\"></span>
			Полное имя помощника(ов): <span class=\"paper_field\"></span>
			Тип работ: <span class=\"paper_field\"></span>
			Место проведения работ: <span class=\"paper_field\"></span>
			<hr><b>Описание:</b>
			Короткое описание изменений: <span class=\"paper_field\"></span>
			Основные позитивные моменты: <span class=\"paper_field\"></span>
			<hr>Ответственный за постройку: <span class=\"sign_field\"></span>
			Помощник(и): <span class=\"sign_field\"></span>
			Главный Инженер: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Подписывая этот документ, я обязываюсь выполнить всю намеченную работу до конца, и несу полную ответственность за проведения работ на этой территории, до тех пор пока не сдам объект в полностью готовом состоянии и не предъявлю работу своему начальству.</font>
			<hr>Место для штампов."}

//---------------Important---------------
var/global/list/important_forms = list(/obj/item/weapon/paper/emergency_shuttle,
							/obj/item/weapon/paper/ert,
							/obj/item/weapon/paper/delta,
							/obj/item/weapon/paper/incident_report,
							/obj/item/weapon/paper/internal_affairs)
/obj/item/weapon/paper/emergency_shuttle
	name = "Отчет по причине вызова экстренного эвакуационного шаттла"
	info = {"<center><large><b>Командный Cостав КСН "Исход"</b>
			Отчет по причине вызова экстренного эвакуационного шаттла</large></center>
			<hr>Полное имя представителя командования: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Бортовое время: <span class=\"paper_field\"></span>
			<hr><b>Отчет:</b>
			<span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/ert
	name = "Отчет вызова экстренной команды"
	info = {"<center><large><b>Командный Cостав КСН "Исход"</b>
			Отчет вызова экстренной команды</large></center>
			<hr>Полное имя представителя командования: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Бортовое время: <span class=\"paper_field\"></span>
			Тип экстренной ситуации: <span class=\"paper_field\"></span>
			Размеры ущерба/Сколько погибло/Текущее состояние всей станции и персонала: <span class=\"paper_field\"></span>
			<hr><b>Краткое/Полное изложение сути проишествия:</b>
			<span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/delta
	name = "Инициация кода 'Дельта'"
	info = {"<center><large><b>Командный Cостав КСН "Исход"</b>
			Инициация кода "Дельта"<large></center>
			<hr>Полное имя представителя командования: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Бортовое время: <span class=\"paper_field\"></span>
			Причина инициации кода "Дельта": <span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Внимание, инициируя код "Дельта" данное лицо берет на себя полную ответственность за происходящее. Данная глава станции КСН "Исход" полностью понимает, что активация кода "Дельта" крайняя мера и означает, что ситуация на станции полностью вышла из под контроля</font>
			<hr>Место для штампов."}

/obj/item/weapon/paper/incident_report
	name = "Стандартный отчет о произошедшем инциденте"
	info = {"<center><large><b>Командный Cостав КСН "Исход"</b>
			Стандартный отчет о произошедшем инциденте</large></center>
			<hr>Полное имя представителя командования: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			Инцидент: <span class=\"paper_field\"></span>
			Последствия инцидента: <span class=\"paper_field\"></span>
			Принятые меры для предотвращения инцидента: <span class=\"paper_field\"></span>
			<hr><b>Запрос действий/инструкций от ЦК (если необходимы):</b>
			<span class=\"paper_field\"></span>
			<hr>Составитель: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

/obj/item/weapon/paper/internal_affairs
	name = "Отчет Агента Внутренних Дел"
	info = {"<center><large><b>КСН "Исход"</b>
			Отчет Агента Внутренних Дел</large></center>
			<hr>Полное имя Агента: <span class=\"paper_field\"></span>
			Субъект/интересующий инцидент под вопросом: <span class=\"paper_field\"></span>
			Инцидент: <span class=\"paper_field\"></span>
			Местоположение: <span class=\"paper_field\"></span>
			Персонал, вовлеченные в инцидент: <span class=\"paper_field\"></span>
			<hr><b>Изложение фактов:</b>
			<span class=\"paper_field\"></span>
			<hr>Агент: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}

//---------------Misc---------------
var/global/list/misc_forms = list(/obj/item/weapon/paper/bar_menu,
							/obj/item/weapon/paper/canteen_menu,
							/obj/item/weapon/paper/offence_report,
							/obj/item/weapon/paper/noname_fax_reply,
							/obj/item/weapon/paper/name_fax_reply,
							/obj/item/weapon/paper/transport_visa,
							/obj/item/weapon/paper/customs_report)
/obj/item/weapon/paper/bar_menu
	name = "Меню бара"
	info = {"<font size=\"4\"><center><b><span class=\"paper_field\"></span></b></center></font>
			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Алкогольные напитки</b></center></font></div>
			Space Beer<span class=\"paper_field\"></span>
			Iced Space Beer<span class=\"paper_field\"></span>
			Station 13 Grog<span class=\"paper_field\"></span>
			Magm-Ale<span class=\"paper_field\"></span>
			Griffeater's Gin<span class=\"paper_field\"></span>
			Uncle Git's Special Reserve<span class=\"paper_field\"></span>
			Caccavo Guaranteed Quality Tequilla<span class=\"paper_field\"></span>
			Tunguska Triple Distilled<span class=\"paper_field\"></span>
			Goldeneye Vermouth<span class=\"paper_field\"></span>
			Captain Pete's Cuban Spiced Rum<span class=\"paper_field\"></span>
			Doublebeard Beared Special Wine<span class=\"paper_field\"></span>
			Chateua De Baton Premium Cognac<span class=\"paper_field\"></span>
			Robert Robust's Coffee Liqueur<span class=\"paper_field\"></span>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Коктейли </b></center></font></div>
			Allies Cocktail<span class=\"paper_field\"></span>
			Andalusia<span class=\"paper_field\"></span>
			Anti-Freeze<span class=\"paper_field\"></span>
			Bahama Mama<span class=\"paper_field\"></span>
			Classic Martini<span class=\"paper_field\"></span>
			Cuba Libre<span class=\"paper_field\"></span>
			Gin Fizz<span class=\"paper_field\"></span>
			Gin and Tonic<span class=\"paper_field\"></span>
			Irish Car Bomb<span class=\"paper_field\"></span>
			Irish Coffee<span class=\"paper_field\"></span>
			Irish Cream<span class=\"paper_field\"></span>
			Long Island Iced Tea<span class=\"paper_field\"></span>
			Manhattan<span class=\"paper_field\"></span>
			The Manly Dorf<span class=\"paper_field\"></span>
			Margarita<span class=\"paper_field\"></span>
			Screwdriver<span class=\"paper_field\"></span>
			Syndicate Bomb<span class=\"paper_field\"></span>
			Pan-Galactic Gargle Blaster<span class=\"paper_field\"></span>
			Tequilla Sunrise<span class=\"paper_field\"></span>
			Vodka Martini<span class=\"paper_field\"></span>
			Vodka and Tonic<span class=\"paper_field\"></span>
			Whiskey Cola<span class=\"paper_field\"></span>
			Whiskey Soda<span class=\"paper_field\"></span>
			White Russian<span class=\"paper_field\"></span>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Безалкогольные напитки</b></center></font></div>
			Coffee<span class=\"paper_field\"></span>
			Tea<span class=\"paper_field\"></span>
			Hot Chocolate<span class=\"paper_field\"></span>
			Iced Tea<span class=\"paper_field\"></span>
			Iced Coffee<span class=\"paper_field\"></span>
			Orange Juice<span class=\"paper_field\"></span>
			Tomato Juice<span class=\"paper_field\"></span>
			Tonic Water<span class=\"paper_field\"></span>
			Sodas<span class=\"paper_field\"></span>"}

/obj/item/weapon/paper/canteen_menu
	name = "Меню столовой"
	info = {"<font size=\"4\"><center><b>Меню питания</b></center></font>
			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Первое блюдо</b></center></font></div>
			<span class=\"paper_field\"></span>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Гарнир</b></center></font></div>
			<span class=\"paper_field\"></span>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Второе горячее блюдо</b></center></font></div>
			<span class=\"paper_field\"></span>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Десерт</b></center></font></div>
			<span class=\"paper_field\"></span>


			<hr><div style=\"border-width: 4px; border-style: solid; padding: 10px;\"><font size=\"4\"><center><b></b>Напитки</b></center></font></div>
			<span class=\"paper_field\"></span>


			<hr>Ответственный за меню: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Заведующий столовой оставляет за собой право изменения действующего меню. Наличие блюда в меню не дает полной гарантии наличия в настоящем или будущем времени данного блюда. </font>"}

/obj/item/weapon/paper/offence_report
	name = "Заявление о правонарушении"
	info = {"<center><large><b>Служба Безопасности КСН "Исход"</b>
			Заявление о правонарушении</large></center>
			<hr>Полное имя пострадавшего: <span class=\"paper_field\"></span>
			Тип происшествия: <span class=\"paper_field\"></span>
			Место происшествия: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			<hr><b>Описание происшествия:</b>
			<span class=\"paper_field\"></span>
			<hr>Пострадавший: <span class=\"sign_field\"></span>
			Ответственного лицо, принявшее заявление: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Заполняется только лицами пострадавшими от правонарушения. Присутствие офицера при заполнение не обязательно.</font>"}

/obj/item/weapon/paper/noname_fax_reply
	name = "Неименной ответ на факс"
	info = {"<center>NT
			<large><b>Центральное Командование NanoTrasen</b>
			Официальный документ</large></center>
			<hr><span class=\"paper_field\"></span>

			СН ЦентКом, Тау Кита
			<hr><font size = \"1\">*Несоблюдение распоряжений, описанных в настоящем документе, является прямым нарушением законов NanoTrasen. Лица, нарушившие действующий протокол, могут быть привлечены к ответственности по возвращении на СН ЦентКом.<br>
			Получатель(и) этого документа подтверждает, что он несет полную ответственность за любой ущерб, причиненный экипажу или станции, в результате игнорирования предписаний или рекомендаций, изложенных в настоящем документе.</font>"}

/obj/item/weapon/paper/name_fax_reply
	name = "Именной ответ на факс"
	info = {"<center>NT
			<large><b>Центральное Командование NanoTrasen</b>
			Официальный документ</large></center>
			<hr><span class=\"paper_field\"></span>

			ДОЛЖНОСТЬ, <i>Фамилия Имя</i>
			СН ЦентКом, Тау Кита
			<hr><font size = \"1\">*Несоблюдение распоряжений, описанных в настоящем документе, является прямым нарушением законов NanoTrasen. Лица, нарушившие действующий протокол, могут быть привлечены к ответственности по возвращении на СН ЦентКом.<br>
			Получатель(и) этого документа подтверждает, что он несет полную ответственность за любой ущерб, причиненный экипажу или станции, в результате игнорирования предписаний или рекомендаций, изложенных в настоящем документе.</font>"}

/obj/item/weapon/paper/transport_visa
	name = "Транспортная виза"
	info = {"<center><large><b>НТС "Велосити"</b>
			Транспортная виза</large></center>
			<hr>Полное имя: <span class=\"paper_field\"></span>
			Должность: <span class=\"paper_field\"></span>
			<b>Корпорация Карго Индастриз</b></center>
			<hr>Место отправления: НТС "Велосити"
			Место прибытия: <span class=\"paper_field\"></span>
			Цель посещения: <span class=\"paper_field\"></span>
			Подпись: <span class=\"sign_field\"></span>
			<hr><b>Разрешение</b>
			Охрана транспортной системы: <span class=\"sign_field\"></span>
			<hr><font size = \"1\">*Если настоящий документ был изготовлен нелегально и/или вне пропускного пункта НТС "Велосити", заполнитель документа понесет административное наказание согласно пункту 46-7b кодекса Карго Индастриз.</font>"}

/obj/item/weapon/paper/customs_report
	name = "Протокол растаможивания"
	info = {"<center><large><b>Служба Безопасности НТС "Велосити"</b>
			Протокол растаможивания</large></center>
			<hr>Полное имя запросившего: <span class=\"paper_field\"></span>
			Полное имя офицера транзитной станции: <span class=\"paper_field\"></span>
			Тип предметов подлежащих растаможиванию: <span class=\"paper_field\"></span>
			<font size = \"1\">Количество и наименование.</font>
			Цель выдачи: <span class=\"paper_field\"></span>
			Примечания: <span class=\"paper_field\"></span>
			Объект ввоза растаможенных предметов:<span class=\"paper_field\"></span>
			<hr>Запросивший: <span class=\"sign_field\"></span>
			Офицер, выдавший разрешение: <span class=\"sign_field\"></span>
			<hr>Место для штампов."}
