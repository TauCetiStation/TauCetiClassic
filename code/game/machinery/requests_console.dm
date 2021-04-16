/******************** Requests Console ********************/
/** Originally written by errorage, updated by: Carn, needs more work though. I just added some security fixes */

var/list/req_console_assistance = list()
var/list/req_console_supplies = list()
var/list/req_console_information = list()
var/list/departments_genitive = list()

/obj/machinery/requests_console
	name = "Requests Console"
	desc = "Консоль предназначенна для отправки запросов в разные отделы станции."
	anchored = 1
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp0"
	var/department = "Неизвестный"  //The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/department_genitive         // "Оповещение [department_genitive]"
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
	var/silent = 0 // set to 1 for it not to beep all the time
	var/announcementConsole = 0
		// 0 = This console cannot be used to send department announcements
		// 1 = This console can send department announcementsf
	var/open = 0 // 1 if open
	var/announceAuth = 0 //Will be set to 1 when you authenticate yourself for announcements
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
		if(1)
			req_console_assistance += department
		if(2)
			req_console_supplies += department
		if(3)
			req_console_information += department
		if(4)
			req_console_assistance += department
			req_console_supplies += department
		if(5)
			req_console_assistance += department
			req_console_information += department
		if(6)
			req_console_supplies += department
			req_console_information += department
		if(7)
			req_console_assistance += department
			req_console_supplies += department
			req_console_information += department

/obj/machinery/requests_console/Destroy()
	requests_console_list -= src
	switch(departmentType)
		if(1)
			req_console_assistance -= department
		if(2)
			req_console_supplies -= department
		if(3)
			req_console_information -= department
		if(4)
			req_console_assistance -= department
			req_console_supplies -= department
		if(5)
			req_console_assistance -= department
			req_console_information -= department
		if(6)
			req_console_supplies -= department
			req_console_information -= department
		if(7)
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
				dat += text("Вы сейчас можите авторизировать ваше сообщение приложив ID или печать.<BR><BR>")
				dat += text("Подтверждено: [msgVerified]<br>");
				dat += text("Печать: [msgStamped]<br>");
				dat += text("<A href='?src=\ref[src];department=[url_encode(to_dpt)]'>Отравить</A><BR>");
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Назад</A><BR>")

			if(10)	//send announcement
				dat += text("<B>Оповещение станции</B><BR><BR>")
				if(announceAuth)
					dat += text("<b>Авторизация принята</b><BR><BR>")
				else
					dat += text("Проведите вашей картой для авторизации.<BR><BR>")
				dat += text("<b>Сообщение: </b>[message] <A href='?src=\ref[src];writeAnnouncement=1'>Написать</A><BR><BR>")
				if (announceAuth && message)
					dat += text("<A href='?src=\ref[src];sendAnnouncement=1'>Отправить</A><BR>");
				dat += text("<BR><A href='?src=\ref[src];setScreen=0'>Назад</A><BR>")

			else	//main menu
				screen = 0
				announceAuth = 0
				if (newmessagepriority == 1)
					dat += text("<FONT COLOR='RED'>Есть новые сообщения</FONT><BR>")
				if (newmessagepriority == 2)
					dat += text("<FONT COLOR='RED'><B>НОВОЕ ПРИОРИТЕТНОЕ СООБЩЕНИЕ</B></FONT><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=8'>Просмотр сообщений</A><BR><BR>")

				dat += text("<A href='?src=\ref[src];setScreen=1'>Запросить помощь</A><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=2'>Запросить поставку</A><BR>")
				dat += text("<A href='?src=\ref[src];setScreen=3'>Передать информацию анонимно</A><BR><BR>")
				if(announcementConsole)
					dat += text("<A href='?src=\ref[src];setScreen=10'>Отправить оповещение станции</A><BR><BR>")
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
		to_dpt = href_list["write"]  //write contains the string of the receiving department's name

		if(!to_dpt)
			return

		var/new_message = sanitize(input(usr, "Напишите ваше сообщение:", "Ожидание Ввода", ""))
		if(new_message)
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

	if(href_list["writeAnnouncement"])
		var/new_message = sanitize(input(usr, "Напишите ваше сообщение:", "Ожидание Ввода", "") as null|message)
		if(new_message)
			message = new_message
			switch(href_list["priority"])
				if("2")
					priority = 2
				else
					priority = -1
		else
			message = ""
			announceAuth = 0
			screen = 0

	if(href_list["sendAnnouncement"])
		if(!announcementConsole)
			return FALSE

		announcement.play(department_genitive, message)

		announceAuth = 0
		message = ""
		screen = 0

	if(href_list["department"] && message)
		var/log_msg = message
		var/pass = 0
		var/list/auth_data = list()
		var/recipient_from_field = href_list["department"]
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
			MS.send_rc_message(href_list["department"], department, log_msg, msgStamped, msgVerified, priority, department_genitive)
			break
		if(!pass)
			audible_message("[bicon(src)] *Консоль Запроса пикнула: 'ЗАМЕЧАНИЕ: Сервер не обнаружен!'")

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
		if(10)		//send announcement
			if(!announcementConsole)
				return FALSE
			screen = 10
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
			silent = 1
		else
			silent = 0

	updateUsrDialog()

/obj/machinery/requests_console/attackby(obj/item/weapon/O, mob/user)
	if (istype(O, /obj/item/weapon/card/id))
		if(screen == 9)
			var/obj/item/weapon/card/id/T = O
			msgVerified = text("<font color='green'><b>Подтверждено [T.registered_name] ([T.assignment])</b></font>")
			updateUsrDialog()
		if(screen == 10)
			var/obj/item/weapon/card/id/ID = O
			if (access_RC_announce in ID.GetAccess())
				announceAuth = 1
			else
				announceAuth = 0
				to_chat(user, "<span class='warning'>Вы не авторизованы для отправки оповещений на станцию.</span>")
			updateUsrDialog()
	if (istype(O, /obj/item/weapon/stamp))
		if(screen == 9)
			var/obj/item/weapon/stamp/T = O
			msgStamped = text("<font color='blue'><b>[T.name]</b></font>")
			updateUsrDialog()
	return
