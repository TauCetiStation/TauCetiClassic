/******************** Requests Console ********************/
/** Originally written by errorage, updated by: Carn, needs more work though. I just added some security fixes */

var/global/list/req_console_assistance = list()
var/global/list/req_console_supplies = list()
var/global/list/req_console_information = list()
var/global/list/departments_genitive = list()

#define RC_ASSIST 1
#define RC_SUPPLY 2
#define RC_INFO 3
#define RC_ASSIST_SUPPLY 4
#define RC_ASSIST_INFO 5
#define RC_SUPPLY_INFO 6
#define RC_ASSIST_SUPPLY_INFO 7

/obj/machinery/requests_console
	name = "Requests Console"

	desc = "Консоль предназначенна для отправки запросов в разные отделы станции."
	anchored = TRUE
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp0"
	var/department = "Неизвестный"
	// The list of all departments on the station (Determined from this variable on each unit)
	// Set this to the same thing if you want several consoles in one department
	var/department_genitive
	// "Оповещение от [department_genitive]"
	var/list/messages = list() //List of all messages
	var/departmentType = 0
		// 0 = none (not listed, can only repeplied to)
		// 1 = assistance
		// 2 = supplies
		// 3 = info
		// 4 = ass + sup //Erro goddamn you just HAD to shorten "assistance" down to "ass"
		// 5 = ass + info
		// 6 = sup + info
		// 7 = ass + sup + info
	var/newmessagepriority = 0
		// 0 = no new message
		// 1 = normal priority
		// 2 = high priority
	var/screen = 0
		// 0 = main menu,
		// 1 = req. assistance,
		// 2 = req. supplies
		// 3 = relay information
		// 4 = write msg - not used
		// 5 = choose priority - not used
		// 6 = sent successfully
		// 7 = sent unsuccessfully
		// 8 = view messages
		// 9 = authentication before sending
		// 10 = send announcement
	var/silent = FALSE // set to TRUE for it not to beep all the time
	var/open = FALSE // TRUE if open
	var/msgVerified = "" //Will contain the name of the person who varified it
	var/msgStamped = "" //If a message is stamped, this will contain the stamp name
	var/message = "";
	var/to_dpt = ""; //the department which will be receiving the message
	var/priority = -1 ; //Priority of the message being sent
	var/list/departments = list() // Buffer for duplicate department filter
	light_range = 0

	var/datum/announcement/station/command/department/announcement = new

/obj/machinery/requests_console/power_change()
	..()
	update_icon()

/obj/machinery/requests_console/update_icon()
	if(stat & NOPOWER)
		if(icon_state != "req_comp_off")
			icon_state = "req_comp_off"
	else
		if(icon_state == "req_comp_off")
			icon_state = "req_comp0"

/obj/machinery/requests_console/atom_init()
	. = ..()
	if(!department_genitive)
		department_genitive = department
	departments_genitive[department] = department_genitive
	requests_console_list += src
	//req_console_departments += department
	switch(departmentType)
		if(RC_ASSIST)
			req_console_assistance += department
		if(RC_SUPPLY)
			req_console_supplies += department
		if(RC_INFO)
			req_console_information += department
		if(RC_ASSIST_SUPPLY)
			req_console_assistance += department
			req_console_supplies += department
		if(RC_ASSIST_INFO)
			req_console_assistance += department
			req_console_information += department
		if(RC_SUPPLY_INFO)
			req_console_supplies += department
			req_console_information += department
		if(RC_ASSIST_SUPPLY_INFO)
			req_console_assistance += department
			req_console_supplies += department
			req_console_information += department

/obj/machinery/requests_console/Destroy()
	requests_console_list -= src
	switch(departmentType)
		if(RC_ASSIST)
			req_console_assistance -= department
		if(RC_SUPPLY)
			req_console_supplies -= department
		if(RC_INFO)
			req_console_information -= department
		if(RC_ASSIST_SUPPLY)
			req_console_assistance -= department
			req_console_supplies -= department
		if(RC_ASSIST_INFO)
			req_console_assistance -= department
			req_console_information -= department
		if(RC_SUPPLY_INFO)
			req_console_supplies -= department
			req_console_information -= department
		if(RC_ASSIST_SUPPLY_INFO)
			req_console_assistance -= department
			req_console_supplies -= department
			req_console_information -= department
	return ..()

/obj/machinery/requests_console/proc/render_ui_deparments(header, list/list_deps)
	. = text("[header]<BR><BR>")
	for(var/dpt in list_deps)
		if(dpt in departments)
			continue
		departments.Add(dpt)
		var/enc_dpt = url_encode(dpt)
		if (dpt != department)
			. += text("[dpt] <A href='?src=\ref[src];write=[enc_dpt]'>Сообщение</A> ")
			. += text("<A href='?src=\ref[src];write=[enc_dpt];priority=2'>Приоритетое</A>")
			. += text("<BR>")
	. += text("<BR><A href='?src=\ref[src];setScreen=0'>Назад</A><BR>")
	departments.Cut()

/obj/machinery/requests_console/ui_interact(user)
	var/dat = ""
	if(!open)
		switch(screen)
			if(1)	//req. assistance
				dat += render_ui_deparments("Из какого отдела вам нужна помощь?", req_console_assistance)

			if(2)	//req. supplies
				dat += render_ui_deparments("Из какого отдела вам нужны поставки?", req_console_supplies)

			if(3)	//relay information
				dat += render_ui_deparments("В какой отдел вы хотите отправить сообщение?", req_console_information)

			if(6)	//sent successfully
				dat += text("<FONT COLOR='GREEN'>Сообщение отправлено</FONT><BR><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=0'>Продолжить</A><BR>")

			if(7)	//unsuccessful; not sent
				dat += text("<FONT COLOR='RED'>Произошла ошибка. </FONT><BR><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=0'>Продолжить</A><BR>")

			if(8)	//view messages
				for (var/obj/machinery/requests_console/Console in requests_console_list)
					if (Console.department == department)
						Console.newmessagepriority = 0
						Console.icon_state = "req_comp0"
						Console.set_light(1)
				newmessagepriority = 0
				icon_state = "req_comp0"
				for(var/msg in messages)
					dat += text("[msg]<BR>")
				dat += text("<A href='?src=\ref[src];setScreen=0'>Вернуться в главное меню</A><BR>")

			if(9)	//authentication before sending
				dat += text("<B>Авторизация Сообщения</B><BR><BR>")
				dat += text("<b>Сообщение для [to_dpt]: </b>[message]<BR><BR>")
				dat += text("Теперь вы можете авторизовать ваше сообщение, приложив ID или печать.<BR><BR>")
				dat += text("Подтверждено: [msgVerified]<br>");
				dat += text("Печать: [msgStamped]<br>");
				dat += text("<A href='?src=\ref[src];department=[url_encode(to_dpt)]'>Отравить</A><BR>");
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Назад</A><BR>")

			else	//main menu
				screen = 0
				if (newmessagepriority == 1)
					dat += text("<FONT COLOR='RED'>Есть новые сообщения</FONT><BR>")
				if (newmessagepriority == 2)
					dat += text("<FONT COLOR='RED'><B>НОВОЕ ПРИОРИТЕТНОЕ СООБЩЕНИЕ</B></FONT><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=8'>Просмотр сообщений</A><BR><BR>")

				dat += text("<A href='?src=\ref[src];setScreen=1'>Запросить помощь</A><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=2'>Запросить поставку</A><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=3'>Передать информацию анонимно</A><BR><BR>")
				if (silent)
					dat += text("Звук <A href='?src=\ref[src];setSilent=0'>ВЫКЛ</A>")
				else
					dat += text("Звук <A href='?src=\ref[src];setSilent=1'>ВКЛ</A>")

		var/datum/browser/popup = new(user, "window=request_console", src.name)
		popup.set_content(dat)
		popup.open()

/obj/machinery/requests_console/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["write"])
		to_dpt = sanitize(href_list["write"])  //write contains the string of the receiving department's name

		if(!to_dpt)
			return

		var/new_message = sanitize(input(usr, "Напишите ваше сообщение:", "Ожидание Ввода", ""))
		if(!can_still_interact_with(usr))
			return
		if(length(new_message))
			message = new_message
			screen = 9
			switch(href_list["priority"])
				if("2")
					priority = 2
				else
					priority = -1
		else
			to_dpt = "";
			msgVerified = ""
			msgStamped = ""
			screen = 0
			priority = -1

	if(href_list["department"] && message)
		var/log_msg = message
		var/pass = 0
		var/list/auth_data = list()
		var/recipient_from_field = sanitize(href_list["department"])
		if(recipient_from_field in departments_genitive)
			recipient_from_field = departments_genitive[recipient_from_field]
		if(msgVerified)
			auth_data.Add(msgVerified)
		if(msgStamped)
			auth_data.Add(msgStamped)
		var/auth = jointext(auth_data, "<BR>")
		screen = 7 //if it's successful, this will get overrwritten (7 = unsufccessfull, 6 = successfull)
		for(var/obj/machinery/message_server/MS in message_servers)
			if(!MS.active)
				continue
			screen = 6
			pass = 1
			messages += "[worldtime2text()] <B>Отправлено для [recipient_from_field]:</B><BR><DIV class='Section'>[message]</DIV>[auth]"
			MS.send_rc_message(sanitize(href_list["department"]), department, log_msg, msgStamped, msgVerified, priority, department_genitive)
			break
		if(!pass)
			audible_message("[bicon(src)] *Консоль Запроса пищит: 'ЗАМЕЧАНИЕ: Сервер не обнаружен!'")

	//Handle screen switching
	switch(text2num(href_list["setScreen"]))
		if(null)	//skip
		if(1)		//req. assistance
			screen = 1
		if(2)		//req. supplies
			screen = 2
		if(3)		//relay information
			screen = 3
//		if(4)		//write message
//			screen = 4
		if(5)		//choose priority
			screen = 5
		if(6)		//sent successfully
			screen = 6
		if(7)		//unsuccessfull; not sent
			screen = 7
		if(8)		//view messages
			screen = 8
		if(9)		//authentication
			screen = 9
		else		//main menu
			to_dpt = ""
			msgVerified = ""
			msgStamped = ""
			message = ""
			priority = -1
			screen = 0

	//Handle silencing the console
	switch( href_list["setSilent"] )
		if(null)	//skip
		if("1")
			silent = TRUE
		else
			silent = FALSE

	updateUsrDialog()

/obj/machinery/requests_console/attackby(obj/item/weapon/O, mob/user)
	if(screen != 9)
		return
	if (istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/T = O
		msgVerified = text("<font color='green'><b>Подтверждено [T.registered_name] ([T.assignment])</b></font>")
		updateUsrDialog()
	if (istype(O, /obj/item/weapon/stamp))
		var/obj/item/weapon/stamp/T = O
		msgStamped = text("<font color='blue'><b>[T.name]</b></font>")
	updateUsrDialog()
	return


// Heads

/obj/machinery/requests_console/captain
	name = "Captain Requests Console"
	department = "Кабинет Капитана"
	department_genitive = "Кабинета Капитана"
	departmentType = RC_ASSIST_INFO

/obj/machinery/requests_console/hop
	name = "Head of Personnel RC"
	department = "Кабинет ГП"
	department_genitive = "Кабинета ГП"
	departmentType = RC_ASSIST_INFO

/obj/machinery/requests_console/hos
	name = "Head of Security RC"
	department =  "Кабинет ГСБ"
	department_genitive = "Кабинета ГСБ"
	departmentType = RC_ASSIST_INFO

/obj/machinery/requests_console/rd
	name = "Research Director RC"
	department = "Кабинет ДИР"
	department_genitive = "Кабинета ДИР"
	departmentType = RC_ASSIST_INFO
/obj/machinery/requests_console/cmo
	name = "Chief Medical Officer RC"
	department = "Кабинет Главврача"
	department_genitive = "Кабинета Главврача"
	departmentType = RC_ASSIST_INFO

/obj/machinery/requests_console/ce
	name = "Chief Engineer RC"
	department = "Кабинет СИ"
	department_genitive = "Кабинета СИ"
	departmentType = RC_INFO

/obj/machinery/requests_console/bridge
	name = "Bridge Requests Console"
	department = "Мостик"
	department_genitive = "Мостика"
	departmentType = RC_ASSIST_INFO

// Security

/obj/machinery/requests_console/security
	name = "Security Requests Console"
	department = "Служба Безопасности"
	department_genitive = "Службы Безопасности"
	departmentType = RC_ASSIST_INFO


/obj/machinery/requests_console/detective
	name = "Detective Requests Console"
	department = "Офис Детектива"
	department_genitive = "Офиса Детектива"
	departmentType = RC_ASSIST_INFO

/obj/machinery/requests_console/forensic
	name = "Forensic Requests Console"
	department = "Офис Криминалиста"
	department_genitive = "Офиса Криминалиста"
	departmentType = RC_ASSIST_INFO

// Science

/obj/machinery/requests_console/ai
	name = "AI Requests Console"
	department = "ИИ"
	departmentType = RC_ASSIST_INFO

/obj/machinery/requests_console/science
	name = "Science Requests Console"
	department = "Научный"
	department_genitive = "Научного"
	departmentType = RC_SUPPLY

/obj/machinery/requests_console/robotics
	name = "Robotics Requests Console"
	department = "Робототехника"
	department_genitive = "Робототехники"
	departmentType = RC_SUPPLY

// Medbay

/obj/machinery/requests_console/medbay
	name = "Medbay Requests Console"
	department = "Медотсек"
	department_genitive = "Медотсека"

/obj/machinery/requests_console/genetics
	name = "Genetics Requests Console"
	department = "Генетика"
	department_genitive = "Генетики"

/obj/machinery/requests_console/virology
	name = "Virology Requests Console"
	department = "Вирусология"
	department_genitive = "Вирусологии"

// Enginiring

/obj/machinery/requests_console/atmos
	name = "Atmos Requests Console"
	department = "Атмосферный"
	department_genitive = "Атмосферного"
	departmentType = RC_ASSIST_SUPPLY

/obj/machinery/requests_console/engineering
	name = "Engineering Requests Console"
	department = "Инженерный"
	department_genitive = "Инженерного"
	departmentType = RC_ASSIST_SUPPLY

// Civil

/obj/machinery/requests_console/cargo_bay
	name = "Cargo Bay Requests Console"
	department =  "Отдел Поставок"
	department_genitive = "Отдела Поставок"
	departmentType = RC_SUPPLY

/obj/machinery/requests_console/bar
	name = "Bar Requests Console"
	department = "Бар"
	department_genitive = "Бара"
	departmentType = RC_SUPPLY

/obj/machinery/requests_console/chapel
	name = "Chapel Requests Console"
	department = "Церковь"
	department_genitive = "Церкви"
	departmentType = RC_SUPPLY

/obj/machinery/requests_console/janitorial
	name = "Janitorial Requests Console"
	department = "Подсобка Уборщика"
	department_genitive = "Подсобки Уборщика"
	departmentType = RC_ASSIST

/obj/machinery/requests_console/internal_affairs
	name = "Internal Affairs RC"
	department = "Офис Внутренних Дел"
	department_genitive = "Офиса Внутренних Дел"

/obj/machinery/requests_console/kitchen
	name = "Kitchen Requests Console"
	department = "Кухня"
	department_genitive = "Кухни"
	departmentType = RC_SUPPLY

/obj/machinery/requests_console/hydroponics
	name = "Hydroponics Requests Console"
	department = "Гидропоника"
	department_genitive = "Гидропоники"
	departmentType = RC_SUPPLY

/obj/machinery/requests_console/eva
	name = "EVA Requests Console"
	department = "ВКД"

/obj/machinery/requests_console/crew_quarters
	name = "Crew Quarters Requests Console"
	department = "Каюты Экипажа"
	department_genitive = "Кают Экипажа"

/obj/machinery/requests_console/private_office
	name = "Private Office Requests Console"
	department = "Частный Офис"
	department_genitive = "Частного Офиса"

// Storage

/obj/machinery/requests_console/tool_storage
	name = "Tool Storage Requests Console"
	department = "Склад Инструментов"
	department_genitive = "Склада Инструментов"

/obj/machinery/requests_console/tech_storage
	name = "Tech Storage Requests Console"
	department = "Тех Склада"
	department_genitive = "Тех Склада"

/obj/machinery/requests_console/chem_storage
	name = "Chemistry Storage RC"
	department = "Хим Склад"
	department_genitive = "Хим Склада"


#undef RC_ASSIST
#undef RC_SUPPLY
#undef RC_INFO
#undef RC_ASSIST_SUPPLY
#undef RC_ASSIST_INFO
#undef RC_SUPPLY_INFO
#undef RC_ASSIST_SUPPLY_INFO
