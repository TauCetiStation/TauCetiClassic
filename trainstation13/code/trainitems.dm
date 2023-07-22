//TRAIN STATION 13

//This module includes all unique items necessary for passengers and specialized workers

/obj/item/weapon/card/id/passport
	name = "passport"
	desc = "Leeloo Dallas, multipass!"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "passport_1"
	item_state = "civGold_id"

/obj/item/weapon/card/id/passport/atom_init()
	. = ..()
	desc = "Upon closer inspection you notice a nine-digit number: №[rand(111, 999)]-[rand(111, 999)]-[rand(111, 999)]."
	icon_state = "passport_[rand(1, 6)]"

/obj/item/weapon/paper/ticket
	name = "universal ticket"
	desc = "A typical train ticket issued to passenger by a railway operator."
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "ticket_blue"
	info = "<center><b>УНИВѢРСАЛЬНЫЙ БИЛѢТ:</b></center><br> \
			<hr><b><i>Прѣдъявитѣлю билѣта разрѣшаѣтся занять любое свободноѣ мѣсто для пассажировъ пѣрвого и второго класса, \
			в вагонах общѣго назначѣния - от вагона №6 до вагона №9.</i></b> \
			<hr><i>Мѣсто для штамповъ.</i>"

//we don't want the silly text overlay of basic paper!
/obj/item/weapon/paper/ticket/update_icon()
	return

/obj/item/weapon/paper/ticket/golden //"We are the music makers, we are the dreamers of dreams." - Willy Wonka
	name = "golden ticket"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "ticket_golden"

/obj/item/weapon/paper/ticket/golden/atom_init()
	. = ..()
	var/obj/item/weapon/pen/P = new
	info = parsepencode("\[center\]\[large\]\[b\]БИЛѢТ ДИПЛОМАТИЧѢСКОГО КЛАССА:\[/b\]\[/large\]\[br\]\n\
Номѣр поѣзда: \[field\]\[br\]\n\
Номѣр вагона: \[field\]\[br\]\n\
Номѣр мѣста: \[field\]\[br\]\n\
Имя пассажира: \[field\]\[br\]\n\
Особыѣ примѣчания: \[field\]\[br\]\n\
\[small\]Билѣт должѣнъ быть завѣрѣнъ кассиромъ согласно формы установлѣнного штампа.\[/small\]\[br\]\
\[hr\]\[i\]Мѣсто для штамповъ.\[/i\]", P)
	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/ticket/firstclass
	name = "first class ticket"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "ticket_green"

/obj/item/weapon/paper/ticket/firstclass/atom_init()
	. = ..()
	var/obj/item/weapon/pen/P = new
	info = parsepencode("\[center\]\[large\]\[b\]БИЛѢТ ПѢРВОГО КЛАССА:\[/b\]\[/large\]\[br\]\n\
Номѣр поѣзда: \[field\]\[br\]\n\
Номѣр вагона: \[field\]\[br\]\n\
Номѣр мѣста: \[field\]\[br\]\n\
Имя пассажира: \[field\]\[br\]\n\
Особыѣ примѣчания: \[field\]\[br\]\n\
\[small\]Билѣт должѣнъ быть завѣрѣнъ кассиромъ согласно формы установлѣнного штампа.\[/small\]\[br\]\
\[hr\]\[i\]Мѣсто для штамповъ.\[/i\]", P)
	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/ticket/secondclass
	name = "second class ticket"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "ticket_white"

/obj/item/weapon/paper/ticket/secondclass/atom_init()
	. = ..()
	var/obj/item/weapon/pen/P = new
	info = parsepencode("\[center\]\[large\]\[b\]БИЛѢТ ВТОРОГО КЛАССА:\[/b\]\[/large\]\[br\]\n\
Номѣр поѣзда: \[field\]\[br\]\n\
Номѣр вагона: \[field\]\[br\]\n\
Номѣр мѣста: \[field\]\[br\]\n\
Имя пассажира: \[field\]\[br\]\n\
Особыѣ примѣчания: \[field\]\[br\]\n\
\[small\]Билѣт должѣнъ быть завѣрѣнъ кассиромъ согласно формы установлѣнного штампа.\[/small\]\[br\]\
\[hr\]\[i\]Мѣсто для штамповъ.\[/i\]", P)
	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/ticket/partybook //It has nothing to do with fun partying though... More like a political party.
	name = "party membership book"
	desc = "A small green colored book with information on owner's membership in political party."
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "partybook"

/obj/item/weapon/paper/ticket/partybook/atom_init()
	. = ..()
	var/obj/item/weapon/pen/blue/P = new
	info = parsepencode("\[center\]\[large\]\[b\]УДОСТОВѢРѢНИѢ ЧЛѢНА ПАРТИИ ТРУДА:\[/b\]\[/large\]\[br\]\n\
Имя: \[field\]\[br\]\n\
Фамилия: \[field\]\[br\]\n\
Номѣр паспорта: \[field\]\[br\]\n\
Дата вступлѣния в Партию: \[field\]\[br\]\n\
\[hr\]Подпись дѣржатѣля: \[sfield\]\[hr\]\n\
\[small\]Дѣржатѣль сѣго билѣта удостовѣряѣтся в принадлѣжности к Партии Труда Импѣрии Вѣликой Руси.\[/small\]\[br\]\
\[hr\]\[i\]Мѣсто для штампов.\[/i\]", P)
	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/ticket/secretpass
	name = "secret police ID"
	desc = "A small red colored book with information on owner affiliation with imperial secret police."
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "secretpass"

/obj/item/weapon/paper/ticket/secretpass/atom_init()
	. = ..()
	var/obj/item/weapon/pen/red/P = new
	info = parsepencode("\[center\]\[large\]\[b\]УДОСТОВѢРѢНИѢ ГѢНѢРАЛЬНОГО ШТАБА ОБѢСПѢЧѢНИЯ БѢЗОПАСНОСТИ ИМПѢРИИ:\[/b\]\[/large\]\[br\]\n\
Имя: \[field\]\[br\]\n\
Фамилия: \[field\]\[br\]\n\
Номѣр паспорта: \[field\]\[br\]\n\
Дата выдачи удостовѣрѣния: \[field\]\[br\]\n\
\[hr\]Подпись дѣржатѣля: \[sfield\]\[hr\]\n\
\[small\]\[b\]Импѣрия прѣвыше всѣго!\[/b\]\[/small\]\[br\]\
\[hr\]\[i\]Мѣсто для штампов.\[/i\]", P)
	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/ticket/stamp
	name = "stamp paper"
	desc = "A small grey piece of paper with an image of a hammer and a tiny text explaining this stamp is sort regular money but more communist, or rather desperate in nature."
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "stamp"

/obj/item/weapon/paper/ticket/stamp/atom_init()
	. = ..()
	var/obj/item/weapon/pen/P = new
	info = parsepencode("\[center\]\[large\]\[b\]ЗАВОДСКОЙ ТАЛОН\[/b\]\[/large\]\[br\]\n\
\[hr\]\[i\]Номинальная цѣнность талона соотвѣтствуѣтъ 8 часамъ рабочѣго врѣмѣни.\[/i\]", P)
	update_icon()
	updateinfolinks()

//GUIDES

/obj/item/weapon/book/manual/driver
	name = "Train Driving A to B"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state ="book_driver"
	item_state = "book2"
	author = "MegaVagen Transport International"
	title = "Driving Train is Easy or: How I Learned to Stop Worrying and Love the Railway"

	dat = {"<html>
				<head>
				<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
				<style>
				h1 {font-size: 21px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				body {font-size: 13px; font-family: Verdana;}
				</style>
				</head>
				<body>
				<h1>Привѣтствиѣ</h1>
				Привѣтствуѣм! Если вы читаѣте это руководство, то, скорее всего - являетесь <i>машинистом или его помощником.</i><br><br>
				Именно <b>ВЫ</b> руководите движением поезда, следите за РИТЭГОМ и... смешно гудите.<br><br>
				<h2>Заповеди хорошего машиниста:<h2>
				<ul>
					<li>Не издавай неприятные звуки без особой на это причины, особенно если проезжаешь в близости у <i>жилых домов</i>.</li>
					<li>Учи вверенного тебе <i>помощника</i> управлению поездом, <i>ведь он унаследует твои знания когда ты отойдёшь от дел...</i></li>
					<li>Следи за состоянием реактора - <b>экстренные остановки где-то в заснеженном поле обычно плохо заканчиваются.</b></li>
					<li>Работа машиниста тяжела и ответственна, но благодаря ей у тебя высокий статус в обществе. <b>Не подведи пассажиров и своих коллег!</b><li>
				</ul><br>
				<h3>Обязанности машиниста:</h3>
				<ul>
					<li>Важнейшая обязанность машиниста - управление составом. Вы можете поручить эту задачу своему помощнику, но это рекомендуется делать исключительно на прямых участках в безопасных условиях.</li>
					<li>Во время вождения - необходимо следить за светофорами. Если вы не уследите за ними - существенно повышается риск катастрофы. <b>ДВИЖЕНИЕ ВОЗМОЖНО ПРОДОЛЖАТЬ / НАЧИНАТЬ ТОЛЬКО НА ЗЕЛЁНЫЙ ИЛИ ЛУННЫЙ БЕЛЫЙ СИГНАЛ СВЕТОФОРА!</b></li>
					<li>Так же, вы обязаны <i>держать связь с поездными диспетчерами и проводниками своего состава.</i></li>
					<li>Ну и конечно, <i>рекомендуется использование гудка при прибытии на станцию, и свистка при отправлении<i>, дабы пассажиры не проспали свою станцию. Вам лучше не знать что случится если из-за вашей рассеяности уважаемый чиновник проспит свою станцию!</li>
				<i>Будьте хорошими машинистами - именно от вас зависит успех рейса!<br><br>
				<h4>Обязанности помощника машиниста:</h4>
				<ul>
					<li>Перед началом поездки, проверьте <i>автоматические двери</i>. <b>К началу движения все автоматические двери должны быть закрыты!</b></li>
					<li>Помогайте своему наставнику в управлении составом: следите за реактором, управляйте поездом в случае отлучения машиниста. <b>Не стоит лезть туда, куда вас не просят.</b></li>
					<li>В ваших полномочиях - управлять дверьми согласно указаний машиниста или диспетчера.</li>
					<li>Вы можете помогать машинисту с бытовыми вопросами вроде доставки еды, напитков (безалкогольных!) и свежей постели.</li>
				<i>Помогайте своему наставнику, ведь скоро вы сможете получить повышение до машиниста!</i>
				<h5>Напоследок...</h5>
				<i>Правила железнодорожного движения.</i>
				<ul>
					<li>Всегда перед началом движения - машинист или его помощник обязан запросить разрешение у диспетчера по форме:
					<li><b>По второму пути (или другого пути какой занимает ваш поезд после прохождения стрелки), скорого поезда (назовите номер поезда, ВЫ не должны его забывать), машинист (ваша фамилия), системы исправны (убедитесь что это действительно так), генератор включен, нахожусь в рабочей кабине, готов к маневровым передвижениям (также можно сказать - готов к движению)</b></li>
					<li>ПРИ ВИДЕ КРАСНОГО ИЛИ СИНЕГО СИНГНАЛА СВЕТОФОРА - НЕМЕДЛЕННО ОСТАНОВИТЕСЬ! Необязательно запрашивать у диспетчера объяснения причины запрещающего сигнала по маршруту движения, но если вы в чём-то сомневаетесь...</li>
					<li> И это всё. Под конец, мы желаем Вам...</li>
				Счастливого пути!<br>
				</body>
			</html>
			"}


/obj/item/weapon/book/manual/conductor
	name = "The work of Conductor (for dummies!)"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state ="book_conductor"
	item_state = "book2"
	author = "MegaVagen Transport International"
	title = "Hm, how to work as conductor?"

	dat = {"<html>
				<head>
				<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
				<style>
				h1 {font-size: 21px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				body {font-size: 13px; font-family: Verdana;}
				</style>
				</head>
				<body>
				<h1>Приветствие</h1>
				Приветствуем! Мы рады, что вы решились работать кондуктором в нашей транспортной компании! Этот справочник был написан дочерней компанией "МегаВаген", которая всерьез занялась вопросом введения международных стандартов железнодорожной индустрии.<br><br>

				Все профессии на железной дороги в равной степени ответственны и важны:<br><br>
				<i>от поездного диспетчера</i> зависит безопасный и тщательно рассчитанный план движения, <i>от машиниста</i> зависит своевременное достижение цели, <i>от путевого обходчика</i> сохранность состава, <i>от кассира</i> доходность железной дороги, но именно <b>проводник</b> ответственен за соблюдение порядка в вагоне, обеспечение комфорта и хорошего настроения пассажиров.<br><br>
				Без проводника, пассажиры порой беззащитны, практически беспомощны и рискуют пропустить свою станцию.<br><br>
				Без вашего внимания, безбилетники и мошенники могут разрушить благополучие всей железной дороги.<br><br>
				Именно к вам в первую очередь обратятся за помощью, и в случае непредвиденной ситуации - от ваших решений будут зависеть человеческие жизни.<br><br>

				<h2>Основные обязанности проводника в порядке важности:</h2>
				<ul>
					<li>Следите за порядком в вагоне. В случае чрезвычайной ситуации немедленно сообщите об этом машинисту и другим проводникам.</li>
					<li>Проверяйте билеты пассажиров вагона. Это можно сделать как после отправления (чтобы не задерживать провожающих перед отправлением), так и при посадке.</li>
					<li>Выявляйте <b>мошенников</b>, которые решили сэкономить на покупке билета!.</li>
					<li>Выдавайте постельное бельё всем <b>пассажирам поезда</b> после отбытия со станции. <i>Если рейс задержится, распределите постели как можно скорее.</i> - пассажиры не обойдутся без комфортного отдыха.</li>
				</ul><br>

				<i>Следите за своей униформой - это символ вашего высокого статуса. Не стоит выбиваться из рабочего стиля. За соблюдением установленного порядка следит Железнодорожная Инспекция.</i><br><br>
				<i>Ведите себя уважительно в отношении к пассажирам, очень вероятно, что они устали с долгой дороги и просто хотят отдохнуть.</i><br>
				Однако, сохраняйте бдительность - <b>безбилетники</b> своими действиям разворовывают государственную собственность, поэтому вы обязаны быть бдительными!<br><br>

				Удачного сопровождения!<br>
				</body>
			</html>
			"}

/obj/item/weapon/book/manual/rtg
	name = "R.T.G. Operation Manual"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state ="book_rtg"
	item_state = "book8"
	author = "Empire of Greater Rus Institute of Nuclear Physics"
	title = "R.T.G. MK-II Operation Manual"

	dat = {"<html>
				<head>
				<meta http-equiv='Content-Type' content='text/html; charset=utf-8'>
				<style>
				h1 {font-size: 21px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				body {font-size: 13px; font-family: Verdana;}
				</style>
				</head>
				<body>
				<h1>Приветствие</h1>
				<i>Что касается систем, не использующих урана и тория (их запасы не безграничны, а хранение радиоактивных продуктов деления и выделение газообразных продуктов деления представляют собою некоторую экологическую опасность), то в них я предполагаю «тритиевый бридинг»</i> - Андрей Сахаров<br><br>
				Если вы читаете это руководство от Института Ядерной Физики Империи Великой Руси (ИЯФИВР), то вероятно вы имеете дело с энергогенерирующей установкой типа РИТЭГ (радиоизотопный термоэлектрический генератор).<br><br>
				<h2>Правила защиты от смертельного для человека радиационного излучения и обращения с двигателем типа РИТЕГ:<h2>
				<ul>
					<li>Проводите регулярные проверки уровня радиации вне генераторной - необходимо постоянно иметь при себе счётчик Гейгера (встроен в analyzer). В случае срабатывания счётчика в рабочей кабине локомотива (незначительный уровень излучения в жилой зоне допустим, не переживайте, начальство говорит всё будет в порядке), немедленно эвакуируйте локомотив, наденьте защитный костюм и выясните причину повышенного излучения генератора.</li>
					<li>Всегда надевайте противорадиационный защитный костюм перед входом в генераторную с РИТЭГ, вне зависимости от того включен или отключен генератор.</li>
					<li>После выхода из генераторной, необходимо снять костюм и поместить его в специальный шкаф у входа.</li>
					<li>Не реже чем <i>раз в 15 минут</i> проверяйте уровень температуры теплоносителя - превышение температуры в <b>290 градусов по Цельсию<b> приведёт к началу цепной реакции с <i>изотопами тория</i> которая завершится <b>взрывом</b>!<li>
				</ul><br>

				<b>Внимание, двигатель типа РИТЭГ невозможно мгновенно остановить или запустить. Любая ошибка может привести к катастрофе и человеческим жертвам!</b><br><br>

				Желаем вам удачной эксплуатации двигателя!<br>
				</body>
			</html>
			"}
