var/global/list/vendomat_consoles = list()

ADD_TO_GLOBAL_LIST(/obj/machinery/computer/vendomat, vendomat_consoles)
/obj/machinery/computer/vendomat
	name = "Vendomat Console"
	desc = "Used to view vendomats all over the station."
	icon_state = "vendomat"
	state_broken_preset = "techb"
	state_nopower_preset = "tech0"
	light_color = "#b88b2e"
	circuit = /obj/item/weapon/circuitboard/computer/vendomat
	allowed_checks = ALLOWED_CHECK_NONE

/obj/machinery/computer/vendomat/attack_hand(mob/user)
	tgui_interact(user)

/obj/machinery/computer/vendomat/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vendomat_Console", name)
		ui.open()

/obj/machinery/computer/vendomat/tgui_act(action, params)
	. = ..()
	if(.)
		return

/obj/machinery/computer/vendomat/tgui_data(mob/user)
	var/list/data = list()
	var/list/vendomats_to_front = list()
	for(var/obj/machinery/vending/Vend in global.vending_machines)
		vendomats_to_front += list(list("name" = Vend.name, "desc" = Vend.desc, "integrity" = Vend.atom_integrity, "max_integrity" = Vend.max_integrity, "load" = Vend.load, "max_load" = Vend.max_load))
	data["vendomats"] = vendomats_to_front
	return data
