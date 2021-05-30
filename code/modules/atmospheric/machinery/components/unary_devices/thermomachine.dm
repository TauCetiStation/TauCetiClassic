#define THERM_PERF_MULT 2.5

/obj/machinery/atmospherics/components/unary/thermomachine
	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."
	icon = 'icons/obj/Cryogenic3.dmi'
	icon_state = "freezer"
	density = 1
	anchored = 1
	use_power = NO_POWER_USE
	idle_power_usage = 5			// 5 Watts for thermostat related circuitry
	layer = OBJ_LAYER
	allowed_checks = ALLOWED_CHECK_TOPIC

	var/max_temperature = 0
	var/min_temperature = 0

	var/internal_volume = 600		// L

	var/max_power_rating = 20000	// Power rating when the usage is turned up to 100
	var/power_setting = 100

	var/set_temperature = T20C
	var/working = FALSE

/obj/machinery/atmospherics/components/unary/thermomachine/RefreshParts()
	..()
	var/cap_rating = 0
	var/man_rating = 0
	var/bin_rating = 0
	var/datum/gas_mixture/air1 = AIR1

	for(var/obj/item/weapon/stock_parts/P in component_parts)
		if(istype(P, /obj/item/weapon/stock_parts/capacitor))
			cap_rating += P.rating
		if(istype(P, /obj/item/weapon/stock_parts/manipulator))
			man_rating += P.rating
		if(istype(P, /obj/item/weapon/stock_parts/matter_bin))
			bin_rating += P.rating

	if(initial(icon_state) == "freezer")
		power_rating = initial(power_rating) * cap_rating / 2                                     // more powerful
		min_temperature = max(T0C - (initial(min_temperature) + ((man_rating + bin_rating) * 0.5) * 15), TCMB)
	else
		max_power_rating = initial(max_power_rating) * cap_rating / 2
		max_temperature = max(initial(max_temperature) - T20C, 0) * ((bin_rating * 4 + cap_rating) / 5) + T20C

	air1.volume = max(initial(internal_volume) - 200, 0) + 200 * bin_rating
	set_power_level(power_setting)

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon()
	if(panel_open)
		icon_state = initial(icon_state) + "-o"
	else if(NODE1)
		if(use_power && working)
			icon_state = initial(icon_state) + "_1"
		else
			icon_state = initial(icon_state)
	else
		icon_state = initial(icon_state) + "_0"

/obj/machinery/atmospherics/components/unary/thermomachine/process_atmos()
	last_power_draw = 0
	last_flow_rate = 0

	if((stat & (NOPOWER|BROKEN)) || !use_power || !NODE1)
		working = FALSE
		update_icon()
		return FALSE

	return TRUE

/obj/machinery/atmospherics/components/unary/thermomachine/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui)
	var/data[0]
	var/datum/gas_mixture/air1 = AIR1
	var/temp_class = "good"

	if(initial(icon_state) == "freezer")
		if(air1.temperature > (T0C - 20))
			temp_class = "bad"
		else if(air1.temperature < (T0C - 20) && air1.temperature > (T0C - 100))
			temp_class = "average"
	else
		if(air1.temperature > (T20C + 40))
			temp_class = "bad"

	data["on"] = use_power ? 1 : 0
	data["gasPressure"] = round(air1.return_pressure())
	data["gasTemperature"] = round(air1.temperature)
	data["minGasTemperature"] = round(min_temperature)
	data["maxGasTemperature"] = round(max_temperature)
	data["targetGasTemperature"] = round(set_temperature)
	data["powerSetting"] = power_setting
	data["gasTemperatureClass"] = temp_class

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if(!ui)
		ui = new(user, src, ui_key, "freezer.tmpl", name, 440, 300)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/atmospherics/components/unary/thermomachine/Topic(href, href_list)
	if(!..())
		return FALSE

	if(href_list["toggleStatus"])
		set_power_use(!use_power)
		update_icon()
	if(href_list["setPower"]) // setting power to 0 is redundant anyways
		var/new_setting = between(0, text2num(href_list["setPower"]), 100)
		set_power_level(new_setting)
	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		set_temperature = clamp(set_temperature + amount, min_temperature, max_temperature)

	add_fingerprint(usr)

/obj/machinery/atmospherics/components/unary/thermomachine/proc/set_power_level(new_power_setting)
	power_setting = new_power_setting
	power_rating = max_power_rating * (power_setting / 100)

/obj/machinery/atmospherics/components/unary/thermomachine/attackby(obj/item/O, mob/user)
	if(default_deconstruction_screwdriver(user, initial(icon_state) + "-o", initial(icon_state), O))
		set_power_use(NO_POWER_USE)
		update_icon()
		return
	if(default_deconstruction_crowbar(O))
		return
	if(exchange_parts(user, O))
		return
	if(default_change_direction_wrench(user, O))
		return

	return ..()

/obj/machinery/atmospherics/components/unary/thermomachine/default_change_direction_wrench(mob/user, obj/item/weapon/wrench/W)
	if(!..())
		return 0
	SetInitDirections()
	var/obj/machinery/atmospherics/node = NODE1
	if(node)
		node.disconnect(src)
		NODE1 = null
	nullifyPipenet(PARENT1)

	atmos_init()
	node = NODE1
	if(node)
		node.atmos_init()
		node.addMember(src)
	build_network()
	return 1

/obj/machinery/atmospherics/components/unary/thermomachine/examine(mob/user)
	. = ..(user)
	if(panel_open)
		to_chat(user, "The maintenance hatch is open.")

/obj/machinery/atmospherics/components/unary/thermomachine/freezer
	name = "gas cooling system"
	desc = "Cools gas when connected to a pipe network."

	icon_state = "freezer"

	max_temperature = T20C
	min_temperature = 170

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/atom_init()
	. = ..()

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/cooler(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/stack/cable_coil(src, 2)

	RefreshParts()

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/process_atmos()
	if(!..())
		return

	var/datum/gas_mixture/air1 = AIR1

	if(air1.temperature > set_temperature)
		var/heat_transfer = max( -air1.get_thermal_energy_change(set_temperature - 5), 0 )

		//Assume the heat is being pumped into the hull which is fixed at min_temperature
		//not /really/ proper thermodynamics but whatever
		var/cop = THERM_PERF_MULT * air1.temperature / min_temperature   // heatpump coefficient of performance from thermodynamics -> power used = heat_transfer/cop
		heat_transfer = min(heat_transfer, cop * power_rating)           // limit heat transfer by available power

		var/removed = -air1.add_thermal_energy(-heat_transfer)           // remove the heat
		if(debug)
			visible_message("[src]: Removing [removed] W.")

		working = TRUE
		use_power(power_rating)
		update_parents()
	else
		working = FALSE

	update_icon()

/obj/machinery/atmospherics/components/unary/thermomachine/heater
	name = "gas heating system"
	desc = "Heats gas when connected to a pipe network."

	icon_state = "heater"

	max_temperature = T20C + 680
	min_temperature = T20C

/obj/machinery/atmospherics/components/unary/thermomachine/heater/atom_init()
	. = ..()

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/heater(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/stack/cable_coil(src, 5)

	RefreshParts()

/obj/machinery/atmospherics/components/unary/thermomachine/heater/process_atmos()
	if(!..())
		return

	var/datum/gas_mixture/air1 = AIR1

	if(air1.total_moles && air1.temperature < set_temperature)
		air1.add_thermal_energy(power_rating * THERM_PERF_MULT)

		working = TRUE
		use_power(power_rating)
		update_parents()
	else
		working = FALSE

	update_icon()

#undef THERM_PERF_MULT
