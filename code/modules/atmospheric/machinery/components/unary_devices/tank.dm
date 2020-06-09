/obj/machinery/atmospherics/components/unary/tank
	icon = 'icons/atmos/tank.dmi'
	icon_state = "air_map"

	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	var/volume = 10000 // in liters, 1 meters by 1 meters by 2 meters ~tweaked it a little to simulate a pressure tank without needing to recode them yet
	var/start_pressure = 25 * ONE_ATMOSPHERE
	var/gas_type = ""

	density = TRUE
	layer = ABOVE_WINDOW_LAYER

/obj/machinery/atmospherics/components/unary/tank/atom_init()
	. = ..()

	icon_state = replacetext(icon_state, "_map", "")

	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = volume
	air_contents.temperature = T20C

	if(gas_type)
		air_contents.adjust_gas(gas_type, (start_pressure) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature))
		name = "[name] ([gas_data.name[gas_type]])"

/obj/machinery/atmospherics/components/unary/tank/air/atom_init()
	. = ..()

	var/datum/gas_mixture/air_contents = AIR1
	air_contents.adjust_multi("oxygen",  (start_pressure * O2STANDARD) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature), \
	                          "nitrogen",(start_pressure * N2STANDARD) * (air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature))



/obj/machinery/atmospherics/components/unary/tank/process_atmos()
	return PROCESS_KILL

/obj/machinery/atmospherics/components/unary/tank/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, NODE1, dir)

/obj/machinery/atmospherics/components/unary/tank/hide()
	update_underlays()

/obj/machinery/atmospherics/components/unary/tank/air
	name = "Pressure Tank (Air)"
	icon_state = "air_map"

/obj/machinery/atmospherics/components/unary/tank/oxygen
	icon_state = "o2_map"
	gas_type = "oxygen"

/obj/machinery/atmospherics/components/unary/tank/nitrogen
	icon_state = "n2_map"
	gas_type = "nitrogen"

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide
	icon_state = "co2_map"
	gas_type = "carbon_dioxide"

/obj/machinery/atmospherics/components/unary/tank/phoron
	icon_state = "phoron_map"
	gas_type = "phoron"

/obj/machinery/atmospherics/components/unary/tank/nitrous_oxide
	icon_state = "n2o_map"
	gas_type = "sleeping_agent"
