var/global/list/vending_consoles = list()

ADD_TO_GLOBAL_LIST(/obj/machinery/computer/vending, vending_consoles)
/obj/machinery/computer/vending
	name = "Vendomat Console"
	desc = "Used to view vendomats all over the station."
	icon_state = "vendomat"
	state_broken_preset = "techb"
	state_nopower_preset = "tech0"
	light_color = "#b88b2e"
	circuit = /obj/item/weapon/circuitboard/computer/vending
	allowed_checks = ALLOWED_CHECK_NONE

/obj/machinery/computer/vending/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/computer/vending/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "VendingConsole", name)
		ui.open()

/obj/machinery/computer/vending/tgui_act(action, params)
	. = ..()
	if(.)
		return

/obj/machinery/computer/vending/tgui_data(mob/user)
	var/list/data = list()
	var/list/vending_to_front = list()
	var/list/vending_hashed = list()
	for(var/obj/machinery/vending/Vend in global.vending_machines)
		if(is_station_level(Vend.z) && Vend.refill_canister)
			var/area/A = get_area(Vend)
			if(!vending_hashed[Vend.name])
				vending_hashed[Vend.name] = list()
			vending_hashed[Vend.name] += list(list("area" = A.name, "load" = Vend.load, "max_load" = Vend.max_load))

	for(var/hash in vending_hashed)
		vending_to_front += list(list("name" = hash, "listofvends" = vending_hashed[hash]))
	data["vending"] = vending_to_front
	return data
