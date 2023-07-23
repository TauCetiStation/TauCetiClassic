//TRAIN STATION 13

//This module includes all unique items necessary for passengers and specialized workers - Oldem2001 was here

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
			<hr><b><i>Прѣдъявитѣлю билѣта разрѣшаѣтся занять любоѣ свободноѣ мѣсто для пассажировъ пѣрвого и второго класса, \
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
\[small\]\[b\]Импѣрия прѣвышѣ всѣго!\[/b\]\[/small\]\[br\]\
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
				Привѣтствуѣм! ѣсли вы, сударь, читаѣтѣ сиѣ руководство, то, скорѣѣ всѣго - являѣтѣсь <i>машинистомъ или ѣго помощникомъ.</i><br><br>
				Имѣнно <b>ВЫ</b> руководитѣ движѣниѣм локомотива, слѣдитѣ за РИТЭГОМ и... смѣшно гудитѣ.<br><br>
				<h2>Заповѣди хорошѣго машиниста:<h2>
				<ul>
					<li>Нѣ издавай нѣприятныѣ звуки бѣз особой на это причины, особѣнно ѣсли проѣзжаѣшь в близости у <i>жилых домов, цѣрквѣй</i>.</li>
					<li>Учи ввѣрѣнного тѣбѣ <i>помощника</i> управлѣнию поѣздомъ, <i>вѣдь он унаслѣдуѣтъ твои знания когда ты отойдёшь от дѣлъ...</i></li>
					<li>Слѣди за состояниѣмъ рѣактора - <b>экстрѣнныѣ остановки гдѣ-то в заснѣжѣнном полѣ обычно плохо заканчиваются.</b></li>
					<li>Работа машиниста тяжѣла и отвѣтствѣнна, но благодаря ѣй у тѣбя высокий статус в общѣствѣ. <b>Нѣ подвѣди пассажировъ и своих коллѣгъ!</b><li>
				</ul><br>
				<h3>Обязанности машиниста:</h3>
				<ul>
					<li>Важнѣйшая обязанность машиниста - управлѣниѣ составом. Вы можѣтѣ поручить эту задачу своѣму помощнику, но это рѣкомѣндуѣтся дѣлать исключитѣльно на прямых участках в бѣзопасных условиях.</li>
					<li>Во врѣмя вождѣния - нѣобходимо слѣдить за свѣтофорами. ѣсли вы нѣ услѣдитѣ за ними - сущѣствѣнно повышаѣтся рискъ катастрофы. <b>ДВИЖѣНИѣ ВОЗМОЖНО ПРОДОЛЖАТЬ / НАЧИНАТЬ ТОЛЬКО НА ЗѣЛѣНЫЙ ИЛИ ЛУННЫЙ БѣЛЫЙ СИГНАЛЪ СВѣТОФОРА!</b></li>
					<li>Так жѣ, вы обязаны <i>дѣржать связь с поѣздными диспѣтчѣрами и проводниками своѣго состава.</i></li>
					<li>Ну и конѣчно, <i>рѣкомѣндуѣтся использованиѣ гудка при прибытии на станцию, и свистка при отправлѣнии<i>, дабы пассажиры нѣ проспали свою станцию. Вам лучшѣ нѣ знать что случится ѣсли из-за вашѣй рассѣяности уважаѣмый чиновникъ проспитъ свою станцию!</li>
				<i>Будьтѣ хорошими машинистами - имѣнно от васъ зависитъ успѣхъ рѣйса!<br><br>
				<h4>Обязанности помощника машиниста:</h4>
				<ul>
					<li>Пѣрѣд началомъ поѣздки, провѣрьтѣ <i>автоматичѣскиѣ двѣри</i>. <b>К началу движѣния всѣ автоматичѣскиѣ двѣри должны быть закрыты!</b></li>
					<li>Помогайтѣ своѣму наставнику в управлѣнии составомъ: слѣдитѣ за рѣактором, управляйтѣ поѣздом в случаѣ отлучѣния машиниста. <b>Нѣ стоит лѣзть туда, куда вас нѣ просятъ.</b></li>
					<li>В ваших полномочиях - управлять двѣрьми согласно указаний машиниста или диспѣтчѣра.</li>
					<li>Вы можѣтѣ помогать машинисту с бытовыми вопросами вродѣ доставки ѣды, напитков (бѣзалкогольных!) и свѣжѣй постѣли.</li>
				<i>Помогайтѣ своѣму наставнику, вѣдь скоро вы сможѣтѣ получить повышѣниѣ до машиниста!</i>
				<h5>Напослѣдок...</h5>
				<i>Правила жѣлѣзнодорожного движѣния.</i>
				<ul>
					<li>Всѣгда пѣрѣд началом движѣния - машинистъ или ѣго помощникъ обязанъ запросить разрѣшѣниѣ у диспѣтчѣра по формѣ:
					<li><b>По второму пути (или другого пути какой занимаѣтъ ваш поѣздъ послѣ прохождѣния стрѣлки), скорого поѣзда (назовитѣ номѣръ поѣзда, ВЫ нѣ должны ѣго забывать), машинистъ (ваша фамилия), систѣмы исправны (убѣдитѣсь что это дѣйствитѣльно так), гѣнѣраторъ включѣн, нахожусь в рабочѣй кабинѣ, готовъ к манѣвровымъ пѣрѣдвижѣниямъ (такжѣ можно сказать - готов к двѣжѣнию)</b></li>
					<li>ПРИ ВИДѣ КРАСНОГО ИЛИ СИНѣГО СИНГНАЛА СВѣТОФОРА - НѣМѣДЛѣННО ОСТАНОВИТѣСЬ! Нѣобязатѣльно запрашивать у диспѣтчѣра объяснѣния причины запрѣщающѣго сигнала по маршруту движѣния, но ѣсли вы в чём-то сомнѣваѣтѣсь...</li>
					<li> И это всё. Под конѣцъ, мы жѣлаѣмъ Вам...</li>
				Счастливого пути! Импѣрия Прѣвышѣ Всѣго!<br>
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
				<h1>Привѣтствиѣ</h1>
				Привѣтствуѣмъ! Мы рады, что Вы, сударь, рѣшились работать кондукторомъ в нашѣй транспортной компании! Этотъ справочникъ был написан дочѣрнѣй компаниѣй "МѣгаВагѣнъ", которая всѣрьѣз занялась вопросомъ ввѣдѣния мѣждународных стандартовъ жѣлѣзнодорожной индустрии.<br><br>

				Всѣ профѣссии на жѣлѣзной дороги в равной стѣпѣни отвѣтствѣнны и важны:<br><br>
				<i>от поѣздного диспѣтчѣра</i> зависитъ бѣзопасный и тщатѣльно рассчитанный планъ движѣния, <i>от машиниста</i> зависитъ своѣврѣмѣнноѣ достижѣниѣ цѣли, <i>от путѣвого обходчика</i> сохранность состава, <i>от кассира</i> доходность жѣлѣзной дороги, но имѣнно <b>проводникъ</b> отвѣтствѣнѣн за соблюдѣниѣ порядка в вагонѣ, обѣспѣчѣниѣ комфорта и хорошѣго настроѣния пассажиров.<br><br>
				Бѣз проводника, пассажиры порой бѣззащитны, практичѣски бѣспомощны и рискуютъ пропустить свою станцию.<br><br>
				Бѣз вашѣго внимания, бѣзбилѣтники и мошѣнники могут разрушить благополучиѣ всѣй жѣлѣзной дороги.<br><br>
				Имѣнно к вам в пѣрвую очѣрѣдь обратятся за помощью, и в случаѣ нѣпрѣдвидѣнной ситуации - от ваших рѣшѣний будут зависѣть чѣловѣчѣскиѣ жизни.<br><br>

				<h2>Основныѣ обязанности проводника в порядкѣ важности:</h2>
				<ul>
					<li>Слѣдитѣ за порядком в вагонѣ. В случаѣ чрѣзвычайной ситуации нѣмѣдлѣнно сообщитѣ об этом машинисту и другим проводникам.</li>
					<li>Провѣряйтѣ билѣты пассажировъ вагона. Это можно сдѣлать как послѣ отправлѣния (чтобы нѣ задѣрживать провожающих пѣрѣд отправлѣниѣм), так и при посадкѣ.</li>
					<li>Выявляйтѣ <b>мошѣнниковъ</b>, которыѣ рѣшили сэкономить на покупкѣ билѣта!.</li>
					<li>Выдавайтѣ постѣльноѣ бѣльё всѣм <b>пассажирамъ поѣзда</b> послѣ отбытия со станции. <i>ѣсли рѣйс задѣржится, распрѣдѣлитѣ постѣли как можно скорѣѣ.</i> - пассажиры нѣ обойдутся бѣз комфортного отдыха.</li>
				</ul><br>

				<i>Слѣдитѣ за своѣй униформой - это символъ вашѣго высокого статуса. Нѣ стоит выбиваться из рабочѣго стиля. За соблюдѣниѣм установлѣнного порядка слѣдитъ Жѣлѣзнодорожная Инспѣкция.</i><br><br>
				<i>Вѣдитѣ сѣбя уважитѣльно в отношѣнии к пассажирамъ, очѣнь вѣроятно, что они устали с долгой дороги и просто хотятъ отдохнуть.</i><br>
				Однако, сохраняйтѣ бдитѣльность - <b>бѣзбилѣтники</b> своими дѣйствиями разворовывают государствѣнную собствѣнность, поэтому вы обязаны быть бдитѣльными!<br><br>

				Удачного сопровождѣния! Импѣрия Прѣвышѣ Всѣго!<br>
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
				<h1>Привѣтствиѣ</h1>
				<i>Что касаѣтся систѣм, нѣ использующих урана и тория (их запасы нѣ бѣзграничны, а хранѣниѣ радиоактивных продуктовъ дѣлѣния и выдѣлѣниѣ газообразных продуктовъ дѣлѣния прѣдставляютъ собою нѣкоторую экологичѣскую опасность), то в них я прѣдполагаю «тритиѣвый бридинг»</i> - Андрѣй Сахаров<br><br>
				ѣсли вы, сударь, читаѣтѣ это руководство от Института Ядѣрной Физики Импѣрии Вѣликой Руси (ИЯФИВР), то вѣроятно вы имѣѣтѣ дѣло с энѣргогѣнѣрирующѣй установкой типа РИТЭГ (радиоизотопный тѣрмоэлѣктричѣский гѣнѣраторъ).<br><br>
				<h2>Правила защиты от смѣртѣльного для чѣловѣка радиационного излучѣния и обращѣния с двигатѣлѣм типа РИТѣГ:<h2>
				<ul>
					<li>Проводитѣ рѣгулярныѣ провѣрки уровня радиации внѣ гѣнѣраторной - нѣобходимо постоянно имѣть при сѣбѣ счѣтчик Гѣйгѣра (встроѣн в analyzer). В случаѣ срабатывания счѣтчика в рабочѣй кабинѣ локомотива (нѣзначитѣльный уровѣнь излучѣния в жилой зонѣ допустимъ), нѣмѣдлѣнно эвакуируйтѣ локомотивъ, надѣньтѣ защитный костюмъ и выяснитѣ причину повышѣнного излучѣния гѣнѣратора.</li>
					<li>Всѣгда надѣвайтѣ противорадиационный защитный костюмъ пѣрѣд входомъ в гѣнѣраторную с РИТЭГ, внѣ зависимости от того включѣн или отключѣн гѣнѣратор.</li>
					<li>Послѣ выхода из гѣнѣраторной, нѣобходимо снять костюм и помѣстить ѣго в спѣциальный шкаф у входа.</li>
					<li>Нѣ рѣжѣ чѣм <i>раз в 15 минут</i> провѣряйтѣ уровѣнь тѣмпѣратуры тѣплоноситѣля - прѣвышѣниѣ тѣмпѣратуры в <b>290 градусовъ по Цѣльсию<b> привѣдѣтъ к началу цѣпной рѣакции с <i>изотопами тория</i> которая завѣршится <b>взрывомъ</b>!<li>
				</ul><br>

				<b>Вниманиѣ, двигатѣль типа РИТЭГ нѣвозможно мгновѣнно остановить или запустить. Любая ошибка можѣт привѣсти к катастрофѣ и чѣловѣчѣским жѣртвамъ!</b><br><br>

				Жѣлаѣм вам удачной эксплуатации двигатѣля!<br>
				</body>
			</html>
			"}
