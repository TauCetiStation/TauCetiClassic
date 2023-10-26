/datum/e_paper
	var/name = ""
	var/text = ""

/datum/e_paper/proc/Copy(datum/e_paper/File)
	name = File.name
	text = File.text

/proc/print_on_printer(printer_id, datum/e_paper/File, copy = TRUE)
	for(var/obj/machinery/printer/Printer in global.printers)
		if(!Printer.printer_id || (Printer.printer_id != printer_id))
			continue

		if(copy)
			var/datum/e_paper/Copy = new
			Copy.Copy(File)
			Printer.printing_queue += Copy
		else
			Printer.printing_queue += File
		Printer.start_printing()
		break

var/global/list/printers = list()

ADD_TO_GLOBAL_LIST(/obj/machinery/printer, printers)
/obj/machinery/printer
	name = "printer"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "printer"
	anchored = TRUE
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 200

	var/printer_id = ""
	var/map_printer_id = ""
	var/paper_amount = 15
	var/open = FALSE
	var/list/printing_queue = list()

	var/obj/item/weapon/pen/Pen = new

/obj/machinery/printer/atom_init(mapload)
	. = ..()

	if(mapload)
		var/area/A = get_area(src)
		printer_id = "ID-[rand(111, 999)]-[global.printers.Find(src)]-[replacetext(uppertext(A.name)," ","-")]"

/obj/machinery/printer/examine(mob/user)
	. = ..()

	if(Adjacent(user))
		to_chat(user, "Шильдик: [printer_id]")

/obj/machinery/printer/update_icon()
	if(open)
		var/icon_number = CEIL(paper_amount/3)
		icon_state = "printer_open_[icon_number]"
		return
	icon_state = "printer"

/obj/machinery/printer/proc/start_printing()
	if(open || (stat & (BROKEN|NOPOWER)))
		return

	if(!printing_queue.len)
		playsound(src, 'sound/machines/chime.ogg', VOL_EFFECTS_MASTER)
		return

	if(!paper_amount)
		playsound(src, 'sound/machines/buzz-two.ogg', VOL_EFFECTS_MASTER)
		visible_message("<span class='notice'>[bicon(src)] Недостаточно бумаги.</span>")
		addtimer(CALLBACK(src, PROC_REF(start_printing)), 15 SECONDS)
		return

	var/datum/e_paper/File = pick(printing_queue)
	playsound(src, "sound/items/polaroid1.ogg", VOL_EFFECTS_MASTER)
	flick("printer_printing", src)
	addtimer(CALLBACK(src, PROC_REF(print_paper), File), 1.7 SECONDS)

/obj/machinery/printer/proc/print_paper(datum/e_paper/File)
	var/obj/item/weapon/paper/Paper = new(loc)

	Paper.name = File.name
	Paper.parsepencode(File.text, Pen)
	Paper.info = File.text
	Paper.updateinfolinks()
	Paper.update_icon()

	printing_queue -= File
	qdel(File)

	start_printing()

/obj/machinery/printer/attack_hand(mob/user)
	var/list/options = list()
	if(open)
		var/static/radial_pickup = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_pickup")
		var/static/radial_close = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_lock")
		options["Взять"] = radial_pickup
		options["Закрыть"] = radial_close
	else
		var/static/radial_turnon = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_print")
		var/static/radial_open = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_unlock")
		var/static/radial_change_id = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_write")
		options["Печать"] = radial_turnon
		options["Открыть"] = radial_open
		options["Изменить ИН принтера"] = radial_change_id

	var/selection = show_radial_menu(user, src, options, require_near = TRUE, tooltips = TRUE)
	if(!selection)
		return

	switch(selection)
		if("Взять")
			if(!paper_amount)
				to_chat(user, "<span class = 'warning'>Корзина пуста.</span>")
				return
			var/obj/item/weapon/paper/P = new(loc)
			if(ishuman(user))
				user.put_in_hands(P)
			else
				P.forceMove(get_turf(src))
			paper_amount--
			update_icon()

		if("Закрыть")
			if(!open)
				return
			open = FALSE
			playsound(src, 'sound/machines/printer_close.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
			update_icon()

		if("Открыть")
			if(open)
				return
			open = TRUE
			playsound(src, 'sound/machines/printer_open.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
			update_icon()

		if("Печать")
			start_printing()

		if("Изменить ИН принтера")
			var/newid = sanitize(input(user, "Введите новый ИН принтера", "Принтер", printer_id) as text|null, 24)
			if(!newid)
				return
			printer_id = newid

/obj/machinery/printer/attackby(obj/item/I, mob/user, params)
	if(!open)
		return ..()

	if(istype(I, /obj/item/weapon/paper_refill))
		if(paper_amount >= 15)
			to_chat(user, "<span class='notice'>Корзина для бумаг полна.</span>")
			return ..()
		paper_amount = 15
		qdel(I)
		to_chat(user, "<span class='notice'>Корзина для бумаг пополнена.</span>")
		update_icon()
		return

	if(istype(I, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/P = I
		if((P.name != "paper") || P.info || P.stamp_text || P.crumpled)
			to_chat(user, "<span class='notice'>Бумага должна быть новой.</span>")
			return

		user.drop_from_inventory(I, src)
		paper_amount++
		qdel(I)



/obj/machinery/scaner
	name = "scaner"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "scaner"
	anchored = TRUE
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 200

	var/open = FALSE

	var/printer_id = ""

	var/obj/item/weapon/item_inside

	var/scaning = FALSE

/obj/machinery/scaner/atom_init(mapload)
	..()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/scaner/atom_init_late()
	var/obj/machinery/printer/Printer = locate() in range(1,src)
	if(Printer)
		printer_id = Printer.printer_id

/obj/machinery/scaner/examine(mob/user)
	. = ..()

	if(Adjacent(user))
		to_chat(user, "Подключённый принтер: [printer_id]")

/obj/machinery/scaner/update_icon()
	if(open)
		icon_state = "scaner_open_[item_inside ? 1 : 0]"
		return
	icon_state = "scaner"

/obj/machinery/scaner/attack_hand(mob/user)
	var/list/options = list()
	if(open)
		var/static/radial_pickup = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_pickup")
		var/static/radial_close = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_lock")
		options["Взять"] = radial_pickup
		options["Закрыть"] = radial_close
	else
		var/static/radial_turnon = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_print")
		var/static/radial_open = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_unlock")
		var/static/radial_change_id = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_write")
		options["Печать"] = radial_turnon
		options["Открыть"] = radial_open
		options["Изменить ИН принтера для подключения"] = radial_change_id

	var/selection = show_radial_menu(user, src, options, require_near = TRUE, tooltips = TRUE)
	if(!selection)
		return

	switch(selection)
		if("Взять")
			if(!item_inside)
				return
			if(ishuman(user))
				user.put_in_hands(item_inside)
			else
				item_inside.forceMove(get_turf(src))
			item_inside = null
			update_icon()

		if("Закрыть")
			if(!open)
				return
			open = FALSE
			playsound(src, 'sound/machines/printer_close.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
			update_icon()

		if("Открыть")
			if(open)
				return
			open = TRUE
			playsound(src, 'sound/machines/printer_open.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
			update_icon()

		if("Печать")
			if((stat & (BROKEN|NOPOWER)))
				return
			if(open)
				to_chat(user, "<span class = 'warning'>Закройте крышку.</span>")
				return
			if(scaning)
				return
			if(!printer_id)
				to_chat(user, "<span class = 'warning'>Невозможно установить соединение с принтером.</span>")
				return

			scaning = TRUE
			var/datum/e_paper/File = scan_item()
			addtimer(CALLBACK(src, PROC_REF(print_item), File), 0.5 SECONDS)

		if("Изменить ИН принтера")
			var/newid = sanitize(input(user, "Введите ИН принтера для подключения", "Сканер", printer_id) as text|null, 24)
			if(!newid)
				return
			printer_id = newid

/obj/machinery/scaner/attackby(obj/item/I, mob/user, params)
	if(!open)
		return ..()

	if(istype(I, /obj/item/weapon/paper) && !item_inside)
		user.drop_from_inventory(I, src)
		item_inside = I
		update_icon()

/obj/machinery/scaner/proc/print_item(datum/e_paper/File)
	print_on_printer(printer_id, File, FALSE)
	scaning = FALSE

/obj/machinery/scaner/proc/scan_item()
	if(!item_inside)
		return

	flick("scaner_scanning", src)
	var/datum/e_paper/File = new

	var/filename = ""
	var/filetext = ""
	if(istype(item_inside, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/Paper = item_inside
		filename = Paper.name
		filetext = Paper.info

	File.name = filename
	File.text = filetext

	return File
