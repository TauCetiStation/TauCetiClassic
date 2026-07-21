// QM console hook (the generic extra_menu_html / Topic plumbing lives on /obj/machinery/computer/cargo
// in code/modules/cargo/console.dm). This is the Cargo Guard edict's slice of the QM console: it lets
// the quartermaster request the persistent edict for future shifts.
/obj/machinery/computer/cargo/qm/extra_menu_html(mob/user)
	. = ""
	var/datum/edict/cargo_guard/E = get_edict(EDICT_CARGO_GUARD)
	if(!E)
		return
	var/guard_amount = get_edict_value(EDICT_CARGO_GUARD)
	. += "<HR><B>Указ «ЧОП Карго»</B><BR>"
	. += "Слотов ЧОП: [guard_amount] из [CARGO_GUARD_MAX]. Содержание к концу смены: [guard_amount * CARGO_GUARD_PRICE]$.<BR>"
	if(guard_amount >= CARGO_GUARD_MAX)
		return . + "Достигнут максимум слотов.<BR>"
	if(E.requested)
		return . + "Заявка на +1 слот в этой смене уже оформлена.<BR>"
	if(COOLDOWN_FINISHED(E, request_window))
		return . + "<font color='gray'>Окно заявки закрыто (первые 15 минут смены).</font><BR>"
	. += "Для +1 слота держать к концу смены: [(guard_amount + 1) * CARGO_GUARD_PRICE]$.<BR>"
	. += "<A href='byond://?src=\ref[src];request_cargo_guard=1'>ЗАПРОСИТЬ +1 ЧОП НА БУДУЩИЕ СМЕНЫ</A><BR>"

/obj/machinery/computer/cargo/qm/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list["request_cargo_guard"])
		request_cargo_guard(usr)
		updateUsrDialog()

/obj/machinery/computer/cargo/qm/proc/request_cargo_guard(mob/user)
	var/datum/edict/cargo_guard/E = get_edict(EDICT_CARGO_GUARD)
	if(!E || E.requested)
		return
	if(get_edict_value(EDICT_CARGO_GUARD) >= CARGO_GUARD_MAX)
		return
	if(COOLDOWN_FINISHED(E, request_window))
		return

	E.requested = TRUE
	new /obj/item/weapon/paper/cargo_guard_request(get_turf(src))
	var/obj/item/weapon/paper/cargo_guard_request/copy = new
	var/obj/machinery/faxmachine/F = print_to_command_fax(copy)
	var/copy_line
	if(F)
		copy_line = "Копия распечатана на факсе командования ([F.department])."
	else
		qdel(copy)
		copy_line = "<font color='red'>Командный факс не найден — копия не распечатана.</font>"
	temp = "Заявка на +1 ЧОП оформлена. Квартирмейстер должен лично доставить эту форму на ЦК к концу смены живым и не под арестом, а карго — удержать на счету нужную сумму. [copy_line]<BR><BR><A href='byond://?src=\ref[src];mainmenu=1'>OK</A>"
