/obj/machinery/atmospherics/components/unary/oxygen_generator
	icon = 'icons/obj/atmospherics/oxygen_generator.dmi'
	icon_state = "intact_off"

	name = "oxygen generator"
	desc = "Generates oxygen"

	density = TRUE
	layer = GAS_SCRUBBER_LAYER

	var/on = FALSE
	var/oxygen_content = 10

/obj/machinery/atmospherics/components/unary/oxygen_generator/update_icon()
	if(NODE1)
		icon_state = "intact_[on?("on"):("off")]"
	else
		icon_state = "exposed_off"

		on = FALSE

/obj/machinery/atmospherics/components/unary/oxygen_generator/atom_init()
	. = ..()

	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = 50

/obj/machinery/atmospherics/components/unary/oxygen_generator/process_atmos()
	last_power_draw = 0
	last_flow_rate = 0

	if(!on)
		return

	var/datum/gas_mixture/air_contents = AIR1

	var/total_moles = air_contents.total_moles

	if(total_moles < oxygen_content)
		var/current_heat_capacity = air_contents.heat_capacity()

		var/added_oxygen = oxygen_content - total_moles

		air_contents.temperature = (current_heat_capacity * air_contents.temperature + 20 * added_oxygen * T0C) / (current_heat_capacity + 20 * added_oxygen)
		air_contents.adjust_gas("oxygen", added_oxygen)

		update_parents()
