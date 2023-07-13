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

/obj/item/weapon/paper/book/conductor
	name = "train conductor manual"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "book_conductor"

/obj/item/weapon/paper/book/conductor/atom_init()
	. = ..()
	var/obj/item/weapon/pen/P = new
	info = parsepencode("\[center\]\[large\]\[b\]РАБОТА ПРОВОДНИКА “для ЧАЙНИКОВ”\[/b\]\[/large\]\n\
\[i\]для сомневающихся\[/i\]\[/center\]\[br\]\n\
\[quote\]«Кое-что о поездах: куда бы они ни ехали, главное — решиться и сесть на поезд.»\n\
- Проводник Полярного Экспресса\[/quote\]\[br\]\n\
Все профессии на железной дороги в равной степени ответственны и важны:\[br\]\n\
от поездного диспетчера зависит безопасный и тщательно рассчитанный план движения, от машиниста зависит своевременное достижение цели,\n\
от путевого обходчика сохранность состава, от кассира доходность железной дороги,\n\
но именно проводник ответственен за соблюдение порядка в вагоне, обеспечение комфорта и хорошего настроения пассажиров.\[br\]\n\
Без проводника, пассажиры порой беззащитны, практически беспомощны и рискуют пропустить свою станцию.\[br\]\n\
Без вашего внимания, безбилетники и мошенники могут разрушить благополучие всей железной дороги.\[br\]\n\
Именно к вам в первую очередь обратятся за помощью, и в случае непредвиденной ситуации - от ваших решений будут зависеть человеческие жизни.\[br\]\[br\]\n\
Основные обязанности проводника в порядке важности:\[br\]\n\
\[list\]\[*\]\[b\]Следите за порядком в вагоне.\[/b\]\ В случае чрезвычайной ситуации немедленно сообщите информацию машинисту и другим проводникам.\n\
\[*\]\[b\]Проверяйте билеты пассажиров вагона.\[/b\]\ Это можно сделать как после отправления (чтобы не задерживать провожающих перед отправлением),\n\
так и при посадке. Во время проверки билета, обратите внимание на печать - Управление Железных Дорог регулярно меняет форму печати для борьбы с подделками.\n\
Вы можете получить информацию о печати у поездного диспетчера, или обратив внимание на печать которая присутствует у большинства пассажиров.\[/list\]", P)
	update_icon()
	updateinfolinks()