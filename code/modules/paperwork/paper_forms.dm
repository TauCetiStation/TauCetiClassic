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
