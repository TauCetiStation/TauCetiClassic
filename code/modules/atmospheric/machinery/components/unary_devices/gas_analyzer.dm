/obj/machinery/atmospherics/gas_analyzer
	name = "gas analyzer"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "analyzer"
	idle_power_usage = 50
	active_power_usage = 1000
	density = TRUE
	anchored = TRUE
	required_skills = list(/datum/skill/research = SKILL_LEVEL_TRAINED, /datum/skill/atmospherics = SKILL_LEVEL_TRAINED)
	var/currentGasMoles = 0
	var/currentGas = "phoron"
	var/amountPerLevel = 100 //moles
	var/temp = ""
	var/lastResearch = 31
	var/researchDrained = FALSE
	var/obj/item/weapon/tank/insertedTank = null

/obj/machinery/atmospherics/gas_analyzer/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/gas_analyzer(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/tank(null)
	RefreshParts()
	update_icon()

/obj/machinery/atmospherics/gas_analyzer/RefreshParts()
	var/RM = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		RM += M.rating
	amountPerLevel = amountPerLevel / (RM / 2)

/obj/machinery/atmospherics/gas_analyzer/update_icon()
	cut_overlays()
	var/on = !(stat & (BROKEN|NOPOWER) || !anchored)
	add_overlay(image("icons/obj/atmos.dmi", "analyzer_over-p[on]"))
	if(panel_open)
		add_overlay(image("icons/obj/atmos.dmi", "analyzer_over-p"))
	if(insertedTank)
		add_overlay(image("icons/obj/atmos.dmi", "analyzer_over-t"))
	var/indicatorLevel = 0
	if(on)
		indicatorLevel = round((currentGasMoles / amountPerLevel) / 0.25)
	add_overlay(image("icons/obj/atmos.dmi", "analyzer_over-i[indicatorLevel]"))

/obj/machinery/atmospherics/gas_analyzer/process_atmos()
	if(stat & (BROKEN|NOPOWER) || !anchored || !insertedTank)
		return
	var/datum/gas_mixture/air1 = insertedTank.air_contents
	for(var/gas in air1.gas)
		if(gas == currentGas)
			currentGasMoles += air1.gas[gas]
			air1.gas[gas] = 0
			air1.update_values()
			var/L = round(currentGasMoles / amountPerLevel)
			if(L && !researchDrained)
				var/P = researchGas(currentGas, L)
				if(P < 0)
					researchDrained = TRUE
				currentGasMoles -= L * amountPerLevel
				lastResearch = 0
			if(lastResearch > 30)
				set_power_use(idle_power_usage)
			else
				lastResearch ++
				set_power_use(active_power_usage)

/obj/machinery/atmospherics/gas_analyzer/proc/researchGas(gas, levels, repetitionCoeff = 0.5, add = TRUE)
	var/exType = "Gas research ([gas])"
	var/points = -1
	if(!levels)
		return
	for(var/obj/machinery/computer/rdconsole/RD in RDcomputer_list)
		if(RD.id == 1)
			var/earned = RD.files.experiments.earned_score[exType]
			var/best = RD.files.experiments.saved_best_score[exType]
			if(!earned)
				points = gas_data.gases_initial_rnd_points[gas]
				if(!add)
					return points
				RD.files.experiments.saved_best_score[exType] = points //amount on other research iterations will always be lower
				RD.files.experiments.earned_score[exType] += points
				RD.files.research_points += points
				return points
			//formulas below are for geometric progressions if someone needs to know that
			//points for every iterations are equal to points from previous one, multiplied by repetitionCoeff
			var/last = (earned * (repetitionCoeff - 1) + best) / repetitionCoeff
			if(last < 10)
				return points
			points = ((last * (repetitionCoeff ** levels - 1)) / (repetitionCoeff - 1)) * repetitionCoeff
			points = round(points)
			if(add)
				RD.files.experiments.earned_score[exType] += points
				RD.files.research_points += points
	return points

/obj/machinery/atmospherics/gas_analyzer/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/tank) && !insertedTank)
		if(user.drop_from_inventory(W, src))
			var/obj/item/weapon/tank/T = W
			insertedTank = T
			update_icon()

	if(iswrench(W))
		anchored = !anchored
		to_chat(user, "<span class='notice'>You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor.</span>")
		if(!anchored)
			set_power_use(NO_POWER_USE)
		update_icon()
	else
		..()

	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), W))
		update_icon()
		return

	if(default_deconstruction_crowbar(W))
		return

/obj/machinery/atmospherics/gas_analyzer/interact(mob/living/user)
	..()
	if(stat & (BROKEN|NOPOWER) || !anchored)
		return
	var/html = generateInteractionPage()
	var/datum/browser/popup = new(user, "gas_analyzer", "Gas Analyzer", 600, 600)
	popup.set_content(html)
	popup.open()

/obj/machinery/atmospherics/gas_analyzer/proc/checkRdConsole()
	for(var/obj/machinery/computer/rdconsole/RD in RDcomputer_list)
		if(RD.id == 1)
			return TRUE
	return FALSE

/obj/machinery/atmospherics/gas_analyzer/proc/generateInteractionPage()
	var/html = ""
	if(temp)
		html = temp
	else
		if(!checkRdConsole())
			html += "<span class='red'>Рабочих консолей РнД не обнаружено - очки не будут генерироватся.</span><br>"
		if(researchDrained)
			html += "<span class='red'>Газ полностью изучен и более не представляет научной ценности.</span><br>"
		html += "Давление в баллоне: [insertedTank ? insertedTank.air_contents.return_pressure() : "Н/Д"]<br>"
		html += "Молей в баллоне: [insertedTank ? insertedTank.air_contents.total_moles : "Н/Д"]<br>"
		html += "Текущий изучаемый газ: [gas_data.name[currentGas]]<br>"
		html += "Необходимый объём: [currentGasMoles]/[amountPerLevel]<br>"
		html += "Ожидаемые очки за итерацию: [researchGas(currentGas, 1, add = FALSE)]<br>"
		html += "<A align='right' href='?src=\ref[src];changeg=1'>Сменить изучаемый газ</A><br>"
		html += "<A align='right' href='?src=\ref[src];changet=1'>Извлечь баллон</A><br>"
		html += "<A align='right' href='?src=\ref[src];refresh=1'>Обновить</A><br>"
	return html

/obj/machinery/atmospherics/gas_analyzer/Topic(href, href_list)
	if(href_list["changeg"])
		temp += "Внимание: при выборе газа другого типа текущее количество газа будет обнулено.<br>"
		for(var/gas in gas_data.gases)
			temp += "[gas_data.name[gas]]; <A href='?src=\ref[src];changegs=\ref[gas]'>Выбрать</A><br>"
	if(href_list["changegs"])
		var/N = locate(href_list["changegs"])
		if(N != currentGas)
			currentGasMoles = 0
			researchDrained = FALSE
			currentGas = locate(href_list["changegs"])
		temp = ""
		update_icon()
	if(href_list["changet"])
		if(insertedTank)
			insertedTank.forceMove(get_turf(src))
			insertedTank = null
			update_icon()
	interact(usr)

/obj/machinery/atmospherics/gas_analyzer/can_be_node(obj/machinery/atmospherics/target)
	return FALSE
