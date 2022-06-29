/obj/machinery/gas_analyzer
	name = "Gas Analyzer"
	desc = ""
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "gas_analyzer"
	density = TRUE
	anchored = TRUE
	var/scantime = 60
	var/obj/item/weapon/tank/holding = null
	var/operating = FALSE

/obj/machinery/gas_analyzer/update_icon()
	if(holding)
		icon_state = "gas_analyzer_holding"
	else
		icon_state = "gas_analyzer"

	if(operating)
		icon_state = "gas_analyzer_on"

/obj/machinery/gas_analyzer/attackby(obj/item/W, mob/user)
	if(!do_skill_checks(user))
		return
	if(istype(W, /obj/item/weapon/tank))
		if(!src.anchored)
			to_chat(user, "<span class='warning'>Сканер необходимо зафиксировать на полу.</span>")
			return 1
		if(holding)
			to_chat(user, "<span class='warning'>Баллон уже загружен.</span>")
			return 1
		user.drop_from_inventory(W, src)
		holding = W
		update_icon()

/obj/machinery/gas_analyzer/ui_interact(mob/user)
	var/dat = "<div class='Section__title'>"
	dat += "<A href='?src=\ref[src];action=scan'>Запустить сканирование</A>"
	dat += "<A href='?src=\ref[src];action=dispose'>Изъять баллон</A>"
	var/datum/browser/popup = new(user, name, name, 400, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/gas_analyzer/Topic(href, href_list)
	. = ..()
	if(!. || panel_open)
		return FALSE

	if(src.operating)
		to_chat(usr, "<span class='danger'>Процесс сканирования запущен, дождитесь его окончания.</span>")
		updateUsrDialog()
		return

	switch(href_list["action"])
		if ("scan")
			scan()
		if ("dispose")
			dispose()
	updateUsrDialog()

/obj/machinery/gas_analyzer/proc/dispose()
	holding.loc = src.loc
	holding = null
	to_chat(usr, "<span class='notice'>Вы изъяли баллон из сканера.</span>")
	updateUsrDialog()

/obj/machinery/gas_analyzer/proc/scan()
	if(src.operating)
		return
	use_power(1000)
	visible_message("<span class='danger'>You hear a loud squelchy grinding sound.</span>")
	src.operating = 1
	update_icon()

