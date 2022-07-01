/obj/machinery/gas_analyzer
	name = "Gas Analyzer"
	desc = ""
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "gas_analyzer"
	density = TRUE
	anchored = TRUE
	var/scantime = 5
	var/obj/item/weapon/tank/holding = null
	var/operating = FALSE

/obj/machinery/gas_analyzer/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/gas_analyzer(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/gas_analyzer/update_icon()
	if(holding)
		icon_state = "gas_analyzer_holding"
	else
		icon_state = "gas_analyzer"

	if(operating)
		icon_state = "gas_analyzer_on"

/obj/machinery/gas_analyzer/attackby(obj/item/W, mob/user)
	. = ..()

	if(.)
		return

	if(!do_skill_checks(user))
		return

	if(operating)
		to_chat(usr, "<span class='danger'>Процесс сканирования запущен, дождитесь его окончания.</span>")

	if(istype(W, /obj/item/weapon/tank))
		if(!src.anchored)
			to_chat(user, "<span class='warning'>Сканер необходимо зафиксировать на полу.</span>")
			return 1
		if(panel_open)
			to_chat(user, "<span class='warning'>Сперва необходимо закрыть панель.</span>")
			return 1
		if(holding)
			to_chat(user, "<span class='warning'>Баллон уже загружен.</span>")
			return 1
		to_chat(usr, "<span class='notice'>Вы загрузили баллон в сканер.</span>")
		user.drop_from_inventory(W, src)
		holding = W
		update_icon()

	if(isscrewdriver(W))
		if(holding)
			to_chat(user, "<span class='warning'>Сперва необходимо изъять баллон.</span>")
			return
		if(default_deconstruction_screwdriver(user, "gas_analyzer_open", "gas_analyzer", W))
			return

	default_deconstruction_crowbar(W)


/obj/machinery/gas_analyzer/attack_hand(mob/user)
	. = ..()

	if(.)
		return

	if(operating)
		to_chat(usr, "<span class='danger'>Процесс сканирования запущен, дождитесь его окончания.</span>")
		return

	if(holding)
		scan()
	else
		buzz("\The [src] buzzes, \"Для запуска процесса сканирования необходим баллон с газом.\"")

/obj/machinery/gas_analyzer/AltClick(mob/user)
	if(operating)
		to_chat(usr, "<span class='danger'>Процесс сканирования запущен, дождитесь его окончания.</span>")
		return
	if(holding)
		dispose()

/obj/machinery/gas_analyzer/proc/dispose()
	holding.loc = src.loc
	holding = null
	to_chat(usr, "<span class='notice'>Вы изъяли баллон из сканера.</span>")
	updateUsrDialog()
	update_icon()

/obj/machinery/gas_analyzer/proc/scan()
	state("\The [src] states, \"Процесс сканирования запущен, ожидайте результата.\"")
	use_power(1000)
	visible_message("<span class='danger'>Сканер начинает протяжно гудеть и трястись.</span>")
	operating = TRUE
	update_icon()

/obj/machinery/gas_analyzer/process()
	..()
	if (stat & (NOPOWER|BROKEN))
		return

	if (operating)
		scantime -= 1
		if (scantime == 0)
			end()

/obj/machinery/gas_analyzer/proc/end()
	operating = FALSE
	update_icon()
	use_power(0)
	scantime = 5
	ping("\The [src] pings, \"Сканирование завершено.\"")
	print()

/obj/machinery/gas_analyzer/proc/print()
	var/datum/gas_mixture/M = holding.air_contents
	var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(loc)
	P.name = "Gas scanning result"
	P.info = "<center><h4>Результат сканирования газа:</h4></center><br>"
	if(round(M.return_pressure(), 0.1) == 0)
		P.info = "Загруженный баллон пуст!"
	else
		P.info += "<b> Давление </b> = [round(M.return_pressure(), 0.1)] kPa <br>"
		P.info += "<b> Температура </b> = [round(M.temperature-T0C)]&deg;C / [round(M.temperature)]K <br>"
		for(var/mix in M.gas)
			P.info += "<hr>"
			var/percentage = round(M.gas[mix] / M.total_moles * 100)
			P.info += "<h4> [gas_data.name[mix]]: [percentage] % </h4> <br>"
			P.info += "<b> Удельная теплоемкость </b> = [gas_data.specific_heat[mix]] J/(mol*K). <br>"
			P.info += "<b> Молярная масса </b> = [gas_data.molar_mass[mix]] kg/mol. <br>"
			if(gas_data.flags[mix] & XGM_GAS_FUEL)
				P.info += "Может быть использован в качестве топлива.<br>"
			if(gas_data.flags[mix] & XGM_GAS_OXIDIZER)
				P.info += "Может быть использован в качестве окислителя.<br>"
			if(gas_data.flags[mix] & XGM_GAS_CONTAMINANT)
				P.info += "Способен осядать на тканях.<br>"
			if(gas_data.flags[mix] & XGM_GAS_FUSION_FUEL)
				P.info += "Может быть использован для подпитки реакции синтеза.<br>"
	P.update_icon()
