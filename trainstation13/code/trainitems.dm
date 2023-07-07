//TRAIN STATION 13

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
	desc = "A typical train ticket."
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "ticket_blue"
	info = "<center><b>УНИВЕРСАЛЬНЫЙ БИЛЕТ:</b></center><br> \
			<hr><b><i>Предъявителю билета разрешается занять любое свободное место для пассажиров первого и второго класса, \
			в вагонах общего назначения - от вагона №5 до вагона №9.</i></b>"

//we don't want the silly text overlay of basic paper!
/obj/item/weapon/paper/ticket/update_icon()
	return

/obj/item/weapon/paper/ticket/elite
	name = "elite ticket"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "ticket_golden"
	info = "<center><b>БИЛЕТ ДИПЛОМАТИЧЕСКОГО КЛАССА:</b></center><br> \
			<hr>Номер поезда: <span class=\"paper_field\"></span><br> \
			Номер вагона: <span class=\"paper_field\"></span><br> \
			Номер места: <span class=\"paper_field\"></span><br> \
			Имя пассажира: <span class=\"paper_field\"></span><br> \
			Номер паспорта пассажира: <span class=\"paper_field\"></span><br> \
			Особые примечания: <span class=\"paper_field\"></span>."

/obj/item/weapon/paper/ticket/firstclass
	name = "first class ticket"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "ticket_green"
	info = "<center><b>БИЛЕТ ПЕРВОГО КЛАССА:</b></center><br> \
			<hr>Номер поезда: <span class=\"paper_field\"></span><br> \
			Номер вагона: <span class=\"paper_field\"></span><br> \
			Номер места: <span class=\"paper_field\"></span><br> \
			Имя пассажира: <span class=\"paper_field\"></span><br> \
			Номер паспорта пассажира: <span class=\"paper_field\"></span><br> \
			Особые примечания: <span class=\"paper_field\"></span>."

/obj/item/weapon/paper/ticket/secondclass
	name = "second class ticket"
	icon = 'trainstation13/icons/trainitems.dmi'
	icon_state = "ticket_white"
	info = "<center><b>БИЛЕТ ВТОРОГО КЛАССА:</b></center><br> \
			<hr>Номер поезда: <span class=\"paper_field\"></span><br> \
			Номер вагона: <span class=\"paper_field\"></span><br> \
			Номер места: <span class=\"paper_field\"></span><br> \
			Имя пассажира: <span class=\"paper_field\"></span><br> \
			Номер паспорта пассажира: <span class=\"paper_field\"></span><br> \
			Особые примечания: <span class=\"paper_field\"></span>."
