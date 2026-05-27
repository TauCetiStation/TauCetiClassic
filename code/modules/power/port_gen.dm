#define PORT_GEN_HEAT_OVERHEAT_EXPLOSION 300
#define PORT_GEN_MAX_MALFUNCTIONS 10
#define PORT_GEN_MAX_SAFE_POWER_OUTPUT 4

//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen
	name = "Placeholder Generator"	//seriously, don't use this. It can't be anchored without VV magic.
	desc = "A portable generator for emergency backup power."
	icon = 'icons/obj/power.dmi'
	var/icon_state_on = "gen_generic-on"
	icon_state = "gen_generic-off"
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE

	var/active = FALSE
	var/power_gen = 5000
	var/recent_fault = 0
	var/power_output = 1
	var/consumption = 0

/obj/machinery/power/port_gen/proc/HasFuel() //Placeholder for fuel check.
	return 1

/obj/machinery/power/port_gen/proc/UseFuel(seconds_per_tick) //Placeholder for fuel use.
	return

/obj/machinery/power/port_gen/proc/DropFuel()
	return

/obj/machinery/power/port_gen/proc/handleInactive()
	return

/obj/machinery/power/port_gen/proc/handle_malfunctions(seconds_per_tick)
	return

/obj/machinery/power/port_gen/proc/handle_ambient_heat_exchange(seconds_per_tick)
	return

/obj/machinery/power/port_gen/process(seconds_per_tick)
	if(active && HasFuel() && !crit_fail && anchored && powernet)
		add_avail(power_gen * power_output)
		UseFuel(seconds_per_tick)
		updateDialog()
	else
		active = FALSE
		icon_state = initial(icon_state)
		handleInactive()

	handle_malfunctions(seconds_per_tick)
	handle_ambient_heat_exchange(seconds_per_tick)

/obj/machinery/power/port_gen/interact(mob/user)
	if(anchored)
		..()

/obj/machinery/power/port_gen/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The generator is [active ? "on" : "off"].</span>")

//A power generator that runs on solid plasma sheets.
/obj/machinery/power/port_gen/pacman
	name = "P.A.C.M.A.N.-type Portable Generator"
	var/sheets = 0
	var/max_sheets = 100
	var/sheet_name = "solid phoron"
	var/sheet_path = /obj/item/stack/sheet/mineral/phoron
	var/board_path = /obj/item/weapon/circuitboard/pacman
	var/sheet_left = 0 // How much is left of the sheet
	var/seconds_per_sheet = 80
	var/heat = 0
	var/capacity_scale_with_upgrades = TRUE

	var/kaboom_prob_per_second = 0

	var/malfunctions = 0
	var/malfunction_prob_per_second = 0.5

	var/emitted_gas = "sleeping_agent"
	var/emitted_moles_per_sheet = 1.0

	var/consumed_gas = null
	var/consumed_moles_per_sheet = 1.0

	var/heat_transfer_coefficient = 1.0

/obj/machinery/power/port_gen/pacman/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
	component_parts += new /obj/item/stack/cable_coil/red(src, 1)
	component_parts += new /obj/item/stack/cable_coil/red(src, 1)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new board_path(src)
	RefreshParts()

/obj/machinery/power/port_gen/pacman/atom_init()
	. = ..()
	if(anchored)
		connect_to_network()

/obj/machinery/power/port_gen/pacman/Destroy()
	DropFuel()
	return ..()

/obj/machinery/power/port_gen/pacman/RefreshParts()
	..()

	var/temp_rating = 0
	var/consumption_coeff = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/matter_bin) && capacity_scale_with_upgrades)
			max_sheets = SP.rating * SP.rating * 50
		else if(istype(SP, /obj/item/weapon/stock_parts/capacitor))
			temp_rating += SP.rating
		else
			consumption_coeff += SP.rating
	power_gen = round(initial(power_gen) * temp_rating * 2)
	consumption = consumption_coeff

/obj/machinery/power/port_gen/pacman/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The generator has [sheets] units of [sheet_name] fuel left, producing [power_gen] per cycle.</span>")
	if(crit_fail)
		to_chat(user, "<span class='danger'>The generator seems to have broken down.</span>")

/obj/machinery/power/port_gen/pacman/HasFuel()
	if(consumed_gas)
		var/datum/gas_mixture/env = loc.return_air()
		if(!env)
			return FALSE
		if(env.get_gas(consumed_gas) < consumed_moles_per_sheet)
			return FALSE
	if(sheets >= 1 / (seconds_per_sheet / power_output) - sheet_left)
		return TRUE
	return FALSE

/obj/machinery/power/port_gen/pacman/DropFuel()
	if(sheets)
		var/fail_safe = 0
		while(sheets > 0 && fail_safe < 100)
			fail_safe += 1
			var/obj/item/stack/sheet/S = new sheet_path(loc)
			var/amount = min(sheets, S.max_amount)
			S.set_amount(amount)
			sheets -= amount

/obj/machinery/power/port_gen/pacman/UseFuel(seconds_per_tick)
	var/needed_sheets = seconds_per_tick / (seconds_per_sheet * consumption / power_output)
	var/temp = min(needed_sheets, sheet_left)
	needed_sheets -= temp
	sheet_left -= temp
	sheets -= round(needed_sheets)
	needed_sheets -= round(needed_sheets)
	if(sheet_left <= 0 && sheets > 0)
		sheet_left = 1 - needed_sheets
		sheets--

		if(consumed_gas)
			var/datum/gas_mixture/env = loc.return_air()
			env.adjust_gas(consumed_gas, -consumed_moles_per_sheet)

		if(emitted_gas)
			var/datum/gas_mixture/env = loc.return_air()
			env.adjust_gas(emitted_gas, emitted_moles_per_sheet)

	// If any of the heat margins sum to more than this, overheat explosion is possible.
	var/safety_heat_margin = 100

	var/area/A = get_area(src)
	// In a perfect world this would be a function of the area,
	// but currently areas don't know how much power is inbound within them,
	// as electrical networks are inherently non-local.
	// But it's a fun requirement to "keep generators in high load areas", so we keep this.
	var/local_surplus = power_gen * power_output - A.usage(TOTAL)

	// A magic number to make local surplus hurt more than global surplus.
	// Let's imagine the wires are low efficiency and thus act as "resistors".
	var/global_powernet_resistance = 1000
	var/total_surplus = surplus() / global_powernet_resistance + local_surplus

	var/surplus_load_heat_margin = 0

	var/heat_increase_bias = round(power_output + malfunctions * 0.5 - consumption)

	if(total_surplus > 0 && power_gen > 0)
		surplus_load_heat_margin = min(safety_heat_margin - 10, round(total_surplus / power_gen) * 10)
		heat_increase_bias += min(5, round(total_surplus / power_gen))

	// At max would contribute 90 to heat. Unless emagged.
	var/power_output_heat_margin = safety_heat_margin - ((PORT_GEN_MAX_SAFE_POWER_OUTPUT - power_output) / PORT_GEN_MAX_SAFE_POWER_OUTPUT) * (safety_heat_margin - 10)
	var/malfunctions_heat_margin = safety_heat_margin - ((PORT_GEN_MAX_MALFUNCTIONS - malfunctions) / PORT_GEN_MAX_MALFUNCTIONS) * (safety_heat_margin - 10)

	// The fact that all heat margins have the safety_heat_margin - 10 means that even at max no one factor can cause a kaboom.
	var/heat_bound = round(PORT_GEN_HEAT_OVERHEAT_EXPLOSION - safety_heat_margin + power_output_heat_margin + malfunctions_heat_margin + surplus_load_heat_margin)

	var/minimal_heat_increase = (-3.5 + heat_increase_bias * 0.5) * seconds_per_tick
	var/maximal_heat_increase = (3.5 + heat_increase_bias * 0.5) * seconds_per_tick

	heat = round(max(0, heat + rand(minimal_heat_increase, maximal_heat_increase)))
	if(heat >= heat_bound)
		heat = heat_bound
		if(SPT_PROB(malfunction_prob_per_second, seconds_per_tick))
			add_malfunction()

	if(heat > PORT_GEN_HEAT_OVERHEAT_EXPLOSION)
		kaboom_prob_per_second += seconds_per_tick
	else
		kaboom_prob_per_second = 0

	if(SPT_PROB(kaboom_prob_per_second, seconds_per_tick))
		overheat()
		if(!QDELETED(src))
			qdel(src)

/obj/machinery/power/port_gen/pacman/proc/add_malfunction()
	malfunctions = min(malfunctions + 1, PORT_GEN_MAX_MALFUNCTIONS)
	new /obj/effect/abstract/particle_holder(src, /particles/tool/screw, PARTICLE_FADEOUT|PARTICLE_FLICK)
	playsound(src, pick('sound/items/rake1.ogg', 'sound/items/rake2.ogg', 'sound/items/rake3.ogg'), VOL_EFFECTS_MASTER, vol=100, vary=TRUE)

/obj/machinery/power/port_gen/pacman/proc/try_repair_malfunctions_loop(mob/living/user, obj/item/tool)
	user.visible_message("<span class='notice'>[user] starts repairing the [src].</span>")

	if(crit_fail)
		if(!is_skill_competent(user, list(/datum/skill/engineering=SKILL_LEVEL_PRO)))
			to_chat(user, "<span class='warning'>The [src] is too damaged to be repaired by me. I wonder if someone could help?</span>")
			return
		if(tool.use_tool(
			target=src,
			user=user,
			delay=10 SECONDS,
			volume=70,
			quality=QUALITY_PULSING,
			required_skills_override=list(
				/datum/skill/engineering=SKILL_LEVEL_PRO,
			),
			can_move=FALSE,
			particle_type=/particles/tool/wrench,
		))
			if(!panel_open)
				to_chat(user, "<span class='warning'>Gah! The panel is closed. How can I repair it now?</span>")
				return
			crit_fail = FALSE

	if(malfunctions <= 0)
		to_chat(user, "<span class='notice'>[src] doesn't seem to need any repairs.</span>")
		return

	var/hard_limit = 20
	for(var/i in 1 to hard_limit)
		if(!tool.use_tool(
			target=src,
			user=user,
			delay=1 SECOND,
			volume=70,
			quality=QUALITY_PULSING,
			required_skills_override=list(
				/datum/skill/engineering=SKILL_LEVEL_MASTER,
			),
			can_move=FALSE,
			particle_type=/particles/tool/wrench,
		))
			return
		if(malfunctions <= 0)
			return
		if(!panel_open)
			to_chat(user, "<span class='warning'>Gah! The panel is closed. How can I repair it now?</span>")
			return

		malfunctions = max(0, malfunctions - 1)
		kaboom_prob_per_second = max(0, kaboom_prob_per_second - 10)

/obj/machinery/power/port_gen/pacman/handle_malfunctions(seconds_per_tick)
	if(!active)
		return

	if(SPT_PROB(malfunction_prob_per_second, seconds_per_tick))
		add_malfunction()

	if(SPT_PROB(malfunction_prob_per_second, seconds_per_tick) && emitted_gas)
		var/datum/gas_mixture/env = loc.return_air()
		if(env && SPT_PROB(env.get_gas(emitted_gas) / emitted_moles_per_sheet, seconds_per_tick))
			add_malfunction()

	if(SPT_PROB(malfunctions * 10, seconds_per_tick))
		new /obj/effect/abstract/particle_holder(src, /particles/tool/screw, PARTICLE_FADEOUT|PARTICLE_FLICK)
		playsound(src, pick('sound/items/rake1.ogg', 'sound/items/rake2.ogg', 'sound/items/rake3.ogg'), VOL_EFFECTS_MASTER, vol=70, vary=TRUE, extrarange=-1)

	if(malfunctions >= 10 && SPT_PROB(1, seconds_per_tick))
		crit_fail = TRUE

/obj/machinery/power/port_gen/pacman/handle_ambient_heat_exchange(seconds_per_tick)
	if(heat <= 0)
		return

	var/datum/gas_mixture/env = loc.return_air()
	// In space, you don't dissipate heat all that much.
	if(!env)
		if(SPT_PROB(15, seconds_per_tick))
			heat = max(heat - 1, 0)
			updateDialog()
		return

	// The environment is too hot for us to cool down if it takes us 0 energy to increase the temperature to our peak.
	if(env.get_thermal_energy_change(T0C + heat) <=  0)
		return

	var/try_remove_heat = min(heat, rand(0, 4))
	if(try_remove_heat <= 0)
		return

	env.add_thermal_energy(try_remove_heat * power_gen * heat_transfer_coefficient)

	heat = max(heat - try_remove_heat, 0)
	updateDialog()

/obj/machinery/power/port_gen/pacman/handleInactive()
	if(heat > 0)
		heat = max(heat - 2, 0)
		updateDialog()

/obj/machinery/power/port_gen/pacman/proc/overheat()
	explosion(src.loc, 2, 5, 2, -1)

/obj/machinery/power/port_gen/pacman/proc/add_sheets(obj/item/I, mob/user, params)
	var/obj/item/stack/addstack = I
	var/amount = min((max_sheets - sheets), addstack.get_amount())
	if(amount < 1)
		to_chat(user, "<span class='notice'>The [name] is full!</span>")
		return
	to_chat(user, "<span class='notice'>You add [amount] sheets to the [name].</span>")
	sheets += amount
	addstack.use(amount)
	playsound(src, 'sound/items/insert_key.ogg', VOL_EFFECTS_MASTER)

/obj/machinery/power/port_gen/pacman/attackby(obj/item/O, mob/user, params)
	if(istype(O, sheet_path))
		add_sheets(O, user, params)
		updateUsrDialog()
	else if(!active)

		if(exchange_parts(user, O))
			return

		if(iswrenching(O))
			if(!anchored && !isinspace())
				connect_to_network()
				to_chat(user, "<span class='notice'>You secure the generator to the floor.</span>")
				anchored = TRUE
			else if(anchored)
				disconnect_from_network()
				to_chat(user, "<span class='notice'>You unsecure the generator from the floor.</span>")
				anchored = FALSE

			playsound(src, 'sound/items/Deconstruct.ogg', VOL_EFFECTS_MASTER)
		else if(isscrewing(O))
			panel_open = !panel_open
			playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
			if(panel_open)
				to_chat(user, "<span class='notice'>You open the access panel.</span>")
			else
				to_chat(user, "<span class='notice'>You close the access panel.</span>")
		else if(isprying(O) && panel_open)
			default_deconstruction_crowbar(O)
		else if(ispulsing(O) && panel_open)
			try_repair_malfunctions_loop(user, O)

/obj/machinery/power/port_gen/pacman/emag_act(mob/user)
	if(emagged)
		return FALSE
	emagged = 1
	user.SetNextMove(CLICK_CD_INTERACT)
	emp_act(1)
	return TRUE

/obj/machinery/power/port_gen/pacman/ui_interact(mob/user)
	if ((get_dist(src, user) > 1) && !issilicon(user) && !isobserver(user))
		user.unset_machine(src)
		user << browse(null, "window=port_gen")
		return

	var/dat = ""
	if (active)
		dat += text("Generator: <A href='byond://?src=\ref[src];action=disable'>On</A><br>")
	else
		dat += text("Generator: <A href='byond://?src=\ref[src];action=enable'>Off</A><br>")
	dat += text("[capitalize(sheet_name)]: [sheets] - <A href='byond://?src=\ref[src];action=eject'>Eject</A><br>")
	var/stack_percent = round(sheet_left * 100, 1)
	dat += text("Current stack: [stack_percent]% <br>")
	dat += text("Power output: <A href='byond://?src=\ref[src];action=lower_power'>-</A> [power_gen * power_output] <A href='byond://?src=\ref[src];action=higher_power'>+</A><br>")
	dat += text("Power current: [(powernet == null ? "Unconnected" : "[avail()]")]<br>")
	dat += text("Heat: [heat]<br>")

	var/datum/browser/popup = new(user, "port_gen", src.name)
	popup.set_content(dat)
	popup.open()

/obj/machinery/power/port_gen/pacman/is_operational()
	return TRUE

/obj/machinery/power/port_gen/pacman/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["action"])
		if(href_list["action"] == "enable")
			if(!active && HasFuel() && !crit_fail)
				active = TRUE
				icon_state = icon_state_on
				playsound(src, 'sound/machines/pacman_on.ogg', VOL_EFFECTS_MASTER)
		if(href_list["action"] == "disable")
			if (active)
				active = FALSE
				icon_state = initial(icon_state)
				playsound(src, 'sound/machines/pacman_off.ogg', VOL_EFFECTS_MASTER)
		if(href_list["action"] == "eject")
			if(!active)
				DropFuel()
		if(href_list["action"] == "lower_power")
			if (power_output > 1)
				power_output--
		if (href_list["action"] == "higher_power")
			if (power_output < 4 || emagged)
				power_output++

	updateUsrDialog()


/obj/machinery/power/port_gen/pacman/super
	name = "S.U.P.E.R.P.A.C.M.A.N.-type Portable Generator"
	icon_state = "gen_uranium-off"
	icon_state_on = "gen_uranium-on"
	sheet_name = "uranium"
	sheet_path = /obj/item/stack/sheet/mineral/uranium
	power_gen = 15000
	seconds_per_sheet = 130
	board_path = /obj/item/weapon/circuitboard/pacman/super
	emitted_gas = null

/obj/machinery/power/port_gen/pacman/super/overheat()
	explosion(src.loc, 3, 3, 3, -1)

/obj/machinery/power/port_gen/pacman/mrs
	name = "M.R.S.P.A.C.M.A.N.-type Portable Generator"
	icon_state = "gen_uranium-off"
	icon_state_on = "gen_uranium-on"
	sheet_name = "tritium"
	sheet_path = /obj/item/stack/sheet/mineral/tritium
	power_gen = 40000
	seconds_per_sheet = 160
	board_path = /obj/item/weapon/circuitboard/pacman/mrs
	emitted_gas = "hydrogen"

/obj/machinery/power/port_gen/pacman/mrs/overheat()
	explosion(src.loc, 4, 4, 4, -1)

/obj/machinery/power/port_gen/pacman/money
	name = "A.N.C.A.P.M.A.N.-type Portable Generator"
	desc = "Don't simply waste your money - burn them to get power instead!"
	icon_state = "gen_money-off"
	icon_state_on = "gen_money-on"
	sheet_name = "cash"
	sheet_path = /obj/item/weapon/spacecash
	power_gen = 10000
	max_sheets = 10000
	seconds_per_sheet = 10
	board_path = /obj/item/weapon/circuitboard/pacman/money
	capacity_scale_with_upgrades = FALSE
	emitted_gas = "carbon_dioxide"
	consumed_gas = "oxygen"

/obj/machinery/power/port_gen/pacman/money/add_sheets(obj/item/I, mob/user, params)
	var/obj/item/weapon/spacecash/addstack = I
	var/amount = min((max_sheets - sheets), addstack.worth)
	if(amount < 1)
		to_chat(user, "<span class='notice'>The [name] is full!</span>")
		return
	to_chat(user, "<span class='notice'>You add [amount] sheets to the [name].</span>")
	sheets += amount
	qdel(addstack)

/obj/machinery/power/port_gen/pacman/money/overheat()
	visible_message("<span class='notice'>[src] overheats and quietly disintegrates. No customer should ever worry!</span>")
	qdel(src)

#undef PORT_GEN_HEAT_OVERHEAT_EXPLOSION
#undef PORT_GEN_MAX_MALFUNCTIONS
#undef PORT_GEN_MAX_SAFE_POWER_OUTPUT
