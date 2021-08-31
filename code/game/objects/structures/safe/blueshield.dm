/obj/structure/safe/floor/blueshield
	name = "code red safe" // WIP

/obj/structure/safe/floor/blueshield/check_unlocked()
	if(current_tumbler_index > number_of_tumblers)
		if (!(get_security_level() in list("red", "delta")))
			to_chat(usr, "<span class='italics'>You cannot open [src], as its additional lock is engaged!</span>")
			return FALSE
	return ..()

/obj/item/weapon/paper/blueshield
	name = "Инициатива \"Синий Щит\""
	var/subname = ""

/obj/item/weapon/paper/blueshield/atom_init()
	. = ..()
	if (subname)
		name += " - [subname]"
	info = "<center><img src=\"bluentlogo.png\"><br><font size=\"4\"><b>Координационный Совет Безопасности</b><br>Инициатива \"Синий Щит\"</font></center><hr>"
	var/obj/item/weapon/stamp/centcomm/S = new
	S.icon_state = "stamp-cap"
	S.stamp_color = "#3b4872"
	S.stamp_border = "#323353"
	S.stamp_paper(src, "Blueshield Initiative")
	icon_state = "paper_words"
	update_icon()

/obj/item/weapon/paper/blueshield/safe_codes
	subname = "Сейф"

/obj/item/weapon/paper/blueshield/safe_codes/atom_init()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/paper/blueshield/safe_codes/atom_init_late()
	var/list/obj/structure/safe/floor/blueshield/safes = list()
	if(safes_list.len)
		for (var/obj/structure/safe/floor/blueshield/safe in global.safes_list)
			safes += safe
	
	info += "<center>"
	if (safes.len)
		info += "Для выполнения ваших обязанностей вас предоставлено дополнительное оборудование и снаряжение. \
		Оно выбрано исходя из полученных нами разведданных. В случае боевого положения откройте сейф, \
		скрытый под полом вашего хранилища, используя данный код:"
		for (var/obj/structure/safe/safe as anything in safes)
			info += "<br>[safe.get_combination()]"
	else
		info += "Наша разведка не обнаружила деятельность Синдиката вблизи с вверенной вам станцей. \
		Дополнительного оборудования и снаряжения не ожидается."
		info_links = info
	info += "</center>"

/obj/item/weapon/paper/blueshield/wip
	subname = "Инструкции"

/obj/item/weapon/paper/blueshield/wip/atom_init()
	. = ..()
	
	info += "<center>На данный момент наш отдел снабжения не смог решить, что прислать вам, Офицер.<br> \
	Приносим свои сожаления, так как в этом сейфе ничего нет и вам придётся решать проблему своими силами. \
	Мы надеемся на вас.</center>"
