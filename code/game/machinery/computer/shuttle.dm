/obj/machinery/computer/shuttle
	name = "Shuttle"
	cases = list("шаттл", "шаттла", "шаттлу", "шаттл", "шаттлом", "шаттле")
	desc = "Консоль управления шаттлом."
	icon_state = "erokEz"
	state_broken_preset = "erokEzb"
	state_nopower_preset = "erokEz0"
	var/auth_need = 3.0
	var/list/authorized = list()

	light_color = "#7bf9ff"


/obj/machinery/computer/shuttle/attackby(obj/item/weapon/card/W, mob/user)
	if(stat & (BROKEN|NOPOWER))	return
	if ((!( istype(W, /obj/item/weapon/card) ) || !( SSticker ) || SSshuttle.location != 1 || !( user )))	return
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (istype(W, /obj/item/device/pda))
			var/obj/item/device/pda/pda = W
			W = pda.id
		if (!W:access) //no access
			to_chat(user, "Уровень доступа ID карты [W:registered_name] не достаточен.")
			return

		var/list/cardaccess = W:access
		if(!istype(cardaccess, /list) || !cardaccess.len) //no access
			to_chat(user, "Уровень доступа ID карты [W:registered_name] не достаточен.")
			return

		if(!(access_heads in W:access)) //doesn't have this access
			to_chat(user, "Уровень доступа ID карты [W:registered_name] не достаточен.")
			return 0

		var/choice = tgui_alert(user, text("Хотите авторизовать экстренный запуск шаттла? Вам по-прежнему требуется [] авторизации.", src.auth_need - src.authorized.len), "Управление шаттлом", list("Авторизация", "Отмена", "Сброс"))
		if(SSshuttle.location != 1 && user.get_active_hand() != W)
			return 0
		switch(choice)
			if("Авторизация")
				src.authorized -= W:registered_name
				src.authorized += W:registered_name
				if (src.auth_need - src.authorized.len > 0)
					message_admins("[key_name_admin(user)] has authorized early shuttle launch")
					log_game("[user.ckey] has authorized early shuttle launch")
					visible_message("<span class='notice'><B>Внимание! Для экстренного запуска шаттла осталось получить разрешений: [auth_need - authorized.len]</B></span>")
				else
					message_admins("[key_name_admin(user)] has launched the shuttle")
					log_game("[user.ckey] has launched the shuttle early")
					visible_message("<span class='notice'><B>Тревога: активирована экстренная отстыковка шаттла. Взлёт через 10 секунд!</B></span>")
					SSshuttle.online = 1
					SSshuttle.settimeleft(10)
					authorized.Cut()

			if("Отмена")
				src.authorized -= W:registered_name
				visible_message("<span class='notice'><B>Внимание! Для экстренного запуска шаттла осталось получить разрешений: [auth_need - authorized.len]</B></span>")

			if("Сброс")
				visible_message("<span class='notice'><B>Все разрешения на сокращение времени запуска шаттла отменены!</B></span>")
				authorized.Cut()
	return

/obj/machinery/computer/shuttle/emag_act(mob/user)
	if(emagged)
		return FALSE
	var/choice = tgui_alert(user, "Вы хотите запустить шаттл?","Управление шаттлом", list("Запуск", "Отмена"))
	if(SSshuttle.location == 1)
		switch(choice)
			if("Запуск")
				to_chat(world, "<span class='notice'><B>Тревога: активирована экстренная отстыковка шаттла. Взлёт через 10 секунд!</B></span>")
				SSshuttle.settimeleft( 10 )
				emagged = 1
				return TRUE
			if("Отмена")
				return FALSE
