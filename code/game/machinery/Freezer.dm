/obj/machinery/atmospherics/unary/cold_sink/freezer
	name = "gas cooling system"
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "freezer_0"
	density = 1
	anchored = 1
	var/min_temperature = 0
	use_power = 1
	current_heat_capacity = 1000

/obj/machinery/atmospherics/unary/cold_sink/freezer/New()
	..()
	initialize_directions = dir
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/thermomachine(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/cold_sink/freezer/RefreshParts()
	var/H
	var/T
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		H += M.rating
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		T += M.rating
	min_temperature = max(T0C - (170 + T*15), TCMB)
	current_heat_capacity = 1000 * ((H - 1) ** 2)

/obj/machinery/atmospherics/unary/cold_sink/freezer/attackby(obj/item/I, mob/user)
	if(default_deconstruction_screwdriver(user, "freezer-o", "freezer", I))
		on = 0
		update_icon()
		return

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)

	if(default_change_direction_wrench(user, I))
		if(node)
			node.disconnect(src)
			disconnect(node)
		initialize_directions = dir
		initialize()
		build_network()
		if(node)
			node.initialize()
			node.build_network()
			node.update_icon()
		return

/obj/machinery/atmospherics/unary/cold_sink/freezer/update_icon()
	if(panel_open)
		icon_state = "freezer-o"
	else if(src.on)
		icon_state = "freezer_1"
	else
		icon_state = "freezer"
	return

/obj/machinery/atmospherics/unary/cold_sink/freezer/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/atmospherics/unary/cold_sink/freezer/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/atmospherics/unary/cold_sink/freezer/attack_hand(mob/user)
	return ui_interact(user)

/obj/machinery/atmospherics/unary/cold_sink/freezer/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	// this is the data which will be sent to the ui
	var/data[0]
	data["on"] = on ? 1 : 0
	data["gasPressure"] = round(air_contents.return_pressure())
	data["gasTemperature"] = round(air_contents.temperature)
	data["minGasTemperature"] = round(T0C - 200)
	data["maxGasTemperature"] = round(T20C)
	data["targetGasTemperature"] = round(current_temperature)

	var/temp_class = "good"
	if (air_contents.temperature > (T0C - 20))
		temp_class = "bad"
	else if (air_contents.temperature < (T0C - 20) && air_contents.temperature > (T0C - 100))
		temp_class = "average"
	data["gasTemperatureClass"] = temp_class

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "freezer.tmpl", "Gas Cooling System", 440, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/atmospherics/unary/cold_sink/freezer/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list["toggleStatus"])
		src.on = !src.on
		update_icon()
	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			src.current_temperature = min(T20C, src.current_temperature+amount)
		else
			src.current_temperature = max(min_temperature, src.current_temperature+amount)

/obj/machinery/atmospherics/unary/cold_sink/freezer/process()
	..()

/obj/machinery/atmospherics/unary/cold_sink/freezer/power_change()
	..()
	if(stat & NOPOWER)
		on = 0
		update_icon()

/obj/machinery/atmospherics/unary/heat_reservoir/heater
	name = "gas heating system"
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "freezer_0"
	density = 1
	var/max_temperature = 0
	anchored = 1
	current_heat_capacity = 1000

/obj/machinery/atmospherics/unary/heat_reservoir/heater/New()
	..()
	initialize_directions = dir
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/thermomachine(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/heat_reservoir/heater/RefreshParts()
	var/H
	var/T
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		H += M.rating
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		T += M.rating
	max_temperature = T20C + (140 * T)
	current_heat_capacity = 1000 * ((H - 1) ** 2)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/attackby(obj/item/I, mob/user)
	if(default_deconstruction_screwdriver(user, "heater-o", "heater", I))
		on = 0
		update_icon()
		return

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)

	if(default_change_direction_wrench(user, I))
		if(node)
			node.disconnect(src)
			disconnect(node)
		initialize_directions = dir
		initialize()
		build_network()
		if(node)
			node.initialize()
			node.build_network()
			node.update_icon()
		return

/obj/machinery/atmospherics/unary/heat_reservoir/heater/update_icon()
	if(panel_open)
		icon_state = "heater-o"
	else if(src.on)
		icon_state = "heater_1"
	else
		icon_state = "heater"
	return

/obj/machinery/atmospherics/unary/heat_reservoir/heater/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/attack_hand(mob/user)
	return ui_interact(user)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	// this is the data which will be sent to the ui
	var/data[0]
	data["on"] = on ? 1 : 0
	data["gasPressure"] = round(air_contents.return_pressure())
	data["gasTemperature"] = round(air_contents.temperature)
	data["minGasTemperature"] = round(T20C)
	data["maxGasTemperature"] = round(T20C+280)
	data["targetGasTemperature"] = round(current_temperature)

	var/temp_class = "normal"
	if (air_contents.temperature > (T20C+40))
		temp_class = "bad"
	data["gasTemperatureClass"] = temp_class

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "freezer.tmpl", "Gas Heating System", 440, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if (href_list["toggleStatus"])
		src.on = !src.on
		update_icon()
	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			src.current_temperature = min((T20C+280), src.current_temperature+amount)
		else
			src.current_temperature = max(T20C, src.current_temperature+amount)

/obj/machinery/atmospherics/unary/heat_reservoir/heater/process()
	..()

/obj/machinery/atmospherics/unary/heat_reservoir/heater/power_change()
	..()
	if(stat & NOPOWER)
		on = 0
		update_icon()
