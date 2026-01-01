
ADD_TO_GLOBAL_LIST(/obj/machinery/computer/vending, vending_consoles)
/obj/machinery/computer/vending
	name = "Vending monitoring console"
	desc = "Используется для мониторинга наполнения вендинговых аппаратов."
	icon = 'icons/obj/computer.dmi'
	icon_state = "vendomat"
	state_broken_preset = "techb"
	state_nopower_preset = "tech0"
	light_color = "#b88b2e"
	req_access = list()
	circuit = /obj/item/weapon/circuitboard/computer/vending

/obj/machinery/computer/vending/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/computer/vending/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "VendingConsole", name)
		ui.open()

/obj/machinery/computer/vending/tgui_static_data(mob/user)
	var/list/data = list()
	data["nanomapPayload"] = SSmapping.tgui_nanomap_payload()
	data["currentZ"] = SSmapping.level_by_trait(ZTRAIT_STATION)

	return data

/obj/machinery/computer/vending/tgui_data(mob/user)
	var/list/data = list()
	var/list/vending_data = list()
	for(var/obj/machinery/vending/Vend in global.vending_machines)
		if(!is_station_level(Vend.z))
			continue

		var/amount_percent = round(Vend.load/Vend.max_load*100)

		var/vending_status = 1 //1 = working, 2 = unpowered, 3 = broken
		if(Vend.stat & NOPOWER)
			vending_status = 2
		if(Vend.stat & BROKEN)
			vending_status = 3

		vending_data += list(list("name" = Vend.name, "status" = vending_status, "load" = amount_percent, "x" = Vend.x, "y" = Vend.y))

	data["vendingMachines"] = vending_data

	return data
