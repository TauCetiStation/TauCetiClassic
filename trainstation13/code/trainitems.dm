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
	info = "<center><b>УНИВЕРСАЛЬНЫЙ БИЛЕТ:</b></center><br> \
			<hr><b><i>Предъявителю билета разрешается занять любое свободное место для пассажиров первого и второго класса, \
			в вагонах общего назначения - от вагона №6 до вагона №9.</i></b> \
			<hr><i>Место для штампов.</i>"

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
	info = parsepencode("\[center\]\[large\]\[b\]БИЛЕТ ДИПЛОМАТИЧЕСКОГО КЛАССА:\[/b\]\[/large\]\[br\]\n\
Номер поезда: \[field\]\[br\]\n\
Номер вагона: \[field\]\[br\]\n\
Номер места: \[field\]\[br\]\n\
Имя пассажира: \[field\]\[br\]\n\
Особые примечания: \[field\]\[br\]\n\
\[small\]Билет должен быть заверен кассиром согласно формы установленного штампа.\[/small\]\[br\]\
\[hr\]\[i\]Место для штампов.\[/i\]", P)
	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/ticket/firstclass
	name = "first class ticket"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "ticket_green"

/obj/item/weapon/paper/ticket/firstclass/atom_init()
	. = ..()
	var/obj/item/weapon/pen/P = new
	info = parsepencode("\[center\]\[large\]\[b\]БИЛЕТ ПЕРВОГО КЛАССА:\[/b\]\[/large\]\[br\]\n\
Номер поезда: \[field\]\[br\]\n\
Номер вагона: \[field\]\[br\]\n\
Номер места: \[field\]\[br\]\n\
Имя пассажира: \[field\]\[br\]\n\
Особые примечания: \[field\]\[br\]\n\
\[small\]Билет должен быть заверен кассиром согласно формы установленного штампа.\[/small\]\[br\]\
\[hr\]\[i\]Место для штампов.\[/i\]", P)
	update_icon()
	updateinfolinks()

/obj/item/weapon/paper/ticket/secondclass
	name = "second class ticket"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "ticket_white"

/obj/item/weapon/paper/ticket/secondclass/atom_init()
	. = ..()
	var/obj/item/weapon/pen/P = new
	info = parsepencode("\[center\]\[large\]\[b\]БИЛЕТ ВТОРОГО КЛАССА:\[/b\]\[/large\]\[br\]\n\
Номер поезда: \[field\]\[br\]\n\
Номер вагона: \[field\]\[br\]\n\
Номер места: \[field\]\[br\]\n\
Имя пассажира: \[field\]\[br\]\n\
Особые примечания: \[field\]\[br\]\n\
\[small\]Билет должен быть заверен кассиром согласно формы установленного штампа.\[/small\]\[br\]\
\[hr\]\[i\]Место для штампов.\[/i\]", P)
	update_icon()
	updateinfolinks()

//GUIDES

/obj/item/weapon/book/manual/keeperbook
	name = "The work of Conductor (for dummies!)"
	icon_state ="bookNuclear"
	item_state = "book10"
	author = "Transport Community Nanovalgen"
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
				<h1>T</h1>
				Приветствуем! Мы рады, что вы решились работать кондуктором в нашей транспортной компании! Этот справочник был написан дочерней компанией "Нановальген", которая всерьёз занялась этим делом.<br><br>

				Все профессии на железной дороги в равной степени ответственны и важны:<br><br>
				от поездного диспетчера зависит безопасный и тщательно рассчитанный план движения, от машиниста зависит своевременное достижение цели, от путевого обходчика сохранность состава, от кассира доходность железной дороги, но именно проводник ответственен за соблюдение порядка в вагоне, обеспечение комфорта и хорошего настроения пассажиров.<br><br>
				Без проводника, пассажиры порой беззащитны, практически беспомощны и рискуют пропустить свою станцию.<br><br>
				Без вашего внимания, безбилетники и мошенники могут разрушить благополучие всей железной дороги.<br><br>
				Именно к вам в первую очередь обратятся за помощью, и в случае непредвиденной ситуации - от ваших решений будут зависеть человеческие жизни.<br><br>

				<h2>Основные обязанности проводника в порядке важности:</h2>
				<ul>
					<li>Следите за порядком в вагоне. В случае чрезвычайной ситуации немедленно сообщите об этом машинисту и другим проводникам.</li>
					<li>Проверяйте билеты пассажиров вагона. Это можно сделать как после отправления (чтобы не задерживать провожающих перед отправлением), так и при посадке.</li>
					<li>Выявляйте мошенников, которые решили сэкономить на покупке билета!.</li>
					<li>Type the numeric authorisation code into the keypad. This should have been provided.</li>
				</ul><br>

				Вы были одеты, подобающе вашему статусу. Не стоит выбиваться из рабочего стиля.<br><br>
				Ведите себя уважительно в отношении к пассажирам, очень вероятно, что они устали и просто хотят отдохнуть.<br>
				Однако, сохраняйте бдительность - безбилетники являются для вас мошенниками, поэтому вы попросту обязаны хоть что-то сделать!<br><br>

				Удачного сопровождения!<br>
				</body>
			</html>
			"}
