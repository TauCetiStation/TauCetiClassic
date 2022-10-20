/obj/machinery/atmospherics/components/unary/gas_analyzer
	name = "gas analyzer"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "gasanalyzer-off"
	density = TRUE
	anchored = TRUE
	required_skills = list(/datum/skill/research = SKILL_LEVEL_TRAINED, /datum/skill/atmospherics = SKILL_LEVEL_TRAINED)
	var/on = FALSE
	var/datum/gas_mixture/consumed

/obj/machinery/atmospherics/components/unary/gas_analyzer/atom_init()
	. = ..()
	update_icon()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/gas_analyzer(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser/high(null)
	component_parts += new /obj/item/weapon/tank(null)

/obj/machinery/atmospherics/components/unary/gas_analyzer/update_icon()
	icon = "gasanalyzer" + (on ? "-on" : "off")

/obj/machinery/atmospherics/components/unary/gas_analyzer/process_atmos()
	return
