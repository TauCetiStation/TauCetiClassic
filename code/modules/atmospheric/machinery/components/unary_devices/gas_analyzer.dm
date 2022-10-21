/obj/machinery/atmospherics/components/unary/gas_analyzer
	name = "gas analyzer"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "gasanalyzer-off"
	density = TRUE
	anchored = TRUE
	required_skills = list(/datum/skill/research = SKILL_LEVEL_TRAINED, /datum/skill/atmospherics = SKILL_LEVEL_TRAINED)
	var/on = FALSE
	var/currentGasMoles = 0
	var/datum/xgm_gas/currentGas
	var/amountPerLevel = 100 //moles
	var/analyzisTime = 120 //seconds

/obj/machinery/atmospherics/components/unary/gas_analyzer/atom_init()
	. = ..()
	update_icon()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/gas_analyzer(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/tank(null)
	RefreshParts()

/obj/machinery/atmospherics/components/unary/gas_analyzer/RefreshParts()
	var/RM = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		RM += M.rating
	amountPerLevel = amountPerLevel / (RM / 2)
	var/RL = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/L in component_parts)
		RL += L.rating
	analyzisTime = analyzisTime / (RL / 2)

/obj/machinery/atmospherics/components/unary/gas_analyzer/update_icon()
	icon = "gasanalyzer" + (on ? "-on" : "off")

/obj/machinery/atmospherics/components/unary/gas_analyzer/process_atmos()
	if(!on)
		return
	var/datum/gas_mixture/air1 = AIR1
	for(var/gas in air1.gas)
		if(gas == currentGas)
			currentGasMoles += air1.gas[gas]
			air1.gas[gas] = 0
			var/L = round(currentGasMoles / amountPerLevel)
			if(L)
				researchGas(currentGas, L)
			currentGasMoles -= L*amountPerLevel
			
/obj/machinery/atmospherics/components/unary/gas_analyzer/proc/researchGas(gas, level, repetitionCoeff = 0.5)
	var/exType = "Gas research ([gas])"
	var/points = 0

	for(var/obj/machinery/computer/rdconsole/RD in RDcomputer_list)
		if(RD.id == 1)
			var/earned = RD.files.experiments.earned_score[exType]
			if(!earned)
				points += gas_data.gases_initial_rnd_points[gas]
				RD.files.experiments.saved_best_score[exType] = points
			var/best = RD.files.experiments.saved_best_score[exType]
			var/totalLevel = log(repetitionCoeff, ((earned * repetitionCoeff - 1) / best) + 1) + level
			var/deltaPoints = ((best * (repetitionCoeff ** totalLevel - 1)) / repetitionCoeff - 1) - earned
			points += deltaPoints
			RD.files.experiments.earned_score[exType] += deltaPoints
	return points
